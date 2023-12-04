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

% Make the Processing folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Processing','Processing',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

% Make the Decoding folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Decoding','Decoding',cfg_tmp);
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

end % End for whether there exists any input for the Epoch
end % End for whether this is being called within a function

if isfunction
DistributionType = CheckVararginPairs('DistributionType', '', varargin{:});
if ~isempty(DistributionType)

% Make the Plot output folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

% Make the Data Distribution folder names.
cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data Distribution','Distribution',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots=cfg_tmp;

% % Make the Specific Data Distribution Type folder names.
% cfg_tmp=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Distribution;
% [cfg_tmp,~] = cgg_generateFolderAndPath(DistributionType,'DistributionType',cfg_tmp);
% cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Distribution=cfg_tmp;

end % End for whether there exists any input for the Data Distribution
end % End for whether this is being called within a function

end

