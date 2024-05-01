function cfg = cgg_generateDecodingFolders(varargin)
%CGG_GENERATEDECODINGFOLDERS Summary of this function goes here
%   Detailed explanation goes here
%% Destination Directory
isfunction=exist('varargin','var');

if isfunction
TargetDir = CheckVararginPairs('TargetDir', '', varargin{:});
[TargetDir] = cgg_ioTargetDirectory('TargetDir',TargetDir);
else
    if ~exist('TargetDir','var')
    [TargetDir] = cgg_ioTargetDirectory;
    end
end

cfg=struct();

cfg.TargetDir.path=TargetDir;
%% Main Folder

% Make the All Sessions folder name.
cfg_tmp=cfg.TargetDir;
[cfg_tmp,~] = cgg_generateFolderAndPath('Aggregate Data','Aggregate_Data',cfg_tmp);
cfg.TargetDir=cfg_tmp;
%% Epoched Data Folder

% Make the Epoched_Data folder name.
cfg_tmp=cfg.TargetDir.Aggregate_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath('Epoched Data','Epoched_Data',cfg_tmp);
cfg.TargetDir.Aggregate_Data=cfg_tmp;

%% Epoch Folder

% Make the Epoch and its subfolder folder names.
if isfunction
Epoch = CheckVararginPairs('Epoch', '', varargin{:});
if ~isempty(Epoch)
    
% Make the Epoch folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath(Epoch,'Epoch',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data=cfg_tmp;

% Make the Target folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Target','Target',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

% Make the Data folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data','Data',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

if isfunction
Data_Normalized = CheckVararginPairs('Data_Normalized', false, varargin{:});
if Data_Normalized

% Make the Normalized Data output folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data_Normalized','Data_Normalized',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

end % End for whether to make the Normalized Data Folder
end % End for whether this is being called within a function

% Make the Processing folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Processing','Processing',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

% Make the Decoding folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Decoding','Decoding',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

% Make the Partition folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Partition','Partition',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

if isfunction
Decoder = CheckVararginPairs('Decoder', '', varargin{:});
if ~isempty(Decoder)

% Make the Fold folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding;
[cfg_tmp,~] = cgg_generateFolderAndPath(Decoder,'Decoder',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding=cfg_tmp;

% Make the Decoder Plot folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder=cfg_tmp;

if isfunction
Fold = CheckVararginPairs('Fold', '', varargin{:});
if ~isempty(Fold)

FoldName=sprintf('Fold_%d',Fold);

% Make the Fold folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder=cfg_tmp;

end % End for whether there exists any input for the Fold
end % End for whether this is being called within a function

end % End for whether there exists any input for the Decoder
end % End for whether this is being called within a function

if isfunction
Encoding = CheckVararginPairs('Encoding', '', varargin{:});
if ~isempty(Encoding)

% Make the Encoding folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Encoding','Encoding',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

if isfunction
Fold = CheckVararginPairs('Fold', '', varargin{:});
if ~isempty(Fold)

FoldName=sprintf('Fold_%d',Fold);

% Make the Fold folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Encoding;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Encoding=cfg_tmp;

end % End for whether there exists any input for the Fold
end % End for whether this is being called within a function

end % End for whether there exists any input for the Encoding
end % End for whether this is being called within a function

if isfunction
DistributionType = CheckVararginPairs('DistributionType', '', varargin{:});
ImportanceAnalysis = CheckVararginPairs('ImportanceAnalysis', '', varargin{:});
PlotData = CheckVararginPairs('PlotData', '', varargin{:});
Accuracy = CheckVararginPairs('Accuracy', '', varargin{:});
ExplainedVariance = CheckVararginPairs('ExplainedVariance', '', varargin{:});
PlotFolder = CheckVararginPairs('PlotFolder', '', varargin{:});
if ~isempty(DistributionType)||~isempty(ImportanceAnalysis)...
        ||~isempty(PlotData)||~isempty(Accuracy)...
        ||~isempty(ExplainedVariance)||~isempty(PlotFolder)

% Make the Plot output folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

if ~isempty(PlotFolder)
% Make the Plot Folder Variance folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath(PlotFolder,'PlotFolder',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;

PlotSubFolder = CheckVararginPairs('PlotSubFolder', '', varargin{:});
if ~isempty(PlotSubFolder)
% Make the Plot SubFolder folder names.
if ~iscell(PlotSubFolder)
PlotSubFolder={PlotSubFolder};
end
for sidx=1:length(PlotSubFolder)
    SubFolderFieldName=sprintf('SubFolder_%d',sidx);
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder;
[cfg_tmp,~] = cgg_generateFolderAndPath(PlotSubFolder{sidx},SubFolderFieldName,cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder=cfg_tmp;

PlotSubSubFolder = CheckVararginPairs('PlotSubSubFolder', '', varargin{:});
if ~isempty(PlotSubSubFolder)
% Make the Plot SubSubFolder folder names.
if ~iscell(PlotSubSubFolder)
PlotSubSubFolder={PlotSubSubFolder};
end

for ssidx=1:length(PlotSubSubFolder)
    SubSubFolderFieldName=sprintf('SubSubFolder_%d',ssidx);
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.(SubFolderFieldName);
[cfg_tmp,~] = cgg_generateFolderAndPath(PlotSubSubFolder{ssidx},SubSubFolderFieldName,cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.(SubFolderFieldName)=cfg_tmp;
end % End Loop for all subsubfolders folders
end % End for whether there are plot subsubfolders folders
end % End Loop for all subfolders folders
end % End for whether there are plot subfolders folders
end % End for whether there are plot folders

if ~isempty(ExplainedVariance)
% Make the Explained Variance folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath('Explained Variance','ExplainedVariance',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;

ExplainedVariance_Zoom = CheckVararginPairs('ExplainedVariance_Zoom', '', varargin{:});
if ~isempty(ExplainedVariance_Zoom)
% Make the Explained Variance Zoom folder names.
if ~iscell(ExplainedVariance_Zoom)
ExplainedVariance_Zoom={ExplainedVariance_Zoom};
end
for zidx=1:length(ExplainedVariance_Zoom)
    ZoomFieldName=sprintf('Zoom_%d',zidx);
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ExplainedVariance;
[cfg_tmp,~] = cgg_generateFolderAndPath(ExplainedVariance_Zoom{zidx},ZoomFieldName,cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ExplainedVariance=cfg_tmp;
end % End Loop for all zoom folders
end % End for whether there are zoom folders
end % End for whether there are explained variance folders

if ~isempty(DistributionType)
% Make the Data Distribution folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data Distribution','Distribution',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;
end

if ~isempty(ImportanceAnalysis)
% Make the Importance Analysis folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath('Importance Analysis','ImportanceAnalysis',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;

% Make the Importance Analysis Data folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ImportanceAnalysis;
[cfg_tmp,~] = cgg_generateFolderAndPath('Importance Analysis Data','ImportanceAnalysisData',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ImportanceAnalysis=cfg_tmp;
end

if ~isempty(PlotData)
% Make the PlotData folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plot Data','PlotData',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;
end

if ~isempty(Accuracy)
% Make the Accuracy folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath('Accuracy','Accuracy',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;
end

end % End for whether there exists any input for the Data Distribution or Importance Analysis or Plot Data or Accuracy
end % End for whether this is being called within a function

end % End for whether there exists any input for the Epoch
end % End for whether this is being called within a function



end

