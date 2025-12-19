function FullTable = cgg_addLabelClassTableToFullTable(FullTable,LabelClassTables)
%CGG_ADDLABELCLASSTABLETOFULLTABLE Summary of this function goes here
%   Detailed explanation goes here

FullTable = cgg_addLabelClassTableToTable(FullTable,LabelClassTables,'Label');
FullTable = cgg_addLabelClassTableToTable(FullTable,LabelClassTables,'Class');

SubTableNames = ["Split Table", "Attentional Table"];

for stidx = 1:length(SubTableNames)
    SubTableName = SubTableNames(stidx);
    HasSubTable = any(ismember(FullTable.Properties.VariableNames,SubTableName));

    if HasSubTable
    
        SubTable = FullTable.(SubTableName){1};
        SubTableRowNames = SubTable.Properties.RowNames;
        SubTable.("Label Table") = cell(height(SubTable), 1);
        SubTable.("Class Table") = cell(height(SubTable), 1);
    
        for stridx = 1:length(SubTableRowNames)
            SubTableRowName = SubTableRowNames{stridx};
            SubTableRow = SubTable(SubTableRowName,:);
            SubLabelClassTable = LabelClassTables;
            SubLabelClassTable{:,"FullAccuracyTable"} = rowfun(@(x) x{1}.(SubTableName){1}(SubTableRowName,:),LabelClassTables,"InputVariables","FullAccuracyTable","OutputVariableNames","FullAccuracyTable","OutputFormat","cell");
            
            %% Recursion
            % Not even a little joking when I tested and absolutely rocked this
            % recursion first time, no errors, and doubled checked the output
            % matched intention. Pure disbelief
            SubTableRow = cgg_addLabelClassTableToFullTable(SubTableRow,SubLabelClassTable);
            %%
            SubTable(SubTableRowName,:) = SubTableRow;
        end
    
        FullTable.(SubTableName){1} = SubTable;
    
    end

end

end

