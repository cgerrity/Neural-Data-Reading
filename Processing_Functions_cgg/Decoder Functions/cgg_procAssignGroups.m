function PartitionGroups = cgg_procAssignGroups(Identifiers,IdentifierName,NumFolds,varargin)
%CGG_PROCASSIGNGROUPS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NumLevels = CheckVararginPairs('NumLevels', 'All', varargin{:});
else
if ~(exist('NumLevels','var'))
NumLevels='All';
end
end
%%

cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;

if strcmp(NumLevels,'All')
AllSplitNames=cfg_param.AllSplitNames;
elseif isscalar(NumLevels)
AllSplitNames = cfg_param.AllSplitNames{1:NumLevels};
else
    AllSplitNames = cfg_param.AllSplitNames; % Default to all split names
end

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

