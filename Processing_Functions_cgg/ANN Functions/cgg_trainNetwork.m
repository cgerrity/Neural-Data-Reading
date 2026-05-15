function [Encoder,Decoder,Classifier] = cgg_trainNetwork(Encoder,DataStore_Training,DataStore_Validation,DataStore_Testing,varargin)
%CGG_TRAINNETWORK Summary of this function goes here
%   Detailed explanation goes here

%% Get the Parameters

isfunction=exist('varargin','var');

if isfunction
Decoder = CheckVararginPairs('Decoder', [], varargin{:});
else
if ~(exist('Decoder','var'))
Decoder=[];
end
end

if isfunction
Classifier = CheckVararginPairs('Classifier', [], varargin{:});
else
if ~(exist('Classifier','var'))
Classifier=[];
end
end

if isfunction
Optimizer = CheckVararginPairs('Optimizer', 'ADAM', varargin{:});
else
if ~(exist('Optimizer','var'))
Optimizer='ADAM';
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
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', false, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=false;
end
end

if isfunction
WeightReconstruction = CheckVararginPairs('WeightReconstruction', NaN, varargin{:});
else
if ~(exist('WeightReconstruction','var'))
WeightReconstruction=NaN;
end
end

if isfunction
WeightKL = CheckVararginPairs('WeightKL', NaN, varargin{:});
else
if ~(exist('WeightKL','var'))
WeightKL=NaN;
end
end

if isfunction
WeightClassification = CheckVararginPairs('WeightClassification', NaN, varargin{:});
else
if ~(exist('WeightClassification','var'))
WeightClassification=NaN;
end
end

if isfunction
WeightOffsetAndScale = CheckVararginPairs('WeightOffsetAndScale', NaN, varargin{:});
else
if ~(exist('WeightOffsetAndScale','var'))
WeightOffsetAndScale=NaN;
end
end

if isfunction
WeightConfidence = CheckVararginPairs('WeightConfidence', NaN, varargin{:});
else
if ~(exist('WeightConfidence','var'))
WeightConfidence=NaN;
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
SaveDir = CheckVararginPairs('SaveDir', pwd, varargin{:});
else
if ~(exist('SaveDir','var'))
SaveDir=pwd;
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
MiniBatchSize = CheckVararginPairs('MiniBatchSize', 100, varargin{:});
else
if ~(exist('MiniBatchSize','var'))
MiniBatchSize=100;
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
LearningRateEpochRamp = CheckVararginPairs('LearningRateEpochRamp', 5, varargin{:});
else
if ~(exist('LearningRateEpochRamp','var'))
LearningRateEpochRamp=5;
end
end

if isfunction
WeightEpochRamp = CheckVararginPairs('WeightEpochRamp', 10, varargin{:});
else
if ~(exist('WeightEpochRamp','var'))
WeightEpochRamp=10;
end
end

if isfunction
WeightDelayEpoch = CheckVararginPairs('WeightDelayEpoch', 15, varargin{:});
else
if ~(exist('WeightDelayEpoch','var'))
WeightDelayEpoch=15;
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
RescaleLossEpoch = CheckVararginPairs('RescaleLossEpoch', 1, varargin{:});
else
if ~(exist('RescaleLossEpoch','var'))
RescaleLossEpoch=1;
end
end

if isfunction
cfg_Monitor = CheckVararginPairs('cfg_Monitor', [], varargin{:});
else
if ~(exist('cfg_Monitor','var'))
cfg_Monitor=[];
end
end

if isfunction
LossType_Decoder = CheckVararginPairs('LossType_Decoder', 'MSE', varargin{:});
else
if ~(exist('LossType_Decoder','var'))
LossType_Decoder='MSE';
end
end

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
L2Factor = CheckVararginPairs('L2Factor', 1e-4, varargin{:});
else
if ~(exist('L2Factor','var'))
L2Factor=1e-4;
end
end

if isfunction
WantFullBatch = CheckVararginPairs('WantFullBatch', false, varargin{:});
else
if ~(exist('WantFullBatch','var'))
WantFullBatch=false;
end
end

if isfunction
WantSaveOptimalNet = CheckVararginPairs('WantSaveOptimalNet', true, varargin{:});
else
if ~(exist('WantSaveOptimalNet','var'))
WantSaveOptimalNet=true;
end
end

if isfunction
GradientClipType = CheckVararginPairs('GradientClipType', 'SubNetwork', varargin{:});
else
if ~(exist('GradientClipType','var'))
GradientClipType='SubNetwork';
end
end

