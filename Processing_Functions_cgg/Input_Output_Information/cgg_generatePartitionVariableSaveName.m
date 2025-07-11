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

%%

Partition_Dir = INcfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Partition.path;

%%

if contains(ExtraSaveTerm,'Subset')
Partition_NameExt = 'KFoldPartition_Subset.mat';
elseif contains(ExtraSaveTerm,'All')
Partition_NameExt = 'KFoldPartition.mat';
else
Partition_NameExt = sprintf('KFoldPartition_%s.mat',ExtraSaveTerm);
end
Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

%%

cfg_OUT=struct();
cfg_OUT.Partition=Partition_PathNameExt;

end

