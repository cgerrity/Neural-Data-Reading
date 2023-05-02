function [forwardCurveData, backwardCurveData] = FLU_GetConditionCurves(trialData,blockData, exptType, varargin)


minTrials = CheckVararginPairs('minTrials', 30, varargin{:});
% maxTrials = CheckVararginPairs('maxTrials', 40, varargin{:});
trialsAroundLP = CheckVararginPairs('trialsAroundLP', 20, varargin{:});
dvs = CheckVararginPairs('dvs', {'Acc', 'LiftTime', 'ReachTime', 'TotalFixations', 'ObjectFixations', 'RelevantFixations', 'TargetFixations', 'DistractorFixations', 'IrrelevantFixations', 'OtherFixations', 'TargetBias'}, varargin{:});
%dvs = CheckVararginPairs('dvs', {'Acc', 'LiftTime', 'ReachTime'}, varargin{:});%, 'TotalFixations', 'ObjectFixations', 'RelevantFixations', 'TargetFixations', 'DistractorFixations', 'IrrelevantFixations', 'OtherFixations'}, varargin{:});
backwardCurveData = CheckVararginPairs('backwardCurves', [], varargin{:});
forwardCurveData = CheckVararginPairs('forwardCurves', [], varargin{:});

if isempty(backwardCurveData)
    appendData = 0;
else
    appendData = 1;
end

switch exptType
    case 'FLU'
        blockConditions = {'P85_D2', 'P85_D5', 'P70_D2', 'P70_D5'};
        factorDetails = {{'P85', 'P70', [1 1 2 2]},{'D2', 'D5', [1 2 1 2]}};
    case 'FLU_GL'
        blockConditions = {'D2_Pos', 'D2_Neg', 'D2_Neut', 'D5_Pos', 'D5_Neg', 'D5_Neut'};
        factorDetails = {{'D2', 'D5', [1 1 1 2 2 2]}, {'Positive', 'Negative', 'Neutral', [1 2 3 1 2 3]}};
end


%     if strcmp(exptType, 'FLU')
%         BlockType(blockData.HighRewardValue == 0.85 & blockData.NumActiveDims == 2) = 1;
%         BlockType(blockData.HighRewardValue == 0.85 & blockData.NumActiveDims == 5) = 2;
%         BlockType(blockData.HighRewardValue == 0.7 & blockData.NumActiveDims == 2) = 3;
%         BlockType(blockData.HighRewardValue == 0.7 & blockData.NumActiveDims == 5) = 4;
%     elseif strcmp(exptType, 'FLU_GL')
%         BlockType(blockData.MeanPositiveTokens == 2 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 2) = 1;
%         BlockType(blockData.MeanPositiveTokens == 1 & blockData.MeanNegativeTokens == -2 & blockData.NumActiveDims == 2) = 2;
%         BlockType(blockData.MeanPositiveTokens == 0 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 2) = 3;
%         BlockType(blockData.MeanPositiveTokens == 2 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 5) = 4;
%         BlockType(blockData.MeanPositiveTokens == 1 & blockData.MeanNegativeTokens == -2 & blockData.NumActiveDims == 5) = 5;
%         BlockType(blockData.MeanPositiveTokens == 0 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 5) = 6;
%     end

nBlocks = height(blockData);

for iDV = 1:length(dvs)
    dv = dvs{iDV};
    if strcmpi(dv, 'Acc')
        forwardCurves.(dv) = nan(nBlocks, minTrials);
        backwardCurves.(dv) = nan(nBlocks, trialsAroundLP * 2 + 1);
    else
        forwardCurves.(dv).AllAcc = nan(nBlocks, minTrials);
        backwardCurves.(dv).AllAcc = nan(nBlocks, trialsAroundLP * 2 + 1);
        forwardCurves.(dv).Corr = nan(nBlocks, minTrials);
        backwardCurves.(dv).Corr = nan(nBlocks, trialsAroundLP * 2 + 1);
        forwardCurves.(dv).Inc = nan(nBlocks, minTrials);
        backwardCurves.(dv).Inc = nan(nBlocks, trialsAroundLP * 2 + 1);
    end
