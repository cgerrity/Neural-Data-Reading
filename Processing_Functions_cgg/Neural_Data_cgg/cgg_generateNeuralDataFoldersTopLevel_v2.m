function [cfg] = cgg_generateNeuralDataFoldersTopLevel_v2(varargin)
%CGG_GENERATENEURALDATAFOLDERS Summary of this function goes here
%   Detailed explanation goes here

%%
isfunction=exist('varargin','var');

if isfunction
inputfolder = CheckVararginPairs('inputfolder', '', varargin{:});
if isempty(inputfolder)
    inputfolder = uigetdir(['/Volumes/','Womelsdorf Lab','/DATA_neural'], 'Choose the input data folder');
end
else
    inputfolder = uigetdir(['/Volumes/','Womelsdorf Lab','/DATA_neural'], 'Choose the input data folder');
end
% This gets the Session name and the Experiment name
% E.G. Session -> 'Fr_Probe_02_22-05-09_009_01'
% E.G. Experiment -> 'Frey_FLToken_Probe_02'
[inputfolder_dir,SessionName,~]=fileparts(inputfolder);
[~,ExperimentName,~]=fileparts(inputfolder_dir);


% This gets the ouput folder from varargin. Use the name value pair of
% 'outdatadir'. If nothing is selected it will prompt you to select a
% folder.
% Select a folder that is where you would like to write any data. It will
% make the various subfolders that correspond to the experiment and the
% session that you have chosen in the input folder
if isfunction
outdatadir = CheckVararginPairs('outdatadir', '', varargin{:});
if isempty(outdatadir)
    outdatadir = uigetdir(['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'], 'Choose the output data folder');
end
else
    outdatadir = uigetdir(['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'], 'Choose the output data folder');
end

cfg=struct();

cfg.outdatadir.path=outdatadir;
cfg.inputfolder.path=inputfolder;

% Make the Experiment and Session output folder names.
cfg_tmp=cfg.outdatadir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ExperimentName,'Experiment',cfg_tmp);
cfg.outdatadir=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment;
[cfg_tmp,~] = cgg_generateFolderAndPath(SessionName,'Session',cfg_tmp);
cfg.outdatadir.Experiment=cfg_tmp;

% Make the Activity, Event Information, Frame Information, and Trial
% Information output folder names.
cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Activity','Activity',cfg_tmp);
cfg.outdatadir.Experiment.Session=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Event_Information','Event_Information',cfg_tmp);
cfg.outdatadir.Experiment.Session=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Frame_Information','Frame_Information',cfg_tmp);
cfg.outdatadir.Experiment.Session=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Trial_Information','Trial_Information',cfg_tmp);
cfg.outdatadir.Experiment.Session=cfg_tmp;

% 
cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Time_Information','Time_Information',cfg_tmp);
cfg.outdatadir.Experiment.Session=cfg_tmp;



end

