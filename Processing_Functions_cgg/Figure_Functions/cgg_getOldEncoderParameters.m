function Encoding_Dir = cgg_getOldEncoderParameters(cfg_Encoder)
%CGG_GETOLDENCODERPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

WindowStride=cfg_Encoder.WindowStride;
DataWidth=cfg_Encoder.DataWidth;
wantSubset=cfg_Encoder.wantSubset;

HiddenSize=cfg_Encoder.HiddenSizes;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName = cfg_Encoder.ModelName;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
MiniBatchSize = cfg_Encoder.MiniBatchSize;
% LossFactorReconstruction = cfg_Encoder.LossFactorReconstruction;
% LossFactorKL = cfg_Encoder.LossFactorKL;
WeightedLoss = cfg_Encoder.WeightedLoss;
GradientThreshold = cfg_Encoder.GradientThreshold;
Optimizer = cfg_Encoder.Optimizer;
WeightReconstruction = cfg_Encoder.WeightReconstruction;
WeightKL = cfg_Encoder.WeightKL;
WeightClassification = cfg_Encoder.WeightClassification;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
Normalization = cfg_Encoder.Normalization;
LossType_Decoder = cfg_Encoder.LossType_Decoder;

STDChannelOffset = cfg_Encoder.STDChannelOffset;
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
STDRandomWalk = cfg_Encoder.STDRandomWalk;


cfg = cgg_generateEncoderSubFolders('',ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder,'WantDirectory',false);
Encoding_Dir = cgg_getDirectory(cfg,'Classifier');
end

