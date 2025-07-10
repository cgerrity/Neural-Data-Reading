function net = cgg_trainNetworkParallel(InputNet,DataStore_Training,DataStore_Validation,DataStore_Testing,varargin)
%CGG_TRAINNETWORKPARALLEL Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
Optimizer = CheckVararginPairs('Optimizer', 'ADAM', varargin{:});
else
if ~(exist('Optimizer','var'))
Optimizer='ADAM';
end
end

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
SaveFrequency = CheckVararginPairs('SaveFrequency', ValidationFrequency, varargin{:});
else
if ~(exist('SaveFrequency','var'))
SaveFrequency=ValidationFrequency;
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
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
end
end

if isfunction
InitialLearningRate = CheckVararginPairs('InitialLearningRate', 0.01, varargin{:});
else
if ~(exist('InitialLearningRate','var'))
InitialLearningRate=0.01;
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
LearningRateEpochDrop=30;
end
end

if isfunction
WantParallel = CheckVararginPairs('WantParallel', false, varargin{:});
else
if ~(exist('WantParallel','var'))
WantParallel=false;
end
end

if isfunction
LossFactorReconstruction = CheckVararginPairs('LossFactorReconstruction', NaN, varargin{:});
else
if ~(exist('LossFactorReconstruction','var'))
LossFactorReconstruction=NaN;
end
end

if isfunction
LossFactorKL = CheckVararginPairs('LossFactorKL', NaN, varargin{:});
else
if ~(exist('LossFactorKL','var'))
LossFactorKL=NaN;
end
end

if isfunction
RescaleLossEpoch = CheckVararginPairs('RescaleLossEpoch', 1, varargin{:});
else
if ~(exist('RescaleLossEpoch','var'))
RescaleLossEpoch=1;
end
end

if isfunction
WantSaveNet = CheckVararginPairs('WantSaveNet', false, varargin{:});
else
if ~(exist('WantSaveNet','var'))
WantSaveNet=false;
end
end

if isfunction
IterationSaveFrequency = CheckVararginPairs('IterationSaveFrequency', 2, varargin{:});
else
if ~(exist('IterationSaveFrequency','var'))
IterationSaveFrequency=2;
end
end

if isfunction
WindowMonitor = CheckVararginPairs('WindowMonitor', '', varargin{:});
else
if ~(exist('WindowMonitor','var'))
WindowMonitor='';
end
end

if isfunction
WindowMonitor_Accuracy_Measure = CheckVararginPairs('WindowMonitor_Accuracy_Measure', '', varargin{:});
else
if ~(exist('WindowMonitor_Accuracy_Measure','var'))
WindowMonitor_Accuracy_Measure='';
end
end

if isfunction
ReconstructionMonitor = CheckVararginPairs('ReconstructionMonitor', '', varargin{:});
else
if ~(exist('ReconstructionMonitor','var'))
ReconstructionMonitor='';
end
end

if isfunction
GradientMonitor = CheckVararginPairs('GradientMonitor', '', varargin{:});
else
if ~(exist('GradientMonitor','var'))
GradientMonitor='';
end
end

if isfunction
MatchType_Accuracy_Measure = CheckVararginPairs('MatchType_Accuracy_Measure', 'macroF1', varargin{:});
else
if ~(exist('MatchType_Accuracy_Measure','var'))
MatchType_Accuracy_Measure='macroF1';
end
end

if isfunction
WeightedLoss = CheckVararginPairs('WeightedLoss', 'Inverse', varargin{:});
else
if ~(exist('WeightedLoss','var'))
WeightedLoss='Inverse';
end
end

if isfunction
NumIterationsAutoEncoder = CheckVararginPairs('NumIterationsAutoEncoder', 1, varargin{:});
else
if ~(exist('NumIterationsAutoEncoder','var'))
NumIterationsAutoEncoder=1;
end
end

if isfunction
WantComponentMonitor = CheckVararginPairs('WantComponentMonitor', true, varargin{:});
else
if ~(exist('WantComponentMonitor','var'))
WantComponentMonitor=true;
end
end

if isfunction
WantAccuracyMonitor = CheckVararginPairs('WantAccuracyMonitor', false, varargin{:});
else
if ~(exist('WantAccuracyMonitor','var'))
WantAccuracyMonitor=false;
end
end
%%

