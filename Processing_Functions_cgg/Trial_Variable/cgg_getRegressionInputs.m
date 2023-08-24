function [Data_Fit,MatchArray_Fit,varargout] = cgg_getRegressionInputs(InData,TrialNumbers,trialVariables,GainValue,LossValue,varargin)
%CGG_GETREGRESSIONINPUTS Summary of this function goes here
%   Detailed explanation goes here


TrialVariableTrialNumber=[trialVariables(:).TrialNumber];

[TrialCondition_Baseline,MatchValue_Baseline] = cgg_getTrialCriteriaBaseline(trialVariables,varargin{:});
[MatchArray_Input] = cgg_getTrialIndexByCriteria(TrialCondition_Baseline,MatchValue_Baseline);

[MatchArray] = cgg_getFullMatchArray(trialVariables,GainValue,LossValue);

[Data_Fit,TrialNumbers_Data_NotFound,TrialNumbers_Condition_NotFound] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Baseline,MatchValue_Baseline,TrialVariableTrialNumber,InData,TrialNumbers);

varargout{1}=TrialNumbers_Data_NotFound;
varargout{2}=TrialNumbers_Condition_NotFound;

MatchArray_Fit=MatchArray((MatchArray_Input==1)&(~TrialNumbers_Condition_NotFound),:);
end

