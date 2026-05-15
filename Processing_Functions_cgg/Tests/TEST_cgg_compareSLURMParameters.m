
clc; clear; close all;
rng('shuffle');
%%
SLURMChoice = 14;
SLURMIDX = 10;


cfg_Encoder = PARAMETERS_cgg_runAutoEncoder('Epoch','Decision','ParameterSetName','Optimal');
Fold = 1;
[TableSLURM, ~] = ...
SLURMPARAMETERS_cgg_runAutoEncoder_v2('Base',Fold, ...
'SessionRunIDX',NaN,'Epoch','Decision');
[~,cfg_Base] = cgg_assignSLURMEncoderParameters(cfg_Encoder,TableSLURM);
%%
[TableSLURM, ~] = ...
SLURMPARAMETERS_cgg_runAutoEncoder_v2(SLURMChoice,SLURMIDX, ...
'SessionRunIDX',NaN,'Epoch','Decision');
[~,cfg_Alteration] = cgg_assignSLURMEncoderParameters(cfg_Encoder,TableSLURM);
%%
[DynamicAugmentation, DynamicWeighting, DynamicFreezing, DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(cfg_Base.DynamicParameterSet);
cfg_Base.DynamicAugmentation = DynamicAugmentation;
cfg_Base.DynamicWeighting = DynamicWeighting;
cfg_Base.DynamicFreezing = DynamicFreezing;
cfg_Base.DynamicSetDescription = DynamicSetDescription;
%%
[DynamicAugmentation, DynamicWeighting, DynamicFreezing, DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(cfg_Alteration.DynamicParameterSet);
cfg_Alteration.DynamicAugmentation = DynamicAugmentation;
cfg_Alteration.DynamicWeighting = DynamicWeighting;
cfg_Alteration.DynamicFreezing = DynamicFreezing;
cfg_Alteration.DynamicSetDescription = DynamicSetDescription;
%%
cfg_Base.BaselineDynamicParameters = cgg_setBaselineDynamicParameters(cfg_Base,'IsFinalSetting',true);
cfg_Alteration.BaselineDynamicParameters = cgg_setBaselineDynamicParameters(cfg_Alteration,'IsFinalSetting',true);
%%
[DifferentVariables,MissingVariables] = cgg_compareStruct(cfg_Base, cfg_Alteration);