function [net] = cgg_trainCustomTrainingParallelMultipleOutput(InputNet,InDataStore,DataStore_Testing,DataFormat,NumEpochs,miniBatchSize,GradientThreshold,LossType,OutputNames,ClassNames)
%CGG_TRAINCUSTOMTRAININGPARALELL Summary of this function goes here
%   Detailed explanation goes here


OutputNames_tmp=InputNet.OutputNames;

EncoderType='Standard';
if any(contains(OutputNames_tmp,'mean')) && any(contains(OutputNames_tmp,'variance'))
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
net=resetState(net);
%%

numEpochs = NumEpochs;
Gradient_Threshold=GradientThreshold;
velocity = [];
momentum=0.9;
ValidationFrequency=20;

% NumIterRand=100;
MatchType='combinedaccuracy';
IsQuaddle=true;

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

% monitor = trainingProgressMonitor( ...
%     Metrics="TrainingLoss", ...
%     Info=["Loss" "Epoch" "Workers"], ...
%     XLabel="Iteration");
% drawnow;

% monitor = cgg_generateProgressMonitor;
monitor = cgg_generateProgressMonitor_v2('LogLoss',false,'LossComponents',true);

spmd
    stopTrainingEventQueue = parallel.pool.DataQueue;
end
stopTrainingQueue = stopTrainingEventQueue{1};

dataQueue = parallel.pool.DataQueue;
displayFcn = @(x) cgg_displayTrainingProgressClassifier_v2(x,numEpochs,numWorkers,monitor,stopTrainingQueue);
afterEach(dataQueue,displayFcn)

%%

NumDisplayExamples=3;

ValidationMbq_Display = minibatchqueue(shuffle(DataStore_Testing),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);
TrainingMbq_Display = minibatchqueue(shuffle(InDataStore),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);

[XValidation_Display,TValidation_Display] = next(ValidationMbq_Display);
[XTraining_Display,TTraining_Display] = next(TrainingMbq_Display);

DisplayFigure=figure;
DisplayFigure.WindowState='maximized';
DisplayFigure.PaperSize=[20 10];

dataQueue_Plot = parallel.pool.DataQueue;
plotFcn = @(x,iter) cgg_displayDataExamples(x,XTraining_Display,TTraining_Display,XValidation_Display,TValidation_Display,ClassNames,OutputNames,iter,DisplayFigure);
plotFcn_wrapped = @(x) plotFcn(x{1},x{2});

afterEach(dataQueue_Plot,plotFcn_wrapped)


%%
epsilon=0.0000001;
Function_MaximumNorm=@(x) max(norm(x))/Gradient_Threshold;
Function_GradientReduction=@(x,y) x/(y+epsilon);

ValidationMbq = minibatchqueue(DataStore_Testing,...
    MiniBatchSize=numpartitions(DataStore_Testing),...
    MiniBatchFormat=DataFormat);

[ValidationX,ValidationT] = next(ValidationMbq);

switch EncoderType
    case 'Standard'
ModelLoss=@(x1,x2,x3) modelLossMultipleOutput(x1,x2,x3,LossType,OutputNames,ClassNames);
ValidationLoss=@(x1) modelLossMultipleOutput(x1,ValidationX,ValidationT,LossType,OutputNames,ClassNames,'wantPredict',true);
    case 'Variational'
ModelLoss=@(x1,x2,x3) cgg_lossVariationalAutoEncoderMultipleOutput(x1,x2,x3,LossType,OutputNames,ClassNames);
ValidationLoss=@(x1) cgg_lossVariationalAutoEncoderMultipleOutput(x1,ValidationX,ValidationT,LossType,OutputNames,ClassNames,'wantPredict',true);
end

%%

TrueValue=double(extractdata(ValidationT)');

% [MostCommon,RandomChance] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType)
% 
% NumDimensions=length(ClassNames);
% [Dim1,~]=size(TrueValue);
% if Dim1==NumDimensions
%     TrueValue=TrueValue';
% end
% 
% [NumTrials,~]=size(TrueValue);
% 
% RandomChance=NaN(1,NumIterRand);
% for idx=1:NumIterRand
% Prediction=NaN(size(TrueValue));
% for tidx=1:NumTrials
% Prediction(tidx,:) = cgg_getRandomPrediction(ClassNames);
% end
% RandomChance(idx) = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);
% end
% RandomChance=mean(RandomChance);
% 
% [UniqueTarget,~,UniqueValues] = unique(TrueValue,'rows');
% ModeTargetIDX = mode(UniqueValues);
% ModeTarget = UniqueTarget(ModeTargetIDX,:); %# the first output argument
% Prediction=repmat(ModeTarget,NumTrials,1);
% MostCommon = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);

[MostCommon,RandomChance] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType,IsQuaddle);

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

        %% Loop over mini-batches.
        while spmdReduce(@and,hasdata(workerMbq)) && ~stopRequest
        % while hasdata(workerMbq) && ~stopRequest
            %%
            iteration = iteration + 1;
            net=resetState(net);

            % Read a mini-batch of data.
            [workerX,workerT] = next(workerMbq);

            % Evaluate the model loss and gradients on the worker.
            [workerLoss,workerGradients,workerState,workerAccuracy,workerLossVector] = dlfeval(ModelLoss,net,workerX,workerT);

            % Aggregate the losses on all workers.
            workerNormalizationFactor = workerMiniBatchSize(this_workerIDX)./miniBatchSize;
            loss = spmdPlus(workerNormalizationFactor*extractdata(workerLoss));
            LossVector = spmdPlus(workerNormalizationFactor*extractdata(workerLossVector));

            % Aggregate the accuracy on all workers.
            accuracyTrain = spmdPlus(workerNormalizationFactor*workerAccuracy);

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
            accuracyValidation = NaN;

            Loss_Reconstruction=LossVector(1);
            Loss_KL=LossVector(2);
            Loss_Feature=LossVector(3);

%             if mod(iteration,2)==1
%             [lossValidation,~,~,accuracyValidation] = dlfeval(ValidationLoss,net);
%             lossValidation=extractdata(lossValidation);
%             end
            
            %%
            % Update the network parameters using the SGDM optimizer.
            [net,workerVelocity] = sgdmupdate(net,workerGradients,workerVelocity,learningrate,momentum);

            if mod(iteration,ValidationFrequency)==1
            net=resetState(net);
            [lossValidation,~,~,accuracyValidation] = dlfeval(ValidationLoss,net);
            lossValidation=extractdata(lossValidation);
            end

            % Send training progress information to the client.
            if this_workerIDX == 1
                data = [epoch loss iteration accuracyTrain learningrate lossValidation accuracyValidation MostCommon RandomChance Loss_Reconstruction Loss_KL Loss_Feature];
                send(dataQueue,gather(data));
                send(dataQueue_Plot,{net,gather(iteration)});
            end
        end

        % Stop training if the Stop button has been clicked.
        stopRequest = spmdPlus(stopTrainingEventQueue.QueueLength);
        % stopRequest = monitor.Stop;

    end

end

net=net{1};
net=resetState(net);

end

