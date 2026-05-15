

NumEpochs = 60;
cfg = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v3();

%%
[DynamicAugmentation, DynamicWeighting, DynamicFreezing, DynamicSetDescription] = PARAMETERS_cgg_selectDynamicParameters(cfg.DynamicParameterSet);
cfg.DynamicAugmentation = DynamicAugmentation;
cfg.DynamicWeighting = DynamicWeighting;
cfg.DynamicFreezing = DynamicFreezing;
cfg.DynamicSetDescription = DynamicSetDescription;

%%
[LoadParameters, WeightParameters, FreezeParameters] = ...
cgg_generateAllDynamicParameters(cfg);


LoadParameters.plotParametersOverEpochs(NumEpochs);
WeightParameters.plotParametersOverEpochs(NumEpochs);
FreezeParameters.plotParametersOverEpochs(NumEpochs);
