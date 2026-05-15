function [cfgSLURM,IsInccidentalBaseRepeat] = ...
    SLURMPARAMETERS_cgg_runAutoEncoder_v2(SLURMChoice,SLURMIDX,varargin)
%SLURMPARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SessionRunIDX = CheckVararginPairs('SessionRunIDX', NaN, varargin{:});
else
if ~(exist('SessionRunIDX','var'))
SessionRunIDX=NaN;
end
end

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Decision';
end
end

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
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
    'Dropout','WantNormalization','Activation','IsVariational',...
    'BottleNeckDepth','WantSaveOptimalNet','EncoderOutputType',...
    'GradientClipType','MultipleInstanceLearningType', ...
    'DynamicParameterSet','StitchingAndFusionLayer','StartEndPercent', ...
    'wantStratifiedPartition','STDTimeShift','WantSeparateTimeShift', ...
    'WeightOffsetAndScale','RescaleLossEpoch','WeightConfidence', ...
	'ConfidenceType'};

%%

SLURMIDX_Count = 10;
NotBase = true;
NewDynamicParameters = false;
cfg = PARAMETERS_cgg_runAutoEncoder('Epoch',Epoch,'Target',Target,'ParameterSetName','Optimal');
% cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2('Epoch',Epoch,'Target',Target);
cfg.Fold = NaN;
%%
SLURM_struct = struct();

for vidx = 1:length(VariableNames)
    this_VariableName = VariableNames{vidx};
    this_VariableValue = cfg.(this_VariableName);
    this_VariableCell = repmat({this_VariableValue},[SLURMIDX_Count,1]);
    SLURM_struct.(this_VariableName) = this_VariableCell;
end
%%
% Fold = 2;
% ModelName = cfg.ModelName;
% DataWidth = cfg.DataWidth;
% WindowStride = cfg.WindowStride;
% HiddenSizes = cfg.HiddenSizes;
% InitialLearningRate = cfg.InitialLearningRate;
% WeightReconstruction = cfg.WeightReconstruction;
% WeightKL = cfg.WeightKL;
% WeightClassification = cfg.WeightClassification;
% MiniBatchSize = cfg.MiniBatchSize;
% GradientThreshold=cfg.GradientThreshold;
% Subset = cfg.Subset;
% Epoch = cfg.Epoch;
% Target = cfg.Target;
% WeightedLoss = cfg.WeightedLoss;
% Optimizer = cfg.Optimizer;
% ClassifierName = cfg.ClassifierName;
% ClassifierHiddenSize=cfg.ClassifierHiddenSize;
% STDChannelOffset = cfg.STDChannelOffset;
% STDWhiteNoise = cfg.STDWhiteNoise;
% STDRandomWalk = cfg.STDRandomWalk;
% NumEpochsAutoEncoder=cfg.NumEpochsAutoEncoder;
% NumEpochsFull = cfg.NumEpochsFull;
% Normalization = cfg.Normalization;
% LossType_Decoder = cfg.LossType_Decoder;
% LossType_Classifier=cfg.LossType_Classifier;
% maxworkerMiniBatchSize=cfg.maxworkerMiniBatchSize;
% L2Factor = cfg.L2Factor;
% Dropout = cfg.Dropout;
% WantNormalization = cfg.WantNormalization;
% Activation = cfg.Activation;
% IsVariational = cfg.IsVariational;
% BottleNeckDepth = cfg.BottleNeckDepth;
% WantSaveOptimalNet = cfg.WantSaveOptimalNet;
% EncoderOutputType = cfg.EncoderOutputType;
% GradientClipType = cfg.GradientClipType;
% MultipleInstanceLearningType = cfg.MultipleInstanceLearningType;
% DynamicParameterSet = cfg.DynamicParameterSet;
% StitchingAndFusionLayer = cfg.StitchingAndFusionLayer;
% StartEndPercent = cfg.StartEndPercent;

%%


%%

SLURMDescription = '>>> Current SLURM Aim is %s\n';
Description = repmat({'Base'},[SLURMIDX_Count,1]);

switch SLURMChoice

%% SLURM Choice 1
    case 1

