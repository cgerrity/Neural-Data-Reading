function cfg = cgg_generateEncoderSubFolders_v3(EncodingDir,cfg_Encoder,varargin)
%CGG_GENERATEENCODERSUBFOLDERS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=true;
end
end

cfg=struct();
cfg.EncodingDir.path=EncodingDir;

%%

if isfield(cfg_Encoder,'ModelName')
ModelName = cfg_Encoder.ModelName;
end

if isfield(cfg_Encoder,'DataWidth')
DataWidth = cfg_Encoder.DataWidth;
end

if isfield(cfg_Encoder,'WindowStride')
WindowStride = cfg_Encoder.WindowStride;
end

if isfield(cfg_Encoder,'HiddenSizes')
HiddenSize = cfg_Encoder.HiddenSizes;
end

if isfield(cfg_Encoder,'InitialLearningRate')
InitialLearningRate = cfg_Encoder.InitialLearningRate;
end

if isfield(cfg_Encoder,'WeightReconstruction')
WeightReconstruction = cfg_Encoder.WeightReconstruction;
end

if isfield(cfg_Encoder,'WeightKL')
WeightKL = cfg_Encoder.WeightKL;
end

if isfield(cfg_Encoder,'WeightClassification')
WeightClassification = cfg_Encoder.WeightClassification;
end

if isfield(cfg_Encoder,'MiniBatchSize')
MiniBatchSize = cfg_Encoder.MiniBatchSize;
end

if isfield(cfg_Encoder,'wantSubset')
IsSubset = cfg_Encoder.wantSubset;
end

if isfield(cfg_Encoder,'Subset')
SubsetSessionName = cfg_Encoder.Subset;
end

if isfield(cfg_Encoder,'WeightedLoss')
WeightedLoss = cfg_Encoder.WeightedLoss;
end

if isfield(cfg_Encoder,'GradientThreshold')
GradientThreshold = cfg_Encoder.GradientThreshold;
end

if isfield(cfg_Encoder,'ClassifierName')
ClassifierName = cfg_Encoder.ClassifierName;
end

if isfield(cfg_Encoder,'ClassifierHiddenSize')
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
end

if isfield(cfg_Encoder,'STDChannelOffset')
STDChannelOffset = cfg_Encoder.STDChannelOffset;
end

if isfield(cfg_Encoder,'STDWhiteNoise')
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
end

if isfield(cfg_Encoder,'STDRandomWalk')
STDRandomWalk = cfg_Encoder.STDRandomWalk;
end

if isfield(cfg_Encoder,'Optimizer')
Optimizer = cfg_Encoder.Optimizer;
end

if isfield(cfg_Encoder,'NumEpochsAutoEncoder')
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
end

if isfield(cfg_Encoder,'Normalization')
Normalization = cfg_Encoder.Normalization;
end

if isfield(cfg_Encoder,'LossType_Decoder')
LossType_Decoder = cfg_Encoder.LossType_Decoder;
end

if isfield(cfg_Encoder,'Dropout')
Dropout = cfg_Encoder.Dropout;
end

if isfield(cfg_Encoder,'WantNormalization')
WantNormalization = cfg_Encoder.WantNormalization;
end

if isfield(cfg_Encoder,'Activation')
Activation = cfg_Encoder.Activation;
end

if isfield(cfg_Encoder,'IsVariational')
IsVariational = cfg_Encoder.IsVariational;
end

if isfield(cfg_Encoder,'BottleNeckDepth')
BottleNeckDepth = cfg_Encoder.BottleNeckDepth;
end

if isfield(cfg_Encoder,'L2Factor')
L2Factor = cfg_Encoder.L2Factor;
end

if isfield(cfg_Encoder,'maxworkerMiniBatchSize')
maxworkerMiniBatchSize = cfg_Encoder.maxworkerMiniBatchSize;
end

EncoderOutputType = [];
if isfield(cfg_Encoder,'EncoderOutputType')
EncoderOutputType = cfg_Encoder.EncoderOutputType;
end

MultipleInstanceLearningType = [];
if isfield(cfg_Encoder,'MultipleInstanceLearningType')
MultipleInstanceLearningType = cfg_Encoder.MultipleInstanceLearningType;
end

PriorProportion = [];
if isfield(cfg_Encoder,'PriorProportion')
PriorProportion = cfg_Encoder.PriorProportion;
end

RescaleLossEpoch = [];
if isfield(cfg_Encoder,'RescaleLossEpoch')
RescaleLossEpoch = cfg_Encoder.RescaleLossEpoch;
end

Fold = [];
if isfield(cfg_Encoder,'Fold')
Fold = cfg_Encoder.Fold;
end

