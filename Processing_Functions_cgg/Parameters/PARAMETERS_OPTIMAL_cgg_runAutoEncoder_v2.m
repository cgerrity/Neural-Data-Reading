function cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2(varargin)
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
%%

% Epoch='Decision';
% Target = 'Dimension';

ParameterSetName = 'Prior Optimal';

%%

DataWidth = 100;
StartingIDX = 'All';
EndingIDX = 'All';
WindowStride = 50;

%%

ModelName = 'GRU';
ClassifierName = 'Deep LSTM - Dropout 0.5';

%%
Dropout = 0.5;
WantNormalization = false;
Activation = '';
IsVariational = true;
BottleNeckDepth = 1;
EncoderOutputType = 'Deterministic'; %'Stochastic', 'Deterministic'

%%

HiddenSizes=[1000,500,250];
ClassifierHiddenSize=[250,100,50];
NumEpochsAutoEncoder = 0;
MiniBatchSize = 100;
GradientThreshold = 100;
GradientClipType = 'SubNetwork'; %['SubNetwork','Global']
NumEpochsFull = 100;
InitialLearningRate = 0.01;
WeightReconstruction = 100;
WeightKL = 0.1; % WeightKL = 1;
WeightClassification = 1000; % WeightClassification = 1;
WeightOffsetAndScale = 0;
RescaleLossEpoch = 1;
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']
Optimizer = 'ADAM'; % Name of Optimizer ['ADAM', 'SGD']
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
MultipleInstanceLearningType = 'None'; % 'MIL'
L2Factor = 1e-4;

NumEpochsFull_Final = 1000;

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
% DynamicFreezing.EpochPoints = [0,25,50];
% DynamicFreezing.MagnitudePoints = [0,0,1];

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
WantSaveOptimalNet = false;

%% Learning Rate Parameters

LearningRateDecay = 0.9;
LearningRateEpochDrop = 30;
LearningRateEpochRamp = 5;

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
        cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_SyntheticEasy('Epoch',Epoch,'Target',Target);
    otherwise
end

%%

[cfg.DynamicAugmentation, cfg.DynamicWeighting, cfg.DynamicFreezing, ...
    cfg.DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(...
    cfg.DynamicParameterSet);

%%

if isfield(cfg,'varargin')
cfg = rmfield(cfg,'varargin');
end
end

