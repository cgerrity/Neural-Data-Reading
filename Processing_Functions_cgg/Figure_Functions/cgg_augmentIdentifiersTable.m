function cgg_augmentIdentifiersTable(cfg,InFunc,VariableName)
%CGG_AUGMENTIDENTIFIERSTABLE Summary of this function goes here
%   Detailed explanation goes here
%%
Identifiers_TablePath = cgg_getDirectory(cfg.ResultsDir,'Processing');
Identifiers_TableNameExt = 'Identifiers_Table.mat';
Identifiers_TablePathNameExt = [Identifiers_TablePath filesep ...
    Identifiers_TableNameExt];

if isfile(Identifiers_TablePathNameExt)
    Identifiers_Table = load(Identifiers_TablePathNameExt);
    Identifiers_Table = Identifiers_Table.Identifiers_Table;
end

%%
if ~any(ismember(Identifiers_Table.Properties.VariableNames,VariableName))
    
    Output = InFunc(Identifiers_Table);
    Identifiers_Table.(VariableName) = Output;
    %
    save(Identifiers_TablePathNameExt,"Identifiers_Table","-v7.3");
end
end

