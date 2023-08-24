function [TrialCondition,MatchValue] = cgg_getTrialCriteriaLearned(trialVariables,varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

TrialCondition_Baseline = CheckVararginPairs('TrialCondition_Baseline', cell(0), varargin{:});
MatchValue_Baseline = CheckVararginPairs('MatchValue_Baseline', cell(0), varargin{:});

TrialVariableTrialNumber=[trialVariables(:).TrialNumber];
[~,NumConditions]=size(TrialCondition_Baseline);

% Learned
TrialCondition=TrialCondition_Baseline;
TrialCondition(:,NumConditions+1)={trialVariables(:).TrialsFromLP};
TrialCondition(:,NumConditions+1)=cellfun(@(x)...
    {~isempty(x) && x >= 0}, TrialCondition(:,NumConditions+1));

MatchValue=MatchValue_Baseline;
MatchValue{1,NumConditions+1}=1;
end

