function cfg = cgg_generateEncoderSubFolders_v2(EncodingDir,cfg_Encoder)
%CGG_GENERATEENCODERSUBFOLDERS Summary of this function goes here
%   Detailed explanation goes here


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
%% Model Name Folder

% Make the Model Name folder name.
cfg_tmp=cfg.EncodingDir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ModelName,'ModelName',cfg_tmp);
cfg.EncodingDir=cfg_tmp;

%% Model Parameters Folder

% Make the Variational folder name.
NameModelParameters = '';
if IsVariational
    NameVariational = 'Variational';
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
[cfg_tmp,~] = cgg_generateFolderAndPath(NameModelParameters,'ModelParameters',cfg_tmp);
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
NameWidthandStride = [NameDataWidth ' ~ ' NameWindowStride];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameWidthandStride,'WidthStride',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters=cfg_tmp;

%% Normalization Folder

% Make the Normalization name.
NameNormalization = sprintf('Normalization - %s',Normalization);
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameNormalization,'Normalization',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride=cfg_tmp;
%% Hidden Size Folder

% Make the Hidden Size folder name.
if length(HiddenSize)==1
    NameHiddenSize = sprintf('Hidden Size - %d',HiddenSize);
else
    NameHiddenSize = ['Hidden Size - ' sprintf('%d',HiddenSize(1)) sprintf('-%d',HiddenSize(2:end))];
end
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameHiddenSize,'HiddenSize',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization=cfg_tmp;

%% Learning Folder

% Make the Learning folder name.
NameInitialLearningRate = sprintf('Initial Learning Rate - %.2e',InitialLearningRate);

if ~isnan(GradientThreshold)
    NameGradientThreshold = sprintf('Gradient Threshold - %.2e',GradientThreshold);
else
    NameGradientThreshold = 'Gradient Threshold - None';
end
NameOptimizer = sprintf('Optimizer - %s',Optimizer);
NameL2Factor = sprintf('L2 Factor - %.2e',L2Factor);
NameLearning = [NameInitialLearningRate ' ~ ' NameGradientThreshold ' ~ ' NameOptimizer ' ~ ' NameL2Factor];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLearning,'Learning',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize=cfg_tmp;

%% Mini Batch Size Folder

% Make the Mini Batch Size folder name.
NameMiniBatchSize = sprintf('Mini Batch Size - %d',MiniBatchSize);
% Make Gradient Accumulation folder name
NameMaxMiniBatchSize = sprintf('Max Accumulation - %d',maxworkerMiniBatchSize);
NameMiniBatchFolder = [NameMiniBatchSize ' ~ ' NameMaxMiniBatchSize];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameMiniBatchFolder,'MiniBatchSize',cfg_tmp);
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

NameDataAugmentation = [NameChannelOffset ' ~ ' NameWhiteNoise ...
    ' ~ ' NameRandomWalk];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameDataAugmentation,'DataAugmentation',cfg_tmp);
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
[cfg_tmp,~] = cgg_generateFolderAndPath(NameIsSubset,'IsSubset',cfg_tmp);
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
NameAutoEncoder = [NameAutoEncoderEpochs ' ~ ' NameAutoEncoderLoss];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameAutoEncoder,'AutoEncoder',cfg_tmp);
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
NameLoss = [NameWeightReconstruction ' ~ ' NameWeightClassification ' ~ ' NameWeightKL];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLoss,'Loss',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder=cfg_tmp;

% Make the AutoEncoder Plot folder name.
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss;
[cfg_tmp,~] = cgg_generateFolderAndPath('Information','AutoEncoderInformation',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss=cfg_tmp;

%% Classifier Folder

% Make the Classifier Name folder name.
NameClassifierModel = sprintf('Classifier - %s',ClassifierName);
if length(ClassifierHiddenSize) < 1
    NameClassifierHiddenSizes = 'Hidden Size - None';
elseif length(ClassifierHiddenSize) == 1
    NameClassifierHiddenSizes = ['Hidden Size - ' sprintf('%d',ClassifierHiddenSize(1))];
else
    NameClassifierHiddenSizes = ['Hidden Size - ' sprintf('%d',ClassifierHiddenSize(1)) sprintf('-%d',ClassifierHiddenSize(2:end))];
end
if ~isempty(WeightedLoss)
    NameWeightedLoss = sprintf('Weighted Loss - %s',WeightedLoss);
else
    NameWeightedLoss = 'Weighted Loss - None';
end
NameClassifier = [NameClassifierModel ' ~ ' NameClassifierHiddenSizes ...
    ' ~ ' NameWeightedLoss];
cfg_tmp=cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameClassifier,'Classifier',cfg_tmp);
cfg.EncodingDir.ModelName.ModelParameters.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss=cfg_tmp;

end

