function [cfg, TargetDir] = cgg_generateSessionAggregationFolders(varargin)
%CGG_GENERATESESSIONAGGREGATIONFOLDERS Summary of this function goes here
%   Detailed explanation goes here
%% Destination Directory
isfunction=exist('varargin','var');

if isfunction
[TargetDir] = cgg_ioTargetDirectory(varargin{:});
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

%% Plot Folder

% Make the Plot folder name.
cfg_tmp=cfg.TargetDir.Aggregate_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp);
cfg.TargetDir.Aggregate_Data=cfg_tmp;

%% Epoch Folders

% Make the Epoch and its subfolder folder names.
if isfunction
Epoch = CheckVararginPairs('Epoch', '', varargin{:});
if ~isempty(Epoch)
    
% Make the Epoched_Data folder name.
cfg_tmp=cfg.TargetDir.Aggregate_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath('Epoched Data','Epoched_Data',cfg_tmp);
cfg.TargetDir.Aggregate_Data=cfg_tmp;
    
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


end % End for whether there exists any input for the Epoch
end % End for whether this is being called within a function

%% Activity Folders

% Make the Activity folder names.
if isfunction
Activity = CheckVararginPairs('Activity', '', varargin{:});
if ~isempty(Activity)
cfg_tmp=cfg.TargetDir.Aggregate_Data.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath(Activity,'Activity',cfg_tmp);
cfg.TargetDir.Aggregate_Data.Plots=cfg_tmp;
end % End for whether there exists any input for the activity type
end % End for whether this is being called within a function

% Make the Activity SubFolder name(s).
if isfunction
ActivitySubFolder = CheckVararginPairs('ActivitySubFolders', '', varargin{:});
if ~isempty(ActivitySubFolder)&&~isempty(Activity)
for sidx=1:length(ActivitySubFolder)
this_ActivitySubFolder=ActivitySubFolder{sidx};
cfg_tmp=cfg.TargetDir.Aggregate_Data.Plots.Activity;
[cfg_tmp,~] = cgg_generateFolderAndPath(this_ActivitySubFolder,...
    sprintf('ActivitySubFolder_%d',sidx),cfg_tmp);
cfg.TargetDir.Aggregate_Data.Plots.Activity=cfg_tmp;
end % End for looping through all sub folders of activity
end % End for whether there exists any input for the subfolders and the 
    % activity type
end % End for whether this is being called within a function

end

