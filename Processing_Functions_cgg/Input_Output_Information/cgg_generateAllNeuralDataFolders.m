function [inputfolder,outdatadir,SessionName,ExperimentName,...
    outdatadir_EventInformation,outdatadir_FrameInformation,...
    outdatadir_TrialInformation] = ...
    cgg_generateAllNeuralDataFolders(varargin)
%CGG_GENERATE Summary of this function goes here
%   Detailed explanation goes here
%% Directories

% This gets the input folder from varargin. Use the name value pair of
% 'inputfolder'. If nothing is selected it will prompt you to select a
% folder.
% Select a folder that has the highest session information e.g.
% 'Fr_Probe_02_22-05-09_009_01'
inputfolder = CheckVararginPairs('inputfolder', '', varargin{:});
if isempty(inputfolder)
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
outdatadir = CheckVararginPairs('outdatadir', '', varargin{:});
if isempty(outdatadir)
    outdatadir = uigetdir(['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'], 'Choose the output data folder');
end

%%
% Make the Experiment and Session output folder names.
outdatadir_Experiment=[outdatadir, filesep, ExperimentName];
outdatadir_SessionName=[outdatadir_Experiment, filesep, SessionName];

% Make the Event Information and Frame Information output folder names.
outdatadir_EventInformation=[outdatadir_SessionName, filesep, 'Event_Information'];
outdatadir_FrameInformation=[outdatadir_SessionName, filesep, 'Frame_Information'];
outdatadir_TrialInformation=[outdatadir_SessionName, filesep, 'Trial_Information'];


% Check if the Experiment and Session output folders exist and if they do
% not, create them.
if ~exist(outdatadir_Experiment, 'dir')
    mkdir(outdatadir_Experiment);
end
if ~exist(outdatadir_SessionName, 'dir')
    mkdir(outdatadir_SessionName);
end

% Check if the Event Information, Frame Information, and Trial Information
% output folders exist and if they do not, create them.
if ~exist(outdatadir_EventInformation, 'dir')
    mkdir(outdatadir_EventInformation);
end
if ~exist(outdatadir_FrameInformation, 'dir')
    mkdir(outdatadir_FrameInformation);
end
if ~exist(outdatadir_TrialInformation, 'dir')
    mkdir(outdatadir_TrialInformation);
end


end

