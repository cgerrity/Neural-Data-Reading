function [OutTrialCondition,OutMatchValue] = cgg_addTrialCriteria(InTrialCondition,InMatchValue,AddTrialCondition,AddMatchValue)
%CGG_ADDTRIALCRITERIA Summary of this function goes here
%   Detailed explanation goes here

OutMatchValue=[InMatchValue,AddMatchValue];
OutTrialCondition=[InTrialCondition,AddTrialCondition];

end

