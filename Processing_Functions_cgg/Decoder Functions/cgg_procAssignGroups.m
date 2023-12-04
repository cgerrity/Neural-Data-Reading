function PartitionGroups = cgg_procAssignGroups(Identifiers,IdentifierName,NumFolds)
%CGG_PROCASSIGNGROUPS Summary of this function goes here
%   Detailed explanation goes here

cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;

AllSplitNames=cfg_param.AllSplitNames;

PartitionGroups=NaN(1,numel(Identifiers));

DataNumberIDX=strcmp(IdentifierName,"Data Number");
DataNumber=cellfun(@(x) x(DataNumberIDX),Identifiers,'UniformOutput',true);
DataNumber=diag(diag(DataNumber));

GroupList = cgg_procAssignGroupsBySplit(Identifiers,IdentifierName,AllSplitNames,NumFolds);

NumGroups=numel(GroupList);
GroupNumber=0;

for gidx=1:NumGroups
    GroupNumber=GroupNumber+1;
    this_List=GroupList{gidx};

    NumTrials=length(this_List);
    Partition_IDX=NaN(NumTrials,1);
    for lidx=1:NumTrials
        Partition_IDX(lidx)=find(DataNumber==this_List(lidx));
    end
    PartitionGroups(Partition_IDX)=GroupNumber;
end

end

