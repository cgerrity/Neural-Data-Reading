function cfg = PARAMETERS_cgg_runAutoEncoder(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Decision';
end
end

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
end

if isfunction
ParameterSetName = CheckVararginPairs('ParameterSetName', 'Default', varargin{:});
else
if ~(exist('ParameterSetName','var'))
ParameterSetName='Default';
end
end
%%

% Epoch='Synthetic_1';
% Epoch='Synthetic_Simple';
% Epoch='Decision';
% Target = 'SharedFeatureCoding';
% Target = 'Dimension';
% Target = 'Trial Outcome';

%%

% DataWidth = 400;
DataWidth = 100;
% StartingIDX = ((-0.4+1.5)/3*3000);
% EndingIDX = StartingIDX;
StartingIDX = 'All';
EndingIDX = 'All';
% WindowStride = 'All';
WindowStride = 50;
StartEndPercent = [NaN,NaN];

%%

% ModelName = 'LSTM - Normalized';
% ModelName = 'Variational LSTM - Dropout 0.5';
% ModelName = 'Feedforward - ReLU';
ModelName = 'Variational GRU - Dropout 0.5';
ModelName = 'GRU';
% ModelName = 'Variational Feedforward - ReLU';
% ModelName = 'Feedforward - ReLU - Normalized - Dropout 0.5';
% ModelName = 'Variational Convolutional Multi-Filter [3,5,7] - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM';
% ModelName = 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM';
% ClassifierName = 'Deep Feedforward - Dropout 0.5';
ClassifierName = 'Deep LSTM - Dropout 0.5';

%%
Dropout = 0.5;
WantNormalization = false;
Activation = '';
IsVariational = true;
BottleNeckDepth = 1;
EncoderOutputType = 'Deterministic'; %'Stochastic', 'Deterministic'
%%

% HiddenSizes=[1500,750,300,150];
HiddenSizes=[1000,500,250];
ClassifierHiddenSize=[250,100,50];
NumEpochsAutoEncoder = 0;
MiniBatchSize = 100;
GradientThreshold = 100;
GradientClipType = 'SubNetwork';
NumEpochsFull = 100;
InitialLearningRate = 0.01;
WeightReconstruction = 100;
WeightKL = 0.1; % WeightKL = 1;
WeightClassification = 1000; % WeightClassification = 1;
WeightOffsetAndScale = 0;
WeightConfidence = 0;
RescaleLossEpoch = 1;
PriorProportion = 0; % Proportion of prior loss to keep when normalizing loss values
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']
Optimizer = 'ADAM'; % Name of Optimizer ['ADAM', 'SGD']
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
MultipleInstanceLearningType = 'None'; % 'MIL'
ConfidenceType = ''; % "Trial", "Task", ["Trial", "Task"]
WantBatchCorrection=false;
L2Factor = 1e-4;

NumEpochsFull_Final = 1000;

%%

StitchingAndFusionLayer = ''; % 'Default'

%% Dynamic Weight Augmentation Parameters

% DynamicWeighting = struct();
% DynamicWeighting.Reconstruction.EpochPoints = [100,100];
% DynamicWeighting.Reconstruction.MagnitudePoints = [1,1];
% DynamicWeighting.KL.EpochPoints = [100,100];
% DynamicWeighting.KL.MagnitudePoints = [1,1];
% DynamicWeighting.Classification.EpochPoints = [100,100];
% DynamicWeighting.Classification.MagnitudePoints = [1e-4,1];

%% Network Freezing Parameters

Freeze_cfg = struct();
% Freeze_cfg.Encoder.DelayEpochs = 25;
% Freeze_cfg.Encoder.RampEpochs = 50;
% Freeze_cfg.Decoder.DelayEpochs = 25;
% Freeze_cfg.Decoder.RampEpochs = 50;
% Freeze_cfg.Classifier.DelayEpochs = 25;
% Freeze_cfg.Classifier.RampEpochs = 50;
% 

% DynamicFreezing = struct();
% DynamicFreezing.EpochPoints = [0,25,50];
% DynamicFreezing.MagnitudePoints = [0,0,1];

% Freeze_cfg.Encoder.EpochPoints = [100,100];
% Freeze_cfg.Encoder.MagnitudePoints = [1,1];
% Freeze_cfg.Decoder.EpochPoints = [100,100];
% Freeze_cfg.Decoder.MagnitudePoints = [1,1];
% Freeze_cfg.Classifier.EpochPoints = [100,100];
% Freeze_cfg.Classifier.MagnitudePoints = [1e-2,1];

%% Set Gradient Accumulation size depending on the system
maxworkerMiniBatchSize=100;

% AccumulationInformation = struct('Name',[],'Value',[]);
AccumulationInformation = {...
    "CPU",maxworkerMiniBatchSize;...
    "NVIDIA TITAN X (Pascal)",20;...
    "NVIDIA TITAN Xp",20;...
    "NVIDIA RTX A6000",20;...
    };

AccumulationInformation = struct(...
    'SystemName', AccumulationInformation(:,1), ...
    'MaxBatchSize', AccumulationInformation(:,2));


%% Data Augmentation Parameters

STDChannelOffset = 0.3;
STDWhiteNoise = 0.15;
STDRandomWalk = 0.007;
STDTimeShift = NaN;
WantSeparateTimeShift = false;
% STDChannelOffset = 0.6;
% STDWhiteNoise = 0.15;
% STDRandomWalk = 0.014;
% STDChannelOffset = NaN;
% STDWhiteNoise = NaN;
% STDRandomWalk = NaN;
% STDChannelOffset = 0.15;
% STDWhiteNoise = 0.007;
% STDRandomWalk = 0.0003;

%% Dynamic Data Augmentation Parameters

% DynamicAugmentation = struct();
% DynamicAugmentation.EpochPoints = [100,100];
% DynamicAugmentation.MagnitudePoints = [1e-2,1];
% DynamicAugmentation.EpochPoints = [50,100,100,200];
% DynamicAugmentation.MagnitudePoints = [1,1e-2,1,1e-2];

%% Dynamic Parameters
DynamicParameterSet = "Soft Two-Stage Curriculum";
[DynamicAugmentation, DynamicWeighting, DynamicFreezing, ...
    DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(...
    DynamicParameterSet);

%%

Subset = true;

wantStratifiedPartition = true;

MatchType_Accuracy_Measure = 'macroF1';

WantSaveNet = false;
WantSaveOptimalNet = true;
%% Learning Rate Parameters

LearningRateDecay = 0.9;
LearningRateEpochDrop = 30;
LearningRateEpochRamp = 5;

%% KL Annealing Parameters

WeightDelayEpoch = 15;
WeightEpochRamp = 10;

%% Validation and Saving

ValidationFrequency = 25;
SaveFrequency = 25;
IterationSaveFrequency = 25;

%% Monitoring

WantProgressMonitor = true;
WantExampleMonitor = true;
WantComponentMonitor = true;
WantAccuracyMonitor = true;
WantWindowMonitor = true;
WantReconstructionMonitor = true;
WantGradientMonitor = true;

AccuracyMeasures = {'Scaled_BalancedAccuracy','combinedaccuracy','macroF1'};


%% Renaming for outdated functions

NumEpochsBase = NumEpochsAutoEncoder;
NumEpochsSession = NumEpochsFull;

LossFactorReconstruction = WeightReconstruction;
LossFactorKL = WeightKL;
wantSubset = Subset;

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

%%
switch Epoch
    case 'Synthetic_Easy'
        ParameterSetName = 'Synthetic_Easy';
    case 'Synthetic'
        ParameterSetName = 'Synthetic_Easy';
    case 'Synthetic_Easy_SmallSize'
        ParameterSetName = 'Synthetic_Easy';
    % case 'Dimension'
    %     ParameterSetName = 'Optimal';
    otherwise
end

%%

cfg_ParameterSet = struct();
switch ParameterSetName
    case 'Dimension'
        cfg_ParameterSet = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v3('Epoch',Epoch,'Target',Target);
    case 'Synthetic_Easy'
        cfg_ParameterSet = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_SyntheticEasy('Epoch',Epoch,'Target',Target);
    case 'Optimal'
        cfg_ParameterSet = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v3('Epoch',Epoch,'Target',Target);
    case 'Decision'
        cfg_ParameterSet = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v3('Epoch',Epoch,'Target',Target);
    case 'Prior Optimal'
        cfg_ParameterSet = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2('Epoch',Epoch,'Target',Target);
    case 'Default'
    otherwise
end

cfg = cgg_mergeStructs(cfg_ParameterSet,cfg);

cfg.ParameterSetName = ParameterSetName;

%%
[cfg.DynamicAugmentation, cfg.DynamicWeighting, cfg.DynamicFreezing, ...
    cfg.DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(...
    cfg.DynamicParameterSet);
%% Baseline Dynamic Parameters
% Used when comparing different hyperparameters. No augmentation or
% weighting, has both but no dynamics, has both and has dynamics. When
% testing for multiple values of these parameters there should be a way to
% look at these baseline parameters while also changing them individually

cfg.BaselineDynamicParameters = cgg_setBaselineDynamicParameters(cfg);
%%
cfg.NumEpochsBase = cfg.NumEpochsAutoEncoder;
cfg.NumEpochsSession = cfg.NumEpochsFull;

cfg.LossFactorReconstruction = cfg.WeightReconstruction;
cfg.LossFactorKL = cfg.WeightKL;
cfg.wantSubset = cfg.Subset;

%%
if isfield(cfg,'StitchingAndFusionLayer')
if ~strcmp(string(cfg.StitchingAndFusionLayer),"") && length(cfg.HiddenSizes) >=3 && cfg.HiddenSizes(1) >=500
AccumulationInformation = {...
    "CPU",cfg.maxworkerMiniBatchSize;...
    "NVIDIA TITAN X (Pascal)",2;...
    "NVIDIA TITAN Xp",2;...
    "NVIDIA RTX A4000",2;...
    "NVIDIA RTX A6000",2;...
    };

cfg.AccumulationInformation = struct(...
    'SystemName', AccumulationInformation(:,1), ...
    'MaxBatchSize', AccumulationInformation(:,2));
end
end

if length(cfg.ClassifierHiddenSize) <=3 && cfg.HiddenSizes(1) <=400
AccumulationInformation = {...
    "CPU",cfg.maxworkerMiniBatchSize;...
    "NVIDIA TITAN X (Pascal)",50;...
    "NVIDIA TITAN Xp",50;...
    "NVIDIA RTX A4000",50;...
    "NVIDIA RTX A6000",50;...
    };

cfg.AccumulationInformation = struct(...
    'SystemName', AccumulationInformation(:,1), ...
    'MaxBatchSize', AccumulationInformation(:,2));
end

if contains(ParameterSetName,'Synthetic')
AccumulationInformation = {...
    "CPU",cfg.maxworkerMiniBatchSize;...
    "NVIDIA TITAN X (Pascal)",cfg.maxworkerMiniBatchSize;...
    "NVIDIA TITAN Xp",cfg.maxworkerMiniBatchSize;...
    "NVIDIA RTX A4000",cfg.maxworkerMiniBatchSize;...
    "NVIDIA RTX A6000",cfg.maxworkerMiniBatchSize;...
    };

cfg.AccumulationInformation = struct(...
    'SystemName', AccumulationInformation(:,1), ...
    'MaxBatchSize', AccumulationInformation(:,2));
end
%%

if isfield(cfg,'varargin')
cfg = rmfield(cfg,'varargin');
end

end

