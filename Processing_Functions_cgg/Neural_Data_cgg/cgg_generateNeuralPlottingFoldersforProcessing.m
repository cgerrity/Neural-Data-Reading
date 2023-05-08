function [cfg] = cgg_generateNeuralPlottingFoldersforProcessing(outdatadir,...
    SessionName,ExperimentName,probe_area,Activity_Type)
%CGG_GENERATENEURALDATAFOLDERS_v2 Summary of this function goes here
%   Detailed explanation goes here

cfg=struct();

cfg.outdatadir.path=outdatadir;

% Make the Experiment and Session output folder names.
cfg_tmp=cfg.outdatadir;
[cfg_tmp,~] = cgg_generateFolderAndPath(ExperimentName,'Experiment',cfg_tmp);
cfg.outdatadir=cfg_tmp;

cfg_tmp=cfg.outdatadir.Experiment;
[cfg_tmp,~] = cgg_generateFolderAndPath(SessionName,'Session',cfg_tmp);
cfg.outdatadir.Experiment=cfg_tmp;

% Make the Plots output folder names within this Session.
cfg_tmp=cfg.outdatadir.Experiment.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath('Plots','Plots',cfg_tmp);
cfg.outdatadir.Experiment.Session=cfg_tmp;

% Make the Area output folder name.
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots;
[cfg_tmp,~] = cgg_generateFolderAndPath(probe_area,'Area',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots=cfg_tmp;

% Make the Activity output folder names
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area;
[cfg_tmp,~] = cgg_generateFolderAndPath(Activity_Type,'Activity',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area=cfg_tmp;

% Processing Steps
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity;
[cfg_tmp,~] = cgg_generateFolderAndPath('Processing_Steps','Processing_Steps',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity=cfg_tmp;

% Processing Steps: WideBand
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
[cfg_tmp,~] = cgg_generateFolderAndPath('WideBand','WideBand',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps=cfg_tmp;

% Processing Steps: Bandpass
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
[cfg_tmp,~] = cgg_generateFolderAndPath('Bandpass','Bandpass',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps=cfg_tmp;

% Processing Steps: Rectify
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
[cfg_tmp,~] = cgg_generateFolderAndPath('Rectify','Rectify',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps=cfg_tmp;

% Processing Steps: Lowpass
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
[cfg_tmp,~] = cgg_generateFolderAndPath('Lowpass','Lowpass',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps=cfg_tmp;

% Processing Steps: Resample
cfg_tmp=cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
[cfg_tmp,~] = cgg_generateFolderAndPath('Resample','Resample',cfg_tmp);
cfg.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps=cfg_tmp;

end

