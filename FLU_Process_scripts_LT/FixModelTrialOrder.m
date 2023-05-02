function modelTrialReorder = FixModelTrialOrder(allTrialData, FLUData, subjTrialData)
modelTrialReorder = zeros(length(FLUData.SubjectID),1);
    
subjectsNew = unique(allTrialData.SubjectNum);
subjectsOld = unique(FLUData.SubjectID);

for iSubj = 1:length(subjectsNew)
    subjNew = subjectsNew(iSubj);
    subjOld = subjectsOld(iSubj);
    sessionsNew = unique(allTrialData.SessionNum(allTrialData.SubjectNum==subjNew));
    sessionsOld = unique(FLUData.SessionNum(FLUData.SubjectID == subjOld));
    trialCountsOld = nan(length(sessionsOld),1);
    for iSess = 1:length(sessionsOld)
        sessRowsOld = FLUData.SubjectID == subjOld & FLUData.SessionNum == sessionsOld(iSess);
        blocks = unique(FLUData.BlockNum(sessRowsOld));
        for iBlock = 1:length(blocks)
            blockRows = FLUData.BlockNum == blocks(iBlock) & sessRowsOld;
            if length(blockRows) < 30
                sessRowsOld(blockRows) = 0;
            end
        end
        trialCountsOld(iSess) = sum(FLUData.SubjectID == subjOld & FLUData.SessionNum == sessionsOld(iSess));
    end
    for iSess = 1:length(sessionsNew)
%         if subjNew == 1
%             sessRowsNew  = find(subjTrialData.SubjectNum == subjNew & subjTrialData.SessionNum == sessionsNew(iSess));
%         else
            sessRowsNew = find(allTrialData.SubjectNum == subjNew & allTrialData.SessionNum == sessionsNew(iSess));
%         end
        nTrialsNew = length(sessRowsNew);
        match = find(trialCountsOld == nTrialsNew);
        if length(match) == 1
            if match ~= iSess
                modelTrialReorder(sessRowsNew) = find(FLUData.SubjectID == subjOld & FLUData.SessionNum == sessionsOld(match));
%                 if subjNew == 1
%                     modelTrialReorder(sessRowsNew & subjTrialData.AbortCode > 0) = NaN;
%                 end
            end
        elseif length(find(trialCountsOld == nTrialsNew + 1)) == 1
            rows = find(FLUData.SubjectID == subjOld & FLUData.SessionNum == sessionsOld(find(trialCountsOld == nTrialsNew + 1)));
            if FLUData.TrialInBlock(rows(1:end-1)) == allTrialData.TrialInBlock(sessRowsNew)
                modelTrialReorder(sessRowsNew) = rows(1:end-1);
            end
        else
            fred = 2;
        end
    end
end