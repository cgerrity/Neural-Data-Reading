

if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
clc; clear; close all;
end

Epoch = 'Decision';
FoldStart = 1; FoldEnd = 10;
NumFolds = numel(FoldStart:FoldEnd); 
SamplingFrequency=1000;
wantSubset = true;
wantStratifiedPartition = true;

VariableName='Correct Trial';

X_Name='Time (s)';
Y_Name='Accuracy';


%%

if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
[Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset);
else
% [Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset,'Identifiers',Identifiers,'IdentifierName',IdentifierName);
end

%%

cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

DataWidth = cfg_Decoder.DataWidth/SamplingFrequency;
WindowStride = cfg_Decoder.WindowStride/SamplingFrequency;

Decoders = cfg_Decoder.Decoder;
NumDecoders = length(Decoders);

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;

if wantSubset
    if wantStratifiedPartition
Partition_NameExt = 'KFoldPartition_Subset.mat';
    else
Partition_NameExt = 'KFoldPartition_Subset_NS.mat';
    end
else
    if wantStratifiedPartition
Partition_NameExt = 'KFoldPartition.mat';
    else
Partition_NameExt = 'KFoldPartition_NS.mat';
    end
end

Each_Prediction=cell(NumDecoders,NumFolds);
EachIdentifiers=cell(NumDecoders,NumFolds);

ClassNames=[];

for didx=1:NumDecoders
for fidx=FoldStart:FoldEnd

    Fold = fidx;
    Decoder = Decoders{didx};

    if wantSubset
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',[Decoder,'_Subset'],'Fold',Fold);
    else
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);
    end

Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;

Partition_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

if wantSubset
Accuracy_NameExt = sprintf('%s_Accuracy_Subset.mat',Decoder);
else
Accuracy_NameExt = sprintf('%s_Accuracy.mat',Decoder);
end

Accuracy_PathNameExt = [Decoding_Dir filesep Accuracy_NameExt];

m_Accuracy = matfile(Accuracy_PathNameExt,'Writable',false);
Each_Prediction{didx,fidx} = m_Accuracy.Each_Prediction;

this_TestingIDX=test(KFoldPartition,fidx);

EachIdentifiers{didx,fidx}=Identifiers(this_TestingIDX);

end

this_ClassNames=cell2mat(transpose(cellfun(@(x2) cell2mat(x2),Each_Prediction{1,fidx},'UniformOutput',false)));
this_ClassNames=this_ClassNames(:,1);
this_ClassNames=unique(this_ClassNames);
ClassNames=unique([ClassNames;this_ClassNames]);
end

InSavePlotCFG = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Plots;