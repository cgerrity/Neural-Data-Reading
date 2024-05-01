function PEV = cgg_procPercentExplainedVariance(Activity,GroupIDX)
%CGG_PROCPERCENTEXPLAINEDVARIANCE Summary of this function goes here
%   Detailed explanation goes here
%%
AllGroups=unique(GroupIDX);

NumGroups=length(unique(GroupIDX));

Activity_Group=cell(NumGroups,1);

for gidx=1:NumGroups

    this_GroupdIDX=AllGroups(gidx);
    this_ActivityIDX=GroupIDX==this_GroupdIDX;

    this_Activity_Group=Activity(this_ActivityIDX);
    Activity_Group{gidx}=this_Activity_Group;

end

NumTrials_Group=cellfun(@length,Activity_Group);
Mean_Activity_Group=cellfun(@mean,Activity_Group);
Mean_Activity_All=mean(Activity);


SS_Group=NaN(NumGroups,1);
for gidx=1:NumGroups
    this_SS_Group=sum((Activity_Group{gidx}-Mean_Activity_Group(gidx)).^2);
    SS_Group(gidx)=this_SS_Group;
end

SS_BetweenGroups=sum(NumTrials_Group.*(Mean_Activity_Group-Mean_Activity_All).^2);

DegreesFreedom=NumGroups-1;

SS_Total=sum((Activity-Mean_Activity_All).^2);

MeanSquaredError=sum(SS_Group);

PEV=(SS_BetweenGroups - DegreesFreedom*MeanSquaredError)/(SS_Total+MeanSquaredError);

end

