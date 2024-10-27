function [outputArg1,outputArg2] = cgg_procRegressionResultsFromProcessing(inputArg1,inputArg2)
%CGG_PROCREGRESSIONRESULTSFROMPROCESSING Summary of this function goes here
%   Detailed explanation goes here


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

[cfg_Target] = cgg_generateSessionAggregationFolders('TargetDir',MainDir,...
    'Folder','Variables','SubFolder','Regression');

[cfg_Results, ~] = cgg_generateSessionAggregationFolders('TargetDir',MainDir);

cfg_Save.ResultsDir=cfg_Results.TargetDir;

PlotDatacfg=cfg_Target.TargetDir.Aggregate_Data.Plots;


end

