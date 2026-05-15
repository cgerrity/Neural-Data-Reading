function cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_SyntheticEasy(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Synthetic_Easy', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Synthetic_Easy';
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

cfg = PARAMETERS_cgg_runAutoEncoder('ParameterSetName','Default');
cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v3();
cfg.Epoch = 'Synthetic_Easy';
cfg.Target = Target;
cfg.ParameterSetName = 'Synthetic_Easy';
cfg.wantStratifiedPartition = true;
cfg.WeightConfidence = 1;

%%

cfg.HiddenSizes=[256,128,64];
cfg.ClassifierHiddenSize=[64,32,16];

cfg.LearningRateEpochRamp = 0;
cfg.WeightDelayEpoch = 2;
cfg.WeightEpochRamp = 3;

cfg.PriorProportion = 0.9;
cfg.RescaleLossEpoch = 0;

% cfg.StitchingAndFusionLayer = '';

cfg.DynamicParameterSet = 'Soft Three-Stage Curriculum - Shortened';
%% Validation and Saving

cfg.ValidationFrequency = 4;
cfg.SaveFrequency = 4;
cfg.IterationSaveFrequency = 4;

%% Monitoring

cfg.WantProgressMonitor = true;
cfg.WantExampleMonitor = true;
cfg.WantComponentMonitor = true;
cfg.WantAccuracyMonitor = true;
cfg.WantWindowMonitor = true;
cfg.WantReconstructionMonitor = true;
cfg.WantGradientMonitor = true;

cfg.AccuracyMeasures = {'Scaled_BalancedAccuracy'};

%%
% cfg.EncoderOutputType = 'Stochastic'; %'Stochastic', 'Deterministic'
% cfg.GradientClipType = 'Global'; %['SubNetwork','Global']
% cfg.NumEpochsFull = 500;
% cfg.InitialLearningRate = 0.001;
% cfg.STDTimeShift = 100;
% cfg.WantSeparateTimeShift = true;
% 
% cfg.STDChannelOffset = 0.3*0.1;
% cfg.STDWhiteNoise = 0.15*0.1;
% cfg.STDRandomWalk = 0.007*0.1;
% 
% cfg.WeightReconstruction = 100;
% cfg.WeightClassification = 10;
% cfg.WeightKL = 0.1;
% 
% cfg.DynamicParameterSet = "Soft Three-Stage Curriculum";
% 
% %% Small Testing for faster debugging
% % cfg.HiddenSizes=[100,50,25];
% % cfg.ClassifierHiddenSize=[25,10];
% % cfg.StartEndPercent = [NaN,0.25];
% % cfg.AccuracyMeasures = {'Scaled_BalancedAccuracy'};
% 
% %% Renaming for outdated functions
% 
% cfg.NumEpochsBase = cfg.NumEpochsAutoEncoder;
% cfg.NumEpochsSession = cfg.NumEpochsFull;
% 
% cfg.LossFactorReconstruction = cfg.WeightReconstruction;
% cfg.LossFactorKL = cfg.WeightKL;
% cfg.wantSubset = cfg.Subset;

end

