function net = cgg_trainNetworkParallel(InputNet,DataStore_Training,DataStore_Testing,varargin)
%CGG_TRAINNETWORKPARALLEL Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='combinedaccuracy';
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
GradientThreshold = CheckVararginPairs('GradientThreshold', 1, varargin{:});
else
if ~(exist('GradientThreshold','var'))
GradientThreshold=1;
end
end

if isfunction
NumEpochs = CheckVararginPairs('NumEpochs', 100, varargin{:});
else
if ~(exist('NumEpochs','var'))
NumEpochs=100;
end
end

if isfunction
ValidationFrequency = CheckVararginPairs('ValidationFrequency', 20, varargin{:});
else
if ~(exist('ValidationFrequency','var'))
ValidationFrequency=20;
end
end

if isfunction
SaveFrequency = CheckVararginPairs('SaveFrequency', 100, varargin{:});
else
if ~(exist('SaveFrequency','var'))
SaveFrequency=100;
end
end

if isfunction
SaveDirPlot = CheckVararginPairs('SaveDirPlot', pwd, varargin{:});
else
if ~(exist('SaveDirPlot','var'))
SaveDirPlot=pwd;
end
end

if isfunction
SaveTerm = CheckVararginPairs('SaveTerm', '', varargin{:});
else
if ~(exist('SaveTerm','var'))
SaveTerm='';
end
end

if isfunction
MiniBatchSize = CheckVararginPairs('MiniBatchSize', 100, varargin{:});
else
if ~(exist('MiniBatchSize','var'))
MiniBatchSize=100;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT'}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT'};
end
end

if isfunction
InitialLearnngRate = CheckVararginPairs('InitialLearnngRate', 0.01, varargin{:});
else
if ~(exist('InitialLearnngRate','var'))
InitialLearnngRate=0.01;
end
end

if isfunction
LearningRateDecay = CheckVararginPairs('LearningRateDecay', 0.9, varargin{:});
else
if ~(exist('LearningRateDecay','var'))
LearningRateDecay=0.9;
end
end

if isfunction
LearningRateEpochDrop = CheckVararginPairs('LearningRateEpochDrop', 30, varargin{:});
else
if ~(exist('LearningRateEpochDrop','var'))
LearningRateEpochDrop=10;
end
end

if isfunction
WantParallel = CheckVararginPairs('WantParallel', false, varargin{:});
else
if ~(exist('WantParallel','var'))
WantParallel=false;
end
end

%%

OutputNames_All=InputNet.OutputNames;

OutputNames_Mean=string(OutputNames_All(contains(OutputNames_All,'mean')));
OutputNames_LogVar=string(OutputNames_All(contains(OutputNames_All,'log-variance')));
OutputNames_Classifier=string(OutputNames_All(contains(OutputNames_All,'Dim')));
OutputNames_Reconstruction=string(OutputNames_All(contains(OutputNames_All,'reshape')));

OutputInformation=struct();
OutputInformation.Mean=OutputNames_Mean;
OutputInformation.LogVar=OutputNames_LogVar;
OutputInformation.Classifier=OutputNames_Classifier;
OutputInformation.Reconstruction=OutputNames_Reconstruction;

IsVariational=true;
if isempty(OutputNames_Mean) && isempty(OutputNames_LogVar)
IsVariational=false;
end

HasClassifier=~isempty(OutputNames_Classifier);
HasReconstruction=~isempty(OutputNames_Reconstruction);

if any(contains(OutputNames_Classifier,'CTC'))
    LossType='CTC';
elseif HasClassifier
    LossType='Classification';
elseif HasReconstruction
    LossType='Regression';
else
    LossType='None';
end

%%

if HasClassifier
[ClassNames,~] = cgg_getClassesFromDataStore(DataStore_Training);
else
ClassNames=cell(0);
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

if WantParallel
    numWorkers = pool.NumWorkers;
else
    numWorkers = 1;
end

net=InputNet;
net=resetState(net);
%%

velocity = [];
momentum=0.9;

if executionEnvironment == "gpu"
     MiniBatchSize = MiniBatchSize .* numWorkers;