% ModelName = repmat({ModelName},[SLURMIDX_Count,1]);
% maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);
% NumEpochsAutoEncoder = repmat({NumEpochsAutoEncoder},[SLURMIDX_Count,1]);
% ClassifierName = repmat({ClassifierName},[SLURMIDX_Count,1]);
% HiddenSizes = repmat({HiddenSizes},[SLURMIDX_Count,1]);
% Activation = repmat({Activation},[SLURMIDX_Count,1]);
% WantNormalization = repmat({WantNormalization},[SLURMIDX_Count,1]);
% IsVariational = repmat({IsVariational},[SLURMIDX_Count,1]);
% WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
% WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
% WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);
% MiniBatchSize = repmat({MiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Issue
    Description{CurrentIDX} = 'Feedforward Network'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Feedforward';
    SLURM_struct.WantNormalization{CurrentIDX} = true;
    % IsVariational{CurrentIDX} = true;
    % WeightReconstruction{CurrentIDX} = 1; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 10000;
CurrentIDX = CurrentIDX +1;% Good
    Description{CurrentIDX} = 'LSTM Network'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'LSTM';
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Convolutional Network - Gradient Accumulation size 25'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Convolutional'; 
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 25; % 25 on small GPU at least 20 on big GPU
    % MiniBatchSize{CurrentIDX} = 5;
    SLURM_struct.HiddenSizes{CurrentIDX} = [8,16,32,cfg.HiddenSizes(end)];
    SLURM_struct.WantNormalization{CurrentIDX} = 'Instance';
    % IsVariational{CurrentIDX} = false;
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Resnet Network - Gradient Accumulation size 20'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Resnet';
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 20; % 20 on small GPU
    SLURM_struct.HiddenSizes{CurrentIDX} = [8,16,32,cfg.HiddenSizes(end)];
    SLURM_struct.WantNormalization{CurrentIDX} = 'Instance';
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Multi-Filter Network - Gradient Accumulation size 25'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Multi-Filter Convolutional'; 
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 25; % 2 on small GPU at least 25 on big GPU
    SLURM_struct.HiddenSizes{CurrentIDX} = [8,16,32,cfg.HiddenSizes(end)];
    SLURM_struct.WantNormalization{CurrentIDX} = 'Instance';
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;% Good
    Description{CurrentIDX} = 'Self-supervised epochs - 10'; % <<<<<<<<
    SLURM_struct.NumEpochsAutoEncoder{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1; % Good
    Description{CurrentIDX} = 'Self-supervised epochs - 50'; % <<<<<<<<
    SLURM_struct.NumEpochsAutoEncoder{CurrentIDX} = 50;
CurrentIDX = CurrentIDX +1; % FIXME: Time
    Description{CurrentIDX} = 'Self-supervised epochs - 100'; % <<<<<<<<
    SLURM_struct.NumEpochsAutoEncoder{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1; %Good
    Description{CurrentIDX} = 'Classifier - GRU'; % <<<<<<<<
    SLURM_struct.ClassifierName{CurrentIDX} = 'Deep GRU - Dropout 0.5';
CurrentIDX = CurrentIDX +1; %Good
    Description{CurrentIDX} = 'Classifier - Feedforward'; % <<<<<<<<
    SLURM_struct.ClassifierName{CurrentIDX} = 'Deep Feedforward - Dropout 0.5';

%% SLURM Choice 2
    case 2

% L2Factor = repmat({L2Factor},[SLURMIDX_Count,1]);
% WantNormalization = repmat({WantNormalization},[SLURMIDX_Count,1]);
% maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-1'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1e-1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-2'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1e-2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-3'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-5'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1e-5;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-6'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1e-6;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-7'; % <<<<<<<<
    SLURM_struct.L2Factor{CurrentIDX} = 1e-7;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Layer Normalization'; % <<<<<<<<
    SLURM_struct.WantNormalization{CurrentIDX} = true;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Gradient Accumulation size 1'; % <<<<<<<<
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Gradient Accumulation size 50'; % <<<<<<<<
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 50;

%% SLURM Choice 3
    case 3

% DataWidth = repmat({DataWidth},[SLURMIDX_Count,1]);
% WindowStride = repmat({WindowStride},[SLURMIDX_Count,1]);
% WeightedLoss = repmat({WeightedLoss},[SLURMIDX_Count,1]);
% maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%Good
    Description{CurrentIDX} = 'Data Width 200'; % <<<<<<<<
    SLURM_struct.DataWidth{CurrentIDX} = 200; SLURM_struct.WindowStride{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 50'; % <<<<<<<<
    SLURM_struct.DataWidth{CurrentIDX} = 50; SLURM_struct.WindowStride{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 20'; % <<<<<<<<
    SLURM_struct.DataWidth{CurrentIDX} = 20; SLURM_struct.WindowStride{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 10'; % <<<<<<<<
    SLURM_struct.DataWidth{CurrentIDX} = 10; SLURM_struct.WindowStride{CurrentIDX} = 5;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 4'; % <<<<<<<<
    SLURM_struct.DataWidth{CurrentIDX} = 4; SLURM_struct.WindowStride{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 1 - with Gradient Accumulation size 10'; % <<<<<<<<
    SLURM_struct.WindowStride{CurrentIDX} = 1; % FIXME: Increase SLURM Memory
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 25'; % <<<<<<<<
    SLURM_struct.WindowStride{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 75'; % <<<<<<<<
    SLURM_struct.WindowStride{CurrentIDX} = 75;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 100'; % <<<<<<<<
    SLURM_struct.WindowStride{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Unweighted Loss'; % <<<<<<<<
    SLURM_struct.WeightedLoss{CurrentIDX} = '';


%% SLURM Choice 4
    case 4

% HiddenSizes = repmat({HiddenSizes},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [2000,1000,500] - 3 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [2000,1000,500];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [4000,2000,1000] - 3 layers ~ Much Higher'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [4000,2000,1000];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [500,250,100] - 3 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [500,250,100];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [2000,1000,500,250] - 4 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [2000,1000,500,250];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - [1000,500,250,100] - 4 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [1000,500,250,100];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [4000,2000,1000,500,250] - 5 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [4000,2000,1000,500,250];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [1000,500,250,100,50] - 5 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [1000,500,250,100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - [500,250] - 2 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [500,250];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - [1000,500] - 2 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [1000,500];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - 1000 - 1 layer'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = 1000;

%% SLURM Choice 5
    case 5

% ClassifierHiddenSize = repmat({ClassifierHiddenSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [500,250,100] - 3 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [500,250,100];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [100,50,25] - 3 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [100,50,25];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [50,25,10] - 3 layers ~ Much Lower'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [50,25,10];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [500,250,100,50] - 4 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [500,250,100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [250,100,50,25] - 4 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [250,100,50,25];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [1000,500,250,100,50] - 5 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [1000,500,250,100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [250,100,50,25,10] - 5 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [250,100,50,25,10];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [250,100] - 2 layers ~ Higher'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [250,100];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [100,50] - 2 layers ~ Lower'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - 250 - 1 layer'; % <<<<<<<<
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = 250;

%% SLURM Choice 6
    case 6

% MiniBatchSize = repmat({MiniBatchSize},[SLURMIDX_Count,1]);
% InitialLearningRate = repmat({InitialLearningRate},[SLURMIDX_Count,1]);
% maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);
% Activation = repmat({Activation},[SLURMIDX_Count,1]);
% ModelName = repmat({ModelName},[SLURMIDX_Count,1]); 

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 10'; % <<<<<<<<
    SLURM_struct.MiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 25'; % <<<<<<<<
    SLURM_struct.MiniBatchSize{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 50'; % <<<<<<<<
    SLURM_struct.MiniBatchSize{CurrentIDX} = 50;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 200'; % <<<<<<<<
    SLURM_struct.MiniBatchSize{CurrentIDX} = 200;
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 200;
CurrentIDX = CurrentIDX +1;% FIXME: Increase SLURM Memory
    Description{CurrentIDX} = 'Mini-Batch Size - 400'; % <<<<<<<<
    SLURM_struct.MiniBatchSize{CurrentIDX} = 400;
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 400;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Initial Learnging Rate - 5e-2'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 5e-2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Initial Learnging Rate - 5e-3'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 5e-3;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Initial Learnging Rate - 1e-3'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Initial Learnging Rate - 5e-4'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 5e-4;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Initial Learnging Rate - 1e-4'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 1e-4;

%% SLURM Choice 7
    case 7

% WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
% WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
% WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 1'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 1'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 2'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 10'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 100'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 1000'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1000;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-4'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 1e-4;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-5'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 1e-5;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-6'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 1e-6;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 1:1:1e-4 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 1; 
%     WeightKL{CurrentIDX} = 1e-4; 
%     WeightClassification{CurrentIDX} = 1;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 2:1:1e-4 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 2; 
%     WeightKL{CurrentIDX} = 1e-4; 
%     WeightClassification{CurrentIDX} = 1;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 1:2:1e-4 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 1; 
%     WeightKL{CurrentIDX} = 1e-4; 
%     WeightClassification{CurrentIDX} = 2;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 1:10:1 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 1; 
%     WeightKL{CurrentIDX} = 1; 
%     WeightClassification{CurrentIDX} = 10;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 1:100:1 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 1; 
%     WeightKL{CurrentIDX} = 1; 
%     WeightClassification{CurrentIDX} = 100;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 1:1:1e-3 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 1; 
%     WeightKL{CurrentIDX} = 1e-3; 
%     WeightClassification{CurrentIDX} = 1;
% CurrentIDX = CurrentIDX +1;%FIXME: Time
%     Description{CurrentIDX} = 'Weights Ratio - 1:1:1e-2 (R:C:K)'; % <<<<<<<<
%     WeightReconstruction{CurrentIDX} = 1; 
%     WeightKL{CurrentIDX} = 1e-2; 
%     WeightClassification{CurrentIDX} = 1;

%% SLURM Choice 8
    case 8

% Optimizer = repmat({Optimizer},[SLURMIDX_Count,1]);
% Normalization = repmat({Normalization},[SLURMIDX_Count,1]);
% LossType_Decoder = repmat({LossType_Decoder},[SLURMIDX_Count,1]);
% IsVariational = repmat({IsVariational},[SLURMIDX_Count,1]);
% maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Optimizer - SGD'; % <<<<<<<<
    SLURM_struct.Optimizer{CurrentIDX} = 'SGD';%FIXME: Time
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - None'; % <<<<<<<<
    SLURM_struct.Normalization{CurrentIDX} = 'None';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - Channel - Z-Score - Global - MinMax - [-1,1]'; % <<<<<<<<
    SLURM_struct.Normalization{CurrentIDX} = 'Channel - Z-Score - Global - MinMax - [-1,1]';
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Data Normalization - Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered'; % <<<<<<<<
    SLURM_struct.Normalization{CurrentIDX} = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - Channel - Z-Score'; % <<<<<<<<
    SLURM_struct.Normalization{CurrentIDX} = 'Channel - Z-Score';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - Global - MinMax - [-1,1]'; % <<<<<<<<
    SLURM_struct.Normalization{CurrentIDX} = 'Global - MinMax - [-1,1]';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Decoder Loss Type - MAE'; % <<<<<<<<
    SLURM_struct.LossType_Decoder{CurrentIDX} = 'MAE'; %FIXME
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'No Decoder'; % <<<<<<<<
    SLURM_struct.LossType_Decoder{CurrentIDX} = 'None'; %FIXME
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Not Variational'; % <<<<<<<<
    SLURM_struct.IsVariational{CurrentIDX} = false;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Gradient Accumulation size 25'; % <<<<<<<<
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 25;

%% SLURM Choice 9
case 9

% Dropout = repmat({Dropout},[SLURMIDX_Count,1]);
% BottleNeckDepth = repmat({BottleNeckDepth},[SLURMIDX_Count,1]);
% GradientThreshold = repmat({GradientThreshold},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Dropout - 0'; % <<<<<<<<
    SLURM_struct.Dropout{CurrentIDX} = 0;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Dropout - 0.25'; % <<<<<<<<
    SLURM_struct.Dropout{CurrentIDX} = 0.25;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Dropout - 0.9'; % <<<<<<<<
    SLURM_struct.Dropout{CurrentIDX} = 0.9;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Dropout - 0.75'; % <<<<<<<<
    SLURM_struct.Dropout{CurrentIDX} = 0.75;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Bottleneck Depth - 2'; % <<<<<<<<
    SLURM_struct.BottleNeckDepth{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Bottleneck Depth - 3'; % <<<<<<<<
    SLURM_struct.BottleNeckDepth{CurrentIDX} = 3;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 0.1'; % <<<<<<<<
    SLURM_struct.GradientThreshold{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 1'; % <<<<<<<<
    SLURM_struct.GradientThreshold{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 10'; % <<<<<<<<
    SLURM_struct.GradientThreshold{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 1000'; % <<<<<<<<
    SLURM_struct.GradientThreshold{CurrentIDX} = 1000;

%% SLURM Choice 10
case 10

% maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);
% WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
% WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
% WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);
% BottleNeckDepth = repmat({BottleNeckDepth},[SLURMIDX_Count,1]);
% GradientThreshold = repmat({GradientThreshold},[SLURMIDX_Count,1]);
% InitialLearningRate = repmat({InitialLearningRate},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Gradient Accumulation size 10'; % <<<<<<<<
    SLURM_struct.maxworkerMiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Bottleneck Depth - 4'; % <<<<<<<<
    SLURM_struct.BottleNeckDepth{CurrentIDX} = 4;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 10000'; % <<<<<<<<
    SLURM_struct.GradientThreshold{CurrentIDX} = 10000;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 0.01'; % <<<<<<<<
    SLURM_struct.GradientThreshold{CurrentIDX} = 0.01;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Initial Learnging Rate - 0.1'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Initial Learnging Rate - 0.5'; % <<<<<<<<
    SLURM_struct.InitialLearningRate{CurrentIDX} = 0.5;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1:1e-2:1e-2 (R:C:K)'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1; 
    SLURM_struct.WeightKL{CurrentIDX} = 1e-2; 
    SLURM_struct.WeightClassification{CurrentIDX} = 1e-2;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1e-4:1e-6:1e-6 (R:C:K)'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1e-4; 
    SLURM_struct.WeightKL{CurrentIDX} = 1e-6; 
    SLURM_struct.WeightClassification{CurrentIDX} = 1e-6;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1:10:1e-4 (R:C:K)'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1; 
    SLURM_struct.WeightKL{CurrentIDX} = 1e-4; 
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1:100:1e-4 (R:C:K)'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1; 
    SLURM_struct.WeightKL{CurrentIDX} = 1e-4; 
    SLURM_struct.WeightClassification{CurrentIDX} = 100;

%% SLURM Choice 11
    case 11

% ModelName = repmat({ModelName},[SLURMIDX_Count,1]);
% HiddenSizes = repmat({HiddenSizes},[SLURMIDX_Count,1]);
% ClassifierHiddenSize = repmat({ClassifierHiddenSize},[SLURMIDX_Count,1]);
% WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
% WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
% WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);
% EncoderOutputType = repmat({EncoderOutputType},[SLURMIDX_Count,1]);
% GradientClipType = repmat({GradientClipType},[SLURMIDX_Count,1]);
% MultipleInstanceLearningType = repmat({MultipleInstanceLearningType},[SLURMIDX_Count,1]);
% DynamicParameterSet = repmat({DynamicParameterSet},[SLURMIDX_Count,1]);
% ModelName = repmat({ModelName},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Logistic Regression'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Logistic Regression';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Hidden Sizes - [250,100,50] - 3 layers ~ Much Lower'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [250,100,50];
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Small Network with Large Classification Weight'; % <<<<<<<<
    SLURM_struct.HiddenSizes{CurrentIDX} = [250];
    SLURM_struct.ClassifierHiddenSize{CurrentIDX} = [100];
    SLURM_struct.WeightReconstruction{CurrentIDX} = 1; 
    SLURM_struct.WeightKL{CurrentIDX} = 1e-4; 
    SLURM_struct.WeightClassification{CurrentIDX} = 10000;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'PCA'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'PCA';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Stochastic Encoder'; % <<<<<<<<
    SLURM_struct.EncoderOutputType{CurrentIDX} = 'Stochastic';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Stochastic Encoder with Global Gradient Clip'; % <<<<<<<<
    SLURM_struct.EncoderOutputType{CurrentIDX} = 'Stochastic';
    SLURM_struct.GradientClipType{CurrentIDX} = 'Global';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Multiple Instance Learning'; % <<<<<<<<
    % EncoderOutputType{CurrentIDX} = 'Stochastic';
    % GradientClipType{CurrentIDX} = 'Global';
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Soft Three-Stage Curriculum with Multiple Instance Learning'; % <<<<<<<<
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Three-Stage Curriculum";
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Soft Three-Stage Curriculum'; % <<<<<<<<
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'None';
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Three-Stage Curriculum";
CurrentIDX = CurrentIDX +1;%FIXME: Issue
    Description{CurrentIDX} = 'Feedforward Network with Soft Three-Stage Curriculum and Multiple Instance Learning'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Feedforward';
    SLURM_struct.WantNormalization{CurrentIDX} = true;
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Three-Stage Curriculum";

%% SLURM Choice 12
    case 12

% WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
% WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
% WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 2'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 10'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 100'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 1000'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 1000;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 0.1'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.1'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.01'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 0.01;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-3'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 10'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 0.1'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 0.1;

%% SLURM Choice 13
    case 13

% NumEpochsAutoEncoder = repmat({NumEpochsAutoEncoder},[SLURMIDX_Count,1]);

CurrentIDX = 1;% Good
    Description{CurrentIDX} = 'Self-supervised epochs - 10'; % <<<<<<<<
    SLURM_struct.NumEpochsAutoEncoder{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;% Good
    Description{CurrentIDX} = 'Self-supervised epochs - 10'; % <<<<<<<<
    SLURM_struct.NumEpochsAutoEncoder{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 100'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 1000'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 1000;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 0.1'; % <<<<<<<<
    SLURM_struct.WeightClassification{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.1'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.01'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 0.01;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-3'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 10'; % <<<<<<<<
    SLURM_struct.WeightKL{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 0.1'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 0.1;

%% SLURM Choice 14
    case 14
% Target = repmat({Target},[SLURMIDX_Count,1]);
% EncoderOutputType = repmat({EncoderOutputType},[SLURMIDX_Count,1]);
% GradientClipType = repmat({GradientClipType},[SLURMIDX_Count,1]);
% MultipleInstanceLearningType = repmat({MultipleInstanceLearningType},[SLURMIDX_Count,1]);
% StitchingAndFusionLayer = repmat({StitchingAndFusionLayer},[SLURMIDX_Count,1]);
% StartEndPercent = repmat({StartEndPercent},[SLURMIDX_Count,1]);
% ClassifierName = repmat({ClassifierName},[SLURMIDX_Count,1]);
% DynamicParameterSet = repmat({DynamicParameterSet},[SLURMIDX_Count,1]);
% ModelName = repmat({ModelName},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Target is Outcome'; % <<<<<<<<
    SLURM_struct.Target{CurrentIDX} = 'Outcome';
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Target is Outcome with Stochastic Encoder with Global Gradient Clip'; % <<<<<<<<
    SLURM_struct.Target{CurrentIDX} = 'Outcome';
    SLURM_struct.EncoderOutputType{CurrentIDX} = 'Stochastic';
    SLURM_struct.GradientClipType{CurrentIDX} = 'Global';
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Target is Outcome with Stochastic Encoder with Global Gradient Clip and Multiple Instance Learning'; % <<<<<<<<
    SLURM_struct.Target{CurrentIDX} = 'Outcome';
    SLURM_struct.EncoderOutputType{CurrentIDX} = 'Stochastic';
    SLURM_struct.GradientClipType{CurrentIDX} = 'Global';
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Stitching and Fusion Layer'; % <<<<<<<<
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'None';
    SLURM_struct.StitchingAndFusionLayer{CurrentIDX} = 'Default';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Stitching and Fusion Layer with MIL'; % <<<<<<<<
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
    SLURM_struct.StitchingAndFusionLayer{CurrentIDX} = 'Default';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Pre-Feedback Data with MIL'; % <<<<<<<<
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
    SLURM_struct.StartEndPercent{CurrentIDX} = [NaN,0.5];
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Pre-Feedback Data without MIL'; % <<<<<<<<
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'None';
    SLURM_struct.StartEndPercent{CurrentIDX} = [NaN,0.5];
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Feedforward Classifier with Soft Three-Stage Curriculum and Multiple Instance Learning'; % <<<<<<<<
    SLURM_struct.ClassifierName{CurrentIDX} = 'Deep Feedforward - Dropout 0.5';
    SLURM_struct.WantNormalization{CurrentIDX} = true;
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Three-Stage Curriculum";
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Feedforward Model with Normalization and Classifier with Soft Three-Stage Curriculum and Multiple Instance Learning'; % <<<<<<<<
    SLURM_struct.ModelName{CurrentIDX} = 'Feedforward';
    SLURM_struct.ClassifierName{CurrentIDX} = 'Deep Feedforward - Dropout 0.5';
    SLURM_struct.WantNormalization{CurrentIDX} = true;
    SLURM_struct.MultipleInstanceLearningType{CurrentIDX} = 'MIL';
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Three-Stage Curriculum";
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Hierarchically Stratified Sampling'; % <<<<<<<<
    SLURM_struct.wantStratifiedPartition{CurrentIDX} = true;

%% SLURM Choice 15
    case 15

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Data Augmentation with separate time shift'; % <<<<<<<<
    SLURM_struct.STDWhiteNoise{CurrentIDX} = 0.15*0.1;
    SLURM_struct.STDRandomWalk{CurrentIDX} = 0.007*0.1;
    SLURM_struct.STDChannelOffset{CurrentIDX} = 0.3*0.1;
    SLURM_struct.STDTimeShift{CurrentIDX} = 100;
    SLURM_struct.WantSeparateTimeShift{CurrentIDX} = true;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Standard Stratified Sampling'; % <<<<<<<<
    SLURM_struct.wantStratifiedPartition{CurrentIDX} = 'Standard';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weighted Loss'; % <<<<<<<<
    SLURM_struct.WeightReconstruction{CurrentIDX} = 100;
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
    SLURM_struct.WeightKL{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Augmentation with separate time shift and Weighted Loss'; % <<<<<<<<
    SLURM_struct.STDWhiteNoise{CurrentIDX} = 0.15*0.1;
    SLURM_struct.STDRandomWalk{CurrentIDX} = 0.007*0.1;
    SLURM_struct.STDChannelOffset{CurrentIDX} = 0.3*0.1;
    SLURM_struct.STDTimeShift{CurrentIDX} = 100;
    SLURM_struct.WantSeparateTimeShift{CurrentIDX} = true;
    SLURM_struct.WeightReconstruction{CurrentIDX} = 100;
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
    SLURM_struct.WeightKL{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Soft Three-Stage Curriculum: Data Augmentation with separate time shift and Weighted Loss'; % <<<<<<<<
    SLURM_struct.STDWhiteNoise{CurrentIDX} = 0.15*0.1;
    SLURM_struct.STDRandomWalk{CurrentIDX} = 0.007*0.1;
    SLURM_struct.STDChannelOffset{CurrentIDX} = 0.3*0.1;
    SLURM_struct.STDTimeShift{CurrentIDX} = 100;
    SLURM_struct.WantSeparateTimeShift{CurrentIDX} = true;
    SLURM_struct.WeightReconstruction{CurrentIDX} = 100;
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
    SLURM_struct.WeightKL{CurrentIDX} = 1;
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Three-Stage Curriculum";
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Soft Two-Stage Curriculum: Data Augmentation with separate time shift and Weighted Loss'; % <<<<<<<<
    SLURM_struct.STDWhiteNoise{CurrentIDX} = 0.15*0.1;
    SLURM_struct.STDRandomWalk{CurrentIDX} = 0.007*0.1;
    SLURM_struct.STDChannelOffset{CurrentIDX} = 0.3*0.1;
    SLURM_struct.STDTimeShift{CurrentIDX} = 100;
    SLURM_struct.WantSeparateTimeShift{CurrentIDX} = true;
    SLURM_struct.WeightReconstruction{CurrentIDX} = 100;
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
    SLURM_struct.WeightKL{CurrentIDX} = 1;
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "Soft Two-Stage Curriculum";
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'No Dynamic Parameters: Data Augmentation with separate time shift and Weighted Loss'; % <<<<<<<<
    SLURM_struct.STDWhiteNoise{CurrentIDX} = 0.15*0.1;
    SLURM_struct.STDRandomWalk{CurrentIDX} = 0.007*0.1;
    SLURM_struct.STDChannelOffset{CurrentIDX} = 0.3*0.1;
    SLURM_struct.STDTimeShift{CurrentIDX} = 100;
    SLURM_struct.WantSeparateTimeShift{CurrentIDX} = true;
    SLURM_struct.WeightReconstruction{CurrentIDX} = 100;
    SLURM_struct.WeightClassification{CurrentIDX} = 10;
    SLURM_struct.WeightKL{CurrentIDX} = 1;
    SLURM_struct.DynamicParameterSet{CurrentIDX} = "No Dynamic Parameters";
%% SLURM Choice Default
    otherwise
NotBase = false;
SLURM_struct.Fold = {1;2;3;4;5;6;7;8;9;10};
% WantSaveOptimalNet = repmat({true},[SLURMIDX_Count,1]);
% NumEpochsFull = 500;
for idx = 1:length(Description)
Description{idx} = sprintf('Base Case - Fold %d',SLURM_struct.Fold{idx});
end
end

%%

% VariableNames = {'Fold','ModelName','DataWidth','WindowStride',...
%     'HiddenSizes','InitialLearningRate','WeightReconstruction',...
%     'WeightKL','WeightClassification','MiniBatchSize','Subset',...
%     'Target','Epoch','WeightedLoss','GradientThreshold',...
%     'ClassifierName','ClassifierHiddenSize','STDChannelOffset',...
%     'STDWhiteNoise','STDRandomWalk','NumEpochsAutoEncoder',...
%     'NumEpochsFull','Optimizer','Normalization','LossType_Decoder',...
%     'LossType_Classifier','maxworkerMiniBatchSize','L2Factor',...
%     'Dropout','WantNormalization','Activation','IsVariational',...
%     'BottleNeckDepth','WantSaveOptimalNet','EncoderOutputType',...
%     'GradientClipType','MultipleInstanceLearningType', ...
%     'DynamicParameterSet','StitchingAndFusionLayer','StartEndPercent'};

%%

cfgSLURM = struct();

for vidx = 1:length(VariableNames)
    this_VariableName = VariableNames{vidx};
    this_Variable = SLURM_struct.(this_VariableName);
    % this_Variable = eval(this_VariableName);

    if iscell(this_Variable)
        this_NumVariable = length(this_Variable);
        this_SLURMIDX = mod(SLURMIDX-1,this_NumVariable)+1;
        this_Variable = this_Variable{this_SLURMIDX};
    end

    cfgSLURM.(this_VariableName) = this_Variable;
end

IsSubset = cgg_isSubsetStruct(cfg,rmfield(cfgSLURM,'Fold'));
IsInccidentalBaseRepeat = IsSubset && NotBase;

BaselineDynamicParameters_SLURM = cgg_setBaselineDynamicParameters(cfgSLURM);
BaselineDynamicParameters_SLURM = rmfield(BaselineDynamicParameters_SLURM,"WantReset");
[DifferentVariables,~] = cgg_compareStruct(BaselineDynamicParameters_SLURM, cfg);
NewDynamicParameters = any(contains(DifferentVariables,fieldnames(BaselineDynamicParameters_SLURM)));

if NewDynamicParameters
cfgSLURM.BaselineDynamicParameters = cgg_setBaselineDynamicParameters(cfg);
cfgSLURM.BaselineDynamicParameters.WantReset = NotBase;
end

if isnan(SessionRunIDX)
fprintf(SLURMDescription,Description{SLURMIDX});
end


% disp(cfgSLURM);
% disp(datetime);

end

