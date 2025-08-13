function [cfg] = cgg_generateChannelMappingFolders(probe_area,varargin)
%CGG_GENERATENEURALDATAFOLDERS Summary of this function goes here
%   Detailed explanation goes here

%%
isfunction=exist('varargin','var');

if isfunction
[inputfolder,outdatadir,SessionName,ExperimentName] = ...
    cgg_ioInputOutputDirectories(varargin{:});
else
    if exist('inputfolder','var') && exist('outdatadir','var')
    [inputfolder,outdatadir,SessionName,ExperimentName] = ...
    cgg_ioInputOutputDirectories('inputfolder',inputfolder,...
    'outdatadir',outdatadir);
    elseif exist('outdatadir','var')
    [inputfolder,outdatadir,SessionName,ExperimentName] = ...
    cgg_ioInputOutputDirectories('outdatadir',outdatadir);
    elseif exist('inputfolder','var')
    [inputfolder,outdatadir,SessionName,ExperimentName] = ...
    cgg_ioInputOutputDirectories('inputfolder',inputfolder);
    else
    [inputfolder,outdatadir,SessionName,ExperimentName] = ...
    cgg_ioInputOutputDirectories;
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

cfg.outdatadir.path=outdatadir;
cfg.inputfolder.path=inputfolder;

%%

% Make the Experiment and Session output folder names.
cfg_tmp=cfg.outdatadir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ExperimentName,'Experiment',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment;
[cfg_tmp,~] = cgg_generateFolderAndPath(SessionName,'Session',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment=cfg_tmp;

% Make the Activity output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session=cfg_tmp;

% Make the Area output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath(probe_area,'Area',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots=cfg_tmp;

% Make the Activity output folder names
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area;
[cfg_tmp,~] = cgg_generateFolderAndPath('WideBand','Activity',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area=cfg_tmp;

% Channel Mapping Plots
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity;
[cfg_tmp,~] = cgg_generateFolderAndPath('Channel_Mapping',...
    'Channel_Mapping',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity=cfg_tmp;

% Correlation Plots
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity;
[cfg_tmp,~] = cgg_generateFolderAndPath('Correlation',...
    'Correlation',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity=cfg_tmp;

% Channel Example Plots
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity;
[cfg_tmp,~] = cgg_generateFolderAndPath('Activity Example',...
    'Activity_Example',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity=cfg_tmp;


end

