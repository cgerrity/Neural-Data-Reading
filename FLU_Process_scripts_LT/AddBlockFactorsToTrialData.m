function trialData = AddBlockFactorsToTrialData(trialData, blockData)

nTrials = height(trialData);
stochasticity = nan(nTrials,1);
dimensionality = nan(nTrials,1);
blockType = nan(nTrials,1);
ided = nan(nTrials,1);
learningStatus = nan(nTrials,1);

for iBlock = 1:height(blockData)
    
    blockDetails = blockData(iBlock,:);
    
    blockRows = trialData.SubjectNum == blockDetails.SubjectNum & trialData.SessionNum == blockDetails.SessionNum & trialData.Block == blockDetails.Block;
    stochasticity(blockRows) = 1 - blockDetails.HighRewardValue;
    dimensionality(blockRows) = blockDetails.NumActiveDims;
    blockType(blockRows) = blockDetails.BlockType;
    ided(blockRows) = blockDetails.ID_ED;
    learningStatus(blockRows) = trialData.TrialsFromLP(blockRows) > -1;
    
end

trialData = [trialData table(stochasticity, dimensionality, blockType, ided, learningStatus, ...
    'VariableNames', {'Stochasticity', 'Dimensionality', 'BlockType', 'ID_ED', 'LearningStatus'})];