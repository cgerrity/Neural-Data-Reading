function NewTarget = cgg_procPreviousTrialSharedFeature(OldTarget)
%CGG_PROCPREVIOUSTRIALSHAREDFEATURE Summary of this function goes here
%   Detailed explanation goes here

CodingOrder(1,:)=[0,1,1];
CodingOrder(2,:)=[0,1,0];
CodingOrder(3,:)=[0,0,1];
CodingOrder(4,:)=[0,0,0];
CodingOrder(5,:)=[1,1,1];
CodingOrder(6,:)=[1,1,0];
CodingOrder(7,:)=[1,0,1];
CodingOrder(8,:)=[1,0,0];

%%

Target_tmp=struct2table(OldTarget);

CorrectTrial=Target_tmp.CorrectTrial;
CorrectTrial=strcmp(CorrectTrial,'True');
PreviousTrialCorrect=[NaN;CorrectTrial];
PreviousTrialCorrect(end)=[];
Target_tmp.AdjustedCorrectTrial=CorrectTrial;
Target_tmp.AdjustedPreviousTrialCorrect=PreviousTrialCorrect;


CurrentDims=Target_tmp.SelectedObjectDimVals;
PriorDims=[NaN;CurrentDims];
PriorDims(end)=[];
SharedFeature=cellfun(@(x1,x2) any(x1(x1~=0)==x2(x1~=0)),PriorDims,CurrentDims);
Target_tmp.SharedFeature=SharedFeature;

TinyArray=[CorrectTrial,PreviousTrialCorrect,SharedFeature];

[Combinations,~,InitialIDX]=unique(TinyArray,'rows');

SkipFactor=20;

for cidx=1:length(Combinations)

    this_Combination=Combinations(cidx,:);
    this_OrderIDX=find(ismember(CodingOrder,this_Combination,"rows"));
    if any(isnan(this_Combination))
        this_OrderIDX=9;
    end

    this_TrialsIDX=InitialIDX==cidx;

    InitialIDX(this_TrialsIDX)=this_OrderIDX+SkipFactor;

end

SharedFeatureCoding=InitialIDX-SkipFactor;

Target_tmp.SharedFeatureCoding=SharedFeatureCoding;

NewTarget=table2struct(Target_tmp);


end

