function [SweepName,SweepNameIgnore] = PARAMETERS_cggEncoderParameterSweep(SweepType)
%PARAMETERS_CGGENCODERPARAMETERSWEEP Summary of this function goes here
%   Detailed explanation goes here


%%
CurrentCases = {'Classifier Hidden Size','Classifier','Data Width', ...
    'Hidden Size','Initial Learning Rate','Variational','L_2 Factor', ...
    'Batch Size','Model','Data Augmentation','Unsupervised Epochs', ...
    'Optimizer','Normalization','Weighted Loss','Stride', ...
    'Gradient Accumulation Size','Loss Weights','Bottleneck Depth','Dropout', ...
    'Gradient Threshold','Decoder Loss Type','Layers','Initial Units',...
    'Classification Weight','KL Weight','Reconstruction Weight','Session',...
    'MultipleInstanceLearningType','Stratification','Data Augmentation', ...
    'Is Augmented','Has Loss Weighting','Dynamic Parameters'};
%%

SweepNameAlwaysIgnore = ["AccumulationInformation","BaselineDynamicParameters"];

switch SweepType
    case 'Classifier Hidden Size'
        SweepName = "ClassifierHiddenSize";
        SweepNameIgnore = [];
    case 'Classifier'
        SweepName = "ClassifierName";
        SweepNameIgnore = [];
    case 'Data Width'
        SweepName = "DataWidth";
        SweepNameIgnore = "WindowStride";
    case 'Hidden Size'
        SweepName = "HiddenSizes";
        SweepNameIgnore = ["maxworkerMiniBatchSize","NumberOfLayers","FirstHiddenSize"];
    case 'Initial Learning Rate'
        SweepName = "InitialLearningRate";
        SweepNameIgnore = [];
    case 'Variational'
        SweepName = "IsVariational";
        SweepNameIgnore = [];
    case 'L_2 Factor'
        SweepName = "L2Factor";
        SweepNameIgnore = [];
    case 'Batch Size'
        SweepName = "MiniBatchSize";
        SweepNameIgnore = "maxworkerMiniBatchSize";
    case 'Model'
        SweepName = "ModelName";
        SweepNameIgnore = ["HiddenSizes","maxworkerMiniBatchSize","Activation","FirstHiddenSize","WantNormalization","NumberOfLayers"];
        % SweepNameIgnore = ["HiddenSizes","maxworkerMiniBatchSize","Activation","WeightReconstruction","WeightClassification","WeightKL","WantNormalization","LossFactorKL","LossFactorReconstruction","FirstHiddenSize"];
    case 'Data Normalization'
        SweepName = "Normalization";
        SweepNameIgnore = [];
    case 'Unsupervised Epochs'
        SweepName = "NumEpochsAutoEncoder";
        SweepNameIgnore = "NumEpochsBase";
    case 'Optimizer'
        SweepName = "Optimizer";
        SweepNameIgnore = [];
    case 'Normalization'
        SweepName = "WantNormalization";
        SweepNameIgnore = [];
    case 'Weighted Loss'
        SweepName = "WeightedLoss";
        SweepNameIgnore = [];
    case 'Stride'
        SweepName = "WindowStride";
        SweepNameIgnore = "maxworkerMiniBatchSize";
    case 'Gradient Accumulation Size'
        SweepName = "maxworkerMiniBatchSize";
        SweepNameIgnore = "ModelName";
    case 'Loss Weights'
        SweepName = ["WeightReconstruction","WeightClassification","WeightKL"];
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction","HasLossWeighting"];
    case 'Reconstruction Weight'
        SweepName = "WeightReconstruction";
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction","HasLossWeighting"];
    case 'KL Weight'
        SweepName = "WeightKL";
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction","HasLossWeighting"];
    case 'Classification Weight'
        SweepName = "WeightClassification";
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction","HasLossWeighting"];
    case 'Bottleneck Depth'
        SweepName = "BottleNeckDepth";
        SweepNameIgnore = [];
    case 'Dropout'
        SweepName = "Dropout";
        SweepNameIgnore = [];
    case 'Gradient Threshold'
        SweepName = "GradientThreshold";
        SweepNameIgnore = [];
    case 'Decoder Loss Type'
        SweepName = "LossType_Decoder";
        SweepNameIgnore = [];
    case 'Layers'
        SweepName = "NumberOfLayers";
        SweepNameIgnore = ["HiddenSizes"];
    case 'Initial Units'
        SweepName = "FirstHiddenSize";
        SweepNameIgnore = ["HiddenSizes"];
    case 'Session'
        SweepName = "Subset";
        SweepNameIgnore = ["NumEpochsSession","NumEpochsFull"];
    case 'MultipleInstanceLearningType'
        SweepName = "MultipleInstanceLearningType";
        SweepNameIgnore = [];
    case 'Stratification'
        SweepName = "wantStratifiedPartition";
        SweepNameIgnore = [];
    case 'Data Augmentation'
        SweepName = ["STDChannelOffset","STDRandomWalk","STDWhiteNoise","STDTimeShift","WantSeparateTimeShift"];
        SweepNameIgnore = ["IsAugmented"];
    case 'Is Augmented'
        SweepName = "IsAugmented";
        SweepNameIgnore = ["STDChannelOffset","STDRandomWalk","STDWhiteNoise","STDTimeShift","WantSeparateTimeShift"];
    case 'Has Loss Weighting'
        SweepName = "HasLossWeighting";
        SweepNameIgnore = ["WeightReconstruction","WeightClassification","WeightKL","WeightOffsetAndScale","LossFactorKL","LossFactorReconstruction"];
    case 'Dynamic Parameters'
        SweepName = "DynamicParameterSet";
        SweepNameIgnore = ["HasLossWeighting","WeightReconstruction","WeightClassification","WeightKL","WeightOffsetAndScale","IsAugmented","STDChannelOffset","STDRandomWalk","STDWhiteNoise","STDTimeShift","WantSeparateTimeShift","LossFactorKL","LossFactorReconstruction","DynamicSetDescription","DynamicAugmentation","DynamicWeighting","DynamicFreezing"];
    otherwise
        SweepName = [];
        SweepNameIgnore = [];
end

SweepNameIgnore = [SweepNameIgnore,SweepNameAlwaysIgnore];


end

