function [Encoder,Decoder,Classifier] = cgg_trainAllAutoEncoder_v2(DataStore_Training,DataStore_Validation,DataStore_Testing,cfg_Encoder,cfg_Network,varargin)
%CGG_TRAINALLAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
PCAInformation = CheckVararginPairs('PCAInformation', [], varargin{:});
else
if ~(exist('PCAInformation','var'))
PCAInformation=[];
end
end

if isfunction
LoadParameters = CheckVararginPairs('LoadParameters', [], varargin{:});
else
if ~(exist('LoadParameters','var'))
LoadParameters=[];
end
end

if isfunction
WeightParameters = CheckVararginPairs('WeightParameters', [], varargin{:});
else
if ~(exist('WeightParameters','var'))
WeightParameters=[];
end
end

if isfunction
FreezeParameters = CheckVararginPairs('FreezeParameters', [], varargin{:});
else
if ~(exist('FreezeParameters','var'))
FreezeParameters=[];
end
end

if isfunction
AccuracyType = CheckVararginPairs('AccuracyType', 'Aggregate', varargin{:});
else
if ~(exist('AccuracyType','var'))
AccuracyType='Aggregate';
end
end

%% Messages
MessageUnsupervised = '+++ Unsupervised Training\n';
MessageSupervised = '+++ Supervised Training\n';
MessageEnd = '=== End of Run\n';
MessageDelete_Current = '!!! Deleting Current Run Networks - Keeping Optimal\n';
MessageDelete_Optimal = '!!! Deleting Optimal Networks - Keeping None\n';

MessageGenerating_Model = '*** Generating %s\n'; % Model
MessageLoading_Model = '*** Loading %s %s %s\n'; % TrainingStage, Optimality, Model
MessageFreezing_Model = '*** Freezing %s %s %s\n'; % TrainingStage, Optimality, Model

MessageModelPath = '??? Model Path: %s\n'; % Encoding_Dir

%%

HiddenSizes=cfg_Encoder.HiddenSizes;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
MiniBatchSize=cfg_Encoder.MiniBatchSize;
GradientThreshold=cfg_Encoder.GradientThreshold;
GradientClipType = cfg_Encoder.GradientClipType;
NumEpochsFull = cfg_Encoder.NumEpochsFull;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName=cfg_Encoder.ModelName;
WeightReconstruction=cfg_Encoder.WeightReconstruction;
WeightKL=cfg_Encoder.WeightKL;
WeightClassification=cfg_Encoder.WeightClassification;
WeightOffsetAndScale=cfg_Encoder.WeightOffsetAndScale;
WeightConfidence=cfg_Encoder.WeightConfidence;
RescaleLossEpoch = cfg_Encoder.RescaleLossEpoch;
PriorProportion = cfg_Encoder.PriorProportion;
WeightedLoss = cfg_Encoder.WeightedLoss;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
MultipleInstanceLearningType = cfg_Encoder.MultipleInstanceLearningType;
ConfidenceType = cfg_Encoder.ConfidenceType;
WantBatchCorrection = cfg_Encoder.WantBatchCorrection;
Optimizer = cfg_Encoder.Optimizer;
LossType_Decoder = cfg_Encoder.LossType_Decoder;
LossType_Classifier = cfg_Encoder.LossType_Classifier;
L2Factor = cfg_Encoder.L2Factor;

Freeze_cfg_Default = cfg_Encoder.Freeze_cfg;

% maxworkerMiniBatchSize=cfg_Encoder.maxworkerMiniBatchSize;

maxworkerMiniBatchSize = cgg_getAccumulationSizeForCurrentSystem(cfg_Encoder.AccumulationInformation);

IsQuaddle=cfg_Encoder.IsQuaddle;

WantSaveNet = cfg_Encoder.WantSaveNet;
WantSaveOptimalNet = cfg_Encoder.WantSaveOptimalNet;
WantSaveNet_tmp = true;

ValidationFrequency = cfg_Encoder.ValidationFrequency;
SaveFrequency = cfg_Encoder.SaveFrequency;
IterationSaveFrequency = cfg_Encoder.IterationSaveFrequency;

LearningRateDecay = cfg_Encoder.LearningRateDecay;
LearningRateEpochDrop = cfg_Encoder.LearningRateEpochDrop;
LearningRateEpochRamp = cfg_Encoder.LearningRateEpochRamp;

WeightDelayEpoch = cfg_Encoder.WeightDelayEpoch;
WeightEpochRamp = cfg_Encoder.WeightEpochRamp;

Freeze_cfg_Autoencoder = struct();
Freeze_cfg_FullNetwork = struct();

