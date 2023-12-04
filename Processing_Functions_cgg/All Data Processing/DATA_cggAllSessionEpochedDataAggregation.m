%% DATA_cggAllSessionEpochedDataAggregation

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Epoch_3'; %Testing

%%

for sidx=1:length(cfg)
    
    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;
    SessionFolder=cfg(sidx).SessionFolder;
    TargetDir=outdatadir;

    cgg_gatherDataFromSingleSession(SessionFolder,Epoch,TargetDir)

end