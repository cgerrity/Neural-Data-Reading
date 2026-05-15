%% DATA_cggUpdateYAMLParameters

clc; clear; close all;

Fold_Start=1;
Fold_End=10;

%%
SLURMChoice_All = {'Base',11,14,15};
SLURMIDX_All = {NaN,7,10,[1,2,3,4,5,6,7]};

%%
for cidx = 1:length(SLURMChoice_All)
    SLURMChoice = SLURMChoice_All{cidx};
    this_SLURMIDX_All = SLURMIDX_All{cidx};
    for idx = 1:length(this_SLURMIDX_All)
        SLURMIDX = this_SLURMIDX_All(idx);
for fidx=Fold_Start:Fold_End
Fold=fidx;
if strcmp(SLURMChoice,'Base')
SLURMIDX = Fold;
end
cgg_runAutoEncoder(Fold,'SLURMChoice',SLURMChoice,'SLURMIDX',SLURMIDX,'StopAfterParameterSave',true);
end

    end
end