OutputNames_All=InputNet.OutputNames;

OutputNames_Mean=string(OutputNames_All(contains(OutputNames_All,'mean')));
OutputNames_LogVar=string(OutputNames_All(contains(OutputNames_All,'log-variance')));
OutputNames_Classifier=string(OutputNames_All(contains(OutputNames_All,'Dim')));
OutputNames_Reconstruction=string(OutputNames_All(contains(OutputNames_All,'reshape') | contains(OutputNames_All,'Output')));

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
[ClassNames,~,ClassPercent,~] = cgg_getClassesFromDataStore(DataStore_Training);
else
ClassNames=cell(0);
ClassPercent=cell(0);
end


switch WeightedLoss
    case 'Inverse'
        Weights = cellfun(@(x) dlarray(diag(diag(1./(x/100))),'C'),ClassPercent,'UniformOutput',false);
    otherwise
        Weights = cell(0);
end

%%

HasWindowMonitor = false;
if ~isempty(WindowMonitor)
    HasWindowMonitor = true;
end
HasWindowMonitor_Accuracy_Measure = false;
if ~isempty(WindowMonitor_Accuracy_Measure)
    HasWindowMonitor_Accuracy_Measure = true;
end
HasGradientMonitor = false;
if ~isempty(GradientMonitor)
    HasGradientMonitor = true;
end

% HasWindowMonitor = exist('WindowMonitor','var');
% HasWindowMonitor_Accuracy_Measure = exist('WindowMonitor_Accuracy_Measure','var');
% HasGradientMonitor = exist('GradientMonitor','var');

% HasReconstructionMonitor = false;
% if ~isempty(ReconstructionMonitor)
%     HasReconstructionMonitor = true;
% end

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
% net=resetState(net);
net = cgg_resetState(net);

%%

if HasGradientMonitor
WeightIDX = contains(net.Learnables.Parameter,"Weights");
GradientValuesNames = net.Learnables.Layer(WeightIDX) + "-" + net.Learnables.Parameter(WeightIDX);
end
%%
switch Optimizer
    case 'SGD'
        velocity = [];
        momentum=0.9;
        workerVelocity = velocity;
    case 'ADAM'
        averageGrad = [];
        averageSqGrad = [];
    otherwise
end

if executionEnvironment == "gpu"
     MiniBatchSize = MiniBatchSize .* numWorkers;
end

% maxworkerMiniBatchSize = 10;
% numWorkers = ceil(MiniBatchSize/maxworkerMiniBatchSize);

workerMiniBatchSize = floor(MiniBatchSize ./ repmat(numWorkers,1,numWorkers));
remainder = MiniBatchSize - sum(workerMiniBatchSize);
workerMiniBatchSize = workerMiniBatchSize + [ones(1,remainder) zeros(1,numWorkers-remainder)];

% NumTrials = numpartitions(DataStore_Training);
% Iteration_DataStoreIDX = cgg_getIndicesIntoGroups(MiniBatchSize,NumTrials);
% IterationsPerEpoch = length(Iteration_DataStoreIDX);

%%

% batchNormLayers = arrayfun(@(l)isa(l,"nnet.cnn.layer.BatchNormalizationLayer"),net.Layers);
% batchNormLayersNames = string({net.Layers(batchNormLayers).Name});
% state = net.State;
% isBatchNormalizationStateMean = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedMean";
% isBatchNormalizationStateVariance = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedVariance";

% monitor = cgg_generateProgressMonitor_v2('LossType',LossType,'LogLoss',false,'WantKLLoss',IsVariational,'WantReconstructionLoss',HasReconstruction,'WantClassificationLoss',HasClassifier);
monitor = cgg_generateProgressMonitor_v4('LossType',LossType,'LogLoss',false,'WantKLLoss',IsVariational,'WantReconstructionLoss',HasReconstruction,'WantClassificationLoss',HasClassifier,'SaveDir',SaveDirPlot);
monitor_Accuracy_Measure = cgg_generateProgressMonitor_v4('LossType',LossType,'LogLoss',false,'WantKLLoss',IsVariational,'WantReconstructionLoss',HasReconstruction,'WantClassificationLoss',HasClassifier,'SaveDir',SaveDirPlot,'SaveTerm',MatchType_Accuracy_Measure);

spmd
    stopTrainingEventQueue = parallel.pool.DataQueue;
