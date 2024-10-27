%% FIGURE_cggPaperFigures

clc; clear; close all;
%%

Data_Location = "Main";
AreaNameCheck={'ACC','PFC','CD'};

%%

[~,outputfolder_base,temporaryfolder_base,~] = cgg_getBaseFolders();

MainDir=[outputfolder_base filesep 'Data_Neural'];
ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

RemovedChannelsDir = [MainDir filesep 'Variables' filesep 'Summary'];

BadChannelsPathNameExt = [RemovedChannelsDir filesep 'BadChannels.mat'];
NotSignificantChannelsPathNameExt = [RemovedChannelsDir filesep ...
    'NotSignificantChannels.mat'];

BadChannels = load(BadChannelsPathNameExt);
NotSignificantChannels = load(NotSignificantChannelsPathNameExt);

CommonRemovedChannels = [BadChannels.CommonDisconnectedChannels, ...
    NotSignificantChannels.CommonNotSignificant];


%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Plot Data','PlotSubFolder',VariableFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

[cfg_PlotData, ~] = cgg_generateSessionAggregationFolders('TargetDir',MainDir,'Folder','Variables','SubFolder','Regression');

PlotDatacfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;



%%%



