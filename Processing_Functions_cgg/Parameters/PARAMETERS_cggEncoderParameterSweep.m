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
    'Classification Weight','KL Weight','Reconstruction Weight','Session'};
%%

SweepNameAlwaysIgnore = "AccumulationInformation";

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
    case 'Data Augmentation'
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
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction"];
    case 'Reconstruction Weight'
        SweepName = "WeightReconstruction";
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction"];
    case 'KL Weight'
        SweepName = "WeightKL";
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction"];
    case 'Classification Weight'
        SweepName = "WeightClassification";
        SweepNameIgnore = ["LossFactorKL","LossFactorReconstruction"];
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
    otherwise
        SweepName = [];
        SweepNameIgnore = [];
end

SweepNameIgnore = [SweepNameIgnore,SweepNameAlwaysIgnore];


end

