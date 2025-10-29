%% DATA_cggUpdateTargets

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

Identifiers_Table = cgg_getIdentifiersTable(cfg_Folders,false,'Epoch',Epoch);

%%

UpdateFunction=@(x) x;

%%


%%
for sidx=1:length(cfg)
    
    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;

cgg_updateSessionTargetStructure(UpdateFunction,Epoch,inputfolder,outdatadir)

end