function [cfg] = cgg_generateNeuralPlottingFolders_v2(outdatadir,...
    SessionName,ExperimentName,probe_area,Activity_Type,Alignment_Type,varargin)
%CGG_GENERATENEURALDATAFOLDERS_v2 Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=true;
end
end

cfg=struct();

cfg.outdatadir.path=outdatadir;

% Make the Experiment and Session output folder names.
cfg_tmp=cfg.outdatadir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ExperimentName,'Experiment',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment;
[cfg_tmp,~] = cgg_generateFolderAndPath(SessionName,'Session',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment=cfg_tmp;

% Make the Plots output folder names within this Session.
cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session=cfg_tmp;

% Make the Area output folder name.
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath(probe_area,'Area',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots=cfg_tmp;

% Make the Activity output folder names
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area;
[cfg_tmp,~] = cgg_generateFolderAndPath(Activity_Type,'Activity',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area=cfg_tmp;

% Make the Alignment type output folder names
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity;
[cfg_tmp,~] = cgg_generateFolderAndPath(Alignment_Type,'Alignment',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity=cfg_tmp;

% Make the Trial Separation Plot type output folder names
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
[cfg_tmp,~] = cgg_generateFolderAndPath('Correct_vs_Error','Correct_vs_Error',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Learning','Learning',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Attentional_Load','Attentional_Load',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Motivational_Context','Motivational_Context',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Trial_In_Block','Trial_In_Block',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Previous_Trial_Outcome','Previous_Trial_Outcome',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Block_Number','Block_Number',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Performance','Performance',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Token_State','Token_State',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders('Fluid','Fluid',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
cfg_tmp = cgg_generateFolderAndPath('Chosen_Feature','Chosen_Feature',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

NumFeatures=9;

for fidx=1:NumFeatures
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment.Chosen_Feature;
cfg_tmp = cgg_generateNeuralPlottingCorrectErrorFolders(sprintf('Feature_%d',fidx),sprintf('Feature_%d',fidx),cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment.Chosen_Feature=cfg_tmp;        
end

% Mean Value
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
[cfg_tmp,~] = cgg_generateFolderAndPath('Mean_Values','Mean_Values',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

% Regression
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;
[cfg_tmp,~] = cgg_generateFolderAndPath('Regression','Regression',cfg_tmp,'WantDirectory',WantDirectory);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment=cfg_tmp;

end

