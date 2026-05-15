function cfg_OUT = cgg_generatePartitionVariableSaveName(INcfg,varargin)
%CGG_GENERATEPARTITIONVARIABLESAVENAME Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%%

if isfunction
ExtraSaveTerm = CheckVararginPairs('ExtraSaveTerm', '', varargin{:});
else
if ~(exist('ExtraSaveTerm','var'))
ExtraSaveTerm='';
end
end

if isfunction
wantStratifiedPartition = CheckVararginPairs('wantStratifiedPartition', true, varargin{:});
else
if ~(exist('wantStratifiedPartition','var'))
wantStratifiedPartition=true;
end
end
%%

Partition_Dir = INcfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Partition.path;

%%

if contains(ExtraSaveTerm,'Subset')
Partition_NameExt = 'KFoldPartition_Subset.mat';
elseif contains(ExtraSaveTerm,'All') || isempty(ExtraSaveTerm)
Partition_NameExt = 'KFoldPartition.mat';
else
Partition_NameExt = sprintf('KFoldPartition_%s.mat',ExtraSaveTerm);
end

%%
if ~wantStratifiedPartition
    [~,Partition_Name,Partition_Ext] = fileparts(Partition_NameExt);
    Partition_Name = [Partition_Name, '_NS'];
    Partition_NameExt = [Partition_Name Partition_Ext];
elseif strcmp(wantStratifiedPartition,'Standard')
    [~,Partition_Name,Partition_Ext] = fileparts(Partition_NameExt);
    Partition_Name = [Partition_Name, '_Standard'];
    Partition_NameExt = [Partition_Name Partition_Ext];
end

%%
Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

%%

cfg_OUT=struct();
cfg_OUT.Partition=Partition_PathNameExt;

end

