function cfg = cgg_generateEncoderSubFolders(EncodingDir,ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,IsSubset)
%CGG_GENERATEENCODERSUBFOLDERS Summary of this function goes here
%   Detailed explanation goes here


cfg=struct();
cfg.EncodingDir.path=EncodingDir;
%% Model Name Folder

% Make the Model Name folder name.
cfg_tmp=cfg.EncodingDir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ModelName,'ModelName',cfg_tmp);
cfg.EncodingDir=cfg_tmp;

%% Data Width Folder

% Make the Data Width folder name.
if isnumeric(DataWidth)
    NameDataWidth = sprintf('Data Width - %d',DataWidth);
else
    NameDataWidth = sprintf('Data Width - %s',DataWidth);
end
cfg_tmp=cfg.EncodingDir.ModelName;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameDataWidth,'DataWidth',cfg_tmp);
cfg.EncodingDir.ModelName=cfg_tmp;

%% Window Stride Folder

% Make the Window Stride folder name.
if isnumeric(WindowStride)
    NameWindowStride = sprintf('Window Stride - %d',WindowStride);
else
    NameWindowStride = sprintf('Window Stride - %s',WindowStride);
end
cfg_tmp=cfg.EncodingDir.ModelName.DataWidth;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameWindowStride,'WindowStride',cfg_tmp);
cfg.EncodingDir.ModelName.DataWidth=cfg_tmp;

%% Hidden Size Folder

% Make the Hidden Size folder name.
if length(HiddenSize)==1
    NameHiddenSize = sprintf('Hidden Size - %d',HiddenSize);
else
    NameHiddenSize = ['Hidden Size - ' sprintf('%d',HiddenSize(1)) sprintf('-%d',HiddenSize(2:end))];
end
cfg_tmp=cfg.EncodingDir.ModelName.DataWidth.WindowStride;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameHiddenSize,'HiddenSize',cfg_tmp);
cfg.EncodingDir.ModelName.DataWidth.WindowStride=cfg_tmp;

%% Initial Learning Rate Folder

% Make the Initial Learning Rate folder name.
NameInitialLearningRate = sprintf('Initial Learning Rate - %.0e',InitialLearningRate);
cfg_tmp=cfg.EncodingDir.ModelName.DataWidth.WindowStride.HiddenSize;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameInitialLearningRate,'InitialLearningRate',cfg_tmp);
cfg.EncodingDir.ModelName.DataWidth.WindowStride.HiddenSize=cfg_tmp;

%% Is Subset Folder

% Make the Is Subset folder name.
if IsSubset
    NameIsSubset = 'Subset';
else
    NameIsSubset = 'All Sessions';
end
cfg_tmp=cfg.EncodingDir.ModelName.DataWidth.WindowStride.HiddenSize.InitialLearningRate;
[cfg_tmp,~] = cgg_generateFolderAndPath(NameIsSubset,'IsSubset',cfg_tmp);
cfg.EncodingDir.ModelName.DataWidth.WindowStride.HiddenSize.InitialLearningRate=cfg_tmp;
end

