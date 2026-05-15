function [DifferentVariables,MissingVariables] = cgg_compareStruct(Struct1,Struct2)
%CGG_COMPARESTRUCT Summary of this function goes here
%   Detailed explanation goes here

% Struct1 = Struct1;
FieldNames = fieldnames(Struct1);
for fidx = 1:length(FieldNames)
this_FieldName = FieldNames{fidx};
this_Variable = Struct1.(this_FieldName);
this_Variable = cgg_convertArrayToString(this_Variable);
Struct1.(this_FieldName) = this_Variable;
end

% Struct2 = Struct2;
FieldNames = fieldnames(Struct2);
for fidx = 1:length(FieldNames)
this_FieldName = FieldNames{fidx};
this_Variable = Struct2.(this_FieldName);
this_Variable = cgg_convertArrayToString(this_Variable);
Struct2.(this_FieldName) = this_Variable;
end

Table1 = struct2table(Struct1,"AsArray",true);
Table2 = struct2table(Struct2,"AsArray",true);

[Table1,Table2,MissingFromTable1,MissingFromTable2] = cgg_fillMissingTableVariables(Table1,Table2,"MissingVariable");


% diffTable = setdiff(Table1, Table2);

MissingVariables = [MissingFromTable1, MissingFromTable2];

DiffTable = Table1 ~= Table2;

DifferentVariables = DiffTable.Properties.VariableNames(DiffTable{:,:});
% Convert back to struct if needed
% diffStruct = table2struct(diffTable);
end