end
stopTrainingQueue = stopTrainingEventQueue{1};

dataQueue = parallel.pool.DataQueue;
displayFcn = @(x) cgg_displayTrainingUpdate_v2(x,NumEpochs,numWorkers,monitor,stopTrainingQueue);
afterEach(dataQueue,displayFcn)

dataQueue_Accuracy_Measure = parallel.pool.DataQueue;
displayFcn_Accuracy_Measure = @(x) cgg_displayTrainingUpdate_v2(x,NumEpochs,numWorkers,monitor_Accuracy_Measure,stopTrainingQueue);
afterEach(dataQueue_Accuracy_Measure,displayFcn_Accuracy_Measure)

%%

NumDisplayExamples=10;

ValidationMbq_Display = minibatchqueue(shuffle(DataStore_Validation),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);
TrainingMbq_Display = minibatchqueue(shuffle(DataStore_Training),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);

%%
% [XValidation_Display,TValidation_Display] = next(ValidationMbq_Display);
% [XTraining_Display,TTraining_Display] = next(TrainingMbq_Display);

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
DisplayFigure.Visible='off';

dataQueue_Plot = parallel.pool.DataQueue;
% plotFcn = @(x,iter) cgg_displayDataExamples(x,XTraining_Display,TTraining_Display,XValidation_Display,TValidation_Display,ClassNames,OutputInformation,iter,DisplayFigure);
plotFcn = @(x,iter,IsOptimal) cgg_displayDataExamples_v2(x,TrainingMbq_Display,ValidationMbq_Display,ClassNames,OutputInformation,iter,DisplayFigure,'ReconstructionMonitor',ReconstructionMonitor,'IsQuaddle',IsQuaddle,'NumExamples',3,'IsOptimal',IsOptimal);
plotFcn_wrapped = @(x) plotFcn(x{1},x{2},x{3});

% PlotSavePathNameExt = [SaveDirPlot filesep 'Example-Monitor_Iteration-%d' SaveTerm '.pdf'];
PlotSavePathNameExt = [SaveDirPlot filesep 'Example-Monitor_Iteration-%s' SaveTerm '.pdf'];
plotFcn_savePlot = @(x) saveas(DisplayFigure, sprintf(PlotSavePathNameExt,x));

afterEach(dataQueue_Plot,plotFcn_wrapped)

if HasWindowMonitor
dataQueue_WindowMonitor = parallel.pool.DataQueue;
displayFcnMonitor = @(x) cgg_displayWindowMonitor(WindowMonitor,x);
afterEach(dataQueue_WindowMonitor,displayFcnMonitor);
end
if HasWindowMonitor_Accuracy_Measure
dataQueue_WindowMonitor_Accuracy_Measure = parallel.pool.DataQueue;
displayFcnMonitor_Accuracy_Measure = @(x) cgg_displayWindowMonitor(WindowMonitor_Accuracy_Measure,x);
afterEach(dataQueue_WindowMonitor_Accuracy_Measure,displayFcnMonitor_Accuracy_Measure);
end

if HasGradientMonitor
dataQueue_GradientMonitor = parallel.pool.DataQueue;
displayFcnMonitor_Gradient = @(x) updatePlot(GradientMonitor,GradientValuesNames,x{1},x{2},x{3},x{4});
afterEach(dataQueue_GradientMonitor,displayFcnMonitor_Gradient);
end

%%
% epsilon=0.0000001;
% Function_MaximumNorm=@(x) max(norm(x(:)))/GradientThreshold;
% Function_MaximumNorm=@(x) max(pagenorm(x),[],"all")/GradientThreshold;
% Function_GradientReduction=@(x,y) x/(y+epsilon);

ValidationMbq = minibatchqueue(DataStore_Validation,...
    MiniBatchSize=numpartitions(DataStore_Validation),...
    MiniBatchFormat=DataFormat);
TestingMbq = minibatchqueue(DataStore_Testing,...
    MiniBatchSize=numpartitions(DataStore_Testing),...
    MiniBatchFormat=DataFormat);

[ValidationX,ValidationT] = next(ValidationMbq);
[TestingX,TestingT] = next(TestingMbq);

