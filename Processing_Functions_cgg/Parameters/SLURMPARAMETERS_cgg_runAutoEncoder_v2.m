function cfgSLURM = SLURMPARAMETERS_cgg_runAutoEncoder(SLURMChoice,SLURMIDX)
%SLURMPARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

Fold = 1;
ModelName = 'GRU';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [1000,500,250];
InitialLearningRate = 0.01;
WeightReconstruction = 100;
WeightKL = 1;
WeightClassification = 1;
MiniBatchSize = 100;
GradientThreshold=100;
Subset = true;
Epoch = 'Decision';
Target = 'Dimension';
WeightedLoss = 'Inverse';
Optimizer = 'ADAM';
ClassifierName = 'Deep LSTM - Dropout 0.5';
ClassifierHiddenSize=[250,100,50];
STDChannelOffset = 0.3;
STDWhiteNoise = 0.15;
STDRandomWalk = 0.007;
NumEpochsAutoEncoder=0;
NumEpochsFull = 10;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=100;
L2Factor = 1e-4;
Dropout = 0.5;
WantNormalization = false;
Activation = '';
IsVariational = true;
BottleNeckDepth = 1;

switch SLURMChoice

%% SLURM Choice 1
    case 1

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 2
    case 2

Dropout = {0;0.25;0.9;0.75;0.5;0.5;0.5;0.5;0.5;0.5};
IsVariational = {true;true;true;true;false;true;true;true;true;true};
BottleNeckDepth = {1;1;1;1;1;2;3;1;1;1};
GradientThreshold = {100;100;100;100;100;100;100;0.1;1;10};

%% SLURM Choice 3
    case 3

DataWidth = num2cell(repmat(DataWidth,[10,1]));
WindowStride = num2cell(repmat(WindowStride,[10,1]));
WeightedLoss = repmat({WeightedLoss},[10,1]);

CurrentIDX = 1;
DataWidth{CurrentIDX} = 200; WindowStride{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;
DataWidth{CurrentIDX} = 50; WindowStride{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;
DataWidth{CurrentIDX} = 20; WindowStride{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
DataWidth{CurrentIDX} = 10; WindowStride{CurrentIDX} = 5;
CurrentIDX = CurrentIDX +1;
DataWidth{CurrentIDX} = 1; WindowStride{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
WindowStride{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
WindowStride{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;
WindowStride{CurrentIDX} = 75;
CurrentIDX = CurrentIDX +1;
WindowStride{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;
WeightedLoss{CurrentIDX} = '';


%% SLURM Choice 4
    case 4

HiddenSizes = repmat({HiddenSizes},[10,1]);

CurrentIDX = 1;
HiddenSizes{CurrentIDX} = [2000,1000,500];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [4000,2000,1000];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [500,250,100];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [2000,1000,500,250];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [1000,500,250,100];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [4000,2000,1000,500,250];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [1000,500,250,100,50];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [500,250];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = [1000,500];
CurrentIDX = CurrentIDX +1;
HiddenSizes{CurrentIDX} = 1000;

%% SLURM Choice 5
    case 5

ClassifierHiddenSize = repmat({ClassifierHiddenSize},[10,1]);

CurrentIDX = 1;
ClassifierHiddenSize{CurrentIDX} = [500,250,100];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [100,50,25];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [50,25,10];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [500,250,100,50];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [250,100,50,25];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [1000,500,250,100,50];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [250,100,50,25,10];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [250,100];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = [100,50];
CurrentIDX = CurrentIDX +1;
ClassifierHiddenSize{CurrentIDX} = 250;

%% SLURM Choice 6
    case 6

MiniBatchSize = repmat({MiniBatchSize},[10,1]);
InitialLearningRate = repmat({InitialLearningRate},[10,1]);

CurrentIDX = 1;
MiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
MiniBatchSize{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;
MiniBatchSize{CurrentIDX} = 50;
CurrentIDX = CurrentIDX +1;
MiniBatchSize{CurrentIDX} = 200;
CurrentIDX = CurrentIDX +1;
MiniBatchSize{CurrentIDX} = 400;
CurrentIDX = CurrentIDX +1;
InitialLearningRate{CurrentIDX} = 5e-2;
CurrentIDX = CurrentIDX +1;
InitialLearningRate{CurrentIDX} = 5e-3;
CurrentIDX = CurrentIDX +1;
InitialLearningRate{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;
InitialLearningRate{CurrentIDX} = 5e-4;
CurrentIDX = CurrentIDX +1;
InitialLearningRate{CurrentIDX} = 1e-4;

%% SLURM Choice 7
    case 7

WeightReconstruction = repmat({WeightReconstruction},[10,1]);
WeightKL = repmat({WeightKL},[10,1]);
WeightClassification = repmat({WeightClassification},[10,1]);

CurrentIDX = 1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1; 
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 2; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 10; 
    WeightKL{CurrentIDX} = 1; 
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1; 
    WeightClassification{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1; 
    WeightClassification{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 100; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-3; 
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-2; 
    WeightClassification{CurrentIDX} = 1;

%% SLURM Choice 8
    case 8

Optimizer = repmat({Optimizer},[10,1]);
Normalization = repmat({Normalization},[10,1]);
LossType_Decoder = repmat({LossType_Decoder},[10,1]);

CurrentIDX = 1;
    Optimizer{CurrentIDX} = 'SGD';
CurrentIDX = CurrentIDX +1;
    Normalization{CurrentIDX} = 'None';
CurrentIDX = CurrentIDX +1;
    Normalization{CurrentIDX} = 'Channel - Z-Score - Global - MinMax - [-1,1]';
CurrentIDX = CurrentIDX +1;
    Normalization{CurrentIDX} = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered';
CurrentIDX = CurrentIDX +1;
    Normalization{CurrentIDX} = 'Channel - Z-Score';
CurrentIDX = CurrentIDX +1;
    Normalization{CurrentIDX} = 'Global - MinMax - [-1,1]';
CurrentIDX = CurrentIDX +1;
    Normalization{CurrentIDX} = 'MAE';

%% SLURM Choice Default
    otherwise

Fold = {1;2;3;4;5;6;7;8;9;10};
NumEpochsFull = 500;

end

%%

VariableNames = {'Fold','ModelName','DataWidth','WindowStride',...
    'HiddenSizes','InitialLearningRate','WeightReconstruction',...
    'WeightKL','WeightClassification','MiniBatchSize','Subset',...
    'Target','Epoch','WeightedLoss','GradientThreshold',...
    'ClassifierName','ClassifierHiddenSize','STDChannelOffset',...
    'STDWhiteNoise','STDRandomWalk','NumEpochsAutoEncoder',...
    'NumEpochsFull','Optimizer','Normalization','LossType_Decoder',...
    'LossType_Classifier','maxworkerMiniBatchSize','L2Factor',...
    'Dropout','WantNormalization','Activation','IsVariational','BottleNeckDepth'};

%%

cfgSLURM = struct();

for vidx = 1:length(VariableNames)
    this_VariableName = VariableNames{vidx};
    this_Variable = eval(this_VariableName);

    if iscell(this_Variable)
        this_NumVariable = length(this_Variable);
        this_SLURMIDX = mod(SLURMIDX-1,this_NumVariable)+1;
        this_Variable = this_Variable{this_SLURMIDX};
    end

    cfgSLURM.(this_VariableName) = this_Variable;
end


% disp(cfgSLURM);
% disp(datetime);

end

