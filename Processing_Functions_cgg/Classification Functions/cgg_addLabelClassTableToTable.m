function OutTable = cgg_addLabelClassTableToTable(InTable,LabelClassTables,TableType)
%CGG_ADDLABELCLASSTABLETOTABLE Summary of this function goes here
%   Detailed explanation goes here

OutTable = InTable;

%%
LabelIDX = isnan(LabelClassTables.Class);

switch TableType
    case 'Label'
        TypeTables = LabelClassTables(LabelIDX,:);
        VariableName = "Label Table";
    case 'Class'
        TypeTables = LabelClassTables(~LabelIDX,:);
        VariableName = "Class Table";
    otherwise
        TypeTables = LabelClassTables(LabelIDX,:);
        VariableName = "Label Table";
end

%%
NumLabelClass = height(TypeTables);

TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]];

NumVariables = size(TableVariables,1);
AppendTable = table('Size',[NumLabelClass,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%%
RowNames = strings(NumLabelClass,1);
for lcidx = 1:NumLabelClass
    this_Entry = TypeTables(lcidx,:);
    this_Table = this_Entry.FullAccuracyTable{1};
    this_Label = this_Entry.Label;
    this_Class = this_Entry.Class;
    if isnan(this_Class)
        this_RowName = sprintf("Label %d",this_Label);
    else
        this_RowName = sprintf("Label %d ~ Class %d",this_Label,this_Class);
    end
    AppendTable(lcidx,"Accuracy") = this_Table.Accuracy;
    AppendTable(lcidx,"Window Accuracy") = this_Table.("Window Accuracy");
    RowNames(lcidx) = this_RowName;
end
AppendTable.Properties.RowNames = RowNames;

%%
OutTable.(VariableName) = {AppendTable};
end

