function [MatchArray] = cgg_getTrialIndexByCriteria(TrialCondition,MatchValue)
%CGG_GETTRIALINDEXBYCRITERIA Summary of this function goes here
%   Detailed explanation goes here


% TrialCondition is a TxN cell array where N is the number of condtions
% MatchValue is a 1xN cell array where N is the matching value for the
%   conditons

% MatchTrialInformation=struct();

% m_rectrialdef=load(dir_RecTrialDef);
% this_fields = fieldnames(m_rectrialdef);
% this_rectrialdef=m_rectrialdef.(this_fields{1});
% 
% if istable(this_rectrialdef)
%     this_trialindex=this_rectrialdef.trialindex;
% elseif isnumeric(this_rectrialdef)
%     this_trialindex=this_rectrialdef(:,8);
% end

[TrialCount,NumConditions]=size(TrialCondition);
MatchArray=ones(TrialCount,1);

for tidx=1:TrialCount    
    for nidx=1:NumConditions
        this_TrialCondition=TrialCondition{tidx,nidx};
        this_MatchValue=MatchValue{nidx};
        if ~(isequal(this_TrialCondition,this_MatchValue))
            MatchArray(tidx)=0;
        end 
    end
end
end