%% Directories

Encoding_Dir = cgg_getDirectory(cfg_Network, 'Fold', 'Classifier');
AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoderFold','AutoEncoderInformation');

%%

Values_Examples=read(DataStore_Training);

Example_Data=Values_Examples{1};

DataSize=size(Example_Data);

InputSize=DataSize(1:3);
NumWindows=1;

if strcmp(ModelName,'Logistic Regression')
    HiddenSizes = [];
    ClassifierName = 'Logistic';
end

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

%% Get File Names

AutoEncoder_EncoderSavePathNameExt = [AutoEncoding_Dir filesep 'Encoder-Current.mat'];
AutoEncoder_DecoderSavePathNameExt = [AutoEncoding_Dir filesep 'Decoder-Current.mat'];

FullNetwork_EncoderSavePathNameExt = [Encoding_Dir filesep 'Encoder-Current.mat'];
FullNetwork_DecoderSavePathNameExt = [Encoding_Dir filesep 'Decoder-Current.mat'];
FullNetwork_ClassifierSavePathNameExt = [Encoding_Dir filesep 'Classifier-Current.mat'];

AutoEncoder_Optimal_EncoderSavePathNameExt = [AutoEncoding_Dir filesep 'Encoder-Optimal.mat'];
AutoEncoder_Optimal_DecoderSavePathNameExt = [AutoEncoding_Dir filesep 'Decoder-Optimal.mat'];

%%
HasFull_Current_Encoder = isfile(FullNetwork_EncoderSavePathNameExt);
HasFull_Current_Decoder = isfile(FullNetwork_DecoderSavePathNameExt);
HasFull_Current_Classifier = isfile(FullNetwork_EncoderSavePathNameExt);

HasAutoEncoder_Encoder_Current = isfile(AutoEncoder_EncoderSavePathNameExt);
HasAutoEncoder_Decoder_Current = isfile(AutoEncoder_DecoderSavePathNameExt);

HasFullNetwork = HasFull_Current_Encoder && ...
    HasFull_Current_Decoder && ...
    HasFull_Current_Classifier;

HasAutoEncoder = HasAutoEncoder_Encoder_Current && ...
    HasAutoEncoder_Decoder_Current;

