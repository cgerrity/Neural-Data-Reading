function allTrialData = CorrectAbortTrialNumbersFlu(allTrialData)

allTrialData = allTrialData(allTrialData.AbortCode == 0,:);

subjects = unique(allTrialData.SubjectNum);

for iSubj = 1:length(subjects)
    subj = subjects(iSubj);
    subjRows = allTrialData.SubjectNum == subj;
    sessions = unique(allTrialData.SessionNum(subjRows));
    for iSess = 1:length(sessions)
        sess = sessions(iSess);
        sessRows = allTrialData.SessionNum == sess & subjRows;
        blocks = unique(allTrialData.Block(sessRows));
        allTrialData.TrialInExperiment(sessRows) = 1:sum(sessRows);
        for iBlock = 1:length(blocks)
            block = blocks(iBlock);
            blockRows = allTrialData.Block == block & sessRows;
            allTrialData.TrialInBlock(blockRows) = 1:sum(blockRows);
            trialsFromLP = allTrialData.TrialsFromLP(blockRows);
            lp = find(trialsFromLP == 0);
            if ~isempty(lp)
                trialsFromLP = 0 - lp + 1 : sum(blockRows) -lp;
                allTrialData.TrialsFromLP(blockRows) = trialsFromLP;
            end
        end
    end
end