% DynamicAugmentation = [];
% if isfield(cfg_Encoder,'DynamicAugmentation')
% DynamicAugmentation = cfg_Encoder.DynamicAugmentation;
% end
% 
% DynamicWeighting = [];
% if isfield(cfg_Encoder,'DynamicWeighting')
% DynamicWeighting = cfg_Encoder.DynamicWeighting;
% end
% 
% DynamicFreezing = [];
% if isfield(cfg_Encoder,'DynamicFreezing')
% DynamicFreezing = cfg_Encoder.DynamicFreezing;
% end

DynamicParameterSet = [];
if isfield(cfg_Encoder,'DynamicParameterSet')
DynamicParameterSet = cfg_Encoder.DynamicParameterSet;
end
StitchingAndFusionLayer = [];
if isfield(cfg_Encoder,'StitchingAndFusionLayer')
StitchingAndFusionLayer = cfg_Encoder.StitchingAndFusionLayer;
end
ConfidenceType = [];
if isfield(cfg_Encoder,'ConfidenceType')
ConfidenceType = cfg_Encoder.ConfidenceType;
end
StartEndPercent = [];
if isfield(cfg_Encoder,'StartEndPercent')
StartEndPercent = cfg_Encoder.StartEndPercent;
end
wantStratifiedPartition = [];
if isfield(cfg_Encoder,'wantStratifiedPartition')
wantStratifiedPartition = cfg_Encoder.wantStratifiedPartition;
end
WeightConfidence = [];
if isfield(cfg_Encoder,'WeightConfidence')
WeightConfidence = cfg_Encoder.WeightConfidence;
end
WantBatchCorrection = false;
if isfield(cfg_Encoder,'WantBatchCorrection')
WantBatchCorrection = cfg_Encoder.WantBatchCorrection;
end
%% Model Name Folder

% Make the Model Name folder name.
cfg_tmp=cfg.EncodingDir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ModelName,'ModelName',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir=cfg_tmp;

%% Model Parameters Folder

% Make the Variational folder name.
NameModelParameters = '';
if IsVariational
    NameVariational = 'Variational';
    switch EncoderOutputType
        case 'Stochastic'
            NameVariational = sprintf('%s - Stochastic Encoder',NameVariational);
    end
    NameModelParameters = NameVariational;
% else
%     NameVariational = '';
end

% Make the Activation folder name.
if ~isempty(Activation)
%     NameActivation = '';
% else
    NameActivation = sprintf('Activation - %s',Activation);
    NameModelParameters = [NameModelParameters ' ~ ' NameActivation];
end
% Make the Dropout folder name.
if ~(Dropout == 0)
%     NameDropout = 'Dropout - None';
% else
    NameDropout = sprintf('Dropout - %.2e',Dropout);
    NameModelParameters = [NameModelParameters ' ~ ' NameDropout];
end
% Make the Layer Normalization folder name.
if islogical(WantNormalization)
if WantNormalization
    NameLayerNormalization = 'Normalized';
    NameModelParameters = [NameModelParameters ' ~ ' NameLayerNormalization];
% else
%     NameLayerNormalization = '';
end
else
    NameLayerNormalization = sprintf('%s Normalized',WantNormalization);
    NameModelParameters = [NameModelParameters ' ~ ' NameLayerNormalization];
end
% Make the Bottle Neck Depth folder name.
NameBottleNeckDepth = sprintf('Bottle Neck Depth - %d',BottleNeckDepth);
NameModelParameters = [NameModelParameters ' ~ ' NameBottleNeckDepth];

cfg_tmp=cfg.EncodingDir.ModelName;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameModelParameters,'ModelParameters',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName=cfg_tmp;
%% Data Width and Window Stride

% Make the Data Width folder name.
if isnumeric(DataWidth)
    NameDataWidth = sprintf('Data Width - %d',DataWidth);
else
    NameDataWidth = sprintf('Data Width - %s',DataWidth);
end
% Make the Window Stride folder name.
if isnumeric(WindowStride)
    NameWindowStride = sprintf('Window Stride - %d',WindowStride);
else
    NameWindowStride = sprintf('Window Stride - %s',WindowStride);
end
% Make the Time Range folder name.
if any(~isnan(StartEndPercent))
    NameTimeRange = sprintf('Time Percent - [%.1f, %.1f]',StartEndPercent(1),StartEndPercent(2));
    NameTimeRange = [' ~ ' NameTimeRange];
else
    NameTimeRange = [];
end

NameWidthandStride = [NameDataWidth ' ~ ' NameWindowStride NameTimeRange];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameWidthandStride,'WidthStride',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters=cfg_tmp;

%% Normalization Folder

% Make the Normalization name.
NameNormalization = sprintf('Normalization - %s',Normalization);
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameNormalization,'Normalization',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride=cfg_tmp;
%% Hidden Size Folder

