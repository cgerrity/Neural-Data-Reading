function cfg = PARAMETERS_cgg_runAutoEncoder(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

%%

% Epoch='Synthetic_1';
% Epoch='Synthetic_Simple';
Epoch='Decision';
% Target = 'SharedFeatureCoding';
Target = 'Dimension';
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
RescaleLossEpoch = 1;
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']
Optimizer = 'ADAM'; % Name of Optimizer ['ADAM', 'SGD']
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
L2Factor = 1e-4;

NumEpochsFull_Final = 1000;

%% Network Freezing Parameters

Freeze_cfg = struct();
Freeze_cfg.Encoder.DelayEpochs = 25;
Freeze_cfg.Encoder.RampEpochs = 50;
Freeze_cfg.Decoder.DelayEpochs = 25;
Freeze_cfg.Decoder.RampEpochs = 50;
Freeze_cfg.Classifier.DelayEpochs = 25;
Freeze_cfg.Classifier.RampEpochs = 50;

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

end

