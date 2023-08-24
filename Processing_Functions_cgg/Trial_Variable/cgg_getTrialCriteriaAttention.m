function [TrialCondition,MatchValue] = cgg_getTrialCriteriaAttention(trialVariables,NumDimensions,varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

TrialCondition_Baseline = CheckVararginPairs('TrialCondition_Baseline', cell(0), varargin{:});
MatchValue_Baseline = CheckVararginPairs('MatchValue_Baseline', cell(0), varargin{:});

TrialVariableTrialNumber=[trialVariables(:).TrialNumber];
[~,NumConditions]=size(TrialCondition_Baseline);

% Attention
TrialCondition=TrialCondition_Baseline;
TrialCondition(:,NumConditions+1)={trialVariables(:).Dimensionality};

MatchValue=MatchValue_Baseline;
MatchValue{1,NumConditions+1}=NumDimensions;
end

