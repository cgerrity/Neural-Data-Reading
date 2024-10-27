function [MiniBatchTable,NumBatches] = cgg_procAllSessionMiniBatchTable(DataStore,MiniBatchSize)
%CGG_PROCALLSESSIONMINIBATCHTABLE Summary of this function goes here
%   Detailed explanation goes here

FileName = DataStore.UnderlyingDatastores{2}.Files{1};

[TargetDir,~,~]=fileparts(FileName);

Session_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
% SessionNameDataStore = fileDatastore(TargetDir,"ReadFcn",Session_Fun);
SessionNameDataStore = fileDatastore(DataStore.UnderlyingDatastores{2}.Files,"ReadFcn",Session_Fun);

SessionsList=[];
evalc('SessionsList=gather(tall(SessionNameDataStore));');

SessionNames=unique(SessionsList);
NumSessions=length(SessionNames);

TableVariables = [["IDX", "cell"]; ...
		["SessionName", "string"]; ...
		["SessionNumber", "double"]];

NumVariables = size(TableVariables,1);

MiniBatchTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

TableIDX = 0;
%%
for seidx = 1:NumSessions
    this_SessionName = SessionNames{seidx};
    this_SessionIDXLogical = strcmp(SessionsList,SessionNames{seidx});

    this_SessionDataStore = subset(DataStore,this_SessionIDXLogical);
    this_SessionIDX = find(this_SessionIDXLogical);

    [Iteration_SessionDataStoreIDX,IterationsPerEpoch] = ...
        cgg_procSplitSingleSessionDataStoreByMiniBatchSize(...
        this_SessionDataStore,MiniBatchSize);


    Iteration_DataStoreIDX = ...
        cellfun(@(x) this_SessionIDX(x),...
        Iteration_SessionDataStoreIDX,"UniformOutput",false);

    this_Data = cell(IterationsPerEpoch,NumVariables);

    this_Data(:,1) = Iteration_DataStoreIDX';
    this_Data(:,2) = {this_SessionName};
    this_Data(:,3) = {seidx};

    this_TableRange = (1:IterationsPerEpoch)+TableIDX;

    MiniBatchTable(this_TableRange,:) = this_Data;

    TableIDX = TableIDX + IterationsPerEpoch;
end

NumBatches = height(MiniBatchTable);

% MiniBatchTable = MiniBatchTable(randperm(size(MiniBatchTable,1)),:);
end