%% 
if HasFullNetwork
    fprintf(MessageLoading_Model,'Full Network', 'Current', 'Encoder');
    m_FullNetwork_Encoder = matfile(FullNetwork_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_FullNetwork_Encoder.Encoder;
    fprintf(MessageLoading_Model,'Full Network', 'Current', 'Decoder');
    m_FullNetwork_Decoder = matfile(FullNetwork_DecoderSavePathNameExt,"Writable",false);
    Decoder=m_FullNetwork_Decoder.Decoder;
    % m_FullNetwork_Classifier = matfile(FullNetwork_ClassifierSavePathNameExt,"Writable",false);
    % Classifier=m_FullNetwork_Classifier.Classifier;
elseif HasAutoEncoder
    fprintf(MessageLoading_Model,'Autoencoder', 'Current', 'Encoder');
    m_AutoEncoder_Encoder = matfile(AutoEncoder_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_AutoEncoder_Encoder.Encoder;
    fprintf(MessageLoading_Model,'Autoencoder', 'Current', 'Decoder');
    m_AutoEncoder_Decoder = matfile(AutoEncoder_DecoderSavePathNameExt,"Writable",false);
    Decoder=m_AutoEncoder_Decoder.Decoder;
elseif HasFull_Current_Encoder && strcmp(LossType_Decoder,'None')
    fprintf(MessageLoading_Model,'Full Network', 'Current', 'Encoder');
    m_FullNetwork_Encoder = matfile(FullNetwork_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_FullNetwork_Encoder.Encoder;
    Decoder = [];
elseif HasAutoEncoder_Encoder_Current && strcmp(LossType_Decoder,'None')
    fprintf(MessageLoading_Model,'Autoencoder', 'Current', 'Encoder');
    m_AutoEncoder_Encoder = matfile(AutoEncoder_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_AutoEncoder_Encoder.Encoder;
    Decoder = [];
elseif strcmp(LossType_Decoder,'None')
    fprintf(MessageGenerating_Model,'Encoder');
    [Encoder,~] = cgg_constructNetworkArchitecture(ModelName,'InputSize',InputSize,'HiddenSize',HiddenSizes,'cfg_Encoder',cfg_Encoder,'PCAInformation',PCAInformation);
    Decoder = [];
else
    fprintf(MessageGenerating_Model,'Encoder and Decoder');
    [Encoder,Decoder] = cgg_constructNetworkArchitecture(ModelName,'InputSize',InputSize,'HiddenSize',HiddenSizes,'cfg_Encoder',cfg_Encoder,'PCAInformation',PCAInformation);
    Encoder = initialize(Encoder);
    Decoder = initialize(Decoder);
end

% %%
% if strcmp(LossType_Decoder,'None')
%     Decoder = [];
% end
%%
    cfg_Monitor = cgg_generateMonitorCFG(cfg_Encoder,Encoder,Decoder,[],'SaveDir',AutoEncoding_Dir,'NumEpochs',NumEpochsAutoEncoder,'NumWindows',NumWindows);
    
%% Train AutoEncoder
fprintf(MessageUnsupervised);
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
    'WeightDelayEpoch',WeightDelayEpoch,...
    'WeightEpochRamp',WeightEpochRamp,...
    'WantSaveNet',WantSaveNet_tmp,...
    'IterationSaveFrequency',IterationSaveFrequency,...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,...
    'RescaleLossEpoch',RescaleLossEpoch,'cfg_Monitor',cfg_Monitor, ...
    'L2Factor',L2Factor,'WantSaveOptimalNet',true, ...
    'WeightOffsetAndScale',WeightOffsetAndScale, ...
    'GradientClipType',GradientClipType, ...
    'Freeze_cfg',Freeze_cfg_Autoencoder, ...
    'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
    'LoadParameters',LoadParameters, ...
    'WeightParameters',WeightParameters, ...
    'FreezeParameters',FreezeParameters, ...
    'AccuracyType',AccuracyType,'WeightConfidence',WeightConfidence, ...
    'PriorProportion',PriorProportion, ...
    'WantBatchCorrection',WantBatchCorrection);

%% Get Optimal Autoencoder

HasAutoEncoder_Optimal_Encoder = isfile(AutoEncoder_Optimal_EncoderSavePathNameExt);
HasAutocoder_Optimal_Decoder = isfile(AutoEncoder_Optimal_DecoderSavePathNameExt);

HasAutoEncoder_Optimal = HasAutoEncoder_Optimal_Encoder && ...
    HasAutocoder_Optimal_Decoder;

% Get the optimal autoencoder only if it exists. Otherwise the current
% autoencoder is used

% TODO: Why is the Freeze_cfg setup like this???
if HasAutoEncoder_Optimal && ~(HasFull_Current_Encoder && HasFull_Current_Decoder)
    fprintf(MessageLoading_Model,'Autoencoder', 'Optimal', 'Encoder');
    m_AutoEncoder_Encoder = matfile(AutoEncoder_Optimal_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_AutoEncoder_Encoder.Encoder;
    fprintf(MessageLoading_Model,'Autoencoder', 'Optimal', 'Decoder');
    m_AutoEncoder_Decoder = matfile(AutoEncoder_Optimal_DecoderSavePathNameExt,"Writable",false);
    Decoder=m_AutoEncoder_Decoder.Decoder;
    fprintf(MessageFreezing_Model,'Autoencoder', 'Optimal', 'Encoder and Decoder');
    Freeze_cfg_FullNetwork.Encoder = Freeze_cfg_Default.Encoder;
    Freeze_cfg_FullNetwork.Decoder = Freeze_cfg_Default.Decoder;
elseif HasAutoEncoder_Optimal_Encoder && ~HasFull_Current_Encoder && strcmp(LossType_Decoder,'None')
    fprintf(MessageLoading_Model,'Autoencoder', 'Optimal', 'Encoder');
    m_AutoEncoder_Encoder = matfile(AutoEncoder_Optimal_EncoderSavePathNameExt,"Writable",false);
    Encoder=m_AutoEncoder_Encoder.Encoder;
    fprintf(MessageFreezing_Model,'Autoencoder', 'Optimal', 'Encoder');
    Freeze_cfg_FullNetwork.Encoder = Freeze_cfg_Default.Encoder;
end

%%
Freeze_cfg_FullNetwork = Freeze_cfg_Default;
%% Full Network (Encoder, Decoder, Classifier)

if ~HasFull_Current_Classifier
    fprintf(MessageGenerating_Model,'Classifier');
    HiddenSizeBottleNeck = cgg_getBottleNeckSize(Encoder);

    % if ~(WeightConfidence ~=0 && all(strcmp(string(ConfidenceType),"")))
    % ConfidenceType = 'Trial Confidence';
    % else
    % ConfidenceType = '';
    % end
    
    Classifier = cgg_constructClassifierArchitecture(NumClasses,...
        'ClassifierName',ClassifierName,...
        'ClassifierHiddenSize',ClassifierHiddenSize,...
        'LossType',LossType_Classifier,...
        'HiddenSizeBottleNeck',HiddenSizeBottleNeck, ...
        'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
        'ConfidenceType',ConfidenceType);
    Classifier = initialize(Classifier);
else
    fprintf(MessageLoading_Model,'Full Network', 'Current', 'Classifier');
    m_FullNetwork_Classifier = matfile(FullNetwork_ClassifierSavePathNameExt,"Writable",false);
    Classifier=m_FullNetwork_Classifier.Classifier;
end

%%

    cfg_Monitor = cgg_generateMonitorCFG(cfg_Encoder,Encoder,...
        Decoder,Classifier,'SaveDir',Encoding_Dir,...
        'NumEpochs',NumEpochsFull,'NumWindows',NumWindows);
    %%
fprintf(MessageSupervised);
fprintf(MessageModelPath,Encoding_Dir);
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
    'WeightDelayEpoch',WeightDelayEpoch,...
    'WeightEpochRamp',WeightEpochRamp,...
    'WantSaveNet',WantSaveNet_tmp,...
    'IterationSaveFrequency',IterationSaveFrequency,...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,...
    'RescaleLossEpoch',RescaleLossEpoch,'cfg_Monitor',cfg_Monitor, ...
    'L2Factor',L2Factor,'WantSaveOptimalNet',WantSaveOptimalNet, ...
    'WeightOffsetAndScale',WeightOffsetAndScale, ...
    'GradientClipType',GradientClipType, ...
    'Freeze_cfg',Freeze_cfg_FullNetwork, ...
    'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
    'LoadParameters',LoadParameters, ...
    'WeightParameters',WeightParameters, ...
    'FreezeParameters',FreezeParameters, ...
    'AccuracyType',AccuracyType,'WeightConfidence',WeightConfidence, ...
    'PriorProportion',PriorProportion, ...
    'WantBatchCorrection',WantBatchCorrection);


%%
if ~WantSaveNet
    fprintf(MessageDelete_Current);
    cgg_deleteNetworks(cfg_Network,'Optimality','Current');
    % if isfile(FullNetwork_EncoderSavePathNameExt)
    %     delete(FullNetwork_EncoderSavePathNameExt);
    % end
    % if isfile(FullNetwork_DecoderSavePathNameExt)
    %     delete(FullNetwork_DecoderSavePathNameExt);
    % end
    % if isfile(FullNetwork_ClassifierSavePathNameExt)
    %     delete(FullNetwork_ClassifierSavePathNameExt);
    % end
    % if isfile(AutoEncoder_EncoderSavePathNameExt)
    %     delete(AutoEncoder_EncoderSavePathNameExt);
    % end
    % if isfile(AutoEncoder_DecoderSavePathNameExt)
    %     delete(AutoEncoder_DecoderSavePathNameExt);
    % end
end

if ~WantSaveOptimalNet
    % AutoEncoder_EncoderSavePathNameExt = [AutoEncoding_Dir filesep 'Encoder-Optimal.mat'];
    % AutoEncoder_DecoderSavePathNameExt = [AutoEncoding_Dir filesep 'Decoder-Optimal.mat'];
    % 
    % FullNetwork_EncoderSavePathNameExt = [Encoding_Dir filesep 'Encoder-Optimal.mat'];
    % FullNetwork_DecoderSavePathNameExt = [Encoding_Dir filesep 'Decoder-Optimal.mat'];
    % FullNetwork_ClassifierSavePathNameExt = [Encoding_Dir filesep 'Classifier-Optimal.mat'];

    fprintf(MessageDelete_Optimal);
    cgg_deleteNetworks(cfg_Network,'Optimality','Optimal');
    % if isfile(FullNetwork_EncoderSavePathNameExt)
    %     delete(FullNetwork_EncoderSavePathNameExt);
    % end
    % if isfile(FullNetwork_DecoderSavePathNameExt)
    %     delete(FullNetwork_DecoderSavePathNameExt);
    % end
    % if isfile(FullNetwork_ClassifierSavePathNameExt)
    %     delete(FullNetwork_ClassifierSavePathNameExt);
    % end
    % if isfile(AutoEncoder_EncoderSavePathNameExt)
    %     delete(AutoEncoder_EncoderSavePathNameExt);
    % end
    % if isfile(AutoEncoder_DecoderSavePathNameExt)
    %     delete(AutoEncoder_DecoderSavePathNameExt);
    % end
end

%%
fprintf(MessageEnd);

end
