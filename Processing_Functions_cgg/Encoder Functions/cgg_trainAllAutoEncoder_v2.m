function [Encoder,Decoder,Classifier] = cgg_trainAllAutoEncoder_v2(DataStore_Training,DataStore_Validation,DataStore_Testing,cfg_Encoder,cfg_Network)
%CGG_TRAINALLAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

HiddenSizes=cfg_Encoder.HiddenSizes;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
MiniBatchSize=cfg_Encoder.MiniBatchSize;
GradientThreshold=cfg_Encoder.GradientThreshold;
NumEpochsFull = cfg_Encoder.NumEpochsFull;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName=cfg_Encoder.ModelName;
WeightReconstruction=cfg_Encoder.WeightReconstruction;
WeightKL=cfg_Encoder.WeightKL;
WeightClassification=cfg_Encoder.WeightClassification;
RescaleLossEpoch = cfg_Encoder.RescaleLossEpoch;
WeightedLoss = cfg_Encoder.WeightedLoss;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
Optimizer = cfg_Encoder.Optimizer;
LossType_Decoder = cfg_Encoder.LossType_Decoder;
LossType_Classifier = cfg_Encoder.LossType_Classifier;

maxworkerMiniBatchSize=cfg_Encoder.maxworkerMiniBatchSize;

IsQuaddle=cfg_Encoder.IsQuaddle;

WantSaveNet = cfg_Encoder.WantSaveNet;

ValidationFrequency = cfg_Encoder.ValidationFrequency;
SaveFrequency = cfg_Encoder.SaveFrequency;
IterationSaveFrequency = cfg_Encoder.IterationSaveFrequency;

LearningRateDecay = cfg_Encoder.LearningRateDecay;
LearningRateEpochDrop = cfg_Encoder.LearningRateEpochDrop;
LearningRateEpochRamp = cfg_Encoder.LearningRateEpochRamp;

%% Directories

Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');
AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoderInformation');

%%

Values_Examples=read(DataStore_Training);

Example_Data=Values_Examples{1};

DataSize=size(Example_Data);

InputSize=DataSize(1:3);
NumWindows=1;

if length(DataSize)>3
NumWindows=DataSize(4);
end

%%

% SessionNames=unique(SessionsList);
% NumSessions=length(SessionNames);

%%
[ClassNames,NumClasses,~,~] = cgg_getClassesFromDataStore(DataStore_Training);
NumDimensions = length(ClassNames);
%%

DataFormat={'SSCTB','CBT',''};

if NumWindows==1
DataFormat{1}='SSCBT';
end
if NumDimensions <= 1
    DataFormat{2}='BCT';
end

%%

AutoEncoder_EncoderSavePathNameExt = [AutoEncoding_Dir filesep 'Encoder-Current.mat'];
AutoEncoder_DecoderSavePathNameExt = [AutoEncoding_Dir filesep 'Decoder-Current.mat'];

FullNetwork_EncoderSavePathNameExt = [Encoding_Dir filesep 'Encoder-Current.mat'];
FullNetwork_DecoderSavePathNameExt = [Encoding_Dir filesep 'Decoder-Current.mat'];
FullNetwork_ClassifierSavePathNameExt = [Encoding_Dir filesep 'Classifier-Current.mat'];

HasFullNetwork = isfile(FullNetwork_EncoderSavePathNameExt) && ...
    isfile(FullNetwork_DecoderSavePathNameExt) && ...
    isfile(FullNetwork_ClassifierSavePathNameExt);

HasAutoEncoder = isfile(AutoEncoder_EncoderSavePathNameExt) && ...
    isfile(AutoEncoder_DecoderSavePathNameExt);

