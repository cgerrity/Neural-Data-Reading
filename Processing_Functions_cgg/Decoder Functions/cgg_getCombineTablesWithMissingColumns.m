function OutTable = cgg_getCombineTablesWithMissingColumns(Table1,Table2)
%CGG_GETCOMBINETABLESWITHMISSINGCOLUMNS Summary of this function goes here
%   Detailed explanation goes here

Table1VarNames=Table1.Properties.VariableNames;
Table2VarNames=Table2.Properties.VariableNames;

Table1MissingVarIDX=~ismember(Table1VarNames,Table2VarNames);
Table2MissingVarIDX=~ismember(Table2VarNames,Table1VarNames);

Table1MissingVar=Table2VarNames(Table2MissingVarIDX);
Table2MissingVar=Table1VarNames(Table1MissingVarIDX);

for vidx=1:numel(Table1MissingVar)
    thisMissingVar=Table1MissingVar{vidx};
    Table1.(thisMissingVar)(:)=NaN;
end
for vidx=1:numel(Table2MissingVar)
    thisMissingVar=Table2MissingVar{vidx};
    Table2.(thisMissingVar)(:)=NaN;
end

OutTable=[Table1;Table2];

end

