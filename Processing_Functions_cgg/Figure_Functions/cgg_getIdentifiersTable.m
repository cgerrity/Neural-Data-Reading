function Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset,varargin)
%CGG_GETIDENTIFIERSTABLE Summary of this function goes here
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

if isfunction
AdditionalTarget = CheckVararginPairs('AdditionalTarget', '', varargin{:});
else
if ~(exist('AdditionalTarget','var'))
AdditionalTarget='';
end
end

%%

ExtraSaveTerm = cgg_generateExtraSaveTerm('wantSubset',wantSubset);

cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm',ExtraSaveTerm);

Partition_PathNameExt = cfg_partition.Partition;

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);
IndicesPartition=m_Partition.Indices;

%%

if isempty(Identifiers)||isempty(IdentifierName)

TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
Target_Fun=@(x) cgg_loadTargetArray(x);

if ~isempty(AdditionalTarget)

    for tidx = 1:length(AdditionalTarget)
        this_Target = AdditionalTarget{tidx};
        this_cfg_VariableSet = PARAMETERS_cggVariableToData(this_Target);
        this_Target_Fun = this_cfg_VariableSet.Target_Fun;
Target_Fun = @(x) {[cell2mat(cgg_getDataFromIndices(Target_Fun(x),1)),...
    this_Target_Fun(x)], ...
    [cgg_getOutputFromCell(cgg_getDataFromIndices(Target_Fun(x),2)), ...
    string(this_Target)]};
    end

end

Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);

if wantSubset
Target_ds=subset(Target_ds,IndicesPartition);
end

%% Data Distributions to Analyze

UniqueDataIdentifiers=gather(tall(Target_ds));

Identifiers=cellfun(@(x) x{1},UniqueDataIdentifiers,'UniformOutput',false);

IdentifierName=UniqueDataIdentifiers{1}{2};
end

%%

InputIdentifiers=cell2mat(Identifiers);
InputNames=cellstr(IdentifierName);
InputNames{strcmp(InputNames,'Data Number')}='DataNumber';

Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);


end

