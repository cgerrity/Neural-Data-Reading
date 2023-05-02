function corrData = FLU_ModelParameterCorrelation(modelData, behaveTrialData, behaveBlockData, modelVar, behaveVar)

subjectsModel = unique(modelData.SubjectID);
subjectsBehave = unique(behaveTrialData.SubjectNum);

rs = nan(height(behaveBlockData), 1);
ps = nan(height(behaveBlockData), 1);
subjs = nan(height(behaveBlockData), 1);

nSubjs = length(subjectsModel);
subjCorrsAll = nan(nSubjs,1);
subjCorrsCondition = nan(nSubjs * 4,1);


for iSubj = 1:nSubjs
    subjModel = subjectsModel(iSubj);
    subjBehave = subjectsBehave(iSubj);
    sessionsModel = unique(modelData.SessionNum(modelData.SubjectID == subjModel));
    sessionsBehave = unique(behaveTrialData.SessionNum(behaveTrialData.SubjectNum == subjBehave));
    for iSess = 1:length(sessionsModel)
        sessModel = sessionsModel(iSess);
        sessBehave = sessionsBehave(iSess);
        blocksModel = unique(modelData.BlockNum(modelData.SubjectID == subjModel & modelData.SessionNum == sessModel));
        blocksBehave = unique(behaveTrialData.Block(behaveTrialData.SubjectNum == subjBehave & behaveTrialData.SessionNum == sessBehave));
        for iBlock = 1:length(blocksModel)
            modelBlock = blocksModel(iBlock);
            matchBlock = blocksBehave == modelBlock;
            if sum(matchBlock) > 0
                modelBlockRows = find(modelData.SubjectID == subjModel & modelData.SessionNum == sessModel & modelData.BlockNum == modelBlock);
                behaveBlockRows = find(behaveTrialData.SubjectNum == subjBehave & behaveTrialData.SessionNum == sessBehave & behaveTrialData.Block == modelBlock);
                blockBlockRow = behaveBlockData.SubjectNum == subjBehave & behaveBlockData.SessionNum == sessBehave & behaveBlockData.Block == modelBlock;
                
                modelTrials = modelData.TrialInBlock(modelBlockRows);
                behaveTrials = behaveTrialData.TrialInBlock(behaveBlockRows);
                
                [~, ia, ib] = intersect(modelTrials, behaveTrials);
                
                [r, p] = corr(modelData.(modelVar)(modelBlockRows(ia)), behaveTrialData.(behaveVar)(behaveBlockRows(ib)), 'rows', 'pairwise');
                rs(blockBlockRow) = r;
                ps(blockBlockRow) = p;
                subjs(blockBlockRow) = iSubj;
            end
        end
    end
    subjCorrsAll(iSubj) = nanmean(rs(subjs == iSubj));
    for iCond = 1:4
        subjCorrsCondition(iSubj * 4 - 4 + iCond) = nanmean(rs(subjs == iSubj & behaveBlockData.BlockType == iCond));
    end
end

corrData.rs = rs;
corrData.ps = ps;
corrData.subjs = subjs;
corrData.condition = behaveBlockData.BlockType;
corrData.subjCorrsAll = subjCorrsAll;
corrData.SubjCorrsCondition = subjCorrsCondition;


