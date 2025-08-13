function [cfg] = cgg_generateTemporaryDataFolders(varargin)
%CGG_GENERATETEMPORARYDATAFOLDERS Summary of this function goes here
%   Detailed explanation goes here
%% Destination Directory
isfunction=exist('varargin','var');

if isfunction
TemporaryDir = CheckVararginPairs('TemporaryDir', '', varargin{:});
[TemporaryDir] = cgg_ioTargetDirectory('TargetDir',TemporaryDir);
else
    if ~exist('TemporaryDir','var')
    [TemporaryDir] = cgg_ioTargetDirectory;
    end
end

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=true;
end
end

cfg=struct();

cfg.TemporaryDir.path=TemporaryDir;
%% Main Folder

% Make the All Sessions folder name.
cfg_tmp=cfg.TemporaryDir;
[cfg_tmp,~] = cgg_generateFolderAndPath('Aggregate Data','Aggregate_Data',cfg_tmp,'WantDirectory',WantDirectory);
cfg.TemporaryDir=cfg_tmp;
%% Epoch Folders

% Make the Epoch and its subfolder folder names.
if isfunction
Epoch = CheckVararginPairs('Epoch', '', varargin{:});
if ~isempty(Epoch)
    
% Make the Epoched_Data folder name.
cfg_tmp=cfg.TemporaryDir.Aggregate_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath('Temporary Epoched Data','Epoched_Data',cfg_tmp,'WantDirectory',WantDirectory);
cfg.TemporaryDir.Aggregate_Data=cfg_tmp;
    
% Make the Epoch folder names.
cfg_tmp=cfg.TemporaryDir.Aggregate_Data.Epoched_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath(Epoch,'Epoch',cfg_tmp,'WantDirectory',WantDirectory);
cfg.TemporaryDir.Aggregate_Data.Epoched_Data=cfg_tmp;

% Make the Target folder names.
cfg_tmp=cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Target','Target',cfg_tmp,'WantDirectory',WantDirectory);
cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;

% Make the Data folder names.
cfg_tmp=cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data','Data',cfg_tmp,'WantDirectory',WantDirectory);
cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch=cfg_tmp;


end % End for whether there exists any input for the Epoch
end % End for whether this is being called within a function

end

