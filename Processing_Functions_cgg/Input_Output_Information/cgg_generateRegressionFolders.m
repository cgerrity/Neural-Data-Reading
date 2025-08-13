function [cfg] = cgg_generateRegressionFolders(probe_area,varargin)
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
[cfg_tmp,~] = cgg_generateFolderAndPath('Regression','Regression',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session=cfg_tmp;

% Make the Area output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Regression;
[cfg_tmp,~] = cgg_generateFolderAndPath(probe_area,'Area',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Regression=cfg_tmp;


end

