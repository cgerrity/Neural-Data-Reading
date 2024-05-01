function cfg = cgg_generateEncoderSubFolders(EncodingDir,ModelName,...
    DataWidth,WindowStride,HiddenSize,InitialLearningRate,...
    LossFactorReconstruction,LossFactorKL,MiniBatchSize,IsSubset,...
    WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize)
%CGG_GENERATEENCODERSUBFOLDERS Summary of this function goes here
%   Detailed explanation goes here


cfg=struct();
cfg.EncodingDir.path=EncodingDir;
%% Model Name Folder

% Make the Model Name folder name.
cfg_tmp=cfg.EncodingDir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ModelName,'ModelName',cfg_tmp);
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
[cfg_tmp,~] = cgg_generateFolderAndPath(NameWidthandStride,'WidthStride',cfg_tmp);
cfg.EncodingDir.ModelName=cfg_tmp;

%% Data Width Folder

% % Make the Data Width folder name.
% if isnumeric(DataWidth)
%     NameDataWidth = sprintf('Data Width - %d',DataWidth);
% else
%     NameDataWidth = sprintf('Data Width - %s',DataWidth);
% end
% cfg_tmp=cfg.EncodingDir.ModelName;
% [cfg_tmp,~] = cgg_generateFolderAndPath(NameDataWidth,'DataWidth',cfg_tmp);
% cfg.EncodingDir.ModelName=cfg_tmp;

% %% Window Stride Folder
% 
% % Make the Window Stride folder name.
% if isnumeric(WindowStride)
%     NameWindowStride = sprintf('Window Stride - %d',WindowStride);
% else
%     NameWindowStride = sprintf('Window Stride - %s',WindowStride);
% end
% cfg_tmp=cfg.EncodingDir.ModelName.DataWidth;
% [cfg_tmp,~] = cgg_generateFolderAndPath(NameWindowStride,'WindowStride',cfg_tmp);
% cfg.EncodingDir.ModelName.DataWidth=cfg_tmp;

%% Hidden Size Folder

% Make the Hidden Size folder name.
if length(HiddenSize)==1
    NameHiddenSize = sprintf('Hidden Size - %d',HiddenSize);
else
    NameHiddenSize = ['Hidden Size - ' sprintf('%d',HiddenSize(1)) sprintf('-%d',HiddenSize(2:end))];
end
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameHiddenSize,'HiddenSize',cfg_tmp);
cfg.EncodingDir.ModelName.WidthStride=cfg_tmp;

%% Learning Folder

% Make the Learning folder name.
NameInitialLearningRate = sprintf('Initial Learning Rate - %.2e',InitialLearningRate);

if ~isnan(GradientThreshold)
    NameGradientThreshold = sprintf('Gradient Threshold - %.2e',GradientThreshold);
else
    NameGradientThreshold = 'Gradient Threshold - None';
end
NameLearning = [NameInitialLearningRate ' ~ ' NameGradientThreshold];
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.HiddenSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLearning,'Learning',cfg_tmp);
cfg.EncodingDir.ModelName.WidthStride.HiddenSize=cfg_tmp;

% %% Initial Learning Rate Folder
% 
% % Make the Initial Learning Rate folder name.
% NameInitialLearningRate = sprintf('Initial Learning Rate - %.2e',InitialLearningRate);
% cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.HiddenSize;
% [cfg_tmp,~] = cgg_generateFolderAndPath(NameInitialLearningRate,'InitialLearningRate',cfg_tmp);
% cfg.EncodingDir.ModelName.WidthStride.HiddenSize=cfg_tmp;

%% Loss Information Folder

% Make the Loss Information folder name.
if ~isnan(LossFactorReconstruction)
    NameLossFactorReconstruction = sprintf('Loss Factor Reconstruction - %.2e',LossFactorReconstruction);
else
    NameLossFactorReconstruction = 'Loss Factor Reconstruction - None';
end
if ~isnan(LossFactorKL)
    NameLossFactorKL = sprintf('Loss Factor KL - %.2e',LossFactorKL);
else
    NameLossFactorKL = 'Loss Factor KL - None';
end
if ~isempty(WeightedLoss)
    NameWeightedLoss = sprintf('Weighted Loss - %s',WeightedLoss);
else
    NameWeightedLoss = 'Weighted Loss - None';
end
NameLoss = [NameLossFactorReconstruction ' ~ ' NameLossFactorKL ...
    ' ~ ' NameWeightedLoss];
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameLoss,'Loss',cfg_tmp);
cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning=cfg_tmp;

%% Mini Batch Size Folder

% Make the Mini Batch Size folder name.
NameMiniBatchSize = sprintf('Mini Batch Size - %d',MiniBatchSize);
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.Loss;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameMiniBatchSize,'MiniBatchSize',cfg_tmp);
cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.Loss=cfg_tmp;

%% Classifier Folder

% Make the Classifier Name folder name.
NameClassifierModel = sprintf('Classifier - %s',ClassifierName);
if length(ClassifierHiddenSize)==1
    NameClassifierHiddenSizes = 'Hidden Size - None';
else
    NameClassifierHiddenSizes = ['Hidden Size - ' sprintf('%d',ClassifierHiddenSize(1)) sprintf('-%d',ClassifierHiddenSize(2:end))];
end
NameClassifier = [NameClassifierModel ' ~ ' NameClassifierHiddenSizes];
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.Loss.MiniBatchSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameClassifier,'Classifier',cfg_tmp);
cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.Loss.MiniBatchSize=cfg_tmp;

%% Is Subset Folder

% Make the Is Subset folder name.
if IsSubset
    NameIsSubset = 'Subset';
else
    NameIsSubset = 'All Sessions';
end
cfg_tmp=cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.Loss.MiniBatchSize.Classifier;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameIsSubset,'IsSubset',cfg_tmp);
cfg.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.Loss.MiniBatchSize.Classifier=cfg_tmp;
end

