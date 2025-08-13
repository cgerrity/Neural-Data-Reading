function [Iteration_DataStoreIDX,IterationsPerEpoch] = cgg_procSplitSingleSessionDataStoreByMiniBatchSize(DataStore,MiniBatchSize,WantFullBatch)
%CGG_PROCSPLITSINGLESESSIONDATASTOREBYMINIBATCHSIZE Summary of this function goes here
%   Detailed explanation goes here

NumTrials = numpartitions(DataStore);
Iteration_DataStoreIDX = cgg_getIndicesIntoGroups(MiniBatchSize,NumTrials);
FullBatchIDX = cellfun(@(x) length(x) == MiniBatchSize,...
    Iteration_DataStoreIDX);
if WantFullBatch
    Iteration_DataStoreIDX = Iteration_DataStoreIDX(FullBatchIDX);
end
IterationsPerEpoch = length(Iteration_DataStoreIDX);


end

