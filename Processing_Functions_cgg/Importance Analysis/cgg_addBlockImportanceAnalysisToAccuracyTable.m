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

%%
switch TableType
    case 'Full'
        RowNames = PassTable.SessionName;
    case 'Split'
        TrialFilter = PassTable.TrialFilter;
        TrialFilter_Value = PassTable.TrialFilter_Value;
        RowNames = arrayfun(@(x,y) cgg_getSplitTableRowNames(...
            TrialFilter(x,:),y),(1:size(TrialFilter,1))',...
            TrialFilter_Value);
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
    ["Area Names", "cell"]];

NumTableVariables = size(TableVariables,1);
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

this_AreaNames = cellfun(@(x) unique(x),this_AreaNames,"UniformOutput",false);

if all(cellfun(@isempty,IA_Table_Addition.("Area Names")))
IA_Table_Addition.("Area Names") = this_AreaNames;
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

AccuracyTable = [AccuracyTable,AdditionTable];
end
