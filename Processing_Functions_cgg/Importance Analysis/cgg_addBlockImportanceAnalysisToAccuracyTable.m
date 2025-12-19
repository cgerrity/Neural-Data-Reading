function AccuracyTable = cgg_addBlockImportanceAnalysisToAccuracyTable(...
    AccuracyTable,PassTable,cfg_Epoch,varargin)
%CGG_ADDBLOCKIMPORTANCEANALYSISTOACCURACYTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
TableType = CheckVararginPairs('TableType', 'Full', varargin{:});
else
if ~(exist('TableType','var'))
TableType='Full';
end
end

if isfunction
Areas = CheckVararginPairs('Areas', [], varargin{:});
else
if ~(exist('Areas','var'))
Areas=[];
end
end

%%
switch TableType
    case 'Full'
        RowNames = PassTable.SessionName;
    case 'Split'
        TrialFilter = PassTable.TrialFilter;
        TrialFilter_Value = PassTable.TrialFilter_Value;
        % [TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Unpack');
        UnPackFunction = @(TF_var,TFV_var) cgg_getPackedTrialFilter(TF_var,TFV_var,'Unpack');
        RowNames = arrayfun(@(x,y) cgg_getSplitTableRowNames(...
            cgg_getOutput({x,y},UnPackFunction,1,'MultiInput',true), ...
            cgg_getOutput({x,y},UnPackFunction,2,'MultiInput',true)), ...
            TrialFilter,TrialFilter_Value);
        % RowNames = arrayfun(@(x,y) cgg_getSplitTableRowNames(...
        %     UnPackFunction(TrialFilter(x,:),y)),(1:size(TrialFilter,1))',...
        %     TrialFilter_Value);
    case 'Attention'
        RowNames = PassTable.TargetFilter;
end
PassTable.Properties.RowNames = RowNames;
%%
% PassTable = PassFunc(SessionName);

NumEntries = height(PassTable);

TableVariables = ["Block", "cell"];
NumTableVariables = size(TableVariables,1);

AdditionTable =  table('Size',[NumEntries,NumTableVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
%%
TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Area Names", "cell"]; ...
    ["Removal Counts", "table"]];

NumTableVariables = size(TableVariables,1);
%%
if isempty(Areas)
AllUniqueAreas = [];
if strcmp(TableType,'Full')

    for eidx = 1:NumEntries
        this_PassEntry = PassTable(eidx,:);
        [IAPathName,~,~] = cgg_generateImportanceAnalysisFileNames(...
            this_PassEntry,cfg_Epoch);
        
        IAPathNameNameExt = string(IAPathName) + ".mat";
        IAPathNameNameExt = replace(IAPathNameNameExt,"Fold_0","*");
        IADirectory = dir(IAPathNameNameExt);
        IAPathNameNameExts = fullfile({IADirectory.folder},{IADirectory.name});
        if ~isempty(IAPathNameNameExts)
        IA_Table = load(IAPathNameNameExts{1});
        IA_Table = IA_Table.IA_Table;
        this_AreaNames = IA_Table.("AreaNames");
        
        [~,MaxIDX] = max(cellfun(@numel, this_AreaNames));
        AllAreaRemovals = this_AreaNames{MaxIDX};
        this_AllUniqueAreas = unique(AllAreaRemovals);
        AllUniqueAreas = unique([AllUniqueAreas,string(this_AllUniqueAreas)]);
        end
    end
end
else
AllUniqueAreas = Areas;
end
%%

% if NumEntries > 1
%     this_Addition = cell(NumEntries,1);
% end

for eidx = 1:NumEntries
    this_PassEntry = PassTable(eidx,:);
[IAPathName,~,~] = cgg_generateImportanceAnalysisFileNames(...
    this_PassEntry,cfg_Epoch);

IAPathNameNameExt = string(IAPathName) + ".mat";
IAPathNameNameExt = replace(IAPathNameNameExt,"Fold_0","*");
IADirectory = dir(IAPathNameNameExt);
IAPathNameNameExts = fullfile({IADirectory.folder},{IADirectory.name});

IA_Table_Addition = [];
NumFolds = length(IAPathNameNameExts);

for fidx = 1:NumFolds
IA_Table = load(IAPathNameNameExts{fidx});
IA_Table = IA_Table.IA_Table;

this_AreaNames = IA_Table.("AreaNames");
this_Accuracy = num2cell(IA_Table.("Metric"));
this_WindowAccuracy = num2cell(IA_Table.("WindowMetric"),2);

this_NumRows = length(this_AreaNames);

if isempty(IA_Table_Addition)
IA_Table_Addition = table('Size',[this_NumRows,NumTableVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
end

this_UniqueAreaNames = cellfun(@(x) unique(x),this_AreaNames,"UniformOutput",false);

% [~,MaxIDX] = max(cellfun(@numel, this_AreaNames));
% AllAreaRemovals = this_AreaNames{MaxIDX};
% AllUniqueAreas = unique(AllAreaRemovals);

NumberRemovedTable = table();
for aidx = 1:length(AllUniqueAreas)
    this_AreaName = AllUniqueAreas{aidx};
    this_RemovalCount = cellfun(@(x) sum(ismember(x,this_AreaName)),this_AreaNames,"UniformOutput",true);
    NumberRemovedTable.(this_AreaName) = this_RemovalCount;
end

IA_Table_Addition.("Removal Counts") = NumberRemovedTable;

if all(cellfun(@isempty,IA_Table_Addition.("Area Names")))
IA_Table_Addition.("Area Names") = this_UniqueAreaNames;
else
% TODO: Add a check to make sure that the order is the same across the
% different folds. Currently assuming the removal of areas order is the
% same.
end

IA_Table_Addition.("Accuracy") = cellfun(@(x,y) [x;y],...
    IA_Table_Addition.("Accuracy"),this_Accuracy,"UniformOutput",false);
IA_Table_Addition.("Window Accuracy") = cellfun(@(x,y) [x;y],...
    IA_Table_Addition.("Window Accuracy"),this_WindowAccuracy,"UniformOutput",false);

end


% this_Addition{eidx} = IA_Table_Addition;
AdditionTable{eidx,"Block"} = {IA_Table_Addition};
AdditionTable.Properties.RowNames{eidx} = this_PassEntry.Properties.RowNames{1};
end
%%
AccuracyTable = [AccuracyTable,AdditionTable];
end
