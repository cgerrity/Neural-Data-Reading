function OutTable = cgg_addCorrespondingVariablesToTable(InTable,AdditionalTable,SubTableName,ValueName,varargin)
%CGG_ADDCORRESPONDINGVARIABLESTOTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NonTableTerm = CheckVararginPairs('NonTableTerm', [], varargin{:});
else
if ~(exist('NonTableTerm','var'))
NonTableTerm=[];
end
end

if isfunction
IncludeNaNValues = CheckVararginPairs('IncludeNaNValues', true, varargin{:});
else
if ~(exist('IncludeNaNValues','var'))
IncludeNaNValues=true;
end
end

%%

OutTable = InTable;
SubTable = AdditionalTable.(SubTableName){1};

RowNamesSubTable = SubTable.Properties.RowNames;
RowNamesOutTable = OutTable.(SubTableName){1}.Properties.RowNames;

VariableNamesSubTable = SubTable.Properties.VariableNames;
HasValue = any(ismember(VariableNamesSubTable,ValueName));
NaNCheckValueName = VariableNamesSubTable{1};

for ridx = 1:length(RowNamesSubTable)
    IDX = ismember(RowNamesOutTable,RowNamesSubTable{ridx});
    if HasValue
        SubTableEntry = SubTable{ridx,ValueName};
        if iscell(SubTableEntry)
            SubTableEntry = SubTableEntry{1};
        end
        NaNCheck = SubTableEntry;
    else
        SubTableEntry = NonTableTerm;
        NaNCheck = SubTable{ridx,NaNCheckValueName};
        if iscell(NaNCheck)
            NaNCheck = NaNCheck{1};
        end
    end

    ValueIsNaN = all(isnan(NaNCheck),'all');

    if ValueIsNaN && ~IncludeNaNValues
        continue
    end

OutTable = cgg_addBlockValueToTable(OutTable,SubTableName, ...
    IDX,ValueName,SubTableEntry);
end

end

