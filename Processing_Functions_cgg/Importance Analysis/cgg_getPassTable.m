function IA_PassTable = cgg_getPassTable(Folds,cfg_Epoch,varargin)
%CGG_GETPASSTABLE Summary of this function goes here
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
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

if isfunction
TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', NaN, varargin{:});
else
if ~(exist('TrialFilter_Value','var'))
TrialFilter_Value=NaN;
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='Overall';
end
end

if isfunction
RemovalTypes = CheckVararginPairs('RemovalTypes', ["Channel", "Latent"], varargin{:});
else
if ~(exist('RemovalTypes','var'))
RemovalTypes=["Channel", "Latent"];
end
end

% if isfunction
% Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
% else
% if ~(exist('Epoch','var'))
% Epoch='Decision';
% end
% end

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
end

if isfunction
TimeRange = CheckVararginPairs('TimeRange', [-Inf,Inf], varargin{:});
else
if ~(exist('TimeRange','var'))
TimeRange=[-Inf,Inf];
end
end

if isfunction
Methods = CheckVararginPairs('Methods', "Block", varargin{:});
else
if ~(exist('Methods','var'))
Methods = "Block";
end
end

%%
% EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
% EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');
%%
SessionName = string(SessionName);
MatchType = string(MatchType);
Target = string(Target);
TrialFilter = string(TrialFilter);
TargetFilter = string(TargetFilter);

%%
[TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Pack');
%%

% TODO: Add TimeRange
% TODO: Maybe add in Epoch???
TableVariables = [["SessionName", "string"]; ...
    ["Target", "string"]; ...
    ["TrialFilter", "string"]; ...
    ["TrialFilter_Value", "double"]; ...
    ["TargetFilter", "string"]; ...
    ["TimeRange", "double"]; ...
    ["MatchType", "string"]; ...
    ["RemovalType", "string"]; ...
    ["Method", "string"]; ...
    ["Fold", "double"]; ...
    ["NumRemoved", "double"]; ...
    ["IsComplete", "logical"]; ...
    ["HasFlag", "logical"]; ...
    ["InProgress", "logical"]; ...
    ["IsReady", "logical"]; ...
    ["IsFinished", "logical"];...
    ["HasTest", "logical"]];

NumVariables = size(TableVariables,1);
IA_PassTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%% Rank

Method = "Rank";
if any(strcmp(Method,Methods))
NumRemoved = NaN;

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);

    this_PassTable = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange,MatchType, ...
        RemovalType,Method,Fold,NumRemoved);

[IsComplete,HasFlag,InProgress,IsReady,IsFinished,HasTest] = ...
    cgg_checkAnyImportanceAnalysis(this_PassTable,cfg_Epoch);

    this_PassTable.IsComplete = IsComplete;
    this_PassTable.HasFlag = HasFlag;
    this_PassTable.InProgress = InProgress;
    this_PassTable.IsReady = IsReady;
    this_PassTable.IsFinished = IsFinished;
    this_PassTable.HasTest = HasTest;

% this_Table = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange,MatchType, ...
%     RemovalType,Method,Fold,NumRemoved,IsComplete,HasFlag,InProgress, ...
%     IsReady,IsFinished);

IA_PassTable = [IA_PassTable;this_PassTable];

    end
end
end

%% Block

Method = "Block";
if any(strcmp(Method,Methods))
NumRemoved = NaN;

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);

    this_PassTable = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange,MatchType, ...
        RemovalType,Method,Fold,NumRemoved);

[IsComplete,HasFlag,InProgress,IsReady,IsFinished,HasTest] = ...
    cgg_checkAnyImportanceAnalysis(this_PassTable,cfg_Epoch);

    this_PassTable.IsComplete = IsComplete;
    this_PassTable.HasFlag = HasFlag;
    this_PassTable.InProgress = InProgress;
    this_PassTable.IsReady = IsReady;
    this_PassTable.IsFinished = IsFinished;
    this_PassTable.HasTest = HasTest;

% this_Table = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange,MatchType, ...
%     RemovalType,Method,Fold,NumRemoved,IsComplete,HasFlag,InProgress, ...
%     IsReady,IsFinished);

IA_PassTable = [IA_PassTable;this_PassTable];

    end
end
end

%% Random

Method = "Random";
if any(strcmp(Method,Methods))

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);
        LastNumRemoved = RandomRemovalChunk;
        NumRemoved = 1;
        while NumRemoved <= LastNumRemoved

            this_PassTable = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange,MatchType, ...
                RemovalType,Method,Fold,NumRemoved);

            [IsComplete,HasFlag,InProgress,IsReady,IsFinished,HasTest] = ...
                cgg_checkAnyImportanceAnalysis(this_PassTable,cfg_Epoch);

            this_PassTable.IsComplete = IsComplete;
            this_PassTable.HasFlag = HasFlag;
            this_PassTable.InProgress = InProgress;
            this_PassTable.IsReady = IsReady;
            this_PassTable.IsFinished = IsFinished;
            this_PassTable.HasTest = HasTest;

        % [IsComplete,HasFlag,InProgress,IsReady,IsFinished,HasTest] = ...
        %     cgg_checkAnyImportanceAnalysis(Method,NumRemoved,...
        %     RemovalType,Fold,cfg_Epoch,'SessionName',SessionName,...
        %     'MatchType',MatchType,'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value, ...
        %     'TargetFilter',TargetFilter,'Target',Target,'TimeRange',TimeRange);

        % this_Table = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange, ...
        %     MatchType,RemovalType,Method,Fold,NumRemoved,IsComplete, ...
        %     HasFlag,InProgress,IsReady,IsFinished);

        IA_PassTable = [IA_PassTable;this_PassTable];

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
end

%% Sequential


Method = "Sequential";
if any(strcmp(Method,Methods))

for ridx = 1:length(RemovalTypes)
    RemovalType = RemovalTypes(ridx);
    for fidx = 1:length(Folds)
        Fold = Folds(fidx);
        LastNumRemoved = 1;
        NumRemoved = 1;
        while NumRemoved <= LastNumRemoved

            this_PassTable = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange,MatchType, ...
                RemovalType,Method,Fold,NumRemoved);

            [IsComplete,HasFlag,InProgress,IsReady,IsFinished,HasTest] = ...
                cgg_checkAnyImportanceAnalysis(this_PassTable,cfg_Epoch);

            this_PassTable.IsComplete = IsComplete;
            this_PassTable.HasFlag = HasFlag;
            this_PassTable.InProgress = InProgress;
            this_PassTable.IsReady = IsReady;
            this_PassTable.IsFinished = IsFinished;
            this_PassTable.HasTest = HasTest;

        % [IsComplete,HasFlag,InProgress,IsReady,IsFinished] = ...
        %     cgg_checkAnyImportanceAnalysis(Method,NumRemoved,...
        %     RemovalType,Fold,cfg_Epoch,'SessionName',SessionName,...
        %     'MatchType',MatchType,'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value, ...
        %     'TargetFilter',TargetFilter,'Target',Target,'TimeRange',TimeRange);
        % 
        % this_Table = table(SessionName,Target,TrialFilter,TrialFilter_Value,TargetFilter,TimeRange, ...
        %     MatchType,RemovalType,Method,Fold,NumRemoved,IsComplete, ...
        %     HasFlag,InProgress,IsReady,IsFinished);

        IA_PassTable = [IA_PassTable;this_PassTable];

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

%%

% RemoveIndices = IA_PassTable.IsComplete & ~IA_PassTable.HasFlag;
% IA_PassTable(RemoveIndices,:) = [];

end

