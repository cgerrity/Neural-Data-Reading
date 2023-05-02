% accFullModel = LpLME_FLU(allTrialData, 'Acc', {'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock', 'TrialsFromLP'}, {'SubjectNum'}, 'Acc ~ LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock * TrialsFromLP');
% reachTimeFullModel = LpLME_FLU(allTrialData, 'TimeTouchFromLiftOfHoldKey', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock', 'TrialsFromLP'}, {'SubjectNum'}, 'TimeTouchFromLiftOfHoldKey ~ LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock * TrialsFromLP');
% targetBiasFullModel = LpLME_FLU(allTrialData, 'ChosenBias', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock', 'TrialsFromLP'}, {'SubjectNum'}, 'ChosenBias ~ LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock * TrialsFromLP');

fluModels.Acc.FullModel = LpLME_FLU(allTrialData, 'Acc', {'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'Acc ~ LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.Acc.PreLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 0,:), 'Acc', {'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'Acc ~ ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.Acc.PostLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 1,:), 'Acc', {'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'Acc ~ ID_ED * Dimensionality * Stochasticity * TrialInBlock');

fluData.Acc.All = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'All'}}, 'Acc');
fluData.Acc.D2 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, 'Acc');
fluData.Acc.D5 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, 'Acc');
fluData.Acc.o15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'All'}}, 'Acc');
fluData.Acc.o30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'All'}}, 'Acc');
fluData.Acc.All = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'All'}}, 'Acc');
fluData.Acc.PreLP = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PreLP'}}, 'Acc');
fluData.Acc.PostLP = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PostLP'}}, 'Acc');



fluModels.ReachTime.FullModel = LpLME_FLU(allTrialData, 'TimeTouchFromLiftOfHoldKey', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TimeTouchFromLiftOfHoldKey ~ Acc * LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ReachTime.PreLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 0,:), 'TimeTouchFromLiftOfHoldKey', {'Acc', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TimeTouchFromLiftOfHoldKey ~ Acc * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ReachTime.PostLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 1,:), 'TimeTouchFromLiftOfHoldKey', {'Acc', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TimeTouchFromLiftOfHoldKey ~ Acc * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ReachTime.PostLpCorrModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 1 & allTrialData.Acc == 1,:), 'TimeTouchFromLiftOfHoldKey', {'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TimeTouchFromLiftOfHoldKey ~ ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ReachTime.PostLpIncModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 1 & allTrialData.Acc == 0,:), 'TimeTouchFromLiftOfHoldKey', {'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TimeTouchFromLiftOfHoldKey ~ ID_ED * Dimensionality * Stochasticity * TrialInBlock');


fluData.ReachTime.All = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'All'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.D2 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.D5 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.o15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'All'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.o30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'All'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PreLp = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PreLP'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PostLP'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PreLp_2D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PreLP'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PreLp_5D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PreLP'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Corr = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Corr'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Inc = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Inc'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Corr_2D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Corr'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Corr_5D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Corr'}}, 'TimeTouchFromLiftOfHoldKey');

fluData.ReachTime.PostLp_Inc_2D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Inc'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Inc_5D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Inc'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Inc_15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Inc'}}, 'TimeTouchFromLiftOfHoldKey');
fluData.ReachTime.PostLp_Inc_30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'PostLP'}, {'Accuracy', 'Inc'}}, 'TimeTouchFromLiftOfHoldKey');




fluModels.ChosenBias.FullModel = LpLME_FLU(allTrialData, 'ChosenBias', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'ChosenBias ~ Acc * LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ChosenBias.CorrModel = LpLME_FLU(allTrialData(allTrialData.Acc == 1,:), 'ChosenBias', {'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'ChosenBias ~ LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ChosenBias.IncModel = LpLME_FLU(allTrialData(allTrialData.Acc == 0,:), 'ChosenBias', {'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'ChosenBias ~ LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ChosenBias.PreLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 0,:), 'ChosenBias', {'Acc', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'ChosenBias ~ Acc * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.ChosenBias.PostLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 1,:), 'ChosenBias', {'Acc', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'ChosenBias ~ Acc * ID_ED * Dimensionality * Stochasticity * TrialInBlock');

fluData.ChosenBias.All = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'All'}}, 'ChosenBias');
fluData.ChosenBias.D2 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, 'ChosenBias');
fluData.ChosenBias.D5 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, 'ChosenBias');
fluData.ChosenBias.o15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'All'}}, 'ChosenBias');
fluData.ChosenBias.o30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'All'}}, 'ChosenBias');
fluData.ChosenBias.Corr = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'Accuracy', 'Corr'}}, 'ChosenBias');
fluData.ChosenBias.Inc = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'Accuracy', 'Inc'}}, 'ChosenBias');
fluData.ChosenBias.PreLP = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PreLP'}}, 'ChosenBias');
fluData.ChosenBias.PostLP = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PostLP'}}, 'ChosenBias');
fluData.ChosenBias.Corr_PreLp = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'Accuracy', 'Corr'}, {'LearningStatus', 'PreLP'}}, 'ChosenBias');
fluData.ChosenBias.Corr_PostLp = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'Accuracy', 'Corr'}, {'LearningStatus', 'PostLP'}}, 'ChosenBias');
fluData.ChosenBias.Corr_2D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'Accuracy', 'Corr'}}, 'ChosenBias');
fluData.ChosenBias.Corr_5D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'Accuracy', 'Corr'}}, 'ChosenBias');
fluData.ChosenBias.Corr_15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'Accuracy', 'Corr'}}, 'ChosenBias');
fluData.ChosenBias.Corr_30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'Accuracy', 'Corr'}}, 'ChosenBias');

fluModels.TotalFixations.FullModel = LpLME_FLU(allTrialData, 'TotalFixations', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TotalFixations ~ Acc * LearningStatus * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.TotalFixations.PreLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 0,:), 'TotalFixations', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TotalFixations ~ Acc * ID_ED * Dimensionality * Stochasticity * TrialInBlock');
fluModels.TotalFixations.PostLpModel = LpLME_FLU(allTrialData(allTrialData.LearningStatus == 1,:), 'TotalFixations', {'Acc', 'LearningStatus', 'ID_ED', 'Dimensionality', 'Stochasticity'}, {'TrialInBlock'}, {'SubjectNum'}, 'TotalFixations ~ Acc * ID_ED * Dimensionality * Stochasticity * TrialInBlock');

fluData.TotalFixations.All = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'All'}}, 'TotalFixations');
fluData.TotalFixations.D2 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, 'TotalFixations');
fluData.TotalFixations.D5 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, 'TotalFixations');
fluData.TotalFixations.o15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'All'}}, 'TotalFixations');
fluData.TotalFixations.o30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'All'}}, 'TotalFixations');
fluData.TotalFixations.PreLP = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PreLP'}}, 'TotalFixations');
fluData.TotalFixations.PostLP = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}}, {{'LearningStatus', 'PostLP'}}, 'TotalFixations');
fluData.TotalFixations.PreLP_2D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PreLP'}}, 'TotalFixations');
fluData.TotalFixations.PreLP_5D = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PreLP'}}, 'TotalFixations');
fluData.TotalFixations.PreLP_15 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'PreLP'}}, 'TotalFixations');
fluData.TotalFixations.PreLP_30 = GetFluTrialSubset(allBlockData, allTrialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'PreLP'}}, 'TotalFixations');