allTrialData.Dim = allTrialData.Dimensionality;
allTrialData.Sto = allTrialData.Stochasticity;
allTrialData.IvE = allTrialData.ID_ED;
allTrialData.LS = allTrialData.LearningStatus;
allTrialData.ChosenBias = allTrialData.TargetBias;
allTrialData.ChosenBias(allTrialData.Acc == 0) = allTrialData.ChosenBias(allTrialData.Acc == 0) * -1;

accModels = NewTrialResults(allBlockData, allTrialData, 'Acc');
save('FLU_TrialModels_Acc', 'accModels');
liftTimeModels = NewTrialResults(allBlockData, allTrialData, 'LiftTime');
save('FLU_TrialModels_LiftTime', 'liftTimeModels');
reachTimeModels = NewTrialResults(allBlockData, allTrialData, 'ReachTime');
save('FLU_TrialModels_ReachTime', 'reachTimeModels');
targetBiasModels = NewTrialResults(allBlockData, allTrialData, 'TargetBias');
save('FLU_TrialModelsTargetBias', 'targetBiasModels');
chosenBiasModels = NewTrialResults(allBlockData, allTrialData, 'ChosenBias');
save('FLU_TrialModels_ChosenBias', 'chosenBiasModels');