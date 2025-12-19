function OutTable = cgg_getUniqueAbleTableValues(InTable,VariableName,PackingType)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
OutTable = InTable;

switch PackingType
    case 'Pack'
Value_Numeric = InTable.(VariableName);
Value_Numeric = cellfun(@(x) fillmissing(x,'constant',Inf),Value_Numeric,'UniformOutput',false);
Value_String = cellfun(@(x) join(string(x),'/'),Value_Numeric);
OutTable.(VariableName) = Value_String;
    case 'Unpack'
Value_String = InTable.(VariableName);
Value_Numeric = arrayfun(@(x) str2double(split(x,'/'))',Value_String,"UniformOutput",false);
for vidx = 1:length(Value_Numeric)
    Value_Numeric{vidx}(isinf(Value_Numeric{vidx})) = NaN;
end
OutTable.(VariableName) = Value_Numeric;
end
end