function cgg_procAutoEncoder(DataWidth,StartingIDX,EndingIDX,WindowStride,Fold,cfg,cfg_Encoder,varargin)
%CGG_PROCAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=true;
end
end

if isfunction
SubsetAmount = CheckVararginPairs('SubsetAmount', 500, varargin{:});
else
if ~(exist('SubsetAmount','var'))
SubsetAmount=500;
end
end

if isfunction
Dimension = CheckVararginPairs('Dimension', 1:4, varargin{:});
else
if ~(exist('Dimension','var'))
Dimension=1:4;
end
end

if isfunction
Data_Normalized = CheckVararginPairs('Data_Normalized', true, varargin{:});
else
if ~(exist('Data_Normalized','var'))
Data_Normalized=true;
end
end

%%

% NumStacks=1;
% hiddenSize_1 = 100;
% hiddenSize_2=50;
% NumBaseEncoderTrainEpochs=10;
% NumSessionEncoderTrainEpochs=1000;
% 
% NumBaseEpochs=1;
% NumSessionEpochs=2;
% 
% % hiddenSize=NaN(1,NumStacks);
% % hiddenSize(1)=hiddenSize_1;
% % hiddenSize(2)=hiddenSize_2;
% 
% WantProgressWindow=false;

%%

ExtraSaveTerm = cgg_generateExtraSaveTerm('wantSubset',wantSubset,...
    'DataWidth',DataWidth,'WindowStride',WindowStride);

% TargetDir=cfg.TargetDir.path;
% ResultsDir=cfg.ResultsDir.path;
% 
% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Encoding',true,'Fold',Fold);
% cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch,'Encoding',true,'Fold',Fold);
% cfg.ResultsDir=cfg_Results.TargetDir;

Encoding_Dir=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Encoding.Fold.path;

%%

kidx=Fold;

cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm',ExtraSaveTerm);

Partition_PathNameExt = cfg_partition.Partition;

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);
IndicesPartition=m_Partition.Indices;

Training_IDX=training(KFoldPartition,kidx);
Testing_IDX=test(KFoldPartition,kidx);

DataAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;

if Data_Normalized
DataAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data_Normalized.path;
end

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=true;
Want1DVector=false;

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector);
Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
% Target_Fun=@(x) cgg_loadTargetArray(x,'SharedFeatureCoding',true);

Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",Data_Fun);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);

%
DataStore=combine(Data_ds,Target_ds);

if wantSubset
DataStore=subset(DataStore,IndicesPartition);
end

DataStore_Training=subset(DataStore,Training_IDX);
DataStore_Testing=subset(DataStore,Testing_IDX);

InDataStore=DataStore_Training;

TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
SessionNameDataStore = fileDatastore(TargetAggregateDir,"ReadFcn",TargetSession_Fun);

if wantSubset
SessionNameDataStore=subset(SessionNameDataStore,IndicesPartition);
end

%%



NumClasses=[];
evalc('NumClasses=gather(tall(DataStore.UnderlyingDatastores{2}));');
if iscell(NumClasses)
if isnumeric(NumClasses{1})
    [Dim1,Dim2]=size(NumClasses{1});
    [Dim3,Dim4]=size(NumClasses);
if (Dim1>1&&Dim3>1)||(Dim2>1&&Dim4>1)
    NumClasses=NumClasses';
end
    NumClasses=cell2mat(NumClasses);
    [Dim1,Dim2]=size(NumClasses);
if Dim1<Dim2
    NumClasses=NumClasses';
end
end
end

[~,NumDimensions]=size(NumClasses);

ClassNames=cell(1,NumDimensions);
for fdidx=1:NumDimensions
ClassNames{fdidx}=unique(NumClasses(:,fdidx));
end
NumClasses=cellfun(@(x) length(x),ClassNames);

%%

SessionsList=[];
evalc('SessionsList=gather(tall(SessionNameDataStore));');

SessionList_Training=SessionsList(Training_IDX);
SessionsList=SessionList_Training;

% SessionNames=unique(SessionsList);
% NumSessions=length(SessionNames);

% TrialsPerSession=NaN(1,NumSessions);
% InitialChunksPerSession=NaN(1,NumSessions);
% 
% for seidx=1:NumSessions
%     this_TrialsPerSession=sum(strcmp(SessionsList,SessionNames{seidx}));
%     this_NumChunkPerSession=ceil(this_TrialsPerSession/NumObsPerChunk);
%     
% TrialsPerSession(seidx)=this_TrialsPerSession;
% InitialChunksPerSession=this_NumChunkPerSession;
% end
% 
% NumAllSessionTuning=sum(InitialChunksPerSession);

%%

% Preview_Data=preview(DataStore_Training);
% 
% [NumWindows,inputSize]=size(Preview_Data{1});
% 
% NumObservations=numpartitions(DataStore_Training);

%%

% All_AutoEncoder=cell(1,NumStacks);
% All_AutoEncoder_Net=cell(1,NumStacks);
% All_FeatureVector=cell(1,NumStacks+1);
% 
% All_FeatureVector{1,1}=Preview_Data{1}';
% 
% 
% for sidx=1:NumStacks
% 
% this_FeatureVector = All_FeatureVector{1,sidx};
% 
% this_AutoEncoder = trainAutoencoder(this_FeatureVector,hiddenSize(sidx),...
%     'EncoderTransferFunction','satlin',...
%     'DecoderTransferFunction','purelin',...
%     'L2WeightRegularization',0.01,...
%     'SparsityRegularization',4,...
%     'SparsityProportion',0.10,...
%     'MaxEpochs',1,...
%     'ShowProgressWindow',WantProgressWindow);
% 
% this_FeatureVector = encode(this_AutoEncoder,this_FeatureVector);
% 
% this_AutoEncoder_Net=network(this_AutoEncoder);
% this_AutoEncoder_Net.performFcn='mse';
% this_AutoEncoder_Net.trainParam.epochs=NumBaseEncoderTrainEpochs;
% 
% All_AutoEncoder{sidx}=this_AutoEncoder;
% All_AutoEncoder_Net{sidx}=this_AutoEncoder_Net;
% All_FeatureVector{1,sidx+1}=this_FeatureVector;
% end

%% Train Base AutoEncoder and Session Specific

cgg_trainVariationalAutoEncoder_v2(InDataStore,DataStore_Testing,SessionsList,cfg_Encoder,ExtraSaveTerm,Encoding_Dir);


%% All Session Encoder Tuning


% labels = onehotencode(AllClasses(2,:),1,'ClassNames',ClassNames{2});


end

