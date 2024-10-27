function [OutRemovalTable,TablesMatch] = cgg_checkRemovalTablesAcrossFolds(IAPathNameExt,Folds,varargin)
%CGG_CHECKREMOVALTABLESACROSSFOLDS Summary of this function goes here
%   Detailed explanation goes here

%%
FixNaNFunc = @(x) cellfun(@(x) cgg_setNaNToValue(x,0),x,'UniformOutput',false);
CheckTableFunc =@(Table) varfun(FixNaNFunc,Table,"InputVariables",["AreaRemoved","ChannelRemoved","LatentRemoved"]);
AreTablesSameFunc = @(Table1,Table2) ...
    isequal(CheckTableFunc(Table1),CheckTableFunc(Table2));

%%

NumFolds = length(Folds);
% InitialRemovalTable = [];
TablesMatch = true;

Fold = Folds(1);
this_IAPathNameExt = sprintf(IAPathNameExt,Fold);
InitialRemovalTable = cgg_getRemovalTable(this_IAPathNameExt);
OutRemovalTable = InitialRemovalTable;

for fidx = 2:NumFolds
    Fold = Folds(fidx);
    this_IAPathNameExt = sprintf(IAPathNameExt,Fold);
    
    RemovalTable = cgg_getRemovalTable(this_IAPathNameExt);

    if istable(RemovalTable)
        this_TablesMatch = AreTablesSameFunc(RemovalTable,InitialRemovalTable);
        TablesMatch = TablesMatch && this_TablesMatch;
    else
        TablesMatch = false;
    end

    if istable(RemovalTable)
        OutRemovalTable = RemovalTable;
    end

end

end

