function [DynamicAugmentation, DynamicWeighting, DynamicFreezing, DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(DynamicParameterSet)
%PARAMETERS_CGG_SELECTDYNAMICPARAMETERS Returns predefined sets of dynamic 
%schedules for weights, augmentations, and freezing factors.
%
% Inputs:
%   ParameterSet - String identifier for the regime to load
%
% Outputs:
%   DynamicAugmentation - Struct for LoadParameters schedule
%   DynamicWeighting    - Struct for LossWeights schedule
%   DynamicFreezing     - Struct for FreezeParameters schedule
%   SetDescription      - String describing the training regime

arguments (Input)
    DynamicParameterSet (1,1) string
end
arguments (Output)
    DynamicAugmentation struct
    DynamicWeighting struct
    DynamicFreezing struct
    DynamicSetDescription (1,1) string
end

% Pre-initialize empty structs so they are always safely defined
DynamicAugmentation = struct();
DynamicWeighting = struct();
DynamicFreezing = struct();

switch DynamicParameterSet
    
    case 'KL Annealing'
        DynamicSetDescription = "Beta-VAE style KL Annealing. KL weight starts near 0 and ramps up to 1 between epochs 10 and 100 to prevent posterior collapse.";
        
        DynamicWeighting.KL.EpochPoints = [10, 100];
        DynamicWeighting.KL.MagnitudePoints = [1e-4, 1.0];
        
    case 'Curriculum Augmentation'
        DynamicSetDescription = "Curriculum Learning. Starts with clean data, then smoothly introduces noise and channel offsets between epochs 50 and 150.";
        
        DynamicAugmentation.EpochPoints = [50, 150];
        DynamicAugmentation.MagnitudePoints = [1e-4, 1.0];
        
    case 'Hard Two-Stage'
        DynamicSetDescription = "Two-Stage Training. Epochs 0-100: Train AE only (Classifier frozen). Epochs 100+: Freeze AE, train Classifier only.";
        
        % Turn classification loss ON at epoch 100, turn others OFF
        DynamicWeighting.Classification.EpochPoints = [100, 100];
        DynamicWeighting.Classification.MagnitudePoints = [0, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [100, 100];
        DynamicWeighting.Confidence.MagnitudePoints = [0, 1.0];
        DynamicWeighting.Reconstruction.EpochPoints = [100, 100];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1.0, 0];
        DynamicWeighting.KL.EpochPoints = [100, 100];
        DynamicWeighting.KL.MagnitudePoints = [1.0, 0];
        
        % Freeze and unfreeze respective networks at epoch 100
        DynamicFreezing.Encoder.EpochPoints = [100, 100];
        DynamicFreezing.Encoder.MagnitudePoints = [1.0, 0];
        DynamicFreezing.Decoder.EpochPoints = [100, 100];
        DynamicFreezing.Decoder.MagnitudePoints = [1.0, 0];
        DynamicFreezing.Classifier.EpochPoints = [100, 100];
        DynamicFreezing.Classifier.MagnitudePoints = [0, 1.0];

    case 'Soft Two-Stage'
        DynamicSetDescription = "Two-Stage Training. Epochs 0-100: Train AE mostly (Classifier mostly frozen). Epochs 100+: mostly Freeze AE, train Classifier mostly.";
        
        % Turn classification loss ON at epoch 100, turn others OFF
        DynamicWeighting.Classification.EpochPoints = [0, 50, 150];
        DynamicWeighting.Classification.MagnitudePoints = [1e-4,1e-4, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [0, 50, 150];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-4,1e-4, 1.0];
        DynamicWeighting.Reconstruction.EpochPoints = [50, 150];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1.0, 1e-4];
        DynamicWeighting.KL.EpochPoints = [50, 150];
        DynamicWeighting.KL.MagnitudePoints = [1.0, 1e-4];
        
        % Freeze and unfreeze respective networks at epoch 100
        DynamicFreezing.Encoder.EpochPoints = [100, 150];
        DynamicFreezing.Encoder.MagnitudePoints = [1.0, 1e-4];
        DynamicFreezing.Decoder.EpochPoints = [100, 150];
        DynamicFreezing.Decoder.MagnitudePoints = [1.0, 1e-4];
        DynamicFreezing.Classifier.EpochPoints = [0, 50, 150];
        DynamicFreezing.Classifier.MagnitudePoints = [1e-4,1e-4, 1.0];

    case 'Soft Two-Stage Curriculum'
        DynamicSetDescription = "Soft Two-Stage Curriculum Training. Epochs 0-100: Train AE mostly (Classifier mostly frozen). Epochs 100+: mostly Freeze AE, train Classifier mostly. Curriculum Learning. Starts with clean data, then smoothly introduces noise and channel offsets between epochs 50 and 150.";
        
        % Turn classification loss ON at epoch 100, turn others close to
        % off
        DynamicWeighting.Classification.EpochPoints = [0, 50, 150];
        DynamicWeighting.Classification.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [0, 50, 150];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Reconstruction.EpochPoints = [50, 150];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1.0, 1e-2];
        DynamicWeighting.KL.EpochPoints = [50, 150];
        DynamicWeighting.KL.MagnitudePoints = [1.0, 1e-2];
        
        % mostly Freeze and mostly unfreeze respective networks at epoch 100
        DynamicFreezing.Encoder.EpochPoints = [100, 150];
        DynamicFreezing.Encoder.MagnitudePoints = [1.0, 1e-2];
        DynamicFreezing.Decoder.EpochPoints = [100, 150];
        DynamicFreezing.Decoder.MagnitudePoints = [1.0, 1e-2];
        DynamicFreezing.Classifier.EpochPoints = [0, 50, 150];
        DynamicFreezing.Classifier.MagnitudePoints = [1e-2,1e-2, 1.0];

        DynamicAugmentation.EpochPoints = [50, 150];
        DynamicAugmentation.MagnitudePoints = [1e-2, 1.0];

    case 'Soft Two-Stage Curriculum - Version 2'
        DynamicSetDescription = "Soft Two-Stage Curriculum Training Version 2. Epochs 0-100: Train AE mostly (Classifier mostly frozen). Epochs 100+: mostly Freeze AE, train Classifier mostly. Curriculum Learning. Starts with clean data, then smoothly introduces noise and channel offsets between epochs 50 and 150.";
        
        % Turn classification loss ON at epoch 100, turn others close to
        % off
        DynamicWeighting.Classification.EpochPoints = [0, 50, 150];
        DynamicWeighting.Classification.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [0, 50, 150];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Reconstruction.EpochPoints = [50, 100,150];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1.0, 1.0, 1e-2];
        DynamicWeighting.KL.EpochPoints = [50, 100,150];
        DynamicWeighting.KL.MagnitudePoints = [1.0, 1.0, 1e-2];
        
        % mostly Freeze and mostly unfreeze respective networks at epoch 100
        DynamicFreezing.Encoder.EpochPoints = [100, 150];
        DynamicFreezing.Encoder.MagnitudePoints = [1.0, 1e-2];
        DynamicFreezing.Decoder.EpochPoints = [100, 150];
        DynamicFreezing.Decoder.MagnitudePoints = [1.0, 1e-2];
        DynamicFreezing.Classifier.EpochPoints = [0, 50, 150];
        DynamicFreezing.Classifier.MagnitudePoints = [1e-2,1e-2, 1.0];

        DynamicAugmentation.EpochPoints = [50, 150];
        DynamicAugmentation.MagnitudePoints = [1e-2, 1.0];

    case 'Soft Three-Stage Curriculum'
        DynamicSetDescription = "Soft Three-Stage Curriculum Training. First: Train AE mostly (Classifier mostly frozen). Second: mostly Freeze AE, train Classifier mostly. Curriculum Learning. Starts with clean data, then smoothly introduces noise and channel offsets. Noise is then smoothly removed with classifier only changing. Then all components are available to train for classification on easy data";
        
        % Turn classification loss ON at epoch 100, turn others close to
        % off
        DynamicWeighting.Classification.EpochPoints = [0, 50, 75];
        DynamicWeighting.Classification.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [0, 50, 75];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Reconstruction.EpochPoints = [100, 150];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1.0, 1e-2];
        DynamicWeighting.KL.EpochPoints = [100, 150];
        DynamicWeighting.KL.MagnitudePoints = [1.0, 1e-2];
        
        % mostly Freeze and mostly unfreeze respective networks at epoch 100
        DynamicFreezing.Encoder.EpochPoints = [100, 125, 225, 230];
        DynamicFreezing.Encoder.MagnitudePoints = [1.0, 1e-2, 1e-2,1.0];
        DynamicFreezing.Decoder.EpochPoints = [100, 125, 225, 230];
        DynamicFreezing.Decoder.MagnitudePoints = [1.0, 1e-2, 1e-2,1.0];
        DynamicFreezing.Classifier.EpochPoints = [0, 50, 75];
        DynamicFreezing.Classifier.MagnitudePoints = [1e-2,1e-2, 1.0];

        DynamicAugmentation.EpochPoints = [25, 50, 125, 225];
        DynamicAugmentation.MagnitudePoints = [1e-2, 1.0, 1.0, 1e-2];

    case 'Soft Three-Stage Curriculum - Shortened'
        DynamicSetDescription = "Soft Three-Stage Curriculum Training. First: Train AE mostly (Classifier mostly frozen). Second: mostly Freeze AE, train Classifier mostly. Curriculum Learning. Starts with clean data, then smoothly introduces noise and channel offsets. Noise is then smoothly removed with classifier only changing. Then all components are available to train for classification on easy data";
        
        % Turn classification loss ON at epoch 100, turn others close to
        % off
        DynamicWeighting.Classification.EpochPoints = [0, 10, 15];
        DynamicWeighting.Classification.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [0, 10, 15];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-2,1e-2, 1.0];
        DynamicWeighting.Reconstruction.EpochPoints = [20, 30];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1.0, 1e-2];
        DynamicWeighting.KL.EpochPoints = [20, 30];
        DynamicWeighting.KL.MagnitudePoints = [1.0, 1e-2];
        
        % mostly Freeze and mostly unfreeze respective networks at epoch 100
        DynamicFreezing.Encoder.EpochPoints = [20, 25, 45, 46];
        DynamicFreezing.Encoder.MagnitudePoints = [1.0, 1e-2, 1e-2,1.0];
        DynamicFreezing.Decoder.EpochPoints = [20, 25, 45, 46];
        DynamicFreezing.Decoder.MagnitudePoints = [1.0, 1e-2, 1e-2,1.0];
        DynamicFreezing.Classifier.EpochPoints = [0, 10, 15];
        DynamicFreezing.Classifier.MagnitudePoints = [1e-2,1e-2, 1.0];

        DynamicAugmentation.EpochPoints = [5, 10, 25, 45];
        DynamicAugmentation.MagnitudePoints = [1e-2, 1.0, 1.0, 1e-2];
        
    case 'Delayed Classification'
        DynamicSetDescription = "End-to-End Fine-Tuning. AE trains alone for 50 epochs to find good features, then Classification loss ramps up to train end-to-end.";
        
        DynamicWeighting.Classification.EpochPoints = [50, 100];
        DynamicWeighting.Classification.MagnitudePoints = [1e-4, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [50, 100];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-4, 1.0];
        
    case 'Combined'
        DynamicSetDescription = "Combined Schedule: Delayed Classification, and Curriculum Augmentation applied simultaneously.";
        
        % Weights
        DynamicWeighting.Classification.EpochPoints = [50, 120];
        DynamicWeighting.Classification.MagnitudePoints = [1e-4, 1.0];
        DynamicWeighting.Confidence.EpochPoints = [50, 120];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-4, 1.0];
        
        % Augmentations
        DynamicAugmentation.WhiteNoise.EpochPoints = [100, 200];
        DynamicAugmentation.WhiteNoise.MagnitudePoints = [1e-4, 1.0];
        DynamicAugmentation.ChannelOffset.EpochPoints = [100, 200];
        DynamicAugmentation.ChannelOffset.MagnitudePoints = [1e-4, 1.0];

    case 'Full Combination'
        DynamicSetDescription = "Combined Schedule: Delayed Classification, and Curriculum Augmentation applied simultaneously.";
        
        % Static Reconstruction and KL with ramping Classification to Loss
        DynamicWeighting = struct();
        DynamicWeighting.Reconstruction.EpochPoints = [100,100];
        DynamicWeighting.Reconstruction.MagnitudePoints = [1,1];
        DynamicWeighting.KL.EpochPoints = [100,100];
        DynamicWeighting.KL.MagnitudePoints = [1,1];
        DynamicWeighting.Classification.EpochPoints = [100,100];
        DynamicWeighting.Classification.MagnitudePoints = [1e-4,1];
        DynamicWeighting.Confidence.EpochPoints = [100,100];
        DynamicWeighting.Confidence.MagnitudePoints = [1e-4,1];

        % Curriculum Learning from easy clean data to harder noisier data
        DynamicAugmentation.EpochPoints = [50,150];
        DynamicAugmentation.MagnitudePoints = [1e-4,1];

        % Classifier is slowly changed then allowed to learn regularly
        % while the autoencoder is opposite
        DynamicFreezing = struct();
        DynamicFreezing.EpochPoints = [0,25,50];
        DynamicFreezing.MagnitudePoints = [0,0,1];

    case 'No Dynamic Parameters'
        DynamicSetDescription = "Specifc Set for use when comparing to dynamic sets that change. Different than None since None is somewhat a default in cgg_runAutoEncoder";

    case 'None'
        DynamicSetDescription = "Baseline. No Dynamic Parameters are set. The parameters will remain constant throughout training.";
        
    otherwise
        warning('ParameterSet "%s" not recognized. Defaulting to "None".', DynamicParameterSet);
        DynamicSetDescription = "Baseline. No Dynamic Parameters are set. The parameters will remain constant throughout training.";

end

end