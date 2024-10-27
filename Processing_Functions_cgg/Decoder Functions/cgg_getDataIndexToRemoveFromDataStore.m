function [DataIndex,ClassesToRemove] = cgg_getDataIndexToRemoveFromDataStore(DataStore,ClassLowerCount)
%CGG_GETCLASSESFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

[ClassNames,~,~,ClassCounts] = cgg_getClassesFromDataStore(DataStore);

% ClassLowerCount = 11;

ClassesToRemove = cellfun(@(x,y) y(x < ClassLowerCount),ClassCounts,ClassNames,"UniformOutput",false);

AllTargets=[];

TargetDataStore=DataStore.UnderlyingDatastores{2};

evalc('AllTargets=gather(tall(TargetDataStore));');

DataIndex = false(size(AllTargets));

for cidx = 1:length(ClassesToRemove)
    DataIndex = DataIndex | cellfun(@(x) ismember(x(cidx),ClassesToRemove{cidx}),AllTargets);
end

end

