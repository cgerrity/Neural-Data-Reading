%% DATA_cggAllSessionEpochedDataAggregation

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision'; %Testing
Data_Normalized=true;

%%

for sidx=1:length(cfg)
    
    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;
    SessionFolder=cfg(sidx).SessionFolder;
    TargetDir=outdatadir;

    cgg_gatherDataFromSingleSession(SessionFolder,Epoch,TargetDir,...
        'Data_Normalized',Data_Normalized);

end