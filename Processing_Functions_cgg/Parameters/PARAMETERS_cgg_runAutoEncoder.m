function cfg = PARAMETERS_cgg_runAutoEncoder(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

%%

% Epoch='Synthetic';
Epoch='Decision';
% Target = 'SharedFeatureCoding';
Target = 'Dimension';

%%

% DataWidth = 400;
DataWidth = 2;
% StartingIDX = ((-0.4+1.5)/3*3000);
% EndingIDX = StartingIDX;
StartingIDX = 'All';
EndingIDX = 'All';
% WindowStride = 'All';
WindowStride = 1;

%%

ModelName = 'LSTM';
ClassifierName = 'Deep LSTM';

% HiddenSizes=[5000,2500,1000,500];
HiddenSizes=[1000,500];
ClassifierHiddenSize=[500,500,1];
NumEpochsBase=500;
MiniBatchSize=200;
GradientThreshold=100;
NumEpochsSession=500;
InitialLearningRate = 0.001;
LossFactorReconstruction = 1000;
LossFactorKL = NaN;
WeightedLoss = 'Inverse'; % Name of type of weighted loss ['', 'Inverse']

%%

wantSubset = true;

wantStratifiedPartition = true;

MatchType_Accuracy_Measure = 'macroF1';

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

end

