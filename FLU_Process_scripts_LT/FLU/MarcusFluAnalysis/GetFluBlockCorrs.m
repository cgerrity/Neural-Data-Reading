function corrData = GetFluBlockCorrs(trialData, var1, var2, goodTrials)

if length(var1) < length(var2)
    var2 = var2(goodTrials);
end

subjects = unique(trialData.SubjectNum);
corrData = [];
for iSubj = 1:length(subjects)
    subj = subjects(iSubj);
    sessions = unique(trialData.SessionNum(trialData.SubjectNum == subj));
    for iSess = 1:length(sessions)
        sess = sessions(iSess);
        blocks = unique(trialData.Block(trialData.SubjectNum == subj & trialData.SessionNum == sess));
        for iBlock = 1:length(blocks)
            blockRows = trialData.Block == blocks(iBlock) & trialData.SubjectNum == subj & trialData.SessionNum == sess;
            corrData = [corrData; corr(var1(blockRows), var2(blockRows), 'rows', 'pairwise')];
        end
    end
end

