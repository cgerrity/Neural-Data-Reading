function Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset,varargin)
%CGG_GETIDENTIFIERSTABLE Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Decision';
end
end

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
AdditionalTarget = CheckVararginPairs('AdditionalTarget', {}, varargin{:});
else
if ~(exist('AdditionalTarget','var'))
AdditionalTarget={};
end
end

if isfunction
Subset = CheckVararginPairs('Subset', '', varargin{:});
else
if ~(exist('Subset','var'))
Subset='';
end
end

%%
Identifiers_TablePath = cgg_getDirectory(cfg.ResultsDir,'Processing');
Identifiers_TableNameExt = 'Identifiers_Table.mat';
Identifiers_TablePathNameExt = [Identifiers_TablePath filesep ...
    Identifiers_TableNameExt];

if isfile(Identifiers_TablePathNameExt)
    Identifiers_Table = load(Identifiers_TablePathNameExt);
    Identifiers_Table = Identifiers_Table.Identifiers_Table;
    HasAllTargets = all(ismember(AdditionalTarget, Identifiers_Table.Properties.VariableNames));
end

%%
if ~isempty(Subset)
    if islogical(Subset)
        cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm','Subset');
    else
        cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm',Subset);
    end
elseif wantSubset
    cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm','Subset');
else
    cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm','All');
end
%%

Partition_PathNameExt = cfg_partition.Partition;

if ~isfile(Partition_PathNameExt)
    cgg_getKFoldPartitions('Epoch',Epoch,'SingleSessionSubset',Subset,'wantSubset',wantSubset);
end

m_Partition = load(Partition_PathNameExt);

if isfield(m_Partition,'Indices')
IndicesPartition=m_Partition.Indices;
end

%%
if ~HasAllTargets

if isempty(Identifiers)||isempty(IdentifierName)
% TODO: Add capability for non-double values.
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
% Target_Fun = @(x) {[num2cell(cell2mat(cgg_getDataFromIndices(Target_Fun(x),1))),...
%     this_Target_Fun(x)], ...
%     [cgg_getOutputFromCell(cgg_getDataFromIndices(Target_Fun(x),2)), ...
%     string(this_Target)]};
    end

end

Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);

% if wantSubset
% Target_ds=subset(Target_ds,IndicesPartition);
% end

%% Data Distributions to Analyze

UniqueDataIdentifiers=gather(tall(Target_ds));

Identifiers=cellfun(@(x) x{1},UniqueDataIdentifiers,'UniformOutput',false);

IdentifierName=UniqueDataIdentifiers{1}{2};
end

%%

InputIdentifiers=cell2mat(Identifiers);
% InputIdentifiers=vertcat(Identifiers{:});
InputNames=cellstr(IdentifierName);
InputNames{strcmp(InputNames,'Data Number')}='DataNumber';

Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);

save(Identifiers_TablePathNameExt,"Identifiers_Table","-v7.3");
end

if wantSubset
Identifiers_Table = sortrows(Identifiers_Table,"DataNumber","ascend");
Identifiers_Table(~IndicesPartition,:) = [];
end

end