% ModelLoss=@(x1,x2,x3) cgg_lossNetwork(x1,x2,x3,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle);
ModelLoss=@(x1,x2,x3,x4,x5) cgg_lossNetwork(x1,x2,x3,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle,'WeightReconstruction',x4*LossFactorReconstruction,'WeightKL',x5*LossFactorKL,'WeightedLoss',WeightedLoss,'Weights',Weights);
ModelLoss_Initial=@(x1,x2,x3,x4,x5) cgg_lossNetwork(x1,x2,x3,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle,'WeightReconstruction',x4*LossFactorReconstruction,'WeightKL',x5*LossFactorKL,'WantGradient',false,'WeightedLoss',WeightedLoss,'Weights',Weights);
% ValidationLoss=@(x1) cgg_lossNetwork(x1,ValidationX,ValidationT,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle,'wantPredict',true);
ValidationLoss=@(x1,x2,x3) cgg_lossNetwork(x1,ValidationX,ValidationT,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle,'wantPredict',true,'WeightReconstruction',x2*LossFactorReconstruction,'WeightKL',x3*LossFactorKL,'WantGradient',false,'WeightedLoss',WeightedLoss,'Weights',Weights);
TestingLoss=@(x1,x2,x3) cgg_lossNetwork(x1,TestingX,TestingT,LossType,OutputInformation,ClassNames,'IsQuaddle',IsQuaddle,'wantPredict',true,'WeightReconstruction',x2*LossFactorReconstruction,'WeightKL',x3*LossFactorKL,'WantGradient',false,'WeightedLoss',WeightedLoss,'Weights',Weights);


if HasClassifier
    CM_Table_Function=@(InDatastore,InputNet) cgg_procPredictionsFromDatastoreNetwork(InDatastore,InputNet,ClassNames,varargin{:});
end

%%
MostCommon=NaN;
RandomChance=NaN;
Stratified=NaN;
MostCommon_Accuracy_Measure=NaN;
RandomChance_Accuracy_Measure=NaN;
Stratified_Accuracy_Measure=NaN;
if HasClassifier
TrueValue=double(extractdata(ValidationT)');
[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType,IsQuaddle);
[MostCommon_Accuracy_Measure,RandomChance_Accuracy_Measure,Stratified_Accuracy_Measure] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType_Accuracy_Measure,IsQuaddle);
end

