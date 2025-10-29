function FullTable = cgg_addBlockImportanceAnalysisToFullAccuracyTable(...
    FullTable,cfg_Encoder,cfg_Epoch,varargin)
%CGG_ADDBLOCKIMPORTANCEANALYSISTOFULLACCURACYTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
MatchType_Attention = CheckVararginPairs('MatchType_Attention', 'Scaled-MicroAccuracy', varargin{:});
else
if ~(exist('MatchType_Attention','var'))
MatchType_Attention='Scaled-MicroAccuracy';
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', {'Learned'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'Learned'};
end
end

if isfunction
TargetFilters = CheckVararginPairs('TargetFilters', ["TargetFeature","DistractorCorrect","DistractorError"], varargin{:});
else
if ~(exist('TargetFilters','var'))
TargetFilters=["TargetFeature","DistractorCorrect","DistractorError"];
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
RemovalTypes = CheckVararginPairs('RemovalTypes', "Channel", varargin{:});
else
if ~(exist('RemovalTypes','var'))
RemovalTypes="Channel";
end
end

%% Get Variable Names
SessionNames = FullTable.Properties.RowNames;
Target = cfg_Encoder.Target;
Methods = "Block";
NumSessions = height(FullTable);

%%

% IA_PassTable_Session_Func = @(y,TrialFilter_Var,TargetFilters_Var) cgg_getOverallPassTable(...
%     0, y,cfg_Epoch,'MatchType',MatchType,...
%     'MatchType_Attention',MatchType_Attention,...
%     'TrialFilter',TrialFilter_Var,'TargetFilters',TargetFilters_Var,...
%     'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
%     'Methods',Methods);

%%
IA_PassTable_Func = @(y) cgg_getOverallPassTable(...
    0, string(y),cfg_Epoch,'MatchType',MatchType,...
    'MatchType_Attention',MatchType_Attention,...
    'TrialFilter',{'All'},'TargetFilters',TargetFilters,...
    'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
    'Methods',Methods);

IA_PassTable_Cell_Func = @() cellfun(@(x) IA_PassTable_Func(x),SessionNames,'UniformOutput',false);
Cat_Func = @(x) vertcat(x{:});
IA_PassTable_Func = @() Cat_Func(IA_PassTable_Cell_Func());
IA_PassTable = IA_PassTable_Func();
%%
IA_PassTable_Split_Func = @(y) cgg_getOverallPassTable(...
    0, string(y),cfg_Epoch,'MatchType',MatchType,...
    'MatchType_Attention',MatchType_Attention,...
    'TrialFilter',TrialFilter,'TargetFilters',TargetFilters,...
    'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
    'Methods',Methods);

IA_PassTable_Cell_Func = @() cellfun(@(x) IA_PassTable_Split_Func(x),SessionNames,'UniformOutput',false);
Cat_Func = @(x) vertcat(x{:});
IA_PassTable_Func = @() Cat_Func(IA_PassTable_Cell_Func());
IA_PassTable_Split = IA_PassTable_Func();
IA_PassTable = [IA_PassTable;IA_PassTable_Split];
%%
% Add all the possible names to the pass table. Then match the names from
% the full table to the pass table
IA_PassTable.FullNames = IA_PassTable.SessionName;
TrialFilter = IA_PassTable.TrialFilter;
TrialFilter_Value = IA_PassTable.TrialFilter_Value;
IA_PassTable.SplitNames = arrayfun(@(x,y) cgg_getSplitTableRowNames(...
    TrialFilter(x,:),y),(1:size(TrialFilter,1))',...
    TrialFilter_Value);
IA_PassTable.AttentionNames = IA_PassTable.TargetFilter;

%% Overall
Indices_Overall = strcmp(IA_PassTable.SplitNames,"Overall") & strcmp(IA_PassTable.AttentionNames,"Overall");
this_PassTable = IA_PassTable(Indices_Overall,:);

FullTable = cgg_addBlockImportanceAnalysisToAccuracyTable(...
FullTable,this_PassTable,cfg_Epoch,'TableType','Full');

for sidx = 1:NumSessions
    SessionName = SessionNames{sidx};
    % fprintf("??? Current Session is %s\n",SessionName);
    this_SessionIndices = strcmp(IA_PassTable.FullNames,SessionName);
    this_SessionPassTable = IA_PassTable(this_SessionIndices,:);
%% Split
Indices_Split = ~strcmp(this_SessionPassTable.SplitNames,"Overall") & strcmp(this_SessionPassTable.AttentionNames,"Overall");
this_PassTable = this_SessionPassTable(Indices_Split,:);

FullTable.("Split Table"){sidx} = ...
    cgg_addBlockImportanceAnalysisToAccuracyTable( ...
FullTable.("Split Table"){sidx}, ...
this_PassTable,cfg_Epoch,'TableType','Split');
%% Split Attention
SplitNames = FullTable.("Split Table"){sidx}.Properties.RowNames;
for spidx = 1:length(SplitNames)
    this_SplitName = SplitNames{spidx};
Indices_Split_Attention = strcmp(this_SessionPassTable.SplitNames,this_SplitName) & ~strcmp(this_SessionPassTable.AttentionNames,"Overall");
this_PassTable = this_SessionPassTable(Indices_Split_Attention,:);

FullTable.("Split Table"){sidx}.("Attentional Table"){spidx} = ...
    cgg_addBlockImportanceAnalysisToAccuracyTable( ...
FullTable.("Split Table"){sidx}.("Attentional Table"){spidx}, ...
this_PassTable,cfg_Epoch,'TableType','Attention');
end
%% Attention
Indices_Attention = strcmp(this_SessionPassTable.SplitNames,"Overall") & ~strcmp(this_SessionPassTable.AttentionNames,"Overall");
this_PassTable = this_SessionPassTable(Indices_Attention,:);

FullTable.("Attentional Table"){sidx} = ...
    cgg_addBlockImportanceAnalysisToAccuracyTable( ...
FullTable.("Attentional Table"){sidx}, ...
this_PassTable,cfg_Epoch,'TableType','Attention');
%% Attention Split
AttentionalNames = FullTable.("Attentional Table"){sidx}.Properties.RowNames;
for aidx = 1:length(AttentionalNames)
    this_AttentionalName = AttentionalNames{aidx};
Indices_Attention_Split = ~strcmp(this_SessionPassTable.SplitNames,"Overall") & strcmp(this_SessionPassTable.AttentionNames,this_AttentionalName);
this_PassTable = this_SessionPassTable(Indices_Attention_Split,:);

FullTable.("Attentional Table"){sidx}.("Split Table"){aidx} = ...
    cgg_addBlockImportanceAnalysisToAccuracyTable( ...
FullTable.("Attentional Table"){sidx}.("Split Table"){aidx}, ...
this_PassTable,cfg_Epoch,'TableType','Split');
end

end

end