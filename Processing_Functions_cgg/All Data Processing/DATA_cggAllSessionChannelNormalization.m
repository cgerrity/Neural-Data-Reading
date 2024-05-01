%% DATA_cggAllSessionChannelNormalization

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision';
%%

for sidx=25:length(cfg)
    
    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;

cgg_procSessionNormalization(Epoch,inputfolder,outdatadir);

end