if isfunction
Freeze_cfg = CheckVararginPairs('Freeze_cfg', struct(), varargin{:});
else
if ~(exist('Freeze_cfg','var'))
Freeze_cfg=struct();
end
end

if isfunction
MultipleInstanceLearningType = CheckVararginPairs('MultipleInstanceLearningType', 'None', varargin{:});
else
if ~(exist('MultipleInstanceLearningType','var'))
MultipleInstanceLearningType='None';
end
end

if isfunction
LoadParameters = CheckVararginPairs('LoadParameters', [], varargin{:});
else
if ~(exist('LoadParameters','var'))
LoadParameters=[];
end
end

if isfunction
WeightParameters = CheckVararginPairs('WeightParameters', [], varargin{:});
else
if ~(exist('WeightParameters','var'))
WeightParameters=[];
end
end

if isfunction
FreezeParameters = CheckVararginPairs('FreezeParameters', [], varargin{:});
else
if ~(exist('FreezeParameters','var'))
FreezeParameters=[];
end
end

if isfunction
AccuracyType = CheckVararginPairs('AccuracyType', 'Aggregate', varargin{:});
else
if ~(exist('AccuracyType','var'))
AccuracyType='Aggregate';
end
end

if isfunction
PriorProportion = CheckVararginPairs('PriorProportion', 0, varargin{:});
else
if ~(exist('PriorProportion','var'))
PriorProportion=0;
end
end

if isfunction
WantBatchCorrection = CheckVararginPairs('WantBatchCorrection', false, varargin{:});
else
if ~(exist('WantBatchCorrection','var'))
WantBatchCorrection=false;
end
end

MessageAlreadyTrained = '!!! Network trained to maximum number of epochs\n';

%% No Epochs
% End the function if the number of training epochs is less than 1

if NumEpochs < 1
    return
end
Timer_Overhead = tic;
%% Identify the Networks
HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);

% %% Potential to get MultipleInstanceLearningType from Classifier
% for lidx = 1:length(Classifier.Layers)
% if isprop(Classifier.Layers(lidx),'SoftmaxFormat')
% MILTYPE = Classifier.Layers(lidx).SoftmaxFormat;
% break
% end
% end

%% Get frozen components
% WantFreeze = ~isempty(fieldnames(Freeze_cfg));
WantFreeze = ~isempty(FreezeParameters);
if WantFreeze
    FreezeParameters.updateAllParameters(0);
    cgg_getFrozenNetwork(Encoder,"Encoder");
    cgg_getFrozenNetwork(Decoder,"Decoder");
    cgg_getFrozenNetwork(Classifier,"Classifier");
end

%% Get Initial values
fprintf('*** Getting Initial Values\n');
% Initialize Epoch and Iteration counters
[Iteration,Epoch,Run,MaximumValidationAccuracy,...
    MinimumValidationLoss,AggregateValidationAccuracy,...
    OptimizerVariables] = cgg_getIterationInformation(SaveDir,NumEpochs);
fprintf('   --- Epoch: %d, Iteration: %d\n',Epoch,Iteration);
fprintf('   --- Peak Validation Accuracy: %.3f\n',MaximumValidationAccuracy);
fprintf('   --- Aggregate Validation Accuracy: %.3f\n',AggregateValidationAccuracy);
fprintf('   --- Minimum Validation Loss: %.4e\n',MinimumValidationLoss);

if Epoch > NumEpochs
    fprintf(MessageAlreadyTrained);
    return
end

OptimizerVariables = cgg_initializeAllOptimizerVariables(Optimizer,...
    OptimizerVariables);
[Weights,ClassNames] = cgg_getWeightsForLoss(DataStore_Training,...
    WeightedLoss);

SetSize_Training = numpartitions(DataStore_Training);
SetSize_Validation = numpartitions(DataStore_Validation);
SetSize_Testing = numpartitions(DataStore_Testing);

%% Generate Monitors
fprintf('*** Generating Monitors\n');
MonitorTable = cgg_generateAllMonitors(cfg_Monitor,Run);
fprintf('*** Initializing Monitors with Training\n');
Monitor_Values = cgg_initializeMonitorValues([],DataStore_Training,DataFormat,IsQuaddle,cfg_Monitor,'Training');
fprintf('*** Initializing Monitors with Validation\n');
Monitor_Values = cgg_initializeMonitorValues(Monitor_Values,DataStore_Validation,DataFormat,IsQuaddle,cfg_Monitor,'Validation');
Monitor_Values.MaximumValidationAccuracy = MaximumValidationAccuracy;
Monitor_Values.AggregateValidationAccuracy = AggregateValidationAccuracy;
Monitor_Values.MinimumValidationLoss = MinimumValidationLoss;

