function cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

%%

Epoch='Decision';
% Target = 'SharedFeatureCoding';
Target = 'Dimension';

%%

DataWidth = 100;
StartingIDX = 'All';
EndingIDX = 'All';
WindowStride = 50;

%%

ModelName = 'Variational GRU - Dropout 0.5';
ClassifierName = 'Deep LSTM - Dropout 0.5';
EncoderOutputType = 'Deterministic'; %'Stochastic', 'Deterministic'

HiddenSizes=[1000,500,250];
ClassifierHiddenSize=[250,100,50];
NumEpochsBase=0;
NumEpochsAutoEncoder = NumEpochsBase;
MiniBatchSize=100;
GradientThreshold=100;
GradientClipType = 'SubNetwork';
NumEpochsSession=500;
NumEpochsFull = NumEpochsSession;
InitialLearningRate = 0.01;
LossFactorReconstruction = 100;
WeightReconstruction = LossFactorReconstruction;
LossFactorKL = 1;
WeightKL = LossFactorKL;
WeightClassification = 1;
WeightOffsetAndScale = 0;
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']
Optimizer = 'ADAM'; % Name of Optimizer ['ADAM', 'SGD']
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
MultipleInstanceLearningType = 'None'; % 'MIL'

RescaleLossEpoch = 1;

maxworkerMiniBatchSize=10;

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

% DynamicFreezing.EpochPoints = [0,25,50];
% DynamicFreezing.MagnitudePoints = [0,0,1];

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

wantSubset = true;
wantStratifiedPartition = true;
MatchType_Accuracy_Measure = 'macroF1';
WantSaveNet = false;
WantSaveOptimalNet = true;

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

end

