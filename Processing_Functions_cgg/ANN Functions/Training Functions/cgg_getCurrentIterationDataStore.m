function [CurrentDataStore,SessionName,SessionNumber] = ...
    cgg_getCurrentIterationDataStore(MiniBatchTable,MiniBatchIDX,DataStore)
%CGG_GETCURRENTITERATIONDATASTORE Summary of this function goes here
%   Detailed explanation goes here

Iteration_DataStoreIDX = MiniBatchTable{MiniBatchIDX,"IDX"};
if iscell(Iteration_DataStoreIDX)
    Iteration_DataStoreIDX = Iteration_DataStoreIDX{1};
end
CurrentDataStore = subset(DataStore,Iteration_DataStoreIDX);

SessionName = MiniBatchTable{MiniBatchIDX,"SessionName"};
SessionNumber = MiniBatchTable{MiniBatchIDX,"SessionNumber"};



end