%% Establish Loss Functions
fprintf('*** Establishing Loss Functions\n');
ModelLoss_Training = ...
    @(DataStore,Encoder_Net,Decoder_Net,Classifier_Net,...
    LossInformation_Var,WantUpdateLossPrior,WeightKL_Var) ...
    cgg_lossComponents(Encoder_Net,Decoder_Net,Classifier_Net,...
    DataStore,'Weights',Weights,'DataFormat',DataFormat,...
    'wantPredict',false,'wantLoss',true,'IsQuaddle',IsQuaddle,...
    'WantGradient',true,'WantUpdateLossPrior',WantUpdateLossPrior,...
    'LossInformation',LossInformation_Var,...
    'WeightReconstruction',WeightReconstruction,'WeightKL',WeightKL_Var,...
    'WeightClassification',WeightClassification,...
    'ClassNames',ClassNames,'LossType_Decoder',LossType_Decoder,...
    'DataType','Training',...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'L2Factor',L2Factor,'WeightOffsetAndScale',WeightOffsetAndScale, ...
    'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
    'WeightParameters',WeightParameters, ...
    'WeightConfidence',WeightConfidence,'SetSize',SetSize_Training, ...
    'PriorProportion',PriorProportion, ...
    'WantBatchCorrection',WantBatchCorrection);
ModelLoss_Validation = ...
    @(Encoder_Net,Decoder_Net,Classifier_Net,LossInformation_Var,...
    WeightKL_Var) ...
    cgg_lossComponents(Encoder_Net,Decoder_Net,Classifier_Net,...
    DataStore_Validation,'Weights',Weights,'DataFormat',DataFormat,...
    'wantPredict',true,'wantLoss',true,'IsQuaddle',IsQuaddle,...
    'WantGradient',false,'WantUpdateLossPrior',false,...
    'LossInformation',LossInformation_Var,...
    'WeightReconstruction',WeightReconstruction,'WeightKL',WeightKL_Var,...
    'WeightClassification',WeightClassification,...
    'ClassNames',ClassNames,'LossType_Decoder',LossType_Decoder,...
    'DataType','Validation',...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'L2Factor',L2Factor,'WeightOffsetAndScale',WeightOffsetAndScale, ...
    'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
    'WeightParameters',WeightParameters, ...
    'WeightConfidence',WeightConfidence,'SetSize',SetSize_Validation, ...
    'PriorProportion',PriorProportion, ...
    'WantBatchCorrection',WantBatchCorrection);
ModelLoss_Testing = ...
    @(Encoder_Net,Decoder_Net,Classifier_Net,LossInformation_Var,...
    WeightKL_Var) ...
    cgg_lossComponents(Encoder_Net,Decoder_Net,Classifier_Net,...
    DataStore_Testing,'Weights',Weights,'DataFormat',DataFormat,...
    'wantPredict',true,'wantLoss',true,'IsQuaddle',IsQuaddle,...
    'WantGradient',false,'WantUpdateLossPrior',false,...
    'LossInformation',LossInformation_Var,...
    'WeightReconstruction',WeightReconstruction,'WeightKL',WeightKL_Var,...
    'WeightClassification',WeightClassification,...
    'ClassNames',ClassNames,'LossType_Decoder',LossType_Decoder,...
    'DataType','Testing',...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'L2Factor',L2Factor,'WeightOffsetAndScale',WeightOffsetAndScale, ...
    'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
    'WeightParameters',WeightParameters, ...
    'WeightConfidence',WeightConfidence,'SetSize',SetSize_Testing, ...
    'PriorProportion',PriorProportion, ...
    'WantBatchCorrection',WantBatchCorrection);

%% Training

Timer = tic;
WantUpdateLossPrior = true;
LossInformation_Training=[];
FirstIteration = true; 
% The first iteration should run through the validation for plotting

