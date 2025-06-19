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

MessageAlreadyTrained = '!!! Network trained to maximum number of epochs\n';

%% No Epochs
% End the function if the number of training epochs is less than 1

if NumEpochs < 1
    return
end

%% Identify the Networks

HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);

%% Get Initial values

% Initialize Epoch and Iteration counters
[Iteration,Epoch,Run,MaximumValidationAccuracy,...
    MinimumValidationLoss,OptimizerVariables] = ...
    cgg_getIterationInformation(SaveDir,NumEpochs);

if Epoch > NumEpochs
    fprintf(MessageAlreadyTrained);
    return
end

OptimizerVariables = cgg_initializeAllOptimizerVariables(Optimizer,...
    OptimizerVariables);
[Weights,ClassNames] = cgg_getWeightsForLoss(DataStore_Training,...
    WeightedLoss);

%% Generate Monitors

MonitorTable = cgg_generateAllMonitors(cfg_Monitor,Run);
Monitor_Values = cgg_initializeMonitorValues([],DataStore_Training,DataFormat,IsQuaddle,cfg_Monitor,'Training');
Monitor_Values = cgg_initializeMonitorValues(Monitor_Values,DataStore_Validation,DataFormat,IsQuaddle,cfg_Monitor,'Validation');
Monitor_Values.MaximumValidationAccuracy = MaximumValidationAccuracy;
Monitor_Values.MinimumValidationLoss = MinimumValidationLoss;
%% Establish Loss Functions

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
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,'L2Factor',L2Factor);
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
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,'L2Factor',L2Factor);
ModelLoss_Testing = ...
    @(Encoder_Net,Decoder_Net,Classifier_Net,LossInformation_Var,...
    WeightKL_Var) ...
    cgg_lossComponents(Encoder_Net,Decoder_Net,Classifier_Net,...
    DataStore_Testing,'Weights',Weights,'DataFormat',DataFormat,...
    'wantPredict',true,'wantLoss',false,'IsQuaddle',IsQuaddle,...
    'WantGradient',false,'WantUpdateLossPrior',false,...
    'LossInformation',LossInformation_Var,...
    'WeightReconstruction',WeightReconstruction,'WeightKL',WeightKL_Var,...
    'WeightClassification',WeightClassification,...
    'ClassNames',ClassNames,'LossType_Decoder',LossType_Decoder,...
    'DataType','Testing',...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,'L2Factor',L2Factor);

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

        % Get Datastore for only the mini-batch size desired
        [this_DataStore_Training,SessionName,SessionNumber] = ...
            cgg_getCurrentIterationDataStore(MiniBatchTable,...
            MiniBatchIDX,DataStore_Training);
    
        %% Calculate Loss and Gradients
        [LossInformation_Training,CM_Table_Training,Gradients] = ...
            dlfeval(ModelLoss_Training,this_DataStore_Training,...
            Encoder,Decoder,Classifier,...
            LossInformation_Training,WantUpdateLossPrior,WeightKL_Anneal);
        WantUpdateLossPrior = false;
    
        %% Update Gradient Threshold
        Gradients_PreThreshold = Gradients;
        Gradients.Encoder = cgg_calcGradientThreshold(Gradients.Encoder,GradientThreshold);

        % Update Networks using gradients
        [Encoder,OptimizerVariables.Encoder] = cgg_procUpdateNetworks(...
            Encoder,Gradients.Encoder,LearningRate,Optimizer,OptimizerVariables.Encoder);

        if HasDecoder
        % Update Gradient Threshold
        Gradients.Decoder = cgg_calcGradientThreshold(Gradients.Decoder,GradientThreshold);

        % Update Networks using gradients
        [Decoder,OptimizerVariables.Decoder] = cgg_procUpdateNetworks(...
            Decoder,Gradients.Decoder,LearningRate,Optimizer,OptimizerVariables.Decoder);
        end

        if HasClassifier
        % Update Gradient Threshold
        Gradients.Classifier = cgg_calcGradientThreshold(Gradients.Classifier,GradientThreshold);

        % Update Networks using gradients
        [Classifier,OptimizerVariables.Classifier] = cgg_procUpdateNetworks(...
            Classifier,Gradients.Classifier,LearningRate,Optimizer,OptimizerVariables.Classifier);
        end

        %% Get Measures

        if mod(Iteration,ValidationFrequency)==1 || FirstIteration || ValidationFrequency == 1
        [LossInformation_Validation,CM_Table_Validation,~] = ...
            ModelLoss_Validation(Encoder,Decoder,Classifier,LossInformation_Training,WeightKL_Anneal);
        FirstIteration = false;
        else
            LossInformation_Validation = [];
            CM_Table_Validation = [];
        end
    
        %% Update Monitors
        [Monitor_Values,IsOptimal] = cgg_calcAllMonitorValues(...
            Monitor_Values,Encoder,Decoder,Classifier,Epoch,Iteration,...
            LearningRate,...
            LossInformation_Training,LossInformation_Validation,...
            CM_Table_Training,CM_Table_Validation,...
            Gradients,Gradients_PreThreshold);
        %% Only Get Optimal Network for Annealed Weights
        if Epoch < WeightDelayEpoch + WeightEpochRamp
            IsOptimal = false;
        end

        %%
        SaveAll = mod(Iteration,SaveFrequency)==1 || SaveFrequency == 1;
        cgg_updateAllMonitors(MonitorTable,Monitor_Values,SaveAll);

        %% Save Monitors when optimal condition is met
        if IsOptimal
        cgg_saveAllMonitors(MonitorTable,true,true);            
        end

        %% Save Monitors at set times
        cgg_saveAllMonitors(MonitorTable,false,SaveAll);

        %% Save Networks
        SaveNetwork = WantSaveNet && SaveAll;
        cgg_saveNetworks(Encoder,Decoder,Classifier,SaveNetwork,...
            SaveDir,IsOptimal);

        %% Save Validation Information
        cgg_saveValidationCMTable(CM_Table_Validation,IsOptimal,SaveDir);

        %% Save Testing Information
        cgg_saveCMTableFromSeparateNetwork(ModelLoss_Testing,...
            Encoder,Decoder,Classifier,LossInformation_Training,WeightKL_Anneal,...
            IsOptimal,SaveDir);

        %% Save Iteration Parameters
        cgg_saveIterationInformation(Iteration,Epoch,Run,...
            Monitor_Values.MaximumValidationAccuracy,...
            Monitor_Values.MinimumValidationLoss,...
            IterationSaveFrequency,SaveDir,Timer,OptimizerVariables,...
            IsOptimal);
%%
        % If the MiniBatchIDX reaches the end of the table then the epoch
        % has finished
        HasData = ~(MiniBatchIDX == NumBatches);
    end

    if mod(Epoch+1,RescaleLossEpoch) == 1 || RescaleLossEpoch == 1
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
    Monitor_Values.MinimumValidationLoss,...
    Iteration-1,SaveDir,Timer,OptimizerVariables,...
    false);

end

