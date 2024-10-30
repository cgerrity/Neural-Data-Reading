function cfgSLURM = SLURMPARAMETERS_cgg_runAutoEncoder(SLURMChoice,SLURMIDX)
%SLURMPARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

% NumRows = 10;
% 
% LossFactorReconstruction_SLURM = [1,50.*((1:(NumRows-1)))];
% LossFactorReconstruction_SLURM = num2cell(LossFactorReconstruction_SLURM');
% InitialLearningRate_SLURM = [10,5,1,0.5,0.1,0.05,0.01,0.005,0.001,0.0005];
% InitialLearningRate_SLURM = num2cell(InitialLearningRate_SLURM');
% 
% SLURMTesting_VariableNames = ["LossFactorReconstruction","InitialLearningRate"];
% SLURMTesting_Variable = {LossFactorReconstruction_SLURM,InitialLearningRate_SLURM};
% 
% %%
% 
% Fold_Default = 1;
% ModelName_Default = 'LSTM';
% DataWidth_Default = 100;
% WindowStride_Default = 50;
% HiddenSizes_Default = {[500,250]};
% InitialLearningRate_Default = 0.01;
% LossFactorReconstruction_Default = 1;
% LossFactorKL_Default = NaN;
% MiniBatchSize_Default = 10;
% Subset_Default = true;
% 
% %%
% 
% Values_Default = {Fold_Default,ModelName_Default,DataWidth_Default,WindowStride_Default,HiddenSizes_Default,InitialLearningRate_Default,LossFactorReconstruction_Default,LossFactorKL_Default,MiniBatchSize_Default,Subset_Default};
% VariableNames = {'Fold','ModelName','DataWidth','WindowStride','HiddenSizes','InitialLearningRate','LossFactorReconstruction','LossFactorKL','MiniBatchSize','Subset'};
% 
% Table_SLURM_Default = splitvars(table(Values_Default));
% Table_SLURM_Default.Properties.VariableNames = VariableNames;
% 
% Table_SLURM_Default = repmat(Table_SLURM_Default,NumRows,1);
% 
% %%
% 
% AllTablesSLURM = cell(1,length(SLURMTesting_VariableNames));
% 
% for tidx=1:length(AllTablesSLURM)
%     this_TablesSLURM = Table_SLURM_Default;
%     this_VariableName = SLURMTesting_VariableNames(tidx);
% 
%     this_TablesSLURM{:,this_VariableName} = SLURMTesting_Variable{tidx};
% 
%     AllTablesSLURM{tidx} = this_TablesSLURM;
% end
% 
% %%
% 
% TableSLURM = AllTablesSLURM{SLURMChoice};
% TableSLURM = TableSLURM(SLURMIDX,:);
% 
% %%

switch SLURMChoice

%% SLURM Choice 1
    case 1
Fold = 1;
ModelName = 'Variational GRU - Dropout 0.5';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [1000,500,250];
InitialLearningRate = 0.01;
WeightReconstruction = 100;
WeightKL = 1;
WeightClassification = 1;
MiniBatchSize = 512;
GradientThreshold=100;
Subset = false;
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
NumEpochsFull = 500;
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

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 2
    case 2
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

Dropout = {0;0.25;0.9;0.75;0.5;0.5;0.5;0.5;0.5;0.5};
IsVariational = {true;true;true;true;false;true;true;true;true;true};
BottleNeckDepth = {1;1;1;1;1;2;3;1;1;1};
GradientThreshold = {100;100;100;100;100;100;100;0.1;1;10};

%% SLURM Choice 3
    case 3
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
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.01;
WeightReconstruction = 1;
WeightKL = NaN;
WeightClassification = 1;
MiniBatchSize = 10;
GradientThreshold=1;
Subset = true;
Epoch = 'Decision';
Target = 'Dimension';
WeightedLoss = 'Inverse';
Optimizer = 'ADAM';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];
STDChannelOffset = 0.3;
STDWhiteNoise = 0.15;
STDRandomWalk = 0.007;
NumEpochsAutoEncoder=50;
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=5;
L2Factor = 1e-4;
Dropout = 0.5;
WantNormalization = false;
Activation = '';
IsVariational = true;
BottleNeckDepth = 1;

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

