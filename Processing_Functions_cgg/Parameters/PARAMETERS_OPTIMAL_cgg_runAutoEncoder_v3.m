function cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v3(varargin)
%PARAMETERS_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

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

cfg = PARAMETERS_cgg_runAutoEncoder('ParameterSetName','Default');
cfg.Epoch = Epoch;
cfg.Target = Target;
cfg.ParameterSetName = 'Optimal';

%%
cfg.EncoderOutputType = 'Stochastic'; %'Stochastic', 'Deterministic'
cfg.GradientClipType = 'Global'; %['SubNetwork','Global']
cfg.NumEpochsFull = 500;
cfg.InitialLearningRate = 0.001;
cfg.STDTimeShift = 100; % 100
cfg.WantSeparateTimeShift = true; % true

cfg.STDChannelOffset = 0.3*0.1;
cfg.STDWhiteNoise = 0.15*0.1;
cfg.STDRandomWalk = 0.007*0.1;

cfg.WeightReconstruction = NaN;
cfg.WeightClassification = NaN;
cfg.WeightKL = NaN;
cfg.WeightConfidence = NaN;

cfg.WeightReconstruction = 100;
cfg.WeightKL = 1; % WeightKL = 1;
cfg.WeightClassification = 10; % WeightClassification = 1;
cfg.WeightOffsetAndScale = 0;
cfg.WeightConfidence = 10;

cfg.ConfidenceType = ["Trial", "Task"]; % "Trial", "Task", ["Trial", "Task"]

cfg.MultipleInstanceLearningType = 'MIL';

cfg.DynamicParameterSet = 'Soft Three-Stage Curriculum - Shortened';

cfg.wantStratifiedPartition = true;

cfg.StitchingAndFusionLayer = '';

%%
cfg.LearningRateEpochRamp = 0;
cfg.WeightDelayEpoch = 2;
cfg.WeightEpochRamp = 3;

cfg.WeightConfidence = 1;
cfg.PriorProportion = 0.9;
cfg.RescaleLossEpoch = 0;

cfg.AccuracyMeasures = {'Scaled_BalancedAccuracy'};
%%
cfg.BaselineDynamicParameters = cgg_setBaselineDynamicParameters(cfg,'IsFinalSetting',true);
%% Base model without additional elements

% [cfg,~] = PARAMETERS_cgg_selectGeneralParamterSets(cfg,'Base Model');

%% Monitoring

[cfg,~] = PARAMETERS_cgg_selectGeneralParamterSets(cfg,'Fast Training');
% cfg.WantProgressMonitor = true;
% cfg.WantComponentMonitor = true;
% cfg.WantWindowMonitor = true;
% cfg.WantGradientMonitor = true;
%% Renaming for outdated functions

cfg.NumEpochsBase = cfg.NumEpochsAutoEncoder;
cfg.NumEpochsSession = cfg.NumEpochsFull;

cfg.LossFactorReconstruction = cfg.WeightReconstruction;
cfg.LossFactorKL = cfg.WeightKL;
cfg.wantSubset = cfg.Subset;

end

