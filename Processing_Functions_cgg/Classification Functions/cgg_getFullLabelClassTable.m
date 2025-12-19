function LabelClassTables = cgg_getFullLabelClassTable(CM_Table,cfg,varargin)
%CGG_GETFULLLABELCLASSTABLE Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
end

if isfunction
Identifiers_Table = CheckVararginPairs('Identifiers_Table', [], varargin{:});
else
if ~(exist('Identifiers_Table','var'))
Identifiers_Table=[];
end
end
%%

Subset = CheckVararginPairs('Subset', '', varargin{:});
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
[Subset,~] = cgg_verifySubset(Subset,wantSubset);

%%
if isempty(Identifiers_Table)
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
AdditionalTarget = CheckVararginPairs('AdditionalTarget', {}, varargin{:});

Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset,'Epoch',Epoch,'AdditionalTarget',AdditionalTarget,'Subset',Subset);
fprintf('@@@ Label-Class Table Loaded Identifiers Table for %s\n',Subset);
end
%% Generate ClassNames

if strcmp(Target, 'Dimension')
    TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
else
    TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,Target);
end
TrueValue=Identifiers_Table{:,TrueValueIDX};
Identifiers_Table.TrueValue = TrueValue;
[ClassNames,~,~,~] = cgg_getClassesFromCMTable(Identifiers_Table);

fprintf('??? Generated Class Names for Label-Class Table for %s\n',Subset);
%% Initialize Label-Class Table

NumEntries = sum(cellfun(@(x) length(x)+1,ClassNames));

TableVariables = [["FullAccuracyTable", "cell"]; ...
    ["Label", "double"]; ...
    ["Class", "double"]];

NumVariables = size(TableVariables,1);
LabelClassTables = table('Size',[NumEntries,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%%
TableCounter = 1;
for lidx = 1:length(ClassNames)
    this_Label = lidx;
    this_LabelFilter = sprintf("Label %d",this_Label);
    this_varargin = varargin;
    this_varargin{end + 1} = 'LabelClassFilter';
    this_varargin{end + 1} = this_LabelFilter;
    fprintf('??? Running Full Accuracy Table for %s\n',this_LabelFilter);
    FullTable_tmp = cgg_getFullAccuracyTable(CM_Table,cfg,this_varargin{:});

    LabelClassTables(TableCounter,:) = {{FullTable_tmp},this_Label,NaN};
    TableCounter = TableCounter + 1;

    this_Classes = ClassNames{lidx};
    for cidx = 1:length(this_Classes)
        this_Class = this_Classes(cidx);
        this_ClassFilter = sprintf("Class %d",this_Class);
        this_LabelClassFilter = sprintf("%s ~ %s",this_LabelFilter, ...
            this_ClassFilter);
        this_varargin = varargin;
        this_varargin{end + 1} = 'LabelClassFilter';
        this_varargin{end + 1} = this_LabelClassFilter;
        fprintf('??? Running Full Accuracy Table for %s\n',this_LabelClassFilter);
        FullTable_tmp = cgg_getFullAccuracyTable(CM_Table,cfg,this_varargin{:});

        LabelClassTables(TableCounter,:) = {{FullTable_tmp},this_Label,this_Class};
        TableCounter = TableCounter + 1;
    end
end

end

