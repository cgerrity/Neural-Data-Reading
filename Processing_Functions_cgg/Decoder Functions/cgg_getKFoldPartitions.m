function KFoldPartition = cgg_getKFoldPartitions
%CGG_GETKFOLDPARTITIONS Summary of this function goes here
%   Detailed explanation goes here

%%
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;

%%

SubsetAmount=cfg_param.SubsetAmount;
SessionSubset=cfg_param.SessionSubset;
NumFolds=cfg_param.NumFolds;
% Dimension = cfg_param.Dimension;
wantSubset = cfg_param.wantSubset;
wantStratifiedPartition = cfg_param.wantStratifiedPartition;
NumKPartitions = cfg_param.NumKPartitions;

%%

Epoch=cfg_param.Epoch;
% Decoder=cfg_param.Decoder;

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder{1},'Fold',1);
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch);

Partition_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Partition.path;

if (wantSubset) && (wantStratifiedPartition)
Partition_NameExt = 'KFoldPartition_Subset.mat';
elseif (~wantSubset) && (wantStratifiedPartition)
Partition_NameExt = 'KFoldPartition.mat';
elseif (wantSubset) && (~wantStratifiedPartition)
Partition_NameExt = 'KFoldPartition_Subset_NS.mat';
elseif (~wantSubset) && (~wantStratifiedPartition)
Partition_NameExt = 'KFoldPartition_NS.mat';
else
Partition_NameExt = 'KFoldPartition.mat';
end

Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

%%

% DataWidth=cfg_param.DataWidth;
% StartingIDX=cfg_param.StartingIDX;
% EndingIDX=cfg_param.EndingIDX;
% WindowStride=cfg_param.WindowStride;

% [Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,'Dimension',Dimension);

TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
Target_Fun=@(x) cgg_loadTargetArray(x);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);

% if wantSubset
% Combined_ds=subset(Combined_ds,1:SubsetAmount);
% end

if wantSubset
TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
SessionNameDataStore = fileDatastore(TargetAggregateDir,"ReadFcn",TargetSession_Fun);

SessionsList=gather(tall(SessionNameDataStore));
IndicesPartition=strcmp(SessionsList,SessionSubset);

Target_ds=subset(Target_ds,IndicesPartition);
else
IndicesPartition=true(numpartitions(Target_ds),1);
end

%%

if wantStratifiedPartition
% Each Data example gets its own identifier if it matches precise
% characteristics
% UniqueDataIdentifiers=readall(Target_ds);
UniqueDataIdentifiers=gather(tall(Target_ds));
% UniqueDataIdentifiers=cellfun(@num2str,UniqueDataIdentifiers,'UniformOutput',false);

% IdentifierName=cellfun(@(x) x{2},UniqueDataIdentifiers,'UniformOutput',false);
Identifiers=cellfun(@(x) x{1},UniqueDataIdentifiers,'UniformOutput',false);

IdentifierName=UniqueDataIdentifiers{1}{2};

PartitionGroups = cgg_procAssignGroups(Identifiers,IdentifierName,NumFolds);
else
PartitionGroups = numpartitions(Target_ds);
end

%%

% NumObservations=numpartitions(Combined_ds);

% KFoldPartition = cvpartition(NumObservations,"KFold",NumFolds);

KFoldPartition = cvpartition(PartitionGroups,"KFold",NumFolds);

for pidx=2:NumKPartitions
KFoldPartition(pidx) = cvpartition(PartitionGroups,"KFold",NumFolds);
end

Partition_SaveVariables={KFoldPartition,IndicesPartition};
Partition_SaveVariablesName={'KFoldPartition','Indices'};
cgg_saveVariableUsingMatfile(Partition_SaveVariables,Partition_SaveVariablesName,Partition_PathNameExt);

end