%% Loop over each epoch until finished
while Epoch <= NumEpochs

    % Obtain learning rate with step decay and ramping
    LearningRate = cgg_getLearningRate(Epoch,...
        InitialLearningRate,LearningRateDecay,LearningRateEpochDrop,...
        LearningRateEpochRamp);

    % Anneal KL Weight
    WeightKL_Anneal = cgg_annealWeight(Epoch,WeightKL,...
        WeightDelayEpoch,WeightEpochRamp);

    % Update Dynamic parameters
    WeightParameters.WeightKL = WeightKL_Anneal;
    LoadParameters.updateAllParameters(Epoch);
    WeightParameters.updateAllParameters(Epoch);
    FreezeParameters.updateAllParameters(Epoch);

    % If weights are frozen unfreeze them after annealing period
    if WantFreeze
        % Encoder = cgg_setFrozenNetwork(Epoch,Encoder,"Encoder",Freeze_cfg);
        Encoder = cgg_setFrozenNetwork_v2(Encoder,"Encoder",FreezeParameters);
        if HasDecoder
        % Decoder = cgg_setFrozenNetwork(Epoch,Decoder,"Decoder",Freeze_cfg);
        Decoder = cgg_setFrozenNetwork_v2(Decoder,"Decoder",FreezeParameters);
        end
        if HasClassifier
        % Classifier = cgg_setFrozenNetwork(Epoch,Classifier,"Classifier",Freeze_cfg);
        Classifier = cgg_setFrozenNetwork_v2(Classifier,"Classifier",FreezeParameters);
        end
    end

    % Shuffle the DataStore for training
    DataStore_Training = shuffle(DataStore_Training);

    % Get the mini-batch table for this training epoch
    [MiniBatchTable,NumBatches] = ...
    cgg_procAllSessionMiniBatchTable(DataStore_Training,MiniBatchSize,...
    WantFullBatch);

    % Shuffle the mini-batches from the mini-batch table
    MiniBatchTable = MiniBatchTable(randperm(size(MiniBatchTable,1)),:);
    HasData = true;
    MiniBatchIDX = 0;

    %% Loop over each mini-batch in the datastore
    while HasData
        MiniBatchIDX = MiniBatchIDX + 1;
        Iteration = Iteration + 1;
        fprintf('~~~ Current Epoch: %d ~~~ Current Iteration: %d\n',Epoch,Iteration);
        LastIteration = (MiniBatchIDX == NumBatches) && (Epoch == NumEpochs);

        % Get Datastore for only the mini-batch size desired
        [this_DataStore_Training,SessionName,SessionNumber] = ...
            cgg_getCurrentIterationDataStore(MiniBatchTable,...
            MiniBatchIDX,DataStore_Training);
    
        %% Calculate Loss and Gradients
        %FIXME: Gradient accumulation can be performed by looping over this
        %step
        % [LossInformation_Training,CM_Table_Training,Gradients,State] = ...
        %     dlfeval(ModelLoss_Training,this_DataStore_Training,...
        %     Encoder,Decoder,Classifier,...
        %     LossInformation_Training,WantUpdateLossPrior,WeightKL_Anneal);
        fprintf('   ??? Overhead Time is %.3f\n',toc(Timer_Overhead));
        tic;
        [LossInformation_Training,CM_Table_Training,Gradients,State] = ...
            cgg_procGradientAggregation(ModelLoss_Training, ...
            this_DataStore_Training,Encoder,Decoder,Classifier, ...
            LossInformation_Training,WantUpdateLossPrior, ...
            WeightKL_Anneal,maxworkerMiniBatchSize);
        fprintf('   ??? Gradient Aggregation Time is %.3f\n',toc);
        WantUpdateLossPrior = false;
        Timer_Overhead = tic;
    
        %% Update Gradient Threshold
        Gradients_PreThreshold = Gradients;

        % Apply one global clip across all present fields in Gradients
        [Gradients, ~] = cgg_getClippedGradient(Gradients,GradientThreshold,GradientClipType);
        % Gradients.Encoder = cgg_calcGradientThreshold(Gradients.Encoder,GradientThreshold);

        % Update Networks using gradients
        [Encoder,OptimizerVariables.Encoder] = cgg_procUpdateNetworks(...
            Encoder,Gradients.Encoder,LearningRate,Optimizer,OptimizerVariables.Encoder);
        % Update state
        Encoder = cgg_updateState(Encoder,State.Encoder);

        if HasDecoder
        % Update Gradient Threshold
        % Gradients.Decoder = cgg_calcGradientThreshold(Gradients.Decoder,GradientThreshold);

        % Update Networks using gradients
        [Decoder,OptimizerVariables.Decoder] = cgg_procUpdateNetworks(...
            Decoder,Gradients.Decoder,LearningRate,Optimizer,OptimizerVariables.Decoder);
        % Update state
        Decoder = cgg_updateState(Decoder,State.Decoder);
        end

        if HasClassifier
        % Update Gradient Threshold
        % Gradients.Classifier = cgg_calcGradientThreshold(Gradients.Classifier,GradientThreshold);

        % Update Networks using gradients
        [Classifier,OptimizerVariables.Classifier] = cgg_procUpdateNetworks(...
            Classifier,Gradients.Classifier,LearningRate,Optimizer,OptimizerVariables.Classifier);
        % Update state
        Classifier = cgg_updateState(Classifier,State.Classifier);
        end

        %% Get Measures

        if mod(Iteration,ValidationFrequency)==1 || FirstIteration || ValidationFrequency == 1 || LastIteration
            fprintf('   *** Obtaining Validation Measures\n'); tic;
        [LossInformation_Validation,CM_Table_Validation,~,~] = ...
            ModelLoss_Validation(Encoder,Decoder,Classifier,LossInformation_Training,WeightKL_Anneal);
        % FirstIteration = false;
            fprintf('   >>> Obtaining Validation Measures took %.3f seconds\n',toc);
        else
            LossInformation_Validation = [];
            CM_Table_Validation = [];
        end
    
        %% Update Monitors
        fprintf('   *** Calculating Monitor Values\n'); tic;
        [Monitor_Values,IsOptimal] = cgg_calcAllMonitorValues(...
            Monitor_Values,Encoder,Decoder,Classifier,Epoch,Iteration,...
            LearningRate,...
            LossInformation_Training,LossInformation_Validation,...
            CM_Table_Training,CM_Table_Validation,...
            Gradients,Gradients_PreThreshold,'AccuracyType',AccuracyType);
        fprintf('   >>> Calculating Monitor Values took %.3f seconds\n',toc);
        % %% Only Get Optimal Network for Annealed Weights  
        % if Epoch < WeightDelayEpoch + WeightEpochRamp && ~isnan(WeightKL_Anneal)
        %     IsOptimal = false;
        %     Monitor_Values.MaximumValidationAccuracy = -Inf;
        %     Monitor_Values.AggregateValidationAccuracy = -Inf;
        %     Monitor_Values.MinimumValidationLoss = Inf;
        % end
        %%
        SaveAll = mod(Iteration,SaveFrequency)==1 || SaveFrequency == 1 || LastIteration || FirstIteration;
        fprintf('   *** Updating All Monitors\n');tic;
        cgg_updateAllMonitors(MonitorTable,Monitor_Values,SaveAll);
        fprintf('   >>> Updating All Monitors took %.3f seconds\n',toc);

        %% Save Monitors when optimal condition is met
        if IsOptimal
            fprintf('   *** Saving Optimal Monitors\n'); tic;
        cgg_saveAllMonitors(MonitorTable,true,true); 
        fprintf('   >>> Saving Optimal Monitors took %.3f seconds\n',toc);           
        end

        %% Save Monitors at set times
        fprintf('   *** Saving Current Monitors\n'); tic;
        cgg_saveAllMonitors(MonitorTable,false,SaveAll);
        fprintf('   >>> Saving Current Monitors took %.3f seconds\n',toc);

        %% Save Networks
        SaveNetwork = WantSaveNet && SaveAll;
        SaveOptimal = WantSaveOptimalNet && IsOptimal;
        cgg_saveNetworks(Encoder,Decoder,Classifier,SaveNetwork,...
            SaveDir,SaveOptimal);

        %% Save Validation Information
        cgg_saveValidationCMTable(CM_Table_Validation,IsOptimal,SaveDir);

        %% Save Testing Information
        cgg_saveCMTableFromSeparateNetwork(ModelLoss_Testing,...
            Encoder,Decoder,Classifier,LossInformation_Training,WeightKL_Anneal,...
            IsOptimal,SaveDir);

        %% Save Iteration Parameters
        cgg_saveIterationInformation(Iteration,Epoch,Run,...
            Monitor_Values.MaximumValidationAccuracy,...
            Monitor_Values.AggregateValidationAccuracy,...
            Monitor_Values.MinimumValidationLoss,...
            IterationSaveFrequency,SaveDir,Timer,OptimizerVariables,...
            IsOptimal);
%%
        % If the MiniBatchIDX reaches the end of the table then the epoch
        % has finished
        HasData = ~(MiniBatchIDX == NumBatches);
        FirstIteration = false;

        if RescaleLossEpoch == 0
            WantUpdateLossPrior = true;
        end
    end

    if mod(Epoch+1,RescaleLossEpoch) == 1 || RescaleLossEpoch == 1 || RescaleLossEpoch == 0
        WantUpdateLossPrior = true;
    end

Epoch = Epoch + 1;
end

%% Save Final Current Iteration
% Save Networks
cgg_saveNetworks(Encoder,Decoder,Classifier,WantSaveNet,...
    SaveDir,false);
% Save Iteration Parameters
cgg_saveIterationInformation(Iteration,Epoch,Run,...
    Monitor_Values.MaximumValidationAccuracy,...
    Monitor_Values.AggregateValidationAccuracy,...
    Monitor_Values.MinimumValidationLoss,...
    Iteration-1,SaveDir,Timer,OptimizerVariables,...
    false);

end

