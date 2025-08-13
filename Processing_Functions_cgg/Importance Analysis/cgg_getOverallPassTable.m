function IA_PassTable = cgg_getOverallPassTable(Folds,EpochDir,varargin)
%CGG_GETOVERALLPASSTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='Subset';
end
end

if isfunction
RandomRemovalChunk = CheckVararginPairs('RandomRemovalChunk', 10, varargin{:});
else
if ~(exist('RandomRemovalChunk','var'))
RandomRemovalChunk=10;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', 'All', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='All';
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='Overall';
end
end

%% Setting Removal Types
% Should be something not hard coded

RemovalTypes = ["Channel", "Latent"];

%%
SessionName = string(SessionName);
MatchType = string(MatchType);

%%


TableVariables = [["SessionName", "string"]; ...
    ["TrialFilter", "string"]; ...
    ["TargetFilter", "string"]; ...
    ["MatchType", "string"]; ...
    ["RemovalType", "string"]; ...
    ["Method", "string"]; ...
    ["Fold", "double"]; ...
    ["NumRemoved", "double"]; ...
    ["IsComplete", "logical"]; ...
    ["HasFlag", "logical"]; ...
    ["InProgress", "logical"]; ...
    ["IsReady", "logical"]; ...
    ["IsFinished", "logical"]];

NumVariables = size(TableVariables,1);
IA_PassTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%% Rank

Method = "Rank";
NumRemoved = NaN;

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);

[IsComplete,HasFlag,InProgress,IsReady,IsFinished] = ...
    cgg_checkAnyImportanceAnalysis(Method,NumRemoved,RemovalType,Fold,...
    EpochDir,'SessionName',SessionName,'MatchType',MatchType, ...
    'TrialFilter',TrialFilter,'TargetFilter',TargetFilter);

this_Table = table(SessionName,TrialFilter,TargetFilter,MatchType, ...
    RemovalType,Method,Fold,NumRemoved,IsComplete,HasFlag,InProgress, ...
    IsReady,IsFinished);

IA_PassTable = [IA_PassTable;this_Table];

    end
end

%% Random

Method = "Random";

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);
        LastNumRemoved = RandomRemovalChunk;
        NumRemoved = 1;
        while NumRemoved <= LastNumRemoved

        [IsComplete,HasFlag,InProgress,IsReady,IsFinished] = ...
            cgg_checkAnyImportanceAnalysis(Method,NumRemoved,...
            RemovalType,Fold,EpochDir,'SessionName',SessionName,...
            'MatchType',MatchType,'TrialFilter',TrialFilter, ...
            'TargetFilter',TargetFilter);
        
        this_Table = table(SessionName,TrialFilter,TargetFilter, ...
            MatchType,RemovalType,Method,Fold,NumRemoved,IsComplete, ...
            HasFlag,InProgress,IsReady,IsFinished);
        
        IA_PassTable = [IA_PassTable;this_Table];
        
        if IsComplete
            LastNumRemoved = NumRemoved + RandomRemovalChunk;
        end
        if IsFinished
            LastNumRemoved = NumRemoved;
        end
            NumRemoved = NumRemoved + 1;
        end % End while

    end
end

%% Sequential


Method = "Sequential";

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);
        LastNumRemoved = 1;
        NumRemoved = 1;
        while NumRemoved <= LastNumRemoved

        [IsComplete,HasFlag,InProgress,IsReady,IsFinished] = ...
            cgg_checkAnyImportanceAnalysis(Method,NumRemoved,...
            RemovalType,Fold,EpochDir,'SessionName',SessionName,...
            'MatchType',MatchType,'TrialFilter',TrialFilter, ...
            'TargetFilter',TargetFilter);
        
        this_Table = table(SessionName,TrialFilter,TargetFilter, ...
            MatchType,RemovalType,Method,Fold,NumRemoved,IsComplete, ...
            HasFlag,InProgress,IsReady,IsFinished);
        
        IA_PassTable = [IA_PassTable;this_Table];
        
        if IsComplete
            LastNumRemoved = NumRemoved + 1;
        end
        if IsFinished
            LastNumRemoved = NumRemoved;
        end
            NumRemoved = NumRemoved + 1;
        end % End while

    end
end

end

