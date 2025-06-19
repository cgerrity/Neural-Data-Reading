function cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

%%

Epoch='Decision';
Target = 'Dimension';

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

%%

HiddenSizes=[1000,500,250];
ClassifierHiddenSize=[250,100,50];
NumEpochsAutoEncoder = 0;
MiniBatchSize = 100;
GradientThreshold = 100;
NumEpochsFull = 100;
InitialLearningRate = 0.01;
WeightReconstruction = 1;
WeightKL = 1e-4;
WeightClassification = 1000;
RescaleLossEpoch = 1;
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']
Optimizer = 'ADAM'; % Name of Optimizer ['ADAM', 'SGD']
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
L2Factor = 1e-4;

maxworkerMiniBatchSize=100;

%% Data Augmentation Parameters

STDChannelOffset = 0.3;
STDWhiteNoise = 0.15;
STDRandomWalk = 0.007;

%%

wantSubset = true;

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

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

end

