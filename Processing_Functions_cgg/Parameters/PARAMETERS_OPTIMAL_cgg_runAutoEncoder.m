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

HiddenSizes=[1000,500,250];
ClassifierHiddenSize=[250,100,50];
NumEpochsBase=0;
NumEpochsAutoEncoder = NumEpochsBase;
MiniBatchSize=100;
GradientThreshold=100;
NumEpochsSession=500;
NumEpochsFull = NumEpochsSession;
InitialLearningRate = 0.01;
LossFactorReconstruction = 100;
WeightReconstruction = LossFactorReconstruction;
LossFactorKL = 1;
WeightKL = LossFactorKL;
WeightClassification = 1;
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']
Optimizer = 'ADAM'; % Name of Optimizer ['ADAM', 'SGD']
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';

RescaleLossEpoch = 1;

maxworkerMiniBatchSize=10;


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

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

end

