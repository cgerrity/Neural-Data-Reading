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
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=100;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

MiniBatchSize = [1,2,5,10,20,25,50,75,100,200];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice 2
    case 2
Fold = 1;
ModelName = 'LSTM';
DataWidth = 2;
WindowStride = 1;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 200;
GradientThreshold=100;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'Deep LSTM';
ClassifierHiddenSize=[250,250,1];

HiddenSizes = {[500,250];[2,1,250];[4,2,250];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};

%% SLURM Choice 3
    case 3
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=10;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

HiddenSizes = {[500,250];[20,10,250];[20,10,500];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};
MiniBatchSize = [50,5,5,50,50];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice 4
    case 4
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=20;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

HiddenSizes = {[500,250];[20,10,250];[20,10,500];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};
MiniBatchSize = [50,5,5,50,50];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice 5
    case 5
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=50;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

HiddenSizes = {[500,250];[20,10,250];[20,10,500];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};
MiniBatchSize = [50,5,5,50,50];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice 6
    case 6
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=100;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

HiddenSizes = {[500,250];[20,10,250];[20,10,500];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};
MiniBatchSize = [50,5,5,50,50];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice 7
    case 7
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=200;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

HiddenSizes = {[500,250];[20,10,250];[20,10,500];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};
MiniBatchSize = [50,5,5,50,50];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice 8
    case 8
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.001;
LossFactorReconstruction = NaN;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=500;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

HiddenSizes = {[500,250];[20,10,250];[20,10,500];[500,250];[500,250]};
Target = {'Dimension';'SharedFeatureCoding'};
ModelName = {'LSTM';'Multi-Filter Convolution';'Convolution';'Variational GRU - Dropout 0.5';'Variational Feedforward - Softplus - Dropout 0.5'};
MiniBatchSize = [50,5,5,50,50];
MiniBatchSize = num2cell(MiniBatchSize');

%% SLURM Choice Default
    otherwise
Fold = 1;
ModelName = 'LSTM';
DataWidth = 100;
WindowStride = 50;
HiddenSizes = [500,250];
InitialLearningRate = 0.01;
LossFactorReconstruction = 1;
LossFactorKL = NaN;
MiniBatchSize = 10;
GradientThreshold=1;
Subset = true;
Target = 'Dimension';
WeightedLoss = 'Inverse';
ClassifierName = 'LSTM';
ClassifierHiddenSize=[1];

end

VariableNames = {'Fold','ModelName','DataWidth','WindowStride',...
    'HiddenSizes','InitialLearningRate','LossFactorReconstruction',...
    'LossFactorKL','MiniBatchSize','Subset','Target','WeightedLoss',...
    'GradientThreshold','ClassifierName','ClassifierHiddenSize'};

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


disp(cfgSLURM);
disp(datetime);

end

