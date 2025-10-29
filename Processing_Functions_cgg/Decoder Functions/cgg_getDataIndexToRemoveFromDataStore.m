function [DataIndex,ClassesToRemove] = cgg_getDataIndexToRemoveFromDataStore(DataStore,ClassLowerCount,varargin)
%CGG_GETCLASSESFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
TargetDataStoreIDX = CheckVararginPairs('TargetDataStoreIDX', 2, varargin{:});
else
if ~(exist('TargetDataStoreIDX','var'))
TargetDataStoreIDX=2;
end
end

[ClassNames,~,~,ClassCounts] = cgg_getClassesFromDataStore(DataStore,'TargetDataStoreIDX',TargetDataStoreIDX);

% ClassLowerCount = 11;

ClassesToRemove = cellfun(@(x,y) y(x < ClassLowerCount),ClassCounts,ClassNames,"UniformOutput",false);

% AllTargets=[];

TargetDataStore=DataStore.UnderlyingDatastores{TargetDataStoreIDX};

if isa(gcp('nocreate'), 'parallel.ThreadPool')
AllTargets = readall(TargetDataStore,UseParallel=false);
else
AllTargets = readall(TargetDataStore,UseParallel=true);
end

% evalc('AllTargets=gather(tall(TargetDataStore));');

DataIndex = false(size(AllTargets));

for cidx = 1:length(ClassesToRemove)
    DataIndex = DataIndex | cellfun(@(x) ismember(x(cidx),ClassesToRemove{cidx}),AllTargets);
end

end

