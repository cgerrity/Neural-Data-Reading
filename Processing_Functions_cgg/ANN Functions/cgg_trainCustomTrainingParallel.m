function [net] = cgg_trainCustomTrainingParallel(InputNet,DataStoreTrain,DataStoreTest,DataFormat,NumEpochs,miniBatchSize,GradientThreshold,LossType)
%CGG_TRAINCUSTOMTRAININGPARALELL Summary of this function goes here
%   Detailed explanation goes here

OutputNames=InputNet.OutputNames;

EncoderType='Standard';
if any(contains(OutputNames,'mean')) && any(contains(OutputNames,'variance'))
    EncoderType='Variational';
end

%%
if canUseGPU
    executionEnvironment = "gpu";
    numberOfGPUs = gpuDeviceCount("available");
    pool = parpool(numberOfGPUs);
else
    executionEnvironment = "cpu";
    pool = gcp;
end

numWorkers = pool.NumWorkers;

% numWorkers=1;

net=InputNet;
InDataStore=DataStoreTrain;

%%

numEpochs = NumEpochs;
Gradient_Threshold=GradientThreshold;
velocity = [];
momentum=0.9;
ValidationFrequency=5;

if executionEnvironment == "gpu"
     miniBatchSize = miniBatchSize .* numWorkers;
end

workerMiniBatchSize = floor(miniBatchSize ./ repmat(numWorkers,1,numWorkers));
remainder = miniBatchSize - sum(workerMiniBatchSize);
workerMiniBatchSize = workerMiniBatchSize + [ones(1,remainder) zeros(1,numWorkers-remainder)];

batchNormLayers = arrayfun(@(l)isa(l,"nnet.cnn.layer.BatchNormalizationLayer"),net.Layers);
batchNormLayersNames = string({net.Layers(batchNormLayers).Name});
state = net.State;
isBatchNormalizationStateMean = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedMean";
isBatchNormalizationStateVariance = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedVariance";


% monitor = cgg_generateProgressMonitor('LossType','Regression');
monitor = cgg_generateProgressMonitor_v2('LossType','Regression','LogLoss',true);

% monitor = trainingProgressMonitor( ...
%     Metrics="TrainingLoss", ...
%     Info=["Loss" "Epoch" "Workers"], ...
%     XLabel="Iteration");
drawnow;
spmd
    stopTrainingEventQueue = parallel.pool.DataQueue;
end
stopTrainingQueue = stopTrainingEventQueue{1};

dataQueue = parallel.pool.DataQueue;
displayFcn = @(x) cgg_displayTrainingProgress_v2(x,numEpochs,numWorkers,monitor,stopTrainingQueue);
afterEach(dataQueue,displayFcn)

Function_MaximumNorm=@(x) max(norm(x))/Gradient_Threshold;
Function_GradientReduction=@(x,y) x/y;

ValidationMbq = minibatchqueue(DataStoreTest,...
    MiniBatchSize=numpartitions(DataStoreTest),...
    MiniBatchFormat=DataFormat);

[ValidationX,ValidationT] = next(ValidationMbq);

switch EncoderType
    case 'Standard'
ModelLoss=@(x1,x2,x3) modelLoss(x1,x2,x3,LossType);
ValidationLoss=@(x1) modelLoss(x1,ValidationX,ValidationT,LossType,'wantPredict',true);
    case 'Variational'
ModelLoss=@(x1,x2,x3) cgg_lossVariationalAutoEncoder(x1,x2,x3,LossType);
ValidationLoss=@(x1) cgg_lossVariationalAutoEncoder(x1,ValidationX,ValidationT,LossType,'wantPredict',true);
end



%%
spmd
% for widx=1:numWorkers
    
    this_workerIDX=spmdIndex;
    % this_workerIDX=1;

    % Partition the datastore.
    workerImds = partition(InDataStore,numWorkers,this_workerIDX);

    % Create minibatchqueue using partitioned datastore on each worker.
    workerMbq = minibatchqueue(workerImds,...
        MiniBatchSize=workerMiniBatchSize(this_workerIDX),...
        MiniBatchFormat=DataFormat);

    workerVelocity = velocity;
    epoch = 0;
    iteration = 0;
    stopRequest = false;
    %%

    while epoch < numEpochs && ~stopRequest
        epoch = epoch + 1;
        shuffle(workerMbq);

        learningrate = 0.01 * (0.9)^floor(epoch / 10);
%%
        % Loop over mini-batches.
        while spmdReduce(@and,hasdata(workerMbq)) && ~stopRequest
        % while hasdata(workerMbq) && ~stopRequest
            %%
            iteration = iteration + 1;

            % Read a mini-batch of data.
            [workerX,workerT] = next(workerMbq);

            % Evaluate the model loss and gradients on the worker.
            [workerLoss,workerGradients,workerState] = dlfeval(ModelLoss,net,workerX,workerT);

            % Aggregate the losses on all workers.
            workerNormalizationFactor = workerMiniBatchSize(this_workerIDX)./miniBatchSize;
            loss = spmdPlus(workerNormalizationFactor*cgg_extractData(workerLoss));

            % Aggregate the network state on all workers.
            net.State = aggregateState(workerState,workerNormalizationFactor,...
                isBatchNormalizationStateMean,isBatchNormalizationStateVariance);

            % Aggregate the gradients on all workers.
            workerGradients.Value = dlupdate(@aggregateGradients,workerGradients.Value,{workerNormalizationFactor});

            GradAll=workerGradients.Value;
            MaxGrad=cellfun(Function_MaximumNorm,GradAll,'UniformOutput',false);
            % GradAll_Thresholded=cellfun(@(x) x/MaxGrad,GradAll,'UniformOutput',false);
            GradAll_Thresholded=cellfun(Function_GradientReduction,GradAll,MaxGrad,'UniformOutput',false);
            % MaxGrad_Thresholded=max(cellfun(@norm,GradAll_Thresholded));
            
            workerGradients.Value=GradAll_Thresholded;

            % GradAll=workerGradients.Value;
            % MaxGrad=max(cellfun(@norm,GradAll));

            % Message_Info=sprintf('EX Layer: %.5f, Has Data: %d, Loss: %.3f, Max Gradient: %.3f, Epoch: %d',net.Layers(2, 1).Weights(1,1),hasdata(workerMbq),loss,MaxGrad,epoch);
            % disp(Message_Info);

            lossValidation = NaN;

            %%
            % Update the network parameters using the SGDM optimizer.
            [net,workerVelocity] = sgdmupdate(net,workerGradients,workerVelocity,learningrate,momentum);

            if mod(iteration,ValidationFrequency)==1
            [lossValidation,~,~] = dlfeval(ValidationLoss,net);
            lossValidation=cgg_extractData(lossValidation);
            end

            % Send training progress information to the client.
            if this_workerIDX == 1
                data = [epoch loss iteration learningrate lossValidation];
                send(dataQueue,gather(data));
            end
        end

        % Stop training if the Stop button has been clicked.
        stopRequest = spmdPlus(stopTrainingEventQueue.QueueLength);
        % stopRequest = monitor.Stop;

    end

end

net=net{1};

end

