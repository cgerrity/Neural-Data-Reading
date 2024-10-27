function [Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset,varargin)
%CGG_GETDATASTATISTICS Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
Identifiers = CheckVararginPairs('Identifiers', '', varargin{:});
else
if ~(exist('Identifiers','var'))
Identifiers='';
end
end

if isfunction
IdentifierName = CheckVararginPairs('IdentifierName', '', varargin{:});
else
if ~(exist('IdentifierName','var'))
IdentifierName='';
end
end

%%

cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;

Epoch=cfg_param.Epoch;

[~,outputfolder_base,temporaryfolder_base,~] = cgg_getBaseFolders();

% ResultsDir = [temporaryfolder_base filesep 'Data_Neural'];
TargetDir = [outputfolder_base filesep 'Data_Neural'];

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch);
% cfg_Resuts = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch);

%%
Partition_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Partition.path;

if wantSubset
Partition_NameExt = 'KFoldPartition_Subset.mat';
Partition_NS_NameExt = 'KFoldPartition_Subset_NS.mat';
else
Partition_NameExt = 'KFoldPartition.mat';
Partition_NS_NameExt = 'KFoldPartition_NS.mat';
end
Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];
Partition_NS_PathNameExt = [Partition_Dir filesep Partition_NS_NameExt];

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
m_Partition_NS = matfile(Partition_NS_PathNameExt,'Writable',false);
KFoldPartition_NS=m_Partition_NS.KFoldPartition;

NumKPartitions=numel(KFoldPartition);
NumFolds=KFoldPartition(1).NumTestSets;
SubsetAmount=KFoldPartition(1).NumObservations;

if isempty(Identifiers)||isempty(IdentifierName)

TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
Target_Fun=@(x) cgg_loadTargetArray(x);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);

if wantSubset
Target_ds=subset(Target_ds,1:SubsetAmount);
end

%% Data Distributions to Analyze

UniqueDataIdentifiers=gather(tall(Target_ds));

Identifiers=cellfun(@(x) x{1},UniqueDataIdentifiers,'UniformOutput',false);

IdentifierName=UniqueDataIdentifiers{1}{2};

end

%% Obtain Distribution Variables

% Full Dataset
IdentifierIDX=strcmp(IdentifierName,VariableName);
DistributionVariableFull=cellfun(@(x) x(IdentifierIDX),Identifiers,'UniformOutput',true);

% DistributionVariable=NaN(NumDatapointsPerFold,NumFolds,NumKPartitions);
% DistributionVariable_NS=NaN(NumDatapointsPerFold,NumFolds,NumKPartitions);

DistributionVariable=cell(NumFolds,NumKPartitions);
DistributionVariable_NS=cell(NumFolds,NumKPartitions);

for pidx=1:NumKPartitions
for fidx=1:NumFolds
    this_KFoldPartition=KFoldPartition(pidx);
    this_KFoldPartition_NS=KFoldPartition_NS(pidx);

Testing_IDX=test(this_KFoldPartition,fidx);
Testing_NS_IDX=test(this_KFoldPartition_NS,fidx);

this_DistributionVariable=DistributionVariableFull(Testing_IDX);
this_DistributionVariable_NS=DistributionVariableFull(Testing_NS_IDX);

% DistributionVariable(:,fidx,pidx)=this_DistributionVariable;
% DistributionVariable_NS(:,fidx,pidx)=this_DistributionVariable_NS;

DistributionVariable{fidx,pidx}=this_DistributionVariable;
DistributionVariable_NS{fidx,pidx}=this_DistributionVariable_NS;

end
end

%%

ClassNames=unique(DistributionVariableFull);
NumClasses=length(ClassNames);

BinsFull = arrayfun(@(x)length(find(DistributionVariableFull == x)), ClassNames, 'Uniform', true);

BinsEach=NaN(NumClasses,NumFolds,NumKPartitions);
BinsEach_NS=NaN(NumClasses,NumFolds,NumKPartitions);
% for pidx=1:NumKPartitions
% for fidx=1:NumFolds
% % BinsEach(:,fidx,pidx) = arrayfun(@(x)length(find(DistributionVariable(:,fidx,pidx) == x)), ClassNames, 'Uniform', true);
% % BinsEach_NS(:,fidx,pidx) = arrayfun(@(x)length(find(DistributionVariable_NS(:,fidx,pidx) == x)), ClassNames, 'Uniform', true);
% end
% end