end

workerMiniBatchSize = floor(MiniBatchSize ./ repmat(numWorkers,1,numWorkers));
remainder = MiniBatchSize - sum(workerMiniBatchSize);
workerMiniBatchSize = workerMiniBatchSize + [ones(1,remainder) zeros(1,numWorkers-remainder)];

% batchNormLayers = arrayfun(@(l)isa(l,"nnet.cnn.layer.BatchNormalizationLayer"),net.Layers);
% batchNormLayersNames = string({net.Layers(batchNormLayers).Name});
% state = net.State;
% isBatchNormalizationStateMean = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedMean";
% isBatchNormalizationStateVariance = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedVariance";

% monitor = cgg_generateProgressMonitor_v2('LossType',LossType,'LogLoss',false,'WantKLLoss',IsVariational,'WantReconstructionLoss',HasReconstruction,'WantClassificationLoss',HasClassifier);
monitor = cgg_generateProgressMonitor_v4('LossType',LossType,'LogLoss',false,'WantKLLoss',IsVariational,'WantReconstructionLoss',HasReconstruction,'WantClassificationLoss',HasClassifier);

spmd
    stopTrainingEventQueue = parallel.pool.DataQueue;
end
stopTrainingQueue = stopTrainingEventQueue{1};

dataQueue = parallel.pool.DataQueue;
displayFcn = @(x) cgg_displayTrainingUpdate_v2(x,NumEpochs,numWorkers,monitor,stopTrainingQueue);
afterEach(dataQueue,displayFcn)

%%

NumDisplayExamples=3;

ValidationMbq_Display = minibatchqueue(shuffle(DataStore_Testing),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);
TrainingMbq_Display = minibatchqueue(shuffle(DataStore_Training),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);

[XValidation_Display,TValidation_Display] = next(ValidationMbq_Display);
[XTraining_Display,TTraining_Display] = next(TrainingMbq_Display);

% DisplayFigure=figure;
% DisplayFigure.WindowState='maximized';
% DisplayFigure.PaperSize=[20 10];

DisplayFigure=figure;
DisplayFigure.Units="normalized";
DisplayFigure.Position=[0,0,1,1];
DisplayFigure.Units="inches";
DisplayFigure.PaperUnits="inches";
PlotPaperSize=DisplayFigure.Position;
PlotPaperSize(1:2)=[];
DisplayFigure.PaperSize=PlotPaperSize;

dataQueue_Plot = parallel.pool.DataQueue;
plotFcn = @(x,iter) cgg_displayDataExamples(x,XTraining_Display,TTraining_Display,XValidation_Display,TValidation_Display,ClassNames,OutputInformation,iter,DisplayFigure);
plotFcn_wrapped = @(x) plotFcn(x{1},x{2});

PlotSavePathNameExt = [SaveDirPlot filesep 'Example-Monitor_Iteration-%d' SaveTerm '.pdf'];
plotFcn_savePlot = @(x) saveas(DisplayFigure, sprintf(PlotSavePathNameExt,x));

afterEach(dataQueue_Plot,plotFcn_wrapped)

%%
epsilon=0.0000001;
Function_MaximumNorm=@(x) max(norm(x))/GradientThreshold;
Function_GradientReduction=@(x,y) x/(y+epsilon);

ValidationMbq = minibatchqueue(DataStore_Testing,...
    MiniBatchSize=numpartitions(DataStore_Testing),...
    MiniBatchFormat=DataFormat);

[ValidationX,ValidationT] = next(ValidationMbq);

ModelLoss=@(x1,x2,x3) cgg_lossNetwork(x1,x2,x3,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle);
ValidationLoss=@(x1) cgg_lossNetwork(x1,ValidationX,ValidationT,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle,'wantPredict',true);

%%
MostCommon=NaN;
RandomChance=NaN;
if HasClassifier
TrueValue=double(extractdata(ValidationT)');
[MostCommon,RandomChance] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType,IsQuaddle);
end

