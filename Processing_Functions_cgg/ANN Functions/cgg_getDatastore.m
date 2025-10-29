function [Training,Validation,Testing,ClassNames,Training_Augmented] = cgg_getDatastore(EpochDir,SessionName,Fold,cfg_Encoder,varargin)
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

if isfunction
WantData = CheckVararginPairs('WantData', true, varargin{:});
else
if ~(exist('WantData','var'))
WantData=true;
end
end

%%
PartitionDir = fullfile(EpochDir,'Partition');
cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Partition.path = PartitionDir;
DataDir = fullfile(EpochDir,'Data');
TargetDir = fullfile(EpochDir,'Target');
NormalizationInformationDir = fullfile(EpochDir,'Normalization Information');
%%

Target = cfg_Encoder.Target;
Normalization = cfg_Encoder.Normalization;

STDChannelOffset = cfg_Encoder.STDChannelOffset;
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
STDRandomWalk = cfg_Encoder.STDRandomWalk;

if isfield(cfg_Encoder,'STDTimeShift')
STDTimeShift = cfg_Encoder.STDTimeShift;
else
STDTimeShift=NaN;
end
if isfield(cfg_Encoder,'WantSeparateTimeShift')
WantSeparateTimeShift = cfg_Encoder.WantSeparateTimeShift;
else
WantSeparateTimeShift = false;
end

wantSubset = cfg_Encoder.wantSubset;
DataWidth = cfg_Encoder.DataWidth;
WindowStride = cfg_Encoder.WindowStride;

StartingIDX = cfg_Encoder.StartingIDX;
EndingIDX = cfg_Encoder.EndingIDX;
%%

if isfield(cfg_Encoder,'Subset')
    if islogical(cfg_Encoder.Subset)
        cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm','Subset');
    else
        cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm',cfg_Encoder.Subset);
    end
elseif cfg_Encoder.wantSubset
    cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm','Subset');
else
    cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm','All');
end

Partition_PathNameExt = cfg_partition.Partition;

if ~isfile(Partition_PathNameExt)
    cgg_getKFoldPartitions('Epoch',cfg_Encoder.Epoch,'SingleSessionSubset',cfg_Encoder.Subset,'wantSubset',cfg_Encoder.wantSubset);
end
m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

if any(ismember(who(m_Partition),'Indices'))
IndicesPartition=m_Partition.Indices;
end

kidx=Fold;

% m_Partition = matfile(Partition_PathNameExt,'Writable',false);
% KFoldPartition=m_Partition.KFoldPartition;
% KFoldPartition=KFoldPartition(1);
% IndicesPartition=m_Partition.Indices;

NumFolds = KFoldPartition.NumTestSets;

%%

Validation_IDX=test(KFoldPartition,mod(kidx,NumFolds)+1);
Training_IDX=training(KFoldPartition,kidx);
Training_IDX = (Training_IDX-Validation_IDX)==1;
Testing_IDX=test(KFoldPartition,kidx);

DataAggregateDir = DataDir;
TargetAggregateDir = TargetDir;

NormalizationInformationPathNameExt = fullfile(NormalizationInformationDir, 'NormalizationInformation.mat');
NormalizationInformation = load(NormalizationInformationPathNameExt);
NormalizationInformation = NormalizationInformation.NormalizationInformation;

% TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
% SessionNameDataStore = fileDatastore(TargetAggregateDir,"ReadFcn",TargetSession_Fun);

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=false;
Want1DVector=false;

% Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'Normalization',Normalization,'NormalizationTable','');
Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'Normalization',Normalization,'NormalizationTable','','NormalizationInformation',NormalizationInformation);
% Data_Fun_Augmented=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'STDChannelOffset',STDChannelOffset,'STDWhiteNoise',STDWhiteNoise,'STDRandomWalk',STDRandomWalk,'Normalization',Normalization,'NormalizationTable','');
Data_Fun_Augmented=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'STDChannelOffset',STDChannelOffset,'STDWhiteNoise',STDWhiteNoise,'STDRandomWalk',STDRandomWalk,'STDTimeShift',STDTimeShift,'WantSeparateTimeShift',WantSeparateTimeShift,'Normalization',Normalization,'NormalizationTable','','NormalizationInformation',NormalizationInformation);

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

if WantData
Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",Data_Fun);
Data_Augmented_ds = fileDatastore(DataAggregateDir,"ReadFcn",Data_Fun_Augmented);
end
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);
DataNumber_ds = fileDatastore(TargetAggregateDir,"ReadFcn",DataNumber_Fun);

if WantData
DataStore=combine(Data_ds,Target_ds,DataNumber_ds);
DataStore_Augmented=combine(Data_Augmented_ds,Target_ds,DataNumber_ds);
else
DataStore=combine(Target_ds,DataNumber_ds);
DataStore_Augmented=combine(Target_ds,DataNumber_ds);
end

if wantSubset
DataStore=subset(DataStore,IndicesPartition);
DataStore_Augmented=subset(DataStore_Augmented,IndicesPartition);
end

if WantData
[ClassNames,~,~,~] = cgg_getClassesFromDataStore(DataStore);
else
[ClassNames,~,~,~] = cgg_getClassesFromDataStore(DataStore,'TargetDataStoreIDX',1);
end

%% Remove Examples that represent very few targets
if WantData
[DataIndex] = cgg_getDataIndexToRemoveFromDataStore(DataStore,ClassLowerCount);
else
[DataIndex] = cgg_getDataIndexToRemoveFromDataStore(DataStore,ClassLowerCount,'TargetDataStoreIDX',1);
end
DataStore=subset(DataStore,~DataIndex);
DataStore_Augmented=subset(DataStore_Augmented,~DataIndex);

Training_IDX = Training_IDX(~DataIndex);
Validation_IDX = Validation_IDX(~DataIndex);
Testing_IDX = Testing_IDX(~DataIndex);
%%

DataStore_Training=subset(DataStore,Training_IDX);
DataStore_Training_Augmented=subset(DataStore_Augmented,Training_IDX);
DataStore_Validation=subset(DataStore,Validation_IDX);
DataStore_Testing=subset(DataStore,Testing_IDX);

if WantData
% Set the data augmentation read function
DataStore_Training.UnderlyingDatastores{1}.ReadFcn = Data_Fun_Augmented;

% Set the custom preview function if the datastore supports it
if isprop(DataStore_Training.UnderlyingDatastores{1}, 'PreviewFcn')
    DataStore_Training.UnderlyingDatastores{1}.PreviewFcn = Data_Fun_Augmented;
else
    warning('The datastore does not support custom PreviewFcn.');
end
end

Training = DataStore_Training;
Validation = DataStore_Validation;
Testing = DataStore_Testing;
Training_Augmented = DataStore_Training_Augmented;

end