for cidx=1:NumClasses
BinsEach(cidx,:,:) = cellfun(@(x)length(find(x == ClassNames(cidx))), DistributionVariable, 'Uniform', true);
BinsEach_NS(cidx,:,:) = cellfun(@(x)length(find(x == ClassNames(cidx))), DistributionVariable_NS, 'Uniform', true);
end

BinsFullFrac=BinsFull./sum(BinsFull);
BinsEachFrac=BinsEach./sum(BinsEach,1);
BinsEachFrac_NS=BinsEach_NS./sum(BinsEach_NS,1);

BinsFullFracDiff=BinsFullFrac-BinsFullFrac;
BinsEachFracDiff=BinsEachFrac-BinsFullFrac;
BinsEachFracDiff_NS=BinsEachFrac_NS-BinsFullFrac;

% BinsEachFracMean=mean(BinsEachFrac,[2,3]);
% BinsEachFracMean_NS=mean(BinsEachFrac_NS,[2,3]);
% BinsEachFracSTD=std(BinsEachFrac,[],[2,3]);
% BinsEachFracSTD_NS=std(BinsEachFrac_NS,[],[2,3]);
% BinsEachFracSTE=std(BinsEachFrac,[],[2,3])/sqrt(NumFolds);
% BinsEachFracSTE_NS=std(BinsEachFrac_NS,[],[2,3])/sqrt(NumFolds);

% XLocation=1:NumClasses;

% b_Full=bar(XLocation,BinsFullFrac);

% b_Each=bar(XLocation,BinsEachFracMean);

ClassOrder=cell(NumClasses,1);

for fidx=1:NumClasses
ClassOrder{fidx}=num2str(ClassNames(fidx));
end

ClassNamesFull_Array=repmat(ClassOrder,1,1);
SourceNamesFull_Array=repmat("Full Data",NumClasses,1);

DataTable=table(ClassNamesFull_Array(:),SourceNamesFull_Array(:),BinsFull(:),BinsFullFrac(:),BinsFullFracDiff(:));
DataTable.Properties.VariableNames = ["FeatureValue","Source","Count","Fraction","Difference"];

ClassNamesEach_Array=repmat(ClassOrder,1,NumFolds,NumKPartitions);
SourceNamesEach_Array=repmat("Statified",NumClasses,NumFolds,NumKPartitions);
SourceNamesEach_NS_Array=repmat("Not Stratified",NumClasses,NumFolds,NumKPartitions);

DataTable_Each=table(ClassNamesEach_Array(:),SourceNamesEach_Array(:),BinsEach(:),BinsEachFrac(:),BinsEachFracDiff(:));
DataTable_Each.Properties.VariableNames = ["FeatureValue","Source","Count","Fraction","Difference"];
DataTable_Each_NS=table(ClassNamesEach_Array(:),SourceNamesEach_NS_Array(:),BinsEach_NS(:),BinsEachFrac_NS(:),BinsEachFracDiff_NS(:));
DataTable_Each_NS.Properties.VariableNames = ["FeatureValue","Source","Count","Fraction","Difference"];

% DataTable_EachDiff=table(ClassNamesEach_Array(:),SourceNamesEach_Array(:),BinsEachFracDiff(:));
% DataTable_EachDiff.Properties.VariableNames = ["FeatureValue","Source","Fraction"];
% DataTable_EachDiff_NS=table(ClassNamesEach_Array(:),SourceNamesEach_NS_Array(:),BinsEachFracDiff_NS(:));
% DataTable_EachDiff_NS.Properties.VariableNames = ["FeatureValue","Source","Fraction"];

FullDataTable=[DataTable;DataTable_Each;DataTable_Each_NS];
% FullDataTableDiff=[DataTable_EachDiff;DataTable_EachDiff_NS];

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,ClassOrder);
% FullDataTableDiff.FeatureValue = categorical(FullDataTableDiff.FeatureValue,ClassOrder);

end

