function cfgSLURM = SLURMPARAMETERS_cgg_runAutoEncoder_v2(SLURMChoice,SLURMIDX)
%SLURMPARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

SLURMIDX_Count = 10;

cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2();
%%
Fold = 2;
ModelName = cfg.ModelName;
DataWidth = cfg.DataWidth;
WindowStride = cfg.WindowStride;
HiddenSizes = cfg.HiddenSizes;
InitialLearningRate = cfg.InitialLearningRate;
WeightReconstruction = cfg.WeightReconstruction;
WeightKL = cfg.WeightKL;
WeightClassification = cfg.WeightClassification;
MiniBatchSize = cfg.MiniBatchSize;
GradientThreshold=cfg.GradientThreshold;
Subset = cfg.wantSubset;
Epoch = cfg.Epoch;
Target = cfg.Target;
WeightedLoss = cfg.WeightedLoss;
Optimizer = cfg.Optimizer;
ClassifierName = cfg.ClassifierName;
ClassifierHiddenSize=cfg.ClassifierHiddenSize;
STDChannelOffset = cfg.STDChannelOffset;
STDWhiteNoise = cfg.STDWhiteNoise;
STDRandomWalk = cfg.STDRandomWalk;
NumEpochsAutoEncoder=cfg.NumEpochsAutoEncoder;
NumEpochsFull = cfg.NumEpochsFull;
Normalization = cfg.Normalization;
LossType_Decoder = cfg.LossType_Decoder;
LossType_Classifier=cfg.LossType_Classifier;
maxworkerMiniBatchSize=cfg.maxworkerMiniBatchSize;
L2Factor = cfg.L2Factor;
Dropout = cfg.Dropout;
WantNormalization = cfg.WantNormalization;
Activation = cfg.Activation;
IsVariational = cfg.IsVariational;
BottleNeckDepth = cfg.BottleNeckDepth;
WantSaveOptimalNet = cfg.WantSaveOptimalNet;

SLURMDescription = '>>> Current SLURM Aim is %s\n';
Description = repmat({'Base'},[SLURMIDX_Count,1]);

switch SLURMChoice

%% SLURM Choice 1
    case 1

