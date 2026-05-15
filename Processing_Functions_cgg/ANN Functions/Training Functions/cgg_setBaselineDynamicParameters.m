function BaselineDynamicParameters = cgg_setBaselineDynamicParameters(cfg,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsFinalSetting = CheckVararginPairs('IsFinalSetting', false, varargin{:});
else
if ~(exist('IsFinalSetting','var'))
IsFinalSetting=false;
end
end


if isfield(cfg,'BaselineDynamicParameters')
    WantReset = true;
    BaselineDynamicParameters = cfg.BaselineDynamicParameters;
        if isfield(BaselineDynamicParameters,'WantReset')
        WantReset = BaselineDynamicParameters.WantReset;
        end

    if ~WantReset
        return
    end
end



BaselineDynamicParameters =  struct();

% BaselineDynamicParameters.Augmentation.STDChannelOffset = cfg.STDChannelOffset;
% BaselineDynamicParameters.Augmentation.STDWhiteNoise = cfg.STDWhiteNoise;
% BaselineDynamicParameters.Augmentation.STDRandomWalk = cfg.STDRandomWalk;
% BaselineDynamicParameters.Augmentation.STDTimeShift = cfg.STDTimeShift;
% BaselineDynamicParameters.Augmentation.WantSeparateTimeShift = cfg.WantSeparateTimeShift;
% 
% BaselineDynamicParameters.Weighting.WeightReconstruction = cfg.WeightReconstruction;
% BaselineDynamicParameters.Weighting.WeightKL = cfg.WeightKL;
% BaselineDynamicParameters.Weighting.WeightClassification = cfg.WeightClassification;
% BaselineDynamicParameters.Weighting.WeightOffsetAndScale = cfg.WeightOffsetAndScale;
% BaselineDynamicParameters.Weighting.RescaleLossEpoch = cfg.RescaleLossEpoch;

BaselineDynamicParameters.STDChannelOffset = cfg.STDChannelOffset;
BaselineDynamicParameters.STDWhiteNoise = cfg.STDWhiteNoise;
BaselineDynamicParameters.STDRandomWalk = cfg.STDRandomWalk;
BaselineDynamicParameters.STDTimeShift = cfg.STDTimeShift;
BaselineDynamicParameters.WantSeparateTimeShift = cfg.WantSeparateTimeShift;

BaselineDynamicParameters.WeightReconstruction = cfg.WeightReconstruction;
BaselineDynamicParameters.WeightKL = cfg.WeightKL;
BaselineDynamicParameters.WeightClassification = cfg.WeightClassification;
BaselineDynamicParameters.WeightOffsetAndScale = cfg.WeightOffsetAndScale;
BaselineDynamicParameters.WeightConfidence = cfg.WeightConfidence;
BaselineDynamicParameters.RescaleLossEpoch = cfg.RescaleLossEpoch;

BaselineDynamicParameters.WantReset = true;

%%
if IsFinalSetting
BaselineDynamicParameters.WantReset = ~IsFinalSetting;
end
end