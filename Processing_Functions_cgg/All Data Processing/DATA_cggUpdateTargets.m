%% DATA_cggUpdateTargets

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision';

UpdateFunction=@cgg_procPreviousTrialSharedFeature;

%%

for sidx=1:length(cfg)
    
    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;

cgg_updateSessionTargetStructure(UpdateFunction,Epoch,inputfolder,outdatadir)

end