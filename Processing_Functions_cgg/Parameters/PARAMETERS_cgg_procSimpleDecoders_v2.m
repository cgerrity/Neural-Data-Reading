function cfg = PARAMETERS_cgg_procSimpleDecoders_v2
%PARAMETERS_CGG_PROCSIMPLEDECODERS_V2 Summary of this function goes here
%   Detailed explanation goes here

%%

Epoch='Decision';

%%

Decoder={'Logistic','SVM','Gaussian-Logistic','Gaussian-SVM','NaiveBayes'};
Dimension = 1:4;

wantZeroFeatureDetector=false;

DataWidth = 50;
StartingIDX = 'All';
EndingIDX = 'All';
WindowStride = 50;
NumFolds = 10;

WantRandomize = false;

ARModelOrder=10;

cfg_PreProcessing = PARAMETERS_cgg_proc_NeuralDataPreparation('SessionName','none');

SamplingFrequency = cfg_PreProcessing.rect_samprate;

%% K-Fold Splitting

AllSplitNames=cell(0);

SplitNames=string;
SplitNames(1)="Dimension 1";
SplitNames(2)="Dimension 2";
SplitNames(3)="Dimension 3";
SplitNames(4)="Dimension 4";
AllSplitNames{1}=SplitNames;

SplitNames=string;
SplitNames(1)="ACC_001";
SplitNames(2)="ACC_002";
SplitNames(3)="PFC_001";
SplitNames(4)="PFC_002";
SplitNames(5)="CD_001";
SplitNames(6)="CD_002";
AllSplitNames{2}=SplitNames;

SplitNames=string;
SplitNames(1)="Correct Trial";
AllSplitNames{3}=SplitNames;

SplitNames=string;
SplitNames(1)="Gain";
SplitNames(2)="Loss";
AllSplitNames{4}=SplitNames;

SplitNames=string;
SplitNames(1)="Learned";
AllSplitNames{5}=SplitNames;

SplitNames=string;
SplitNames(1)="Session Name";
AllSplitNames{6}=SplitNames;

SplitNames=string;
SplitNames(1)="Trial Chosen";
AllSplitNames{7}=SplitNames;

% SplitNames=string;
% SplitNames(1)="Previous Trial";
% AllSplitNames{8}=SplitNames;

%%
NumIter=4;

wantTrain = true;
wantTest = true;

MatchType = 'combinedaccuracy';

%%
SubsetAmount=940;
SessionSubset='Fr_Probe_03_22_07_13_002_01';

NumKPartitions=20;

NumObsPerChunk = 100;
NumChunks = 4;
NumEpochs = 1;

%%
wantSubset = true;

wantStratifiedPartition = true;

wantTrialChosen = false;

%% Importance Analysis

wantIA = false;

IADecoder = 'SVM';

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end


end

