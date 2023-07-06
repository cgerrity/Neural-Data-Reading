function [TrialCondition,MatchValue] = cgg_getTrialCriteriaRewarded(trialVariables,varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

TrialCondition_Baseline = CheckVararginPairs('TrialCondition_Baseline', cell(0), varargin{:});
MatchValue_Baseline = CheckVararginPairs('MatchValue_Baseline', cell(0), varargin{:});

TrialVariableTrialNumber=[trialVariables(:).TrialNumber];
[~,NumConditions]=size(TrialCondition_Baseline);

% Rewarded
TrialCondition_Rewarded=TrialCondition_Baseline;
TrialCondition_Rewarded(:,NumConditions+1)=[trialVariables(:).CorrectTrial];

MatchValue_Rewarded=MatchValue_Baseline;
MatchValue_Rewarded{1,NumConditions+1}='True';


TrialCondition=TrialCondition_Rewarded;
MatchValue=MatchValue_Rewarded;
end

