function [cfg] = cgg_generateEpochFolders(Epoch,varargin)
%CGG_GENERATEEPOCHFOLDERS Summary of this function goes here
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

% Make the Epoched Data output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Epoched_Data','Epoched_Data',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session=cfg_tmp;

% Make the Epoch output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data;
[cfg_tmp,~] = cgg_generateFolderAndPath(Epoch,'Epoch',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data=cfg_tmp;

% Make the Data output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data','Data',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch=cfg_tmp;

% Make the Target output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Target','Target',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch=cfg_tmp;

% Make the Processing output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Processing','Processing',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch=cfg_tmp;

if isfunction
Data_Normalized = CheckVararginPairs('Data_Normalized', false, varargin{:});
if Data_Normalized

% Make the Normalized Data output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Data_Normalized','Data_Normalized',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch=cfg_tmp;

end % End for whether to make the Normalized Data Folder
end % End for whether this is being called within a function

if isfunction
NormalizationInformation = CheckVararginPairs('NormalizationInformation', false, varargin{:});
if NormalizationInformation

% Make the Normalization Information output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Normalization Information','NormalizationInformation',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch=cfg_tmp;

end % End for whether to make the Normalization Information Folder
end % End for whether this is being called within a function

if isfunction
AreaPlot = CheckVararginPairs('AreaPlot', '', varargin{:});
if ~isempty(AreaPlot)
% Make the Plots output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch=cfg_tmp;

% Make the Area output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath(AreaPlot,'AreaPlot',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Plots=cfg_tmp;
end
end

end

