postLpAcc = nan(height(allBlockData), 1);
for i = 1:height(allBlockData)
    
    postLpAcc(i) = nanmean(strcmpi(allTrialData.isHighestProbReward(allTrialData.SubjectNum == allBlockData.SubjectNum(i) & allTrialData.SessionNum == allBlockData.SessionNum(i) & allTrialData.Block == allBlockData.Block(i) & allTrialData.TrialsFromLP > 2), 'true'));
    
end

allBlockData.PostLpAcc = postLpAcc;