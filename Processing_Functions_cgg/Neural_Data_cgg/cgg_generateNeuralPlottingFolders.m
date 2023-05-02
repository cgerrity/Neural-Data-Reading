function [outdatadir_WideBand,outdatadir_LFP,outdatadir_Spike,...
    outdatadir_MUA,cfg] = cgg_generateNeuralPlottingFolders(...
    outdatadir,SessionName,ExperimentName,probe_area)
%CGG_GENERATENEURALDATAFOLDERS Summary of this function goes here
%   Detailed explanation goes here

% Make the Experiment and Session output folder names.
outdatadir_Experiment=[outdatadir, filesep, ExperimentName];
outdatadir_SessionName=[outdatadir_Experiment, filesep, SessionName];

% Make the Activity output folder names within this area.
outdatadir_Plots=[outdatadir_SessionName, filesep, 'Plots'];

% Make the Area Analysis output folder name.
outdatadir_Area=[outdatadir_Plots, filesep, probe_area];

% Make the Activity output folder names
outdatadir_WideBand=[outdatadir_Area, filesep, 'WideBand'];
outdatadir_LFP=[outdatadir_Area, filesep, 'LFP'];
outdatadir_Spike=[outdatadir_Area, filesep, 'Spike'];
outdatadir_MUA=[outdatadir_Area, filesep, 'MUA'];

% Make the Alignment type output folder names
outdatadir_MUA_Decision=[outdatadir_MUA, filesep, 'Decision'];
cfg.outdatadir_MUA_Decision=outdatadir_MUA_Decision;

% Make the Trial Separation Plot type output folder names
outdatadir_MUA_Decision_Error_Status=[outdatadir_MUA_Decision, filesep, ...
    'Correct_vs_Error'];
cfg.outdatadir_MUA_Decision_Error_Status=...
    outdatadir_MUA_Decision_Error_Status;

outdatadir_MUA_Decision_Learning=[outdatadir_MUA_Decision, filesep, ...
    'Learning'];
cfg.outdatadir_MUA_Decision_Learning=...
    outdatadir_MUA_Decision_Learning;

outdatadir_MUA_Decision_Learning_Unrewarded=[outdatadir_MUA_Decision, filesep, ...
    'Learning_Unrewarded'];
cfg.outdatadir_MUA_Decision_Learning_Unrewarded=...
    outdatadir_MUA_Decision_Learning_Unrewarded;

outdatadir_MUA_Decision_Learning_Rewarded=[outdatadir_MUA_Decision, filesep, ...
    'Learning_Rewarded'];
cfg.outdatadir_MUA_Decision_Learning_Rewarded=...
    outdatadir_MUA_Decision_Learning_Rewarded;

outdatadir_MUA_Decision_Attention=[outdatadir_MUA_Decision, filesep, ...
    'Attentional_Load'];
cfg.outdatadir_MUA_Decision_Attention=...
    outdatadir_MUA_Decision_Attention;

outdatadir_MUA_Decision_Motivation=[outdatadir_MUA_Decision, filesep, ...
    'Motivational_Context'];
cfg.outdatadir_MUA_Decision_Motivation=...
    outdatadir_MUA_Decision_Motivation;

outdatadir_MUA_Decision_Trial_In_Block=[outdatadir_MUA_Decision, filesep, ...
    'Trial_In_Block'];
cfg.outdatadir_MUA_Decision_Trial_In_Block=...
    outdatadir_MUA_Decision_Trial_In_Block;

outdatadir_MUA_Decision_Previous_Trial=[outdatadir_MUA_Decision, filesep, ...
    'Previous_Trial_Outcome'];
cfg.outdatadir_MUA_Decision_Previous_Trial=...
    outdatadir_MUA_Decision_Previous_Trial;

outdatadir_MUA_Decision_Block_Number=[outdatadir_MUA_Decision, filesep, ...
    'Block_Number'];
cfg.outdatadir_MUA_Decision_Block_Number=...
    outdatadir_MUA_Decision_Block_Number;

