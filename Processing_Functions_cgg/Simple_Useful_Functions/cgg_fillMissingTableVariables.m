function [Table1,Table2] = cgg_fillMissingTableVariables(Table1,Table2,MissingValue)
%CGG_FILLMISSINGTABLEVARIABLES Summary of this function goes here
%   Detailed explanation goes here

MissingFromTable1 = setdiff(Table2.Properties.VariableNames, Table1.Properties.VariableNames);
MissingFromTable2 = setdiff(Table1.Properties.VariableNames, Table2.Properties.VariableNames);


for midx = 1:length(MissingFromTable1)
    Table1.(MissingFromTable1{midx}) = repmat(MissingValue,[height(Table1),1]);
end

for midx = 1:length(MissingFromTable2)
    Table2.(MissingFromTable2{midx}) = repmat(MissingValue,[height(Table2),1]);
end

end