end


 for iBlock = 1:nBlocks
     blockTrialData = trialData(trialData.SessionNum == blockData.SessionNum(iBlock) & trialData.Block == blockData.Block(iBlock),:);
     for iDV = 1:length(dvs)
         dv = dvs{iDV};
         forwardRows = blockTrialData.TrialInBlock <= minTrials;
         backwardRows = blockTrialData.TrialsFromLP >= -trialsAroundLP & blockTrialData.TrialsFromLP <= trialsAroundLP;
         backwardCols = blockTrialData.TrialsFromLP(backwardRows) + trialsAroundLP + 1;
         
         corrForward = strcmpi(blockTrialData.isHighestProbReward(forwardRows), 'True');
         corrBackward = strcmpi(blockTrialData.isHighestProbReward(backwardRows), 'True');
         switch dv
             case 'Acc'
                 forwardData = corrForward;
                 backwardData = corrBackward;
             case 'LiftTime'
                 if(ismember('TimeLiftOfHoldKeyFromStimOnset', blockTrialData.Properties.VariableNames))
                     forwardData = blockTrialData.TimeLiftOfHoldKeyFromStimOnset(forwardRows);
                     backwardData = blockTrialData.TimeLiftOfHoldKeyFromStimOnset(backwardRows);
                 elseif(ismember('TimeTouchFromStartOfFreeGaze', blockTrialData.Properties.VariableNames)...
                         && ismember('TimeTouchFromLiftOfHoldKey', blockTrialData.Properties.VariableNames))
                     
                     forwardData = blockTrialData.TimeTouchFromStartOfFreeGaze(forwardRows) ...
                         - blockTrialData.TimeTouchFromLiftOfHoldKey(forwardRows) ...
                         + blockTrialData.Epoch3_Duration(forwardRows);
                     backwardData = blockTrialData.TimeTouchFromStartOfFreeGaze(backwardRows) ...
                         - blockTrialData.TimeTouchFromLiftOfHoldKey(backwardRows) ...
                         + blockTrialData.Epoch3_Duration(backwardRows);
                 end
             case 'ReachTime'
                 forwardData = blockTrialData.TimeTouchFromLiftOfHoldKey(forwardRows);
                 backwardData = blockTrialData.TimeTouchFromLiftOfHoldKey(backwardRows);
             otherwise
                 forwardData = blockTrialData.(dv)(forwardRows);
                 backwardData = blockTrialData.(dv)(backwardRows);
         end
         if ~isempty(forwardRows)
             if strcmpi(dv, 'Acc')
                 forwardCurves.(dvs{iDV})(iBlock,:) = forwardData;
             else
                 forwardCurves.(dvs{iDV}).AllAcc(iBlock,:) = forwardData;
                 forwardCurves.(dvs{iDV}).Corr(iBlock,:) = forwardData;
                 forwardCurves.(dvs{iDV}).Inc(iBlock,:) = forwardData;
                 forwardCurves.(dvs{iDV}).Corr(iBlock,~corrForward) = NaN;
                 forwardCurves.(dvs{iDV}).Inc(iBlock,corrForward) = NaN;
             end
         end
         if ~isempty(backwardRows) && ~isempty(backwardCols)
             if strcmpi(dv, 'Acc')
                 backwardCurves.(dvs{iDV})(iBlock,backwardCols) = backwardData;
             else
                 backwardCurves.(dvs{iDV}).AllAcc(iBlock,backwardCols) = backwardData;
                 backwardCurves.(dvs{iDV}).Corr(iBlock,backwardCols) = backwardData;
                 backwardCurves.(dvs{iDV}).Inc(iBlock,backwardCols) = backwardData;
                 backwardCurves.(dvs{iDV}).Corr(iBlock,~corrBackward) = NaN;
                 backwardCurves.(dvs{iDV}).Inc(iBlock,corrBackward) = NaN;
             end
         end
     end
 end
 
 for iDV = 1:length(dvs)
     dv = dvs{iDV};
     if strcmpi(dv,'Acc')
         if ~appendData
             forwardCurveData.(dv).All.SubjectData = nanmean(forwardCurves.(dv));
             backwardCurveData.(dv).All.SubjectData = nanmean(backwardCurves.(dv));
         else
             forwardCurveData.(dv).All.SubjectData = [forwardCurveData.(dv).All.SubjectData; nanmean(forwardCurves.(dv))];
             backwardCurveData.(dv).All.SubjectData = [backwardCurveData.(dv).All.SubjectData; nanmean(backwardCurves.(dv))];
         end
         for iCond = 1:length(blockConditions)
             condition = blockConditions{iCond};
             blockRows = blockData.BlockType == iCond;
             if ~appendData
                 forwardCurveData.(dv).(condition).SubjectData = nanmean(forwardCurves.(dv)(blockRows,:));
                 backwardCurveData.(dv).(condition).SubjectData = nanmean(backwardCurves.(dv)(blockRows,:));
             else
                 forwardCurveData.(dv).(condition).SubjectData = [forwardCurveData.(dv).(condition).SubjectData; nanmean(forwardCurves.(dv)(blockRows,:))];
                 backwardCurveData.(dv).(condition).SubjectData = [backwardCurveData.(dv).(condition).SubjectData; nanmean(backwardCurves.(dv)(blockRows,:))];
             end
         end
         
         for iFactor = 1:length(factorDetails)
             details = factorDetails{iFactor};
             for iLevel = 1:length(details)-1
                 factorLevel = details{iLevel};
                 blockRows = ismember(blockData.BlockType, find(details{end} == iLevel));
                 if ~appendData
                     forwardCurveData.(dv).(factorLevel).SubjectData = nanmean(forwardCurves.(dv)(blockRows,:));
                     backwardCurveData.(dv).(factorLevel).SubjectData = nanmean(backwardCurves.(dv)(blockRows,:));
                 else
                     forwardCurveData.(dv).(factorLevel).SubjectData = [forwardCurveData.(dv).(factorLevel).SubjectData; nanmean(forwardCurves.(dv)(blockRows,:))];
                     backwardCurveData.(dv).(factorLevel).SubjectData = [backwardCurveData.(dv).(factorLevel).SubjectData; nanmean(backwardCurves.(dv)(blockRows,:))];
                 end
             end
         end
     else
         if ~appendData
             forwardCurveData.(dv).All.AllAcc.SubjectData = nanmean(forwardCurves.(dv).AllAcc);
             backwardCurveData.(dv).All.AllAcc.SubjectData = nanmean(backwardCurves.(dv).AllAcc);
             forwardCurveData.(dv).All.Corr.SubjectData = nanmean(forwardCurves.(dv).Corr);
             backwardCurveData.(dv).All.Corr.SubjectData = nanmean(backwardCurves.(dv).Corr);
             forwardCurveData.(dv).All.Inc.SubjectData = nanmean(forwardCurves.(dv).Inc);
             backwardCurveData.(dv).All.Inc.SubjectData = nanmean(backwardCurves.(dv).Inc);
         else
             forwardCurveData.(dv).All.AllAcc.SubjectData = [forwardCurveData.(dv).All.AllAcc.SubjectData; nanmean(forwardCurves.(dv).AllAcc)];
             backwardCurveData.(dv).All.AllAcc.SubjectData = [backwardCurveData.(dv).All.AllAcc.SubjectData; nanmean(backwardCurves.(dv).AllAcc)];
             forwardCurveData.(dv).All.Corr.SubjectData = [forwardCurveData.(dv).All.AllAcc.SubjectData; nanmean(forwardCurves.(dv).Corr)];
             backwardCurveData.(dv).All.Corr.SubjectData = [backwardCurveData.(dv).All.AllAcc.SubjectData; nanmean(backwardCurves.(dv).Corr)];
             forwardCurveData.(dv).All.Inc.SubjectData = [forwardCurveData.(dv).All.AllAcc.SubjectData; nanmean(forwardCurves.(dv).Inc)];
             backwardCurveData.(dv).All.Inc.SubjectData = [backwardCurveData.(dv).All.AllAcc.SubjectData; nanmean(backwardCurves.(dv).Inc)];
         end
         for iCond = 1:length(blockConditions)
             condition = blockConditions{iCond};
             blockRows = blockData.BlockType == iCond;
             if ~appendData
                 forwardCurveData.(dv).(condition).AllAcc.SubjectData = nanmean(forwardCurves.(dv).AllAcc(blockRows,:));
                 backwardCurveData.(dv).(condition).AllAcc.SubjectData = nanmean(backwardCurves.(dv).AllAcc(blockRows,:));
                 forwardCurveData.(dv).(condition).Corr.SubjectData = nanmean(forwardCurves.(dv).Corr(blockRows,:));
                 backwardCurveData.(dv).(condition).Corr.SubjectData = nanmean(backwardCurves.(dv).Corr(blockRows,:));
                 forwardCurveData.(dv).(condition).Inc.SubjectData = nanmean(forwardCurves.(dv).Inc(blockRows,:));
                 backwardCurveData.(dv).(condition).Inc.SubjectData = nanmean(backwardCurves.(dv).Inc(blockRows,:));
             else
                 forwardCurveData.(dv).(condition).AllAcc.SubjectData = [forwardCurveData.(dv).(condition).AllAcc.SubjectData; nanmean(forwardCurves.(dv).AllAcc(blockRows,:))];
                 backwardCurveData.(dv).(condition).AllAcc.SubjectData = [backwardCurveData.(dv).(condition).AllAcc.SubjectData; nanmean(backwardCurves.(dv).AllAcc(blockRows,:))];
                 forwardCurveData.(dv).(condition).Corr.SubjectData = [forwardCurveData.(dv).(condition).Corr.SubjectData; nanmean(forwardCurves.(dv).Corr(blockRows,:))];
                 backwardCurveData.(dv).(condition).Corr.SubjectData = [backwardCurveData.(dv).(condition).Corr.SubjectData; nanmean(backwardCurves.(dv).Corr(blockRows,:))];
                 forwardCurveData.(dv).(condition).Inc.SubjectData = [forwardCurveData.(dv).(condition).Inc.SubjectData; nanmean(forwardCurves.(dv).Inc(blockRows,:))];
                 backwardCurveData.(dv).(condition).Inc.SubjectData = [backwardCurveData.(dv).(condition).Inc.SubjectData; nanmean(backwardCurves.(dv).Inc(blockRows,:))];
             end
         end
         
         for iFactor = 1:length(factorDetails)
             details = factorDetails{iFactor};
             for iLevel = 1:length(details)-1
                 factorLevel = details{iLevel};
                 blockRows = ismember(blockData.BlockType, find(details{end} == iLevel));
                 if ~appendData
                     forwardCurveData.(dv).(factorLevel).AllAcc.SubjectData = nanmean(forwardCurves.(dv).AllAcc(blockRows,:));
                     backwardCurveData.(dv).(factorLevel).AllAcc.SubjectData = nanmean(backwardCurves.(dv).AllAcc(blockRows,:));
                     forwardCurveData.(dv).(factorLevel).Corr.SubjectData = nanmean(forwardCurves.(dv).Corr(blockRows,:));
                     backwardCurveData.(dv).(factorLevel).Corr.SubjectData = nanmean(backwardCurves.(dv).Corr(blockRows,:));
                     forwardCurveData.(dv).(factorLevel).Inc.SubjectData = nanmean(forwardCurves.(dv).Inc(blockRows,:));
                     backwardCurveData.(dv).(factorLevel).Inc.SubjectData = nanmean(backwardCurves.(dv).Inc(blockRows,:));
                 else
                     forwardCurveData.(dv).(factorLevel).AllAcc.SubjectData = [forwardCurveData.(dv).(factorLevel).AllAcc.SubjectData; nanmean(forwardCurves.(dv).AllAcc(blockRows,:))];
                     backwardCurveData.(dv).(factorLevel).AllAcc.SubjectData = [backwardCurveData.(dv).(factorLevel).AllAcc.SubjectData; nanmean(backwardCurves.(dv).AllAcc(blockRows,:))];
                     forwardCurveData.(dv).(factorLevel).Corr.SubjectData = [forwardCurveData.(dv).(factorLevel).Corr.SubjectData; nanmean(forwardCurves.(dv).Corr(blockRows,:))];
                     backwardCurveData.(dv).(factorLevel).Corr.SubjectData = [backwardCurveData.(dv).(factorLevel).Corr.SubjectData; nanmean(backwardCurves.(dv).Corr(blockRows,:))];
                     forwardCurveData.(dv).(factorLevel).Inc.SubjectData = [forwardCurveData.(dv).(factorLevel).Inc.SubjectData; nanmean(forwardCurves.(dv).Inc(blockRows,:))];
                     backwardCurveData.(dv).(factorLevel).Inc.SubjectData = [backwardCurveData.(dv).(factorLevel).Inc.SubjectData; nanmean(backwardCurves.(dv).Inc(blockRows,:))];
                 end
             end
             
         end
     end
 end