%%
if HasFullNetwork
    m_FullNetwork_Encoder = matfile(FullNetwork_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_FullNetwork_Encoder.Encoder;
    m_FullNetwork_Decoder = matfile(FullNetwork_DecoderSavePathNameExt,"Writable",false);
    Decoder=m_FullNetwork_Decoder.Decoder;
    m_FullNetwork_Classifier = matfile(FullNetwork_ClassifierSavePathNameExt,"Writable",false);
    Classifier=m_FullNetwork_Classifier.Classifier;
elseif HasAutoEncoder
    m_AutoEncoder_Encoder = matfile(AutoEncoder_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_AutoEncoder_Encoder.Encoder;
    m_AutoEncoder_Decoder = matfile(AutoEncoder_DecoderSavePathNameExt,"Writable",false);
    Decoder=m_AutoEncoder_Decoder.Decoder;
else
    [Encoder,Decoder] = cgg_constructNetworkArchitecture(ModelName,'InputSize',InputSize,'HiddenSize',HiddenSizes);
    Encoder = initialize(Encoder);
    Decoder = initialize(Decoder);
end

%%
    cfg_Monitor = cgg_generateMonitorCFG(cfg_Encoder,Encoder,Decoder,[],'SaveDir',AutoEncoding_Dir,'NumEpochs',NumEpochsAutoEncoder);
    
%% Train AutoEncoder

[Encoder,Decoder,~] = cgg_trainNetwork(Encoder,...
    DataStore_Training,DataStore_Validation,DataStore_Testing,...
    'Decoder',Decoder,'Optimizer',Optimizer,'WeightedLoss',WeightedLoss,...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle,...
    'WeightReconstruction',WeightReconstruction,...
    'WeightKL',WeightKL,...
    'WeightClassification',WeightClassification,...
    'GradientThreshold',GradientThreshold,...
    'LossType_Decoder',LossType_Decoder,...
    'NumEpochs',NumEpochsAutoEncoder,'SaveDir',AutoEncoding_Dir,...
    'ValidationFrequency',ValidationFrequency,...
    'SaveFrequency',SaveFrequency,'MiniBatchSize',MiniBatchSize,...
    'InitialLearningRate',InitialLearningRate,...
    'LearningRateDecay',LearningRateDecay,...
    'LearningRateEpochDrop',LearningRateEpochDrop,...
    'LearningRateEpochRamp',LearningRateEpochRamp,...
    'WantSaveNet',WantSaveNet,...
    'IterationSaveFrequency',IterationSaveFrequency,...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,...
    'RescaleLossEpoch',RescaleLossEpoch,'cfg_Monitor',cfg_Monitor);

%% Full Network (Encoder, Decoder, Classifier)

if ~isfile(FullNetwork_ClassifierSavePathNameExt)
    HiddenSizeBottleNeck = cgg_getBottleNeckSize(Encoder);
    
    Classifier = cgg_constructClassifierArchitecture(NumClasses,...
        'ClassifierName',ClassifierName,...
        'ClassifierHiddenSize',ClassifierHiddenSize,...
        'LossType',LossType_Classifier,...
        'HiddenSizeBottleNeck',HiddenSizeBottleNeck);
    Classifier = initialize(Classifier);
end

%%

    cfg_Monitor = cgg_generateMonitorCFG(cfg_Encoder,Encoder,...
        Decoder,Classifier,'SaveDir',Encoding_Dir,...
        'NumEpochs',NumEpochsFull);
    %%
[Encoder,Decoder,Classifier] = cgg_trainNetwork(Encoder,...
    DataStore_Training,DataStore_Validation,DataStore_Testing,...
    'Decoder',Decoder,'Classifier',Classifier,...
    'Optimizer',Optimizer,'WeightedLoss',WeightedLoss,...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle,...
    'WeightReconstruction',WeightReconstruction,...
    'WeightKL',WeightKL,...
    'WeightClassification',WeightClassification,...
    'GradientThreshold',GradientThreshold,...
    'LossType_Decoder',LossType_Decoder,...
    'NumEpochs',NumEpochsFull,'SaveDir',Encoding_Dir,...
    'ValidationFrequency',ValidationFrequency,...
    'SaveFrequency',SaveFrequency,'MiniBatchSize',MiniBatchSize,...
    'InitialLearningRate',InitialLearningRate,...
    'LearningRateDecay',LearningRateDecay,...
    'LearningRateEpochDrop',LearningRateEpochDrop,...
    'LearningRateEpochRamp',LearningRateEpochRamp,...
    'WantSaveNet',WantSaveNet,...
    'IterationSaveFrequency',IterationSaveFrequency,...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,...
    'RescaleLossEpoch',RescaleLossEpoch,'cfg_Monitor',cfg_Monitor);

end
