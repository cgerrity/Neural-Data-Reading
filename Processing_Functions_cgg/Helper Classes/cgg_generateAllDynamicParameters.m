function [LoadParameters, WeightParameters, FreezeParameters] = cgg_generateAllDynamicParameters(cfg_Encoder)
% CGG_GENERATEALLDYNAMICPARAMETERS Extracts properties from the configuration 
% struct and instantiates all dynamic parameter scheduling classes.
%
% Inputs:
%   cfg_Encoder      - Struct containing network configuration and schedules
%
% Outputs:
%   LoadParameters   - Instance of cgg_generateLoadParameters_v2
%   WeightParameters - Instance of cgg_generateLossWeights_v2
%   FreezeParameters - Instance of cgg_generateFreezeParameters

    %% 1. Extract Properties from cfg_Encoder
    % Loss Weights
    WeightReconstruction  = cfg_Encoder.WeightReconstruction;
    WeightKL              = cfg_Encoder.WeightKL;
    WeightClassification  = cfg_Encoder.WeightClassification;
    WeightOffsetAndScale  = cfg_Encoder.WeightOffsetAndScale;
    WeightConfidence      = cfg_Encoder.WeightConfidence;
    DynamicWeighting      = cfg_Encoder.DynamicWeighting;

    % Load / Augmentation Parameters
    STDChannelOffset      = cfg_Encoder.STDChannelOffset;
    STDWhiteNoise         = cfg_Encoder.STDWhiteNoise;
    STDRandomWalk         = cfg_Encoder.STDRandomWalk;
    STDTimeShift          = cfg_Encoder.STDTimeShift;
    WantSeparateTimeShift = cfg_Encoder.WantSeparateTimeShift;
    DynamicAugmentation   = cfg_Encoder.DynamicAugmentation;
    
    % Freezing Parameters
    DynamicFreezing       = cfg_Encoder.DynamicFreezing;

    %% 2. Instantiate Dynamic Parameter Classes
    
    % Generate Freeze Parameters
    FreezeParameters = cgg_generateFreezeParameters( ...
        "DynamicFreezing", DynamicFreezing);
        
    % Generate Loss Weights
    WeightParameters = cgg_generateLossWeights_v2(...
        "DynamicWeighting", DynamicWeighting, ...
        "WeightReconstruction", WeightReconstruction, ...
        "WeightKL", WeightKL, ...
        "WeightClassification", WeightClassification, ...
        "WeightOffsetAndScale", WeightOffsetAndScale, ...
        'WeightConfidence', WeightConfidence);
        
    % Generate Load Parameters
    LoadParameters = cgg_generateLoadParameters_v2(...
        "DynamicAugmentation", DynamicAugmentation,...
        "STDChannelOffset", STDChannelOffset, ...
        "STDWhiteNoise", STDWhiteNoise, ...
        "STDRandomWalk", STDRandomWalk, ...
        "STDTimeShift", STDTimeShift, ...
        "WantSeparateTimeShift", WantSeparateTimeShift);

end