MostCommon_Testing=NaN;
RandomChance_Testing=NaN;
Stratified_Testing=NaN;
MostCommon_Accuracy_Measure_Testing=NaN;
RandomChance_Accuracy_Measure_Testing=NaN;
Stratified_Accuracy_Measure_Testing=NaN;
if HasClassifier
TrueValue_Testing=double(extractdata(TestingT)');
[MostCommon_Testing,RandomChance_Testing,Stratified_Testing] = cgg_getBaselineAccuracyMeasures(TrueValue_Testing,ClassNames,MatchType,IsQuaddle);
[MostCommon_Accuracy_Measure_Testing,RandomChance_Accuracy_Measure_Testing,Stratified_Accuracy_Measure_Testing] = cgg_getBaselineAccuracyMeasures(TrueValue_Testing,ClassNames,MatchType_Accuracy_Measure,IsQuaddle);
end

%%

InitializeMbq = minibatchqueue(DataStore_Training,...
        MiniBatchSize=workerMiniBatchSize(1),...
        MiniBatchFormat=DataFormat);

[InitializeX,InitializeT] = next(InitializeMbq);

% [~,~,~,~,InitialLossReconstruction,InitialLossClassification,InitialLossKL,~,~,~] = dlfeval(ModelLoss,net,InitializeX,InitializeT,NaN,NaN);
[~,~,~,~,InitialLossReconstruction,InitialLossClassification,InitialLossKL,~,~,~] = ModelLoss_Initial(net,InitializeX,InitializeT,NaN,NaN);

if IsVariational
    UnweigtedLossKL = extractdata(InitialLossKL{2});
else
    UnweigtedLossKL = NaN;
end
if HasClassifier
    UnweigtedLossClassification = extractdata(InitialLossClassification{2});
else
    UnweigtedLossClassification = NaN;
end
if HasReconstruction
    UnweigtedLossReconstruction = extractdata(InitialLossReconstruction{2});
else
    UnweigtedLossReconstruction = NaN;
end

LossRatioReconstruction=UnweigtedLossClassification/UnweigtedLossReconstruction;
LossRatioKL=UnweigtedLossClassification/UnweigtedLossKL;

%%

if WantComponentMonitor

SizeData = size(InitializeX);
NumAreas = SizeData(finddim(InitializeX,"C"));
monitor_Component = cgg_generateComponentProgressMonitor('WantKLLoss',IsVariational,'WantReconstructionLoss',HasReconstruction,'WantClassificationLoss',HasClassifier,'SaveDir',SaveDirPlot,'NumAreas',NumAreas);

dataQueue_Component = parallel.pool.DataQueue;
displayFcn_Component = @(x) cgg_displayTrainingLossComponentUpdate(x,monitor_Component);
afterEach(dataQueue_Component,displayFcn_Component)

end
%%

MaximumValidationAccuracy = -Inf;
MinimumValidationLoss = Inf;
wantClassification = false;
SavePathNameExt = [SaveDirPlot filesep 'Optimal_Results.mat'];
SaveVariablesName = {'ValidationAccuracy','TestingAccuracy','ValidationMostCommon','ValidationRandomChance','TestingMostCommon','TestingRandomChance','Iteration','ElapsedTime','Window_AccuracyValidation','Combined_Accuracy_MeasureValidation','Window_AccuracyTesting','Combined_Accuracy_MeasureTesting','ValidationMostCommon_Accuracy_Measure','ValidationRandomChance_Accuracy_Measure','TestingMostCommon_Accuracy_Measure','TestingRandomChance_Accuracy_Measure'};
TimerStart = tic;
NetworkPathNameExt = [SaveDirPlot filesep 'FullNetwork.mat'];
IterationPathNameExt = [SaveDirPlot filesep 'CurrentIteration.mat'];
IterationVariablesName = {'CurrentIteration','CurrentTime'};

%%
% spmd
% for widx=1:numWorkers
    
    this_workerIDX=spmdIndex;
    % this_workerIDX=1;

    % Partition the datastore.
    this_DataStore_Training = partition(DataStore_Training,numWorkers,this_workerIDX);

    % Create minibatchqueue using partitioned datastore on each worker.
    workerMbq = minibatchqueue(this_DataStore_Training,...
        MiniBatchSize=workerMiniBatchSize(this_workerIDX),...
        MiniBatchFormat=DataFormat);

    
    epoch = 0;
    iteration = 0;
    stopRequest = false;
    %%

    while epoch < NumEpochs && ~stopRequest
        epoch = epoch + 1;
        shuffle(workerMbq);

        learningrate = InitialLearningRate * (LearningRateDecay)^floor(...
            epoch / LearningRateEpochDrop);

%        EpochIDX = mod(iteration-1,IterationsPerEpoch)+1;
%        DataStore_Training = shuffle(DataStore_Training);
%        IterationDataStore = subset(DataStore_Training,Iteration_DataStoreIDX{EpochIDX});
%
%        cgg_calcNetworkLossFromDataStore(net,IterationDataStore,DataFormat,LossFunction,varargin)

        %% Loop over mini-batches.
        while spmdReduce(@and,hasdata(workerMbq)) && ~stopRequest
        % while hasdata(workerMbq) && ~stopRequest
            %%
            iteration = iteration + 1;
            % net=resetState(net);
            net = cgg_resetState(net);

            % Determine if Classification is wanted
            if iteration == NumIterationsAutoEncoder
            wantClassification = true;
            learningrate = InitialLearningRate;
            end
            if ~wantClassification
                LossRatioReconstruction = Inf;
            end

            % Read a mini-batch of data.
            [workerX,workerT] = next(workerMbq);

            % Evaluate the model loss and gradients on the worker.
            % [workerLoss,workerGradients,~,workerAccuracy,workerLossReconstruction,workerLossClassification,workerLossKL] = dlfeval(ModelLoss,net,workerX,workerT);
            [workerLoss,workerGradients,~,workerAccuracy,workerLossReconstruction,workerLossClassification,workerLossKL,workerWindow_Accuracy,workerCombined_Accuracy_Measure,workerClassifierOutput] = dlfeval(ModelLoss,net,workerX,workerT,LossRatioReconstruction,LossRatioKL);
            %%
            % Aggregate the losses on all workers.
            workerNormalizationFactor = workerMiniBatchSize(this_workerIDX)./MiniBatchSize;
            loss = spmdPlus(workerNormalizationFactor*extractdata(workerLoss));
            LossReconstruction = spmdPlus(workerNormalizationFactor*extractdata(workerLossReconstruction{1}));
            LossClassification = spmdPlus(workerNormalizationFactor*extractdata(workerLossClassification{1}));
            LossKL = spmdPlus(workerNormalizationFactor*extractdata(workerLossKL{1}));

            LossReconstructionPerArea = spmdPlus(workerNormalizationFactor*extractdata(workerLossReconstruction{3}));
            % Aggregate the accuracy on all workers.
            accuracyTrain = spmdPlus(workerNormalizationFactor*workerAccuracy);
            Window_AccuracyTrain = spmdPlus(workerNormalizationFactor*workerWindow_Accuracy);
            
            % Aggregate the accuracy measure on all workers.
            workerAccuracy_Measure = workerCombined_Accuracy_Measure{1};
            workerWindow_Accuracy_Measure = workerCombined_Accuracy_Measure{2};
            Accuracy_MeasureTrain = spmdPlus(workerNormalizationFactor*workerAccuracy_Measure);
            Window_Accuracy_MeasureTrain = spmdPlus(workerNormalizationFactor*workerWindow_Accuracy_Measure);

%             % Aggregate the network state on all workers.
%             net.State = aggregateState(workerState,workerNormalizationFactor,...
%                 isBatchNormalizationStateMean,isBatchNormalizationStateVariance);

            % Aggregate the gradients on all workers.
            % if WantParallel
            workerGradients.Value = dlupdate(@aggregateGradients,workerGradients.Value,{workerNormalizationFactor});
            % end

            % Get Mean of Gradient
            if HasGradientMonitor
            GradientValues = workerGradients.Value(WeightIDX);
            for gidx = 1:length(GradientValues)
              MeanGradient(iteration,gidx) = mean(GradientValues{gidx},"all");
              STDGradient(iteration,gidx) = std(GradientValues{gidx},[],"all");
            end
            end
%%
            % GradAll=workerGradients.Value;
            % % MaxGrad=cellfun(@size,GradAll,'UniformOutput',false)
            % MaxGrad=cellfun(Function_MaximumNorm,GradAll,'UniformOutput',false);
            % GradAll_Thresholded=cellfun(Function_GradientReduction,GradAll,MaxGrad,'UniformOutput',false);
            % 
            % workerGradients.Value=GradAll_Thresholded;
            workerGradients = cgg_calcGradientThreshold(workerGradients,GradientThreshold);

            % Get Mean of Thresholded Gradient
            if HasGradientMonitor
            GradientValues = workerGradients.Value(WeightIDX);
            for gidx = 1:length(GradientValues)
              MeanThresholdGradient(iteration,gidx) = mean(GradientValues{gidx},"all");
              STDThresholdGradient(iteration,gidx) = std(GradientValues{gidx},[],"all");
            end
            end

            lossValidation = NaN;
            accuracyValidation = NaN;
            Window_AccuracyValidation = NaN;
            Accuracy_MeasureValidation = NaN;
            Window_Accuracy_MeasureValidation = NaN;
            IsOptimal = false;
            InSaveTerm = 'Current';
            Loss_KLValidation = NaN;
            Loss_ClassificationValidation = NaN;
            Loss_ReconstructionValidation = NaN;
            Loss_ReconstructionValidationPerArea = NaN;


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
            switch Optimizer
                case 'SGD'
            % Update the network parameters using the SGDM optimizer.
                [net,workerVelocity] = sgdmupdate(net,workerGradients,workerVelocity,learningrate,momentum);
                case 'ADAM'
                % Update the network parameters using the ADAM optimizer.
                [net,averageGrad,averageSqGrad] = adamupdate(net,workerGradients,averageGrad,averageSqGrad,iteration,learningrate);
                otherwise
            end
            %%
            % Send training progress information to the client.
            if this_workerIDX == 1

                if mod(iteration,ValidationFrequency)==1
                net=resetState(net);
                [lossValidation,~,~,accuracyValidation,Loss_ReconstructionValidation,Loss_ClassificationValidation,Loss_KLValidation,Window_AccuracyValidation,Combined_Accuracy_MeasureValidation,ClassifierOutputValidation] = ValidationLoss(net,LossRatioReconstruction,LossRatioKL);
                % [lossValidation,~,~,accuracyValidation,~,~,~] = dlfeval(ValidationLoss,net,LossRatioReconstruction,LossRatioKL);
                Accuracy_MeasureValidation = Combined_Accuracy_MeasureValidation{1};
                Window_Accuracy_MeasureValidation = Combined_Accuracy_MeasureValidation{1};
                if WantComponentMonitor
                    Loss_ReconstructionValidationPerArea = Loss_ReconstructionValidation{3};
                    Loss_ReconstructionValidation = Loss_ReconstructionValidation{1};
                    Loss_KLValidation = Loss_KLValidation{1};
                    Loss_ClassificationValidation = Loss_ClassificationValidation{1};
                    if isdlarray(Loss_ReconstructionValidation)
                        Loss_ReconstructionValidation=extractdata(Loss_ReconstructionValidation);
                    end
                    if isdlarray(Loss_ReconstructionValidationPerArea)
                        Loss_ReconstructionValidationPerArea=extractdata(Loss_ReconstructionValidationPerArea);
                    end
                    if isdlarray(Loss_KLValidation)
                        Loss_KLValidation=extractdata(Loss_KLValidation);
                    end
                    if isdlarray(Loss_ClassificationValidation)
                        Loss_ClassificationValidation=extractdata(Loss_ClassificationValidation);
                    end
                end
                if isdlarray(lossValidation)
                lossValidation=extractdata(lossValidation);
                end
                end
            
                %%
                data = [epoch iteration learningrate loss lossValidation accuracyTrain accuracyValidation MostCommon RandomChance LossReconstruction LossKL LossClassification];
                send(dataQueue,gather(data));

                data_Accuracy_Measure = [epoch iteration learningrate loss lossValidation Accuracy_MeasureTrain Accuracy_MeasureValidation MostCommon_Accuracy_Measure RandomChance_Accuracy_Measure LossReconstruction LossKL LossClassification];
                send(dataQueue_Accuracy_Measure,gather(data_Accuracy_Measure));

                if HasWindowMonitor
                data_Window = {iteration Window_AccuracyTrain Window_AccuracyValidation};
                send(dataQueue_WindowMonitor,data_Window);
                end
                if HasWindowMonitor_Accuracy_Measure
                data_Window_Accuracy_Measure = {iteration Window_Accuracy_MeasureTrain Window_Accuracy_MeasureValidation};
                send(dataQueue_WindowMonitor_Accuracy_Measure,data_Window_Accuracy_Measure);
                end
                if HasGradientMonitor
                data_Window_Accuracy_Measure = {MeanGradient,STDGradient,MeanThresholdGradient,STDThresholdGradient};
                send(dataQueue_GradientMonitor,data_Window_Accuracy_Measure);
                end
                if WantComponentMonitor
                data_Component = {iteration, LossReconstruction,LossKL,LossClassification,Loss_ReconstructionValidation,Loss_KLValidation,Loss_ClassificationValidation,LossReconstructionPerArea,Loss_ReconstructionValidationPerArea};
                send(dataQueue_Component,data_Component);
                end

                if mod(iteration,IterationSaveFrequency)==1
                    IterationVariables = {iteration,toc(TimerStart)};
                    cgg_saveVariableUsingMatfile(IterationVariables,IterationVariablesName,IterationPathNameExt);
                end

                if HasClassifier
                    if max(Window_AccuracyValidation) > MaximumValidationAccuracy
                        IsOptimal = true;
                        MaximumValidationAccuracy = max(Window_AccuracyValidation);
                    end
                else
                    if lossValidation < MinimumValidationLoss
                        IsOptimal = true;
                        MinimumValidationLoss = lossValidation;
                    end
                end

                % if accuracyValidation > MaximumValidationAccuracy
                % if max(Window_AccuracyValidation) > MaximumValidationAccuracy
                if IsOptimal
                    % IsOptimal = true;
                    InSaveTerm = 'Optimal';
                    % MaximumValidationAccuracy = accuracyValidation;
                    MaximumValidationAccuracy = max(Window_AccuracyValidation);
                    % net=resetState(net);
                    net = cgg_resetState(net);
                    if HasClassifier
                    cgg_saveCMTableFromNetwork(DataStore_Testing,net,ClassNames,SaveDirPlot,varargin{:});
                    end
                    [~,~,~,TestingAccuracy,~,~,~,Window_AccuracyTesting,Combined_Accuracy_MeasureTesting,ClassifierOutputTesting] = TestingLoss(net,LossRatioReconstruction,LossRatioKL);
                    % [~,~,~,TestingAccuracy,~,~,~] = dlfeval(TestingLoss,net,LossRatioReconstruction,LossRatioKL);
                    SaveVariables = {MaximumValidationAccuracy,TestingAccuracy,MostCommon,RandomChance,MostCommon_Testing,RandomChance_Testing,iteration,toc(TimerStart),Window_AccuracyValidation,Combined_Accuracy_MeasureValidation,Window_AccuracyTesting,Combined_Accuracy_MeasureTesting,MostCommon_Accuracy_Measure,RandomChance_Accuracy_Measure,MostCommon_Accuracy_Measure_Testing,RandomChance_Accuracy_Measure_Testing};
                    cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);
                
                    if WantSaveNet
                    try
                        NetSave=net{1};
                    catch
                        NetSave=net;
                    end
                    % NetSave=resetState(NetSave);
                    net = cgg_resetState(NetSave);
                    cgg_saveVariableUsingMatfile({NetSave},{'Network'},NetworkPathNameExt);
                    end

                    %% Optimal Plot Saving
                    if WantAccuracyMonitor
                        CM_Table_Validation=CM_Table_Function(DataStore_Validation,net);
                        CM_Table_Training=CM_Table_Function(this_DataStore_Training,net);
                    end

                    send(dataQueue_Plot,{net,gather(iteration),IsOptimal});
                    savePlot(monitor,IsOptimal);
                    savePlot(monitor_Accuracy_Measure,IsOptimal);
                    plotFcn_savePlot(InSaveTerm);
                    if HasWindowMonitor
                    savePlot(WindowMonitor,IsOptimal);
                    end
                    if HasWindowMonitor_Accuracy_Measure
                    savePlot(WindowMonitor_Accuracy_Measure,IsOptimal);
                    end
                    if HasGradientMonitor
                    savePlot(GradientMonitor,IsOptimal);
                    end
                    if WantComponentMonitor
                    savePlot(monitor_Component,IsOptimal);
                    end
                    
                end

                %% Current Plot Saving
                if mod(iteration,SaveFrequency)==1
                    IsOptimal = false;
                    InSaveTerm = 'Current';
                    if WantAccuracyMonitor
                        CM_Table_Validation=CM_Table_Function(DataStore_Validation,net);
                        CM_Table_Training=CM_Table_Function(this_DataStore_Training,net);
                    end

                    send(dataQueue_Plot,{net,gather(iteration),IsOptimal});
                    savePlot(monitor,IsOptimal);
                    savePlot(monitor_Accuracy_Measure,IsOptimal);
                    plotFcn_savePlot(InSaveTerm);
                    if HasWindowMonitor
                    savePlot(WindowMonitor,IsOptimal);
                    end
                    if HasWindowMonitor_Accuracy_Measure
                    savePlot(WindowMonitor_Accuracy_Measure,IsOptimal);
                    end
                    if HasGradientMonitor
                    savePlot(GradientMonitor,IsOptimal);
                    end
                    if WantComponentMonitor
                    savePlot(monitor_Component,IsOptimal);
                    end
                end

            end
        end

        if mod(epoch+1,RescaleLossEpoch) == 1 || RescaleLossEpoch == 1
        if IsVariational
            UnweigtedLossKL = spmdPlus(workerNormalizationFactor*extractdata(workerLossKL{2}));
        else
            UnweigtedLossKL = NaN;
        end
        if HasClassifier
            UnweigtedLossClassification = spmdPlus(workerNormalizationFactor*extractdata(workerLossClassification{2}));
        else
            UnweigtedLossClassification = NaN;
        end
        if HasReconstruction
            UnweigtedLossReconstruction = spmdPlus(workerNormalizationFactor*extractdata(workerLossReconstruction{2}));
        else
            UnweigtedLossReconstruction = NaN;
        end

        LossRatioReconstruction=UnweigtedLossClassification/UnweigtedLossReconstruction;
        LossRatioKL=UnweigtedLossClassification/UnweigtedLossKL;
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
% net=resetState(net);
net = cgg_resetState(net);

end