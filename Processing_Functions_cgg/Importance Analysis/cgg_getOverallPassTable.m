function IA_PassTable = cgg_getOverallPassTable(Folds, SessionName,cfg_Epoch,varargin)
%CGG_GETOVERALLPASSTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

% if isfunction
% SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
% else
% if ~(exist('SessionName','var'))
% SessionName='Subset';
% end
% end

% if isfunction
% RandomRemovalChunk = CheckVararginPairs('RandomRemovalChunk', 10, varargin{:});
% else
% if ~(exist('RandomRemovalChunk','var'))
% RandomRemovalChunk=10;
% end
% end

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
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

% if isfunction
% TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', NaN, varargin{:});
% else
% if ~(exist('TrialFilter_Value','var'))
% TrialFilter_Value=NaN;
% end
% end

if isfunction
TargetFilters = CheckVararginPairs('TargetFilters', 'Overall', varargin{:});
else
if ~(exist('TargetFilters','var'))
TargetFilters='Overall';
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

if isfunction
WantRemoveComplete = CheckVararginPairs('WantRemoveComplete', true, varargin{:});
else
if ~(exist('WantRemoveComplete','var'))
WantRemoveComplete = true;
end
end

%%
TargetFilters = string(TargetFilters);
if ~any(strcmp(TargetFilters,'Overall'))
TargetFilters = ["Overall","TargetFeature","DistractorCorrect","DistractorError"];
end
NumTargetFilters = length(TargetFilters);

Identifiers_Table = cgg_getIdentifiersTable(cfg_Epoch,false);
if all(~strcmp(TrialFilter,'All') & ~strcmp(TrialFilter,'Target Feature'))

    TypeValueFunc.Default = @(x,y) unique(x,'rows');
    TypeValueFunc.Double = @(x,y) unique(x);
    TypeValueFunc.Cell = @(x,y) unique([x{:}]);
    TypeValueFunc.CellCombine = @(x,y) combinations(x{:});
    TypeValues = cgg_procFilterIdentifiersTable(Identifiers_Table,TrialFilter,[],TypeValueFunc);
TypeValues = TypeValues{:,:};
[NumTypes,~]=size(TypeValues);
else
TypeValues=NaN;
[NumTypes,~]=size(TypeValues);
if strcmp(TrialFilter,'Target Feature')
TypeValues=0;
NumTypes=1;
end
end

%%

IA_PassTable = cell(NumTypes*NumTargetFilters,1);
CombinationCounter = 0;
for aidx = 1:NumTargetFilters
    TargetFilter = TargetFilters(aidx);
    if strcmp(TargetFilter,"Overall")
        this_MatchType = MatchType;
    else
        this_MatchType = MatchType_Attention;
    end
for tidx = 1:NumTypes
    TrialFilter_Value = TypeValues(tidx,:);
% IA_PassTable_Func = @(x,y) cgg_getPassTable(x{1},cfg_Epoch,...
%     'SessionName',y,'MatchType',this_MatchType,'TrialFilter',TrialFilter,...
%     'TrialFilter_Value',TrialFilter_Value,'TargetFilter',TargetFilter,...
%     'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
%     'Methods',Methods);
this_IA_PassTable = cgg_getPassTable(Folds,cfg_Epoch,...
    'SessionName',SessionName,'MatchType',this_MatchType,'TrialFilter',TrialFilter,...
    'TrialFilter_Value',TrialFilter_Value,'TargetFilter',TargetFilter,...
    'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
    'Methods',Methods);

% this_IA_PassTable = rowfun(IA_PassTable_Func,EncoderParameters_CM_Table,"InputVariables",["Fold","Subset"],"SeparateInputs",true,"ExtractCellContents",false,"NumOutputs",1,"OutputFormat","cell");
% this_IA_PassTable = vertcat(this_IA_PassTable{:});
CombinationCounter = CombinationCounter +1;
IA_PassTable{CombinationCounter} = this_IA_PassTable;
end
end
IA_PassTable = vertcat(IA_PassTable{:});

%%

if WantRemoveComplete
RemoveIndices = IA_PassTable.IsComplete & ~IA_PassTable.HasFlag;
IA_PassTable(RemoveIndices,:) = [];
end

end

