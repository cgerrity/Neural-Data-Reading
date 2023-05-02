function [allTrialData, allBlockData] = FixFluSessionNumbers(allTrialData, allBlockData)

subjects = unique(allTrialData.SubjectNum);

for iSubj = 1:length(subjects)
    subj = subjects(iSubj);
    sessions = unique(allTrialData.SessionNum(allTrialData.SubjectNum == subj));
    for iSess = 1:length(sessions)
        sess = sessions(iSess);
        
        allTrialData.SessionNum(allTrialData.SubjectNum == subj & allTrialData.SessionNum == sess) = iSess;
        
    end
end