ModelName = repmat({ModelName},[SLURMIDX_Count,1]);
maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);
NumEpochsAutoEncoder = repmat({NumEpochsAutoEncoder},[SLURMIDX_Count,1]);
ClassifierName = repmat({ClassifierName},[SLURMIDX_Count,1]);
HiddenSizes = repmat({HiddenSizes},[SLURMIDX_Count,1]);
Activation = repmat({Activation},[SLURMIDX_Count,1]);
WantNormalization = repmat({WantNormalization},[SLURMIDX_Count,1]);
IsVariational = repmat({IsVariational},[SLURMIDX_Count,1]);
WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);
MiniBatchSize = repmat({MiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Issue
    Description{CurrentIDX} = 'Feedforward Network'; % <<<<<<<<
    ModelName{CurrentIDX} = 'Feedforward';
    WantNormalization{CurrentIDX} = true;
    % IsVariational{CurrentIDX} = true;
    % WeightReconstruction{CurrentIDX} = 1; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 10000;
CurrentIDX = CurrentIDX +1;% Good
    Description{CurrentIDX} = 'LSTM Network'; % <<<<<<<<
    ModelName{CurrentIDX} = 'LSTM';
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Convolutional Network - Gradient Accumulation size 10'; % <<<<<<<<
    ModelName{CurrentIDX} = 'Convolutional'; 
    maxworkerMiniBatchSize{CurrentIDX} = 10;
    % MiniBatchSize{CurrentIDX} = 5;
    HiddenSizes{CurrentIDX} = [8,16,32];
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Resnet Network - Gradient Accumulation size 10'; % <<<<<<<<
    ModelName{CurrentIDX} = 'Resnet';
    maxworkerMiniBatchSize{CurrentIDX} = 10;
    HiddenSizes{CurrentIDX} = [8,16,32];
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Multi-Filter Network - Gradient Accumulation size 5'; % <<<<<<<<
    ModelName{CurrentIDX} = 'Multi-Filter Convolutional'; 
    maxworkerMiniBatchSize{CurrentIDX} = 5;
    HiddenSizes{CurrentIDX} = [8,16,32];
    % WeightReconstruction{CurrentIDX} = 100; 
    % WeightKL{CurrentIDX} = 1e-4; 
    % WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;% Good
    Description{CurrentIDX} = 'Self-supervised epochs - 10'; % <<<<<<<<
    NumEpochsAutoEncoder{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1; % Good
    Description{CurrentIDX} = 'Self-supervised epochs - 50'; % <<<<<<<<
    NumEpochsAutoEncoder{CurrentIDX} = 50;
CurrentIDX = CurrentIDX +1; % FIXME: Time
    Description{CurrentIDX} = 'Self-supervised epochs - 100'; % <<<<<<<<
    NumEpochsAutoEncoder{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1; %Good
    Description{CurrentIDX} = 'Classifier - GRU'; % <<<<<<<<
    ClassifierName{CurrentIDX} = 'Deep GRU - Dropout 0.5';
CurrentIDX = CurrentIDX +1; %Good
    Description{CurrentIDX} = 'Classifier - Feedforward'; % <<<<<<<<
    ClassifierName{CurrentIDX} = 'Deep Feedforward - Dropout 0.5';

%% SLURM Choice 2
    case 2

L2Factor = repmat({L2Factor},[SLURMIDX_Count,1]);
WantNormalization = repmat({WantNormalization},[SLURMIDX_Count,1]);
maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-1'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1e-1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-2'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1e-2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-3'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-5'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1e-5;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-6'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1e-6;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'L2 Factor - 1e-7'; % <<<<<<<<
    L2Factor{CurrentIDX} = 1e-7;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Layer Normalization'; % <<<<<<<<
    WantNormalization{CurrentIDX} = true;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Gradient Accumulation size 1'; % <<<<<<<<
    maxworkerMiniBatchSize{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Gradient Accumulation size 50'; % <<<<<<<<
    maxworkerMiniBatchSize{CurrentIDX} = 50;

%% SLURM Choice 3
    case 3

DataWidth = repmat({DataWidth},[SLURMIDX_Count,1]);
WindowStride = repmat({WindowStride},[SLURMIDX_Count,1]);
WeightedLoss = repmat({WeightedLoss},[SLURMIDX_Count,1]);
maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%Good
    Description{CurrentIDX} = 'Data Width 200'; % <<<<<<<<
    DataWidth{CurrentIDX} = 200; WindowStride{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 50'; % <<<<<<<<
    DataWidth{CurrentIDX} = 50; WindowStride{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 20'; % <<<<<<<<
    DataWidth{CurrentIDX} = 20; WindowStride{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 10'; % <<<<<<<<
    DataWidth{CurrentIDX} = 10; WindowStride{CurrentIDX} = 5;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Data Width 4'; % <<<<<<<<
    DataWidth{CurrentIDX} = 4; WindowStride{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 1 - with Gradient Accumulation size 10'; % <<<<<<<<
    WindowStride{CurrentIDX} = 1; % FIXME: Increase SLURM Memory
    maxworkerMiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 25'; % <<<<<<<<
    WindowStride{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 75'; % <<<<<<<<
    WindowStride{CurrentIDX} = 75;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Stride 100'; % <<<<<<<<
    WindowStride{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Unweighted Loss'; % <<<<<<<<
    WeightedLoss{CurrentIDX} = '';


%% SLURM Choice 4
    case 4

HiddenSizes = repmat({HiddenSizes},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [2000,1000,500] - 3 layers ~ Higher'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [2000,1000,500];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [4000,2000,1000] - 3 layers ~ Much Higher'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [4000,2000,1000];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [500,250,100] - 3 layers ~ Lower'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [500,250,100];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [2000,1000,500,250] - 4 layers ~ Higher'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [2000,1000,500,250];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - [1000,500,250,100] - 4 layers ~ Lower'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [1000,500,250,100];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [4000,2000,1000,500,250] - 5 layers ~ Higher'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [4000,2000,1000,500,250];
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Hidden Sizes - [1000,500,250,100,50] - 5 layers ~ Lower'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [1000,500,250,100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - [500,250] - 2 layers ~ Lower'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [500,250];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - [1000,500] - 2 layers ~ Higher'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [1000,500];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Hidden Sizes - 1000 - 1 layer'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = 1000;

%% SLURM Choice 5
    case 5

ClassifierHiddenSize = repmat({ClassifierHiddenSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [500,250,100] - 3 layers ~ Higher'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [500,250,100];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [100,50,25] - 3 layers ~ Lower'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [100,50,25];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [50,25,10] - 3 layers ~ Much Lower'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [50,25,10];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [500,250,100,50] - 4 layers ~ Higher'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [500,250,100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [250,100,50,25] - 4 layers ~ Lower'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [250,100,50,25];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [1000,500,250,100,50] - 5 layers ~ Higher'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [1000,500,250,100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [250,100,50,25,10] - 5 layers ~ Higher'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [250,100,50,25,10];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [250,100] - 2 layers ~ Higher'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [250,100];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - [100,50] - 2 layers ~ Lower'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = [100,50];
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Classifier Hidden Sizes - 250 - 1 layer'; % <<<<<<<<
    ClassifierHiddenSize{CurrentIDX} = 250;

%% SLURM Choice 6
    case 6

MiniBatchSize = repmat({MiniBatchSize},[SLURMIDX_Count,1]);
InitialLearningRate = repmat({InitialLearningRate},[SLURMIDX_Count,1]);
maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);
Activation = repmat({Activation},[SLURMIDX_Count,1]);
ModelName = repmat({ModelName},[SLURMIDX_Count,1]); 

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 10'; % <<<<<<<<
    MiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 25'; % <<<<<<<<
    MiniBatchSize{CurrentIDX} = 25;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 50'; % <<<<<<<<
    MiniBatchSize{CurrentIDX} = 50;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Mini-Batch Size - 200'; % <<<<<<<<
    MiniBatchSize{CurrentIDX} = 200;
    maxworkerMiniBatchSize{CurrentIDX} = 200;
CurrentIDX = CurrentIDX +1;% FIXME: Increase SLURM Memory
    Description{CurrentIDX} = 'Mini-Batch Size - 400'; % <<<<<<<<
    MiniBatchSize{CurrentIDX} = 400;
    maxworkerMiniBatchSize{CurrentIDX} = 400;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Initial Learnging Rate - 5e-2'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 5e-2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Initial Learnging Rate - 5e-3'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 5e-3;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Initial Learnging Rate - 1e-3'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Initial Learnging Rate - 5e-4'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 5e-4;
CurrentIDX = CurrentIDX +1;%Good
    Description{CurrentIDX} = 'Initial Learnging Rate - 1e-4'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 1e-4;

%% SLURM Choice 7
    case 7

WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 1'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1'; % <<<<<<<<
    WeightKL{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 1'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 2'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 10'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 100'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 1000'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 1000;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-4'; % <<<<<<<<
    WeightKL{CurrentIDX} = 1e-4;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-5'; % <<<<<<<<
    WeightKL{CurrentIDX} = 1e-5;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-6'; % <<<<<<<<
    WeightKL{CurrentIDX} = 1e-6;
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

Optimizer = repmat({Optimizer},[SLURMIDX_Count,1]);
Normalization = repmat({Normalization},[SLURMIDX_Count,1]);
LossType_Decoder = repmat({LossType_Decoder},[SLURMIDX_Count,1]);
IsVariational = repmat({IsVariational},[SLURMIDX_Count,1]);
maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Optimizer - SGD'; % <<<<<<<<
    Optimizer{CurrentIDX} = 'SGD';%FIXME: Time
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - None'; % <<<<<<<<
    Normalization{CurrentIDX} = 'None';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - Channel - Z-Score - Global - MinMax - [-1,1]'; % <<<<<<<<
    Normalization{CurrentIDX} = 'Channel - Z-Score - Global - MinMax - [-1,1]';
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Data Normalization - Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered'; % <<<<<<<<
    Normalization{CurrentIDX} = 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - Channel - Z-Score'; % <<<<<<<<
    Normalization{CurrentIDX} = 'Channel - Z-Score';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Data Normalization - Global - MinMax - [-1,1]'; % <<<<<<<<
    Normalization{CurrentIDX} = 'Global - MinMax - [-1,1]';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Decoder Loss Type - MAE'; % <<<<<<<<
    LossType_Decoder{CurrentIDX} = 'MAE'; %FIXME
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'No Decoder'; % <<<<<<<<
    LossType_Decoder{CurrentIDX} = 'None'; %FIXME
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Not Variational'; % <<<<<<<<
    IsVariational{CurrentIDX} = false;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Gradient Accumulation size 25'; % <<<<<<<<
    maxworkerMiniBatchSize{CurrentIDX} = 25;

%% SLURM Choice 9
case 9

Dropout = repmat({Dropout},[SLURMIDX_Count,1]);
BottleNeckDepth = repmat({BottleNeckDepth},[SLURMIDX_Count,1]);
GradientThreshold = repmat({GradientThreshold},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Dropout - 0'; % <<<<<<<<
    Dropout{CurrentIDX} = 0;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Dropout - 0.25'; % <<<<<<<<
    Dropout{CurrentIDX} = 0.25;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Dropout - 0.9'; % <<<<<<<<
    Dropout{CurrentIDX} = 0.9;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Dropout - 0.75'; % <<<<<<<<
    Dropout{CurrentIDX} = 0.75;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Bottleneck Depth - 2'; % <<<<<<<<
    BottleNeckDepth{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Bottleneck Depth - 3'; % <<<<<<<<
    BottleNeckDepth{CurrentIDX} = 3;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 0.1'; % <<<<<<<<
    GradientThreshold{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 1'; % <<<<<<<<
    GradientThreshold{CurrentIDX} = 1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 10'; % <<<<<<<<
    GradientThreshold{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 1000'; % <<<<<<<<
    GradientThreshold{CurrentIDX} = 1000;

%% SLURM Choice 10
case 10

maxworkerMiniBatchSize = repmat({maxworkerMiniBatchSize},[SLURMIDX_Count,1]);
WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);
BottleNeckDepth = repmat({BottleNeckDepth},[SLURMIDX_Count,1]);
GradientThreshold = repmat({GradientThreshold},[SLURMIDX_Count,1]);
InitialLearningRate = repmat({InitialLearningRate},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Gradient Accumulation size 10'; % <<<<<<<<
    maxworkerMiniBatchSize{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Bottleneck Depth - 4'; % <<<<<<<<
    BottleNeckDepth{CurrentIDX} = 4;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 10000'; % <<<<<<<<
    GradientThreshold{CurrentIDX} = 10000;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Gradient Threshold - 0.01'; % <<<<<<<<
    GradientThreshold{CurrentIDX} = 0.01;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Initial Learnging Rate - 0.1'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Initial Learnging Rate - 0.5'; % <<<<<<<<
    InitialLearningRate{CurrentIDX} = 0.5;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1:1e-2:1e-2 (R:C:K)'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-2; 
    WeightClassification{CurrentIDX} = 1e-2;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1e-4:1e-6:1e-6 (R:C:K)'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 1e-4; 
    WeightKL{CurrentIDX} = 1e-6; 
    WeightClassification{CurrentIDX} = 1e-6;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1:10:1e-4 (R:C:K)'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Weights Ratio - 1:100:1e-4 (R:C:K)'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 100;

%% SLURM Choice 11
    case 11

ModelName = repmat({ModelName},[SLURMIDX_Count,1]);
HiddenSizes = repmat({HiddenSizes},[SLURMIDX_Count,1]);
ClassifierHiddenSize = repmat({ClassifierHiddenSize},[SLURMIDX_Count,1]);
WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);

CurrentIDX = 1;
    Description{CurrentIDX} = 'Logistic Regression'; % <<<<<<<<
    ModelName{CurrentIDX} = 'Logistic Regression';
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Hidden Sizes - [250,100,50] - 3 layers ~ Much Lower'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [250,100,50];
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'Small Network with Large Classification Weight'; % <<<<<<<<
    HiddenSizes{CurrentIDX} = [250];
    ClassifierHiddenSize{CurrentIDX} = [100];
    WeightReconstruction{CurrentIDX} = 1; 
    WeightKL{CurrentIDX} = 1e-4; 
    WeightClassification{CurrentIDX} = 10000;
CurrentIDX = CurrentIDX +1;
    Description{CurrentIDX} = 'PCA'; % <<<<<<<<
    ModelName{CurrentIDX} = 'PCA';

%% SLURM Choice 12
    case 12

WeightReconstruction = repmat({WeightReconstruction},[SLURMIDX_Count,1]);
WeightKL = repmat({WeightKL},[SLURMIDX_Count,1]);
WeightClassification = repmat({WeightClassification},[SLURMIDX_Count,1]);

CurrentIDX = 1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 2'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 2;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 10'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 100'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 1000'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 1000;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 0.1'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.1'; % <<<<<<<<
    WeightKL{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.01'; % <<<<<<<<
    WeightKL{CurrentIDX} = 0.01;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-3'; % <<<<<<<<
    WeightKL{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 10'; % <<<<<<<<
    WeightKL{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 0.1'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 0.1;

%% SLURM Choice 13
    case 13

NumEpochsAutoEncoder = repmat({NumEpochsAutoEncoder},[SLURMIDX_Count,1]);

CurrentIDX = 1;% Good
    Description{CurrentIDX} = 'Self-supervised epochs - 10'; % <<<<<<<<
    NumEpochsAutoEncoder{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;% Good
    Description{CurrentIDX} = 'Self-supervised epochs - 10'; % <<<<<<<<
    NumEpochsAutoEncoder{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 100'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 100;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 1000'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 1000;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Classification Weight - 0.1'; % <<<<<<<<
    WeightClassification{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.1'; % <<<<<<<<
    WeightKL{CurrentIDX} = 0.1;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 0.01'; % <<<<<<<<
    WeightKL{CurrentIDX} = 0.01;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 1e-3'; % <<<<<<<<
    WeightKL{CurrentIDX} = 1e-3;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'KL Weight - 10'; % <<<<<<<<
    WeightKL{CurrentIDX} = 10;
CurrentIDX = CurrentIDX +1;%FIXME: Time
    Description{CurrentIDX} = 'Reconstruction Weight - 0.1'; % <<<<<<<<
    WeightReconstruction{CurrentIDX} = 0.1;

%% SLURM Choice Default
    otherwise

Fold = {1;2;3;4;5;6;7;8;9;10};
WantSaveOptimalNet = repmat({true},[SLURMIDX_Count,1]);
% NumEpochsFull = 500;
for idx = 1:length(Description)
Description{idx} = sprintf('Base Case - Fold %d',Fold{idx});
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
    'BottleNeckDepth','WantSaveOptimalNet'};

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

fprintf(SLURMDescription,Description{SLURMIDX});


% disp(cfgSLURM);
% disp(datetime);

end

