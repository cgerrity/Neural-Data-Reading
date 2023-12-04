function [MatchData,TrialNumbers_Data_NotFound,TrialNumbers_Condition_NotFound,MatchTrialNumber] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition,MatchValue,TrialNumbers_Condition,AllOutData,TrialNumbers_Data)
%CGG_GETSEPARATETRIALSBYCRITERIA Summary of this function goes here
%   Detailed explanation goes here

[MatchArray] = cgg_getTrialIndexByCriteria(TrialCondition,MatchValue);

NumTrials=length(TrialNumbers_Data);

IsCell=iscell(AllOutData);

if IsCell
MatchData=cell(0);
else
MatchData=[];
end
MatchTrialNumber=[];
MatchData_Counter=0;

this_Data_IDX_NF=ones(size(TrialNumbers_Data));
this_Condtion_IDX_NF=ones(size(TrialNumbers_Condition));

for tidx=1:NumTrials
    this_TrialNumber=TrialNumbers_Data(tidx);
    
    this_Data_IDX=tidx;
    this_Condtion_IDX=TrialNumbers_Condition==this_TrialNumber;
    
    this_Data_IDX_NF(this_Data_IDX)=0;
    this_Condtion_IDX_NF(this_Condtion_IDX)=0;
    
    if MatchArray(this_Condtion_IDX)==1
        MatchData_Counter=MatchData_Counter+1;
        if IsCell
        MatchData{MatchData_Counter}=AllOutData{this_Data_IDX};
        else
        MatchData(:,:,MatchData_Counter)=AllOutData(:,:,this_Data_IDX);
        end
        MatchTrialNumber(MatchData_Counter)=this_TrialNumber;
    end
end

this_Data_IDX_NF=diag(diag(this_Data_IDX_NF));
this_Condtion_IDX_NF=diag(diag(this_Condtion_IDX_NF));

TrialNumbers_Data_NotFound=this_Data_IDX_NF==1;
TrialNumbers_Condition_NotFound=this_Condtion_IDX_NF==1;

if IsCell
    MatchData=MatchData';
end


end

