function GroupList = cgg_procAssignGroupsBySplit(Identifiers,IdentifierName,AllSplitNames,NumFolds,varargin)
%CGG_PROCASSIGNGROUPSBYSPLIT Summary of this function goes here
%   Detailed explanation goes here


DataNumberIDX=strcmp(IdentifierName,"Data Number");
DataNumber=cellfun(@(x) x(DataNumberIDX),Identifiers,'UniformOutput',true);
DataNumber=diag(diag(DataNumber));

%% Initializations

FurtherSplit = CheckVararginPairs('FurtherSplit', DataNumber(1:numel(Identifiers)), varargin{:});
% FurtherSplitCount = CheckVararginPairs('FurtherSplitCount', 0, varargin{:});
% PartitionGroups = CheckVararginPairs('PartitionGroups', NaN(1,numel(Identifiers)), varargin{:});
GroupList = CheckVararginPairs('GroupList', cell(0), varargin{:});
% PartitionGroupNumber = CheckVararginPairs('PartitionGroupNumber', 0, varargin{:});
SplitLevel = CheckVararginPairs('SplitLevel', 0, varargin{:});

MaintainSplit=FurtherSplit;

%%

% Display_Message='Start of Partition Group Number: %d, Split Level: %d, Further Split Count %d\n';

% PartitionGroupNumber=numel(GroupList);
SplitLevel=SplitLevel+1;

% fprintf(Display_Message,PartitionGroupNumber,SplitLevel,FurtherSplitCount);

if SplitLevel>length(AllSplitNames)
    GroupList=[GroupList,{MaintainSplit}];
    return
end

SplitNames=AllSplitNames{SplitLevel};

this_Trial_DataNumber=FurtherSplit;
this_Trial_IDX=NaN(1,length(this_Trial_DataNumber));
for didx=1:length(this_Trial_DataNumber)
this_Trial_IDX(didx)=find(DataNumber==this_Trial_DataNumber(didx));
end

this_Identifiers=Identifiers(this_Trial_IDX);

[MaintainSplit,FurtherSplitNew] = cgg_procSplitIntoGroups(this_Identifiers,IdentifierName,SplitNames,NumFolds);

if ~(isempty(MaintainSplit))
GroupList=[GroupList,{MaintainSplit}];
end

NumFurtherSplitNew=length(FurtherSplitNew);

for fidx=1:NumFurtherSplitNew
    FurtherSplitCount=fidx;
    this_FurtherSplit=FurtherSplitNew{fidx};
    GroupList=cgg_procAssignGroupsBySplit(this_Identifiers,IdentifierName,AllSplitNames,NumFolds,'GroupList',GroupList,'SplitLevel',SplitLevel,'FurtherSplit',this_FurtherSplit,'FurtherSplitCount',FurtherSplitCount);
end

end

