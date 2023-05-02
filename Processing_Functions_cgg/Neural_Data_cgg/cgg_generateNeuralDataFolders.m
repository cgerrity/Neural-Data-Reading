function [outdatadir_WideBand,outdatadir_LFP,outdatadir_Spike,...
    outdatadir_MUA] = cgg_generateNeuralDataFolders(...
    outdatadir,SessionName,ExperimentName,probe_area)
%CGG_GENERATENEURALDATAFOLDERS Summary of this function goes here
%   Detailed explanation goes here

% Make the Experiment and Session output folder names.
outdatadir_Experiment=[outdatadir, filesep, ExperimentName];
outdatadir_SessionName=[outdatadir_Experiment, filesep, SessionName];

% FIXME: EDITTED THIS TO MAKE FOR EASIER FINDING OF ACTIVITY DOUBLE CHECK
% IT DID NOT RUIN ANYTHING!!!!!!!

% % Make the Area Analysis output folder name.
% outdatadir_Area=[outdatadir_SessionName, filesep, probe_area];
% 
% % Make the Activity output folder names within this area.
% outdatadir_Activity=[outdatadir_Area, filesep, 'Activity'];

% Make the Activity output folder names within this area.
outdatadir_Activity=[outdatadir_SessionName, filesep, 'Activity'];

% Make the Area Analysis output folder name.
outdatadir_Area=[outdatadir_Activity, filesep, probe_area];

% FIXME: EDITTED THIS TO MAKE FOR EASIER FINDING OF ACTIVITY DOUBLE CHECK
% IT DID NOT RUIN ANYTHING!!!!!!!

% Make the Processed Activity output folder names
outdatadir_WideBand=[outdatadir_Area, filesep, 'WideBand'];
outdatadir_LFP=[outdatadir_Area, filesep, 'LFP'];
outdatadir_Spike=[outdatadir_Area, filesep, 'Spike'];
outdatadir_MUA=[outdatadir_Area, filesep, 'MUA'];

%%

% Check if the Experiment and Session output folders exist and if they do
% not, create them.
if ~exist(outdatadir_Experiment, 'dir')
    mkdir(outdatadir_Experiment);
end
if ~exist(outdatadir_SessionName, 'dir')
    mkdir(outdatadir_SessionName);
end

% Check if the Area output folders exist and if they do not, create them.
if ~exist(outdatadir_Area, 'dir')
    mkdir(outdatadir_Area);
end

% Check if the Activity output folders exist and if they do not, create them.
if ~exist(outdatadir_Activity, 'dir')
    mkdir(outdatadir_Activity);
end

% Check if the Processed Activit output folders exist and if they do not,
% create them.
if ~exist(outdatadir_WideBand, 'dir')
    mkdir(outdatadir_WideBand);
end
if ~exist(outdatadir_LFP, 'dir')
    mkdir(outdatadir_LFP);
end
if ~exist(outdatadir_Spike, 'dir')
    mkdir(outdatadir_Spike);
end
if ~exist(outdatadir_MUA, 'dir')
    mkdir(outdatadir_MUA);
end

end