%%
% spmd
% for widx=1:numWorkers
    
    this_workerIDX=spmdIndex;
    % this_workerIDX=1;

    % Partition the datastore.
    workerImds = partition(DataStore_Training,numWorkers,this_workerIDX);

    % Create minibatchqueue using partitioned datastore on each worker.
    workerMbq = minibatchqueue(workerImds,...
        MiniBatchSize=workerMiniBatchSize(this_workerIDX),...
        MiniBatchFormat=DataFormat);

    workerVelocity = velocity;
    epoch = 0;
    iteration = 0;
    stopRequest = false;
    %%

    while epoch < NumEpochs && ~stopRequest
        epoch = epoch + 1;
        shuffle(workerMbq);

        learningrate = InitialLearnngRate * (LearningRateDecay)^floor(...
            epoch / LearningRateEpochDrop);

        %% Loop over mini-batches.
        while spmdReduce(@and,hasdata(workerMbq)) && ~stopRequest
        % while hasdata(workerMbq) && ~stopRequest
            %%
            iteration = iteration + 1;
            net=resetState(net);

            % Read a mini-batch of data.
            [workerX,workerT] = next(workerMbq);

            % Evaluate the model loss and gradients on the worker.
            [workerLoss,workerGradients,~,workerAccuracy,workerLossReconstruction,workerLossClassification,workerLossKL] = dlfeval(ModelLoss,net,workerX,workerT);

            % Aggregate the losses on all workers.
            workerNormalizationFactor = workerMiniBatchSize(this_workerIDX)./MiniBatchSize;
            loss = spmdPlus(workerNormalizationFactor*extractdata(workerLoss));
            LossReconstruction = spmdPlus(workerNormalizationFactor*extractdata(workerLossReconstruction));
            LossClassification = spmdPlus(workerNormalizationFactor*extractdata(workerLossClassification));
            LossKL = spmdPlus(workerNormalizationFactor*extractdata(workerLossKL));

            % Aggregate the accuracy on all workers.
            accuracyTrain = spmdPlus(workerNormalizationFactor*workerAccuracy);

%             % Aggregate the network state on all workers.
%             net.State = aggregateState(workerState,workerNormalizationFactor,...
%                 isBatchNormalizationStateMean,isBatchNormalizationStateVariance);

            % Aggregate the gradients on all workers.
            workerGradients.Value = dlupdate(@aggregateGradients,workerGradients.Value,{workerNormalizationFactor});

            GradAll=workerGradients.Value;
            MaxGrad=cellfun(Function_MaximumNorm,GradAll,'UniformOutput',false);
            GradAll_Thresholded=cellfun(Function_GradientReduction,GradAll,MaxGrad,'UniformOutput',false);
            
            workerGradients.Value=GradAll_Thresholded;

            lossValidation = NaN;
            accuracyValidation = NaN;

            if ~IsVariational
                LossKL = NaN;
            end
            if ~HasClassifier
                LossClassification = NaN;
            end
            if ~HasReconstruction
                LossReconstruction = NaN;
            end
            
            %%
            % Update the network parameters using the SGDM optimizer.
            [net,workerVelocity] = sgdmupdate(net,workerGradients,workerVelocity,learningrate,momentum);

            % Send training progress information to the client.
            if this_workerIDX == 1

                if mod(iteration,ValidationFrequency)==1
                net=resetState(net);
                [lossValidation,~,~,accuracyValidation] = dlfeval(ValidationLoss,net);
                lossValidation=extractdata(lossValidation);
                end

                if mod(iteration,SaveFrequency)==1
                    savePlot(monitor);
                    plotFcn_savePlot(iteration);
                end
            
                data = [epoch iteration learningrate loss lossValidation accuracyTrain accuracyValidation MostCommon RandomChance LossReconstruction LossKL LossClassification];
                send(dataQueue,gather(data));
                send(dataQueue_Plot,{net,gather(iteration)});
            end
        end

        % Stop training if the Stop button has been clicked.
        if WantParallel
        stopRequest = spmdPlus(stopTrainingEventQueue.QueueLength);
        else
        stopRequest = monitor.Stop;
        end

    end

% end

try
net=net{1};
catch

end
net=resetState(net);

end