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

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 2
    case 2
Fold = 1;
ModelName = 'Variational GRU - Dropout 0.5';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [1000,500,250];
InitialLearningRate = 0.05;
WeightReconstruction = 1;
WeightKL = 1e-4;
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
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=100;

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 3
    case 3
Fold = 1;
ModelName = 'Variational GRU - Dropout 0.5';
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
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=100;

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 4
    case 4
Fold = 1;
ModelName = 'Variational GRU - Dropout 0.5';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [1000,500,250];
InitialLearningRate = 0.01;
WeightReconstruction = 1;
WeightKL = 1e-4;
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
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=100;

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 5
    case 5
Fold = 1;
ModelName = 'Variational GRU - Dropout 0.5';
DataWidth = 50;
WindowStride = 25;
HiddenSizes = [2000,1000,500,250];
InitialLearningRate = 0.02;
WeightReconstruction = 1;
WeightKL = 1e-4;
WeightClassification = 1;
MiniBatchSize = 200;
GradientThreshold=100;
Subset = true;
Epoch = 'Decision';
Target = 'Dimension';
WeightedLoss = 'Inverse';
Optimizer = 'ADAM';
ClassifierName = 'Deep LSTM - Dropout 0.5';
ClassifierHiddenSize=[500,250,100];
STDChannelOffset = 0.3;
STDWhiteNoise = 0.15;
STDRandomWalk = 0.007;
NumEpochsAutoEncoder=50;
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=100;

Fold = {1;2;3;4;5;6;7;8;9;10};

%% SLURM Choice 6
    case 6
Fold = 1;
ModelName = 'Variational Convolutional Resnet 3x3 - Split Area - Leaky ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh';
DataWidth = 50;
WindowStride = 25;
HiddenSizes = [8,16,32,64,100];
InitialLearningRate = 0.05;
WeightReconstruction = 1;
WeightKL = 1e-7;
WeightClassification = 1;
MiniBatchSize = 100;
GradientThreshold=100;
Subset = true;
Epoch = 'Decision';
Target = 'Dimension';
WeightedLoss = 'Inverse';
Optimizer = 'ADAM';
ClassifierName = 'Deep LSTM - Dropout 0.5';
ClassifierHiddenSize=[100,50,25];
STDChannelOffset = 0.15;
STDWhiteNoise = 0.007;
STDRandomWalk = 0.0003;
NumEpochsAutoEncoder=0;
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=2;

WeightClassification = {0.01;0.05;0.1;0.5;1;2;3;10;20;30};

%% SLURM Choice 7
    case 7
Fold = 1;
ModelName = 'Variational GRU - Dropout 0.25';
DataWidth = 50;
WindowStride = 25;
HiddenSizes = [1000,500,250,100];
InitialLearningRate = 0.01;
WeightReconstruction = 1;
WeightKL = 1e-10;
WeightClassification = 5;
MiniBatchSize = 200;
GradientThreshold=100;
Subset = true;
Epoch = 'Decision';
Target = 'Dimension';
WeightedLoss = 'Inverse';
Optimizer = 'ADAM';
ClassifierName = 'Deep LSTM - Dropout 0.5';
ClassifierHiddenSize=[250,100,50];
STDChannelOffset = 0.15;
STDWhiteNoise = 0.007;
STDRandomWalk = 0.0003;
NumEpochsAutoEncoder=0;
NumEpochsFull = 500;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=10;

HiddenSizes = {[1000,500,250];[2000,1000,500,250];[500,250];[4000,2000,1000,500,250];[1000,500];[500,250,100];[250,100];[1000,500,250,100];[2000,1000,500,250,100];[5000,2500,1000,500]};

%% SLURM Choice 8
    case 8
Fold = 1;
ModelName = 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [1000,500,250,100];
InitialLearningRate = 0.01;
WeightReconstruction = 10;
WeightKL = 1e-5;
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
STDChannelOffset = 0.15;
STDWhiteNoise = 0.007;
STDRandomWalk = 0.0003;
NumEpochsAutoEncoder=6;
NumEpochsFull = 6;
Normalization = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5';
LossType_Decoder = 'MSE';
LossType_Classifier='CrossEntropy';
maxworkerMiniBatchSize=5;

HiddenSizes = {[16,32,64,100];[2,4,8,100];[4,8,16,100];[8,16,32,100];[2,4,8,16,100];[4,8,16,32,100];[8,16,32,64,100];[32,64,100];[16,32,100];[8,16,100]};

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

end

VariableNames = {'Fold','ModelName','DataWidth','WindowStride',...
    'HiddenSizes','InitialLearningRate','WeightReconstruction',...
    'WeightKL','WeightClassification','MiniBatchSize','Subset',...
    'Target','Epoch','WeightedLoss','GradientThreshold',...
    'ClassifierName','ClassifierHiddenSize','STDChannelOffset',...
    'STDWhiteNoise','STDRandomWalk','NumEpochsAutoEncoder',...
    'NumEpochsFull','Optimizer','Normalization','LossType_Decoder',...
    'LossType_Classifier','maxworkerMiniBatchSize'};

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