% cfg = cgg_generateFolderAndPath(outdatadir_MUA_Decision,'Performance',cfg);
% 
% cfg = cgg_generateFolderAndPath(outdatadir_MUA_Decision,'Token_State',cfg);
% 
% cfg = cgg_generateNeuralPlottingCorrectErrorFolders(...
%     outdatadir_MUA_Decision,'Fluid',cfg.outdatadir_MUA_Decision);

outdatadir_MUA_Decision_Feature=[outdatadir_MUA_Decision, filesep, ...
    'Chosen_Feature'];
cfg.outdatadir_MUA_Decision_Feature=...
    outdatadir_MUA_Decision_Feature;

% Make the Plot type output folder names
outdatadir_MUA_Decision_Error_Status_All=[...
    outdatadir_MUA_Decision_Error_Status, filesep, 'All'];
cfg.outdatadir_MUA_Decision_Error_Status_All=...
    outdatadir_MUA_Decision_Error_Status_All;

% Make the Feature plot output folder names
NumFeatures=9;
outdatadir_MUA_Decision_Error_Status_Feature=cell(1,NumFeatures);

outdatadir_MUA_Decision_Error_Status_Feature_template=[...
    outdatadir_MUA_Decision_Feature, filesep, 'Feature_%d'];

for fidx=1:NumFeatures
    outdatadir_MUA_Decision_Error_Status_Feature{fidx}=sprintf(...
        outdatadir_MUA_Decision_Error_Status_Feature_template,fidx);
end
cfg.outdatadir_MUA_Decision_Error_Status_Feature=...
    outdatadir_MUA_Decision_Error_Status_Feature;

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

% Check if the Plots output folders exist and if they do not, create them.
if ~exist(outdatadir_Plots, 'dir')
    mkdir(outdatadir_Plots);
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

% Check if the Trial Event aligned plot output folders exist and if they do
% not, create them.

if ~exist(outdatadir_MUA_Decision, 'dir')
    mkdir(outdatadir_MUA_Decision);
end
if ~exist(outdatadir_MUA_Decision_Error_Status, 'dir')
    mkdir(outdatadir_MUA_Decision_Error_Status);
end
if ~exist(outdatadir_MUA_Decision_Learning, 'dir')
    mkdir(outdatadir_MUA_Decision_Learning);
end
if ~exist(outdatadir_MUA_Decision_Learning_Rewarded, 'dir')
    mkdir(outdatadir_MUA_Decision_Learning_Rewarded);
end
if ~exist(outdatadir_MUA_Decision_Learning_Unrewarded, 'dir')
    mkdir(outdatadir_MUA_Decision_Learning_Unrewarded);
end
if ~exist(outdatadir_MUA_Decision_Attention, 'dir')
    mkdir(outdatadir_MUA_Decision_Attention);
end
if ~exist(outdatadir_MUA_Decision_Motivation, 'dir')
    mkdir(outdatadir_MUA_Decision_Motivation);
end
if ~exist(outdatadir_MUA_Decision_Trial_In_Block, 'dir')
    mkdir(outdatadir_MUA_Decision_Trial_In_Block);
end
if ~exist(outdatadir_MUA_Decision_Previous_Trial, 'dir')
    mkdir(outdatadir_MUA_Decision_Previous_Trial);
end
if ~exist(outdatadir_MUA_Decision_Block_Number, 'dir')
    mkdir(outdatadir_MUA_Decision_Block_Number);
end
% if ~exist(outdatadir_MUA_Decision_Performance, 'dir')
%     mkdir(outdatadir_MUA_Decision_Performance);
% end
% if ~exist(outdatadir_MUA_Decision_Token_State, 'dir')
%     mkdir(outdatadir_MUA_Decision_Token_State);
% end
if ~exist(outdatadir_MUA_Decision_Error_Status_All, 'dir')
    mkdir(outdatadir_MUA_Decision_Error_Status_All);
end
if ~exist(outdatadir_MUA_Decision_Feature, 'dir')
    mkdir(outdatadir_MUA_Decision_Feature);
end

for fidx=1:NumFeatures
if ~exist(outdatadir_MUA_Decision_Error_Status_Feature{fidx}, 'dir')
    mkdir(outdatadir_MUA_Decision_Error_Status_Feature{fidx});
end
end

end

