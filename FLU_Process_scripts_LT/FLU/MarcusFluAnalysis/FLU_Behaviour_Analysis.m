function [blockData, trialData] = FLU_Behaviour_Analysis(blockData,trialData, exptType, varargin)


minTrials = CheckVararginPairs('minTrials', 20, varargin{:});
% maxTrials = CheckVararginPairs('maxTrials', 40, varargin{:});
trialsAroundLP = CheckVararginPairs('minTrials', 20, varargin{:});
dvs = CheckVararginPairs('dvs', {'Acc', 'LiftTime', 'ReachTime', 'TotalFixations', 'ObjectFixations', 'RelevantFixations', 'TargetFixations', 'DistractorFixations', 'IrrelevantFixations', 'OtherFixations'}, varargin{:});
backwardCurveData = CheckVararginPairs('backwardCurves', [], varargin{:});
forwardCurveData = CheckVararginPairs('forwardCurves', [], varargin{:});

if isempty(backwardCurveData)
    appendData = 0;
else
    appendData = 1;
end

switch exptType
    case 'FLU'
        blockConditions = {'P0.85_D2', 'P0.85_ D5', 'P0.7_D2', 'P0.7_D5'};
        factorDetails = {{'P0.85', 'P0.70', [1 1 2 2]},{'D2', 'D5', [1 2 1 2]}};
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
    forwardCurves.(dvs{iDV}) = nan(nBlocks, minTrials);
    backwardCurves.(dvs{iDV}) = nan(nBlocks, trialsAroundLP * 2 + 1);
end


 for iBlock = 1:nBlocks
     blockTrialData = trialData(trialData.SessionNum == blockData.SessionNum(iBlock) & trialData.Block == blockData.Block(iBlock),:);
     for iDV = 1:length(dvs)
         dv = dvs{iDV};
         forwardRows = blockTrialData.TrialInBlock <= minTrials;
         backwardRows = blockTrialData.TrialsFromLP >= -trialsAroundLP & blockTrialData.TrialsFromLP <= trialsFromLP;
         backwardCols = blockTrialData.TrialsFromLP(backwardRows) + trialsAroundLP + 1;
         switch dv
             case 'Acc'
                 forwardCurves.(dvs{iDV})(iBlock,:) = strcmpi(blockTrialData.isHighestProbReward(forwardRows), 'True');
                 backwardCurves.(dvs{iDV})(iBlock,backwardCols) = strcmpi(blockTrialData.isHighestProbReward(backwardRows), 'True');
             case 'LiftTime'
                 forwardCurves.(dvs{iDV})(iBlock,:) = blockTrialData.TimeLiftOfHoldKeyFromStimOnset(forwardRows);
                 backwardCurves.(dvs{iDV})(iBlock,backwardCols) = blockTrialData.TimeLiftOfHoldKeyFromStimOnset(backwardRows);
             case 'ReachTime'
                 forwardCurves.(dvs{iDV})(iBlock,:) = blockTrialData.TimeTouchFromLiftOfHoldKey(forwardRows);
                 backwardCurves.(dvs{iDV})(iBlock,backwardCols) = blockTrialData.TimeTouchFromLiftOfHoldKey(backwardRows);
             otherwise
                 forwardCurves.(dvs{iDV})(iBlock,:) = blockTrialData.(dv)(forwardRows);
                 backwardCurves.(dvs{iDV})(iBlock,backwardCols) = blockTrialData.(dv)(backwardRows);
         end
     end
 end
 
 for iDV = 1:length(dvs)
     dv = dvs{iDV};
     if ~appendData
         forwardCurveData.(dv).All.SubjectData = nanmean(forwardCurves);
         backwardCurveData.(dv).All.SubjectData = nanmean(backwardCurves);
     else
         forwardCurveData.(dv).All.SubjectData = [forwardCurveData.(dv).All.SubjectData; nanmean(forwardCurves)];
         backwardCurveData.(dv).All.SubjectData = [backwardCurveData.(dv).All.SubjectData; nanmean(backwardCurves)];
     end
     for iCond = 1:length(blockConditions)
         condition = blockConditions{iCond};
         blockRows = blockData.BlockType == iCond;
         if ~appendData
             forwardCurveData.(dv).(condition).SubjectData = nanmean(forwardCurves(blockRows,:));
             backwardCurveData.(dv).(condition).SubjectData = nanmean(backwardCurves(blockRows,:));
         else
             forwardCurveData.(dv).(condition).SubjectData = [forwardCurveData.(dv).(condition).SubjectData; nanmean(forwardCurves(blockRows,:))];
             backwardCurveData.(dv).(condition).SubjectData = [backwardCurveData.(dv).(condition).SubjectData; nanmean(backwardCurves(blockRows,:))];
         end
     end
     
     for iFactor = 1:length(factorDetails)
         details = factorDetails{iFactor};
         for iLevel = 1:length(details)-1
             factorLevel = details{iLevel};
             blockRows = ismember(blockData.BlockType, find(details{end} == iLevel));
             if ~appendData
                 forwardCurveData.(dv).(factorLevel).SubjectData = nanmean(forwardCurves(blockRows,:));
                 backwardCurveData.(dv).(factorLevel).SubjectData = nanmean(backwardCurves(blockRows,:));
             else
                 forwardCurveData.(dv).(factorLevel).SubjectData = [forwardCurveData.(dv).(factorLevel).SubjectData; nanmean(forwardCurves(blockRows,:))];
                 backwardCurveData.(dv).(factorLevel).SubjectData = [backwardCurveData.(dv).(factorLevel).SubjectData; nanmean(backwardCurves(blockRows,:))];
             end
         end
     end
 end