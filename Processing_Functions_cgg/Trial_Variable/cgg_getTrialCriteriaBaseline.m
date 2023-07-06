function [TrialCondition,MatchValue] = cgg_getTrialCriteriaBaseline(trialVariables,varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


%%

TrialDuration_Minimum = CheckVararginPairs('TrialDuration_Minimum', 10, varargin{:});

TrialVariableTrialNumber=[trialVariables(:).TrialNumber];
NumTrialVariable=length(TrialVariableTrialNumber);

% Trial Conditions
TrialCondition=cell(NumTrialVariable,1);
TrialCondition(:,1)={trialVariables(:).AbortCode};
TrialCondition(:,2)={trialVariables(:).TrialTime};
TrialCondition(:,2)=cellfun(@(x){~isempty(x) && x >= TrialDuration_Minimum}, TrialCondition(:,2));

% Match Values
MatchValue=cell(1);
MatchValue{1,1}=0;
MatchValue{1,2}=0;
end