% Make the Hidden Size folder name.
if isscalar(HiddenSize)
    NameHiddenSize = sprintf('Hidden Size - %d',HiddenSize);
else
    NameHiddenSize = ['Hidden Size - ' sprintf('%d',HiddenSize(1)) sprintf('-%d',HiddenSize(2:end))];
end
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameHiddenSize,'HiddenSize',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization=cfg_tmp;

%% Learning Folder

% Make the Learning folder name.
NameInitialLearningRate = sprintf('Initial Learning Rate - %.2e',InitialLearningRate);

if ~isnan(GradientThreshold)
    NameGradientThreshold = sprintf('Gradient Threshold - %.2e',GradientThreshold);
else
    NameGradientThreshold = 'Gradient Threshold - None';
end
switch cfg_Encoder.GradientClipType
    case 'Global'
        NameGradientThreshold = [NameGradientThreshold ' - Global'];
end

NameOptimizer = sprintf('Optimizer - %s',Optimizer);
NameL2Factor = sprintf('L2 Factor - %.2e',L2Factor);
NameLearning = [NameInitialLearningRate ' ~ ' NameGradientThreshold ' ~ ' NameOptimizer ' ~ ' NameL2Factor];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLearning,'Learning',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize=cfg_tmp;

%% Mini Batch Size Folder

% Make the Mini Batch Size folder name.
NameMiniBatchSize = sprintf('Mini Batch Size - %d',MiniBatchSize);
% Make Gradient Accumulation folder name
NameMaxMiniBatchSize = sprintf('Max Accumulation - %d',maxworkerMiniBatchSize);
% NameStratified = '';
if wantStratifiedPartition
    NameStratified = ' ~ Hierarchically Stratified';
else
    NameStratified = ' ~ Not Stratified';
end
if ~islogical(wantStratifiedPartition)
    NameStratified = sprintf(' ~ %s',wantStratifiedPartition);
end

NameMiniBatchFolder = [NameMiniBatchSize ' ~ ' NameMaxMiniBatchSize NameStratified];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameMiniBatchFolder,'MiniBatchSize',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning=cfg_tmp;

%% Data Augmentation  Folder

% Make the Data Augmentation Size folder name.
if ~isnan(STDChannelOffset)
    NameChannelOffset = sprintf('Channel Offset - %.2e',STDChannelOffset);
else
    NameChannelOffset = 'Channel Offset - None';
end
if ~isnan(STDWhiteNoise)
    NameWhiteNoise = sprintf('White Noise - %.2e',STDWhiteNoise);
else
    NameWhiteNoise = 'White Noise - None';
end
if ~isnan(STDRandomWalk)
    NameRandomWalk = sprintf('Random Walk - %.2e',STDRandomWalk);
else
    NameRandomWalk = 'Random Walk - None';
end
if isfield(cfg_Encoder,'STDTimeShift') && ~isnan(cfg_Encoder.STDTimeShift)
    NameTimeSift = sprintf(' ~ TimeShift - %.2e',cfg_Encoder.STDTimeShift);
    if isfield(cfg_Encoder,'WantSeparateTimeShift') && cfg_Encoder.WantSeparateTimeShift
        NameTimeSift = sprintf(' ~ Separate TimeShift - %.2e',cfg_Encoder.STDTimeShift);
    end
else
    NameTimeSift = '';
end

NameDataAugmentation = [NameChannelOffset ' ~ ' NameWhiteNoise ...
    ' ~ ' NameRandomWalk NameTimeSift];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameDataAugmentation,'DataAugmentation',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize=cfg_tmp;

%% Is Subset Folder

% Make the Is Subset folder name.
if IsSubset
    NameIsSubset = 'Subset';
else
    NameIsSubset = 'All Sessions';
end
if ~islogical(SubsetSessionName)
    NameIsSubset = SubsetSessionName;
end
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameIsSubset,'IsSubset',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation=cfg_tmp;

%% AutoEncoder Folder

% Make the AutoEncoder folder name.
if strcmp(LossType_Decoder,'None')
NameAutoEncoderLoss = 'None';
NameAutoEncoderEpochs = 'AutoEncoder';
else
NameAutoEncoderLoss = sprintf('Loss Function - %s',LossType_Decoder);
NameAutoEncoderEpochs = sprintf('AutoEncoder - Epochs - %d',NumEpochsAutoEncoder);
end

NameLossRescaling = sprintf('Prior Proportion - %.2e ~ Rescale Epochs - %d',PriorProportion,RescaleLossEpoch);

NameAutoEncoder = [NameAutoEncoderEpochs ' ~ ' NameAutoEncoderLoss ' ~ ' NameLossRescaling];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameAutoEncoder,'AutoEncoder',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset=cfg_tmp;

