function [IsComplete,CompleteNullTable] = cgg_isNullTableComplete(CM_Table,cfg_Epoch,cfg_Encoder,varargin)
%CGG_ISNULLTABLECOMPLETE Summary of this function goes here
%   Detailed explanation goes here

cfg_IA = PARAMETERS_cggImportanceAnalysis();
%%
isfunction=exist('varargin','var');

if isfunction
MaxNumIter = CheckVararginPairs('MaxNumIter', cfg_IA.MaxNumIter, varargin{:});
else
if ~(exist('MaxNumIter','var'))
MaxNumIter=cfg_IA.MaxNumIter;
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

% if isfunction
% WantDisplay = CheckVararginPairs('WantDisplay', false, varargin{:});
% else
% if ~(exist('WantDisplay','var'))
% WantDisplay=false;
% end
% end

%%
if isfield(cfg_Encoder,'Target')
Target = cfg_Encoder.Target;
else
    Target = 'Dimension';
    fprintf('!!! No Target field in cfg_Encoder. Defaulting to ''Dimension''\n');
end

if isfield(cfg_Encoder,'Subset') && isfield(cfg_Encoder,'wantSubset')
[~,~,SessionName] = cgg_verifySubset(cfg_Encoder.Subset,cfg_Encoder.wantSubset);
else
    [~,~,SessionName] = cgg_verifySubset(true,true);
    fprintf('!!! No Subset and wantSubset field in cfg_Encoder. Defaulting to ''Subset''\n');
end

%%
IsComplete = false;
CompleteNullTable = [];
%% Adjust CM_Table

if ~iscell(CM_Table)
CM_Table = {CM_Table};
elseif iscell(CM_Table{1})
CM_Table = CM_Table{1};
end
CM_Table = CM_Table(:);

%% Get the Null Table
NullTable = cgg_loadNullTable(cfg_Epoch,Target,SessionName,TrialFilter,...
    TrialFilter_Value,TargetFilter,MatchType);

%% Identify if the specified data exists in the Null Table
DataNumber = NullTable.DataNumber;

for cidx = 1:length(CM_Table)
    this_CM_Table = CM_Table{cidx};
    this_DataNumber = this_CM_Table.DataNumber;
    MatchingNullEntry = cellfun(@(x) isequal(sort(x),...
        sort(this_DataNumber)),DataNumber,'UniformOutput',true);
    HasMatchingNullEntry = any(MatchingNullEntry);
    % Check if it exists in the table at all
    if ~HasMatchingNullEntry
        return
    end
    % check if multiple entries exist
    if length(find(MatchingNullEntry)) > 1
        return
    end
end

%% Check if the proper number of Iterations has happened
NeedMoreIterations_Baseline = any(cellfun(@(x) length(x) ~= MaxNumIter,...
    NullTable.BaselineChanceDistribution,'UniformOutput',true));
NeedMoreIterations_Chance = any(cellfun(@(x) length(x) ~= MaxNumIter,...
    NullTable.ChanceDistribution,'UniformOutput',true));
NeedMoreIterations = NeedMoreIterations_Baseline || ...
    NeedMoreIterations_Chance;
if NeedMoreIterations
    return
end

%%
% [~,NullTableName] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'cfg',cfg_Epoch);
% fprintf('@@@ Loaded Null Table: %s\n',NullTableName);

IsComplete = true;
CompleteNullTable = NullTable;
end

