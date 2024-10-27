function [blockData, trialData] = AddLpInfo(blockData,trialData)

LP = nan(height(blockData),1);
TrialsFromLP = nan(height(trialData),1);
NotAbort_Trials = (trialData.AbortCode == 0);

for iBlock = 1:height(blockData)
    blockNum = blockData.Block(iBlock);
    trialRows = trialData.Block == blockNum;
    trialRows = trialRows & NotAbort_Trials;
    acc = strcmpi(trialData.isHighestProbReward(trialRows), 'true');
    lp = FindLp(acc, 'slidingWindow', 10, 0.8);
    LP(iBlock) = lp;
    if ~isnan(lp)
        TrialsFromLP(trialRows) = 0 - lp + 1 : sum(trialRows) - lp;
    end
end
if ismember('LP', blockData.Properties.VariableNames)
    blockData.LP = LP;
else
    blockData = [blockData, table(LP)];
end
if ismember('TrialsFromLP', trialData.Properties.VariableNames)
    trialData.TrialsFromLP = TrialsFromLP;
else
    trialData = [trialData, table(TrialsFromLP)];
end