%% Loss Weight Folder

% Make the Loss Weight folder name.
if ~isnan(WeightReconstruction)
    NameWeightReconstruction = sprintf('Weight Reconstruction - %.2e',WeightReconstruction);
else
    NameWeightReconstruction = 'Weight Reconstruction - None';
end
if ~isnan(WeightKL)
    NameWeightKL = sprintf('Weight KL - %.2e',WeightKL);
else
    NameWeightKL = 'Weight KL - None';
end
if ~isnan(WeightClassification)
    NameWeightClassification = sprintf('Weight Classification - %.2e',WeightClassification);
else
    NameWeightClassification = 'Weight Classification - None';
end
NameWeightConfidence = '';
NameConfidence = '';
if any(~strcmp(string(ConfidenceType),""))
    ConfidenceTypes = sort(erase(ConfidenceType," Confidence"));
NameConfidence = sprintf(' %s',ConfidenceTypes(1));
if length(ConfidenceTypes) > 1
    for cidx = 2:length(ConfidenceTypes)
        NameConfidence = sprintf('%s and %s',NameConfidence,ConfidenceTypes(cidx));
    end
end
if WantBatchCorrection
    NameConfidence = sprintf(' BC%s',NameConfidence);
end
end
if isnan(WeightConfidence)
    NameWeightConfidence = sprintf(' ~ Weight%s Confidence - None',NameConfidence);
elseif WeightConfidence ~= 0
    NameWeightConfidence = sprintf(' ~ Weight%s Confidence - %.2e',NameConfidence,WeightConfidence);
end
NameLoss = [NameWeightReconstruction ' ~ ' NameWeightClassification ' ~ ' NameWeightKL NameWeightConfidence];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLoss,'Loss',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder=cfg_tmp;

%% Dynamic Parameters Folder

% % Make the Data Augmentation folder name.
% NameLoad = cgg_getDynamicFolderName("DynamicAugmentation", DynamicAugmentation);
% % Make the Weight folder name.
% NameWeight = cgg_getDynamicFolderName("DynamicWeighting", DynamicWeighting);
% % Make the Freeze folder name
% NameFreeze = cgg_getDynamicFolderName("DynamicFreezing", DynamicFreezing);

% NameDynamic = [NameLoad ' ~ ' NameWeight ' ~ ' NameFreeze];
NameDynamic = sprintf('Dynamic Set - %s',DynamicParameterSet);
if ~strcmp(string(StitchingAndFusionLayer),"")
NameStitchingAndFusion = sprintf('S and F - %s',StitchingAndFusionLayer);
NameDynamic = sprintf('%s ~ %s',NameDynamic,NameStitchingAndFusion);
end

cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameDynamic,'Dynamic',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss=cfg_tmp;

% Make the AutoEncoder Plot folder name.
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic;
[cfg_tmp,~] = cgg_generateFolderAndPath('Information','AutoEncoderInformation',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic=cfg_tmp;

%% Classifier Folder

% Make the Classifier Name folder name.
NameClassifierModel = sprintf('Classifier - %s',ClassifierName);
if length(ClassifierHiddenSize) < 1
    NameClassifierHiddenSizes = 'Hidden Size - None';
elseif isscalar(ClassifierHiddenSize)
    NameClassifierHiddenSizes = ['Hidden Size - ' sprintf('%d',ClassifierHiddenSize(1))];
else
    NameClassifierHiddenSizes = ['Hidden Size - ' sprintf('%d',ClassifierHiddenSize(1)) sprintf('-%d',ClassifierHiddenSize(2:end))];
end
if ~isempty(WeightedLoss)
    NameWeightedLoss = sprintf('Weighted Loss - %s',WeightedLoss);
else
    NameWeightedLoss = 'Weighted Loss - None';
end
if ~isempty(MultipleInstanceLearningType)
    switch MultipleInstanceLearningType
        case 'MIL'
            NameMIL = sprintf(' ~ SCT');
        otherwise
            NameMIL = '';
    end
else
    NameMIL = '';
end
NameClassifier = [NameClassifierModel ' ~ ' NameClassifierHiddenSizes ...
    ' ~ ' NameWeightedLoss NameMIL];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameClassifier,'Classifier',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic=cfg_tmp;

%% Fold Folder

% Make the Fold Name folder name.
FoldName=sprintf('Fold_%d',Fold);

cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic.Classifier;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic.Classifier=cfg_tmp;

% Make the AutoEncoder Plot folder name.
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic.AutoEncoderInformation;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'AutoEncoderFold',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss.Dynamic.AutoEncoderInformation=cfg_tmp;
end

