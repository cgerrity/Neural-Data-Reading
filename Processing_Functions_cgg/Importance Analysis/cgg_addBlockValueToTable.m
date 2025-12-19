function OutTable = cgg_addBlockValueToTable(InTable,TableName,IDX,ValueName,Value)
%CGG_ADDBLOCKVALUETOTABLE Summary of this function goes here
%   Detailed explanation goes here

OutTable = InTable;

if istable(Value)
OutEntry = OutTable.(TableName){1}{IDX,ValueName};
this_EntryTable = OutEntry{1};
if isempty(this_EntryTable)
    OutTable.(TableName){1}{IDX,ValueName}{1} = ...
        [OutTable.(TableName){1}{IDX,ValueName}{1};Value];
else
    this_EntryTable = OutEntry{1};
    VariableNames = this_EntryTable.Properties.VariableNames;
    for nidx = 1:length(VariableNames)
        this_VariableName = VariableNames{nidx};
        this_EntryTable.(this_VariableName){1} = ...
            [this_EntryTable.(this_VariableName){1};Value.(this_VariableName){1}];
    end
    OutEntry{1} = this_EntryTable;
    OutTable.(TableName){1}{IDX,ValueName} = OutEntry;
end
else
OutTable.(TableName){1}{IDX,ValueName}{1} = ...
    [OutTable.(TableName){1}{IDX,ValueName}{1};Value];
end

end

