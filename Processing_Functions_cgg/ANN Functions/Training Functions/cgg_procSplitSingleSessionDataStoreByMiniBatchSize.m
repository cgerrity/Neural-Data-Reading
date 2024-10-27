function [Iteration_DataStoreIDX,IterationsPerEpoch] = cgg_procSplitSingleSessionDataStoreByMiniBatchSize(DataStore,MiniBatchSize)
%CGG_PROCSPLITSINGLESESSIONDATASTOREBYMINIBATCHSIZE Summary of this function goes here
%   Detailed explanation goes here

NumTrials = numpartitions(DataStore);
Iteration_DataStoreIDX = cgg_getIndicesIntoGroups(MiniBatchSize,NumTrials);
IterationsPerEpoch = length(Iteration_DataStoreIDX);


end

