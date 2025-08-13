function cfg = cgg_generateEncoderSubFolders(EncodingDir,ModelName,...
    DataWidth,WindowStride,HiddenSize,InitialLearningRate,...
    WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,IsSubset,...
    WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,...
    STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,...
    NumEpochsAutoEncoder,Normalization,LossType_Decoder,varargin)
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
%% Model Name Folder

% Make the Model Name folder name.
cfg_tmp=cfg.EncodingDir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ModelName,'ModelName',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir=cfg_tmp;

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
cfg_tmp=cfg.EncodingDir.ModelName;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameWidthandStride,'WidthStride',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName=cfg_tmp;

%% Normalization Folder

% Make the Normalization name.
NameNormalization = sprintf('Normalization - %s',Normalization);
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameNormalization,'Normalization',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride=cfg_tmp;
%% Hidden Size Folder

% Make the Hidden Size folder name.
if length(HiddenSize)==1
    NameHiddenSize = sprintf('Hidden Size - %d',HiddenSize);
else
    NameHiddenSize = ['Hidden Size - ' sprintf('%d',HiddenSize(1)) sprintf('-%d',HiddenSize(2:end))];
end
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameHiddenSize,'HiddenSize',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization=cfg_tmp;

%% Learning Folder

% Make the Learning folder name.
NameInitialLearningRate = sprintf('Initial Learning Rate - %.2e',InitialLearningRate);

if ~isnan(GradientThreshold)
    NameGradientThreshold = sprintf('Gradient Threshold - %.2e',GradientThreshold);
else
    NameGradientThreshold = 'Gradient Threshold - None';
end
NameOptimizer = sprintf('Optimizer - %s',Optimizer);
NameLearning = [NameInitialLearningRate ' ~ ' NameGradientThreshold ' ~ ' NameOptimizer];
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLearning,'Learning',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize=cfg_tmp;

%% Mini Batch Size Folder

% Make the Mini Batch Size folder name.
NameMiniBatchSize = sprintf('Mini Batch Size - %d',MiniBatchSize);
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameMiniBatchSize,'MiniBatchSize',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning=cfg_tmp;

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
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameDataAugmentation,'DataAugmentation',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize=cfg_tmp;

%% Is Subset Folder

% Make the Is Subset folder name.
if IsSubset
    NameIsSubset = 'Subset';
else
    NameIsSubset = 'All Sessions';
end
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameIsSubset,'IsSubset',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation=cfg_tmp;

%% AutoEncoder Folder

% Make the AutoEncoder folder name.
NameAutoEncoderLoss = sprintf('Loss Function - %s',LossType_Decoder);
NameAutoEncoderEpochs = sprintf('AutoEncoder - Epochs - %d',NumEpochsAutoEncoder);
NameAutoEncoder = [NameAutoEncoderEpochs ' ~ ' NameAutoEncoderLoss];
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameAutoEncoder,'AutoEncoder',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset=cfg_tmp;

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
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLoss,'Loss',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder=cfg_tmp;

% Make the AutoEncoder Plot folder name.
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss;
[cfg_tmp,~] = cgg_generateFolderAndPath('Information','AutoEncoderInformation',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss=cfg_tmp;

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
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameClassifier,'Classifier',cfg_tmp,'WantDirectory',WantDirectory);
cfg.EncodingDir.ModelName.WidthStride.Normalization.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.AutoEncoder.Loss=cfg_tmp;

end

