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

if isfunction
Normalization = CheckVararginPairs('Normalization', 'None', varargin{:});
else
if ~(exist('Normalization','var'))
Normalization='None';
end
end

if isfunction
NormalizationTable = CheckVararginPairs('NormalizationTable', NaN, varargin{:});
else
if ~(exist('NormalizationTable','var'))
NormalizationTable=NaN;
end
end

if isfunction
ClassLowerCount = CheckVararginPairs('ClassLowerCount', 20, varargin{:});
else
if ~(exist('ClassLowerCount','var'))
ClassLowerCount=20;
end
end

if isfunction
NetworkTrainingVersion = CheckVararginPairs('NetworkTrainingVersion', 'Version 2', varargin{:});
else
if ~(exist('NetworkTrainingVersion','var'))
NetworkTrainingVersion='Version 2';
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

HiddenSize=cfg_Encoder.HiddenSizes;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName = cfg_Encoder.ModelName;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
MiniBatchSize = cfg_Encoder.MiniBatchSize;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
WeightReconstruction = cfg_Encoder.WeightReconstruction;
WeightKL = cfg_Encoder.WeightKL;
WeightClassification = cfg_Encoder.WeightClassification;
WeightedLoss = cfg_Encoder.WeightedLoss;
GradientThreshold = cfg_Encoder.GradientThreshold;
Optimizer = cfg_Encoder.Optimizer;
Normalization = cfg_Encoder.Normalization;
LossType_Decoder = cfg_Encoder.LossType_Decoder;

STDChannelOffset = cfg_Encoder.STDChannelOffset;
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
STDRandomWalk = cfg_Encoder.STDRandomWalk;

Target = cfg_Encoder.Target;

% Encoding_Dir=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Encoding.Target.Fold.path;
Encoding_Dir = cgg_getDirectory(cfg.ResultsDir,'Fold');

% cfg_Network = cgg_generateEncoderSubFolders(Encoding_Dir,ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder);
cfg_Network = cgg_generateEncoderSubFolders_v2(Encoding_Dir,cfg_Encoder);


Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');
AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoderInformation');

% Encoding_Dir = cfg_tmp.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.Loss.Classifier.path;

% AutoEncoding_Dir = cfg_tmp.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.path;

NetworkParametersPathNameExt = [Encoding_Dir filesep 'EncodingParameters.yaml'];

WriteYaml(NetworkParametersPathNameExt, cfg_Encoder);

%%

kidx=Fold;

cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm',ExtraSaveTerm);

Partition_PathNameExt = cfg_partition.Partition;

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

if any(ismember(who(m_Partition),'Indices'))
IndicesPartition=m_Partition.Indices;
end
%%
NumFolds = KFoldPartition.NumTestSets;

Validation_IDX=test(KFoldPartition,mod(kidx,NumFolds)+1);
Training_IDX=training(KFoldPartition,kidx);
Training_IDX = (Training_IDX-Validation_IDX)==1;
Testing_IDX=test(KFoldPartition,kidx);

% DataAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
% TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;

DataAggregateDir = cgg_getDirectory(cfg.TargetDir,'Data');
TargetAggregateDir = cgg_getDirectory(cfg.TargetDir,'Target');

% if Data_Normalized
% % DataAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data_Normalized.path;
% DataAggregateDir = cgg_getDirectory(cfg.TargetDir,'Data_Normalized');
% end

TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
SessionNameDataStore = fileDatastore(TargetAggregateDir,"ReadFcn",TargetSession_Fun);

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=false;
Want1DVector=false;

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'Normalization',Normalization,'NormalizationTable','');
Data_Fun_Augmented=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,'STDChannelOffset',STDChannelOffset,'STDWhiteNoise',STDWhiteNoise,'STDRandomWalk',STDRandomWalk,'Normalization',Normalization,'NormalizationTable','');

switch Target
    case 'Dimension'
    Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
    case 'Trial Outcome'
    Target_Fun=@(x) double(cgg_loadTargetArray(x,'CorrectTrial',true));
    otherwise
    Target_Fun=@(x) cgg_loadTargetArray(x,Target,true);
end

DataNumber_Fun=@(x) cgg_loadTargetArray(x,'DataNumber',true);

Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",Data_Fun);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);
DataNumber_ds = fileDatastore(TargetAggregateDir,"ReadFcn",DataNumber_Fun);

%
% DataStore=combine(Data_ds,Target_ds);
DataStore=combine(Data_ds,Target_ds,DataNumber_ds);

if wantSubset
DataStore=subset(DataStore,IndicesPartition);
end

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

InDataStore=DataStore_Training;

if wantSubset
SessionNameDataStore=subset(SessionNameDataStore,IndicesPartition);
end

% %%
% 
% 
% 
% NumClasses=[];
% evalc('NumClasses=gather(tall(DataStore.UnderlyingDatastores{2}));');
% if iscell(NumClasses)
% if isnumeric(NumClasses{1})
%     [Dim1,Dim2]=size(NumClasses{1});
%     [Dim3,Dim4]=size(NumClasses);
% if (Dim1>1&&Dim3>1)||(Dim2>1&&Dim4>1)
%     NumClasses=NumClasses';
% end
%     NumClasses=cell2mat(NumClasses);
%     [Dim1,Dim2]=size(NumClasses);
% if Dim1<Dim2
%     NumClasses=NumClasses';
% end
% end
% end
% 
% [~,NumDimensions]=size(NumClasses);
% 
% ClassNames=cell(1,NumDimensions);
% for fdidx=1:NumDimensions
% ClassNames{fdidx}=unique(NumClasses(:,fdidx));
% end
% NumClasses=cellfun(@(x) length(x),ClassNames);

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


switch NetworkTrainingVersion
    case 'Version 1'
        cgg_trainAllAutoEncoder(InDataStore,DataStore_Validation,DataStore_Testing,SessionsList,cfg_Encoder,ExtraSaveTerm,cfg_Network);
    case 'Version 2'
        cgg_trainAllAutoEncoder_v2(InDataStore,DataStore_Validation,DataStore_Testing,cfg_Encoder,cfg_Network);
    otherwise
        cgg_trainAllAutoEncoder_v2(InDataStore,DataStore_Validation,DataStore_Testing,cfg_Encoder,cfg_Network);
end

%% All Session Encoder Tuning


% labels = onehotencode(AllClasses(2,:),1,'ClassNames',ClassNames{2});


end

