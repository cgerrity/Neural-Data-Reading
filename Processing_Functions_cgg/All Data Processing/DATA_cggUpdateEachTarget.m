%% DATA_cggUpdateEachTarget

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision';

%%
outdatadir=cfg(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg(1).temporarydir;
cfg_Folders = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch);
cfg_Folders.ResultsDir=cfg_Results.TargetDir;

AggregateTargetPath = cgg_getDirectory(cfg_Folders.TargetDir,'Target');

Identifiers_Table = cgg_getIdentifiersTable(cfg_Folders,false,'Epoch',Epoch);

%%

LearningModelTable = cgg_getNewLearningModelVariablesFromTargetPath(AggregateTargetPath);
%%
UpdateFunction=@(x) cgg_augmentTargetWithLearningModel(x, LearningModelTable);

%%

AggregateTargetsDir = dir(fullfile(AggregateTargetPath, 'Target_*.mat'));

for tidx = 1:length(AggregateTargetsDir)
    TargetPathNameExt = fullfile(AggregateTargetsDir(tidx).folder,AggregateTargetsDir(tidx).name);
    cgg_updateAggregateTargetFile(TargetPathNameExt,UpdateFunction)
end
