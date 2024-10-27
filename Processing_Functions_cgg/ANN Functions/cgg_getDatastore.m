function [Training,Validation,Testing,ClassNames] = cgg_getDatastore(EpochDir,SessionName,Fold,cfg_Encoder,varargin)
%CGG_GETDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
ClassLowerCount = CheckVararginPairs('ClassLowerCount', 20, varargin{:});
else
if ~(exist('ClassLowerCount','var'))
ClassLowerCount=20;
end
end

%%
PartitionDir = fullfile(EpochDir,'Partition');
DataDir = fullfile(EpochDir,'Data');
TargetDir = fullfile(EpochDir,'Target');
%%

Target = cfg_Encoder.Target;
Normalization = cfg_Encoder.Normalization;

STDChannelOffset = cfg_Encoder.STDChannelOffset;
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
STDRandomWalk = cfg_Encoder.STDRandomWalk;

wantSubset = cfg_Encoder.wantSubset;
DataWidth = cfg_Encoder.DataWidth;
WindowStride = cfg_Encoder.WindowStride;

StartingIDX = cfg_Encoder.StartingIDX;
EndingIDX = cfg_Encoder.EndingIDX;
%%
if wantSubset
    Partition_NameExt = 'KFoldPartition_Subset.mat';
elseif contains(SessionName,'Individual')
    disp('Unknown');
Partition_NameExt = '';
else
    Partition_NameExt = 'KFoldPartition.mat';
end
Partition_PathNameExt = [PartitionDir filesep Partition_NameExt];

kidx=Fold;

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);
IndicesPartition=m_Partition.Indices;

NumFolds = KFoldPartition.NumTestSets;

Validation_IDX=test(KFoldPartition,mod(kidx,NumFolds)+1);
Training_IDX=training(KFoldPartition,kidx);
Training_IDX = (Training_IDX-Validation_IDX)==1;
Testing_IDX=test(KFoldPartition,kidx);

DataAggregateDir = DataDir;
TargetAggregateDir = TargetDir;

% TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
% SessionNameDataStore = fileDatastore(TargetAggregateDir,"ReadFcn",TargetSession_Fun);

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=false;
Want1DVector=false;

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'Normalization',Normalization,'NormalizationTable','');
Data_Fun_Augmented=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'STDChannelOffset',STDChannelOffset,'STDWhiteNoise',STDWhiteNoise,'STDRandomWalk',STDRandomWalk,'Normalization',Normalization,'NormalizationTable','');

%%

cfg_Target = PARAMETERS_cggVariableToData(Target);
Target_Fun = cfg_Target.Target_Fun;

% switch Target
%     case 'Dimension'
%     Dimension=1:4;
%     Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
%     case 'Trial Outcome'
%     Target_Fun=@(x) double(cgg_loadTargetArray(x,'CorrectTrial',true));
%     otherwise
%     Target_Fun=@(x) cgg_loadTargetArray(x,'AllTargets',true);
% end


%%
DataNumber_Fun=@(x) cgg_loadTargetArray(x,'DataNumber',true);

Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",Data_Fun);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);
DataNumber_ds = fileDatastore(TargetAggregateDir,"ReadFcn",DataNumber_Fun);

DataStore=combine(Data_ds,Target_ds,DataNumber_ds);

if wantSubset
DataStore=subset(DataStore,IndicesPartition);
end

[ClassNames,~,~,~] = cgg_getClassesFromDataStore(DataStore);

%% Remove Examples that represent very few targets
[DataIndex] = cgg_getDataIndexToRemoveFromDataStore(DataStore,ClassLowerCount);
DataStore=subset(DataStore,~DataIndex);

Training_IDX = Training_IDX(~DataIndex);
Validation_IDX = Validation_IDX(~DataIndex);
Testing_IDX = Testing_IDX(~DataIndex);
%%

DataStore_Training=subset(DataStore,Training_IDX);
DataStore_Validation=subset(DataStore,Validation_IDX);
DataStore_Testing=subset(DataStore,Testing_IDX);

% Set the data augmentation read function
DataStore_Training.UnderlyingDatastores{1}.ReadFcn = Data_Fun_Augmented;

% Set the custom preview function if the datastore supports it
if isprop(DataStore_Training.UnderlyingDatastores{1}, 'PreviewFcn')
    DataStore_Training.UnderlyingDatastores{1}.PreviewFcn = Data_Fun_Augmented;
else
    warning('The datastore does not support custom PreviewFcn.');
end

Training = DataStore_Training;
Validation = DataStore_Validation;
Testing = DataStore_Testing;

end

