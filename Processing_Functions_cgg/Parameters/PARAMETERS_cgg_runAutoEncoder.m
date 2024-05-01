function cfg = PARAMETERS_cgg_runAutoEncoder(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

%%

Epoch='Decision';

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

% HiddenSizes=[5000,2500,1000,500];
HiddenSizes=[50,10];
NumEpochsBase=500;
miniBatchSize=10;
GradientThreshold=1;
NumEpochsSession=500;
InitialLearnngRate = 0.1;

%%

wantSubset = true;

wantStratifiedPartition = true;

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

end

