function data = GetFluParameterConditionMeans(trialData, blockData, dv, data)

data.(dv).D2 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).D5 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).o15 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).o30 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).D2_15 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).D2_30 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).D5_15 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, dv);
data.(dv).D5_30 = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'All'}}, dv);

data.(dv).D2_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).D5_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).o15_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).o30_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).D2_15_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).D2_30_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).D5_15_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PreLP'}}, dv);
data.(dv).D5_30_PreLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PreLP'}}, dv);

data.(dv).D2_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).D5_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).o15_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).o30_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).D2_15_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).D2_30_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}, {'Dimensionality', '2D'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).D5_15_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.15'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PostLP'}}, dv);
data.(dv).D5_30_PostLP = GetFluTrialSubset(blockData, trialData, {{'LearningStatus', 'Learned'}, {'Stochasticity', '0.30'}, {'Dimensionality', '5D'}}, {{'LearningStatus', 'PostLP'}}, dv);
