function [MatchArray] = cgg_getFullMatchArray(trialVariables,GainValue,LossValue,varargin)
%CGG_GETFULLMATCHARRAY Summary of this function goes here
%   Detailed explanation goes here

%%

[TrialCondition_Baseline,MatchValue_Baseline] = cgg_getTrialCriteriaBaseline(trialVariables,varargin{:});

%%

[TrialCondition_Rewarded,MatchValue_Rewarded] = cgg_getTrialCriteriaRewarded(trialVariables,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});
[TrialCondition_Learned,MatchValue_Learned] = cgg_getTrialCriteriaLearned(trialVariables,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});
[TrialCondition_Attention_2,MatchValue_Attention_2] = cgg_getTrialCriteriaAttention(trialVariables,2,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});
[TrialCondition_Attention_3,MatchValue_Attention_3] = cgg_getTrialCriteriaAttention(trialVariables,3,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});
[TrialCondition_Gain,MatchValue_Gain] = cgg_getTrialCriteriaGain(trialVariables,GainValue,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});
[TrialCondition_Loss,MatchValue_Loss] = cgg_getTrialCriteriaLoss(trialVariables,LossValue,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});
[TrialCondition_Previous,MatchValue_Previous] = cgg_getTrialCriteriaPrevious(trialVariables,'TrialCondition_Baseline',TrialCondition_Baseline,'MatchValue_Baseline',MatchValue_Baseline,varargin{:});


%%
% 1 indicates the trial is rewarded. 0 indicates the trial is not rewarded
[MatchArray_Rewarded] = cgg_getTrialIndexByCriteria(TrialCondition_Rewarded,MatchValue_Rewarded);

% 1 indicates the trial occurs after the learning point. 0 indicates the
% trial occurs after the learning point
[MatchArray_Learned] = cgg_getTrialIndexByCriteria(TrialCondition_Learned,MatchValue_Learned);

% 1 indicates the trial has 2 dimensional objects. 0 indicates the trial
% does not have 2 dimensional objects
[MatchArray_Attention_2] = cgg_getTrialIndexByCriteria(TrialCondition_Attention_2,MatchValue_Attention_2);

% 1 indicates the trial has 3 dimensional objects. 0 indicates the trial
% does not have 3 dimensional objects
[MatchArray_Attention_3] = cgg_getTrialIndexByCriteria(TrialCondition_Attention_3,MatchValue_Attention_3);

% 0 in MatchArray_Attention_2 and MatchArray_Attention_3 indicates the
% object has 1 dimension

% 1 indicates the trial has a gain of 3 tokens. 0 indicates the trial has a
% gain of 2 tokens
[MatchArray_Gain] = cgg_getTrialIndexByCriteria(TrialCondition_Gain,MatchValue_Gain);

% 1 indicates the trial has a loss of 3 tokens. 0 indicates the trial has a
% loss of 1 token.
[MatchArray_Loss] = cgg_getTrialIndexByCriteria(TrialCondition_Loss,MatchValue_Loss);

% 1 indicates the previous trial was rewarded. 0 indicates the previous
% trial was not rewarded
[MatchArray_Previous] = cgg_getTrialIndexByCriteria(TrialCondition_Previous,MatchValue_Previous);



%%
MatchArray=MatchArray_Rewarded;
MatchArray=[MatchArray,MatchArray_Learned];
MatchArray=[MatchArray,MatchArray_Attention_2];
MatchArray=[MatchArray,MatchArray_Attention_3];
MatchArray=[MatchArray,MatchArray_Gain];
MatchArray=[MatchArray,MatchArray_Loss];
MatchArray=[MatchArray,MatchArray_Previous];

end

