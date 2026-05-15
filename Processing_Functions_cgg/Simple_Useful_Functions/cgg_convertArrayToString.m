function String = cgg_convertArrayToString(Array)
%CGG_CONVERTARRAYTOSTRING Summary of this function goes here
%   Detailed explanation goes here

if isstruct(Array)
    ArrayTable = struct2table(Array);
    ArrayCell = table2cell(ArrayTable);
    ArrayNames = ArrayTable.Properties.VariableNames;
    ArrayString = strings(size(ArrayCell,1),size(ArrayCell,2));
    for rcidx = 1:size(ArrayCell,1)
    for cidx = 1:size(ArrayCell,2)
        ArrayString(rcidx,cidx) = cgg_convertArrayToString(ArrayCell{rcidx,cidx});
        % ArrayString(rcidx,cidx) = string(ArrayNames{cidx}) + ":" + ArrayString(rcidx,cidx);
        % if isstruct(ArrayCell{cidx})
        % ArrayString(cidx) = cgg_convertArrayToString(ArrayCell{cidx});
        % else
        % ArrayString(cidx) = string(ArrayCell{cidx});
        % end
    end
    % ArrayString(cidx) = join(ArrayString(rcidx,cidx)," ~ ");
    end

    ArrayName = join(string(ArrayNames),":");
    ArrayString = "{" + join(ArrayString,":",2) + "}";
    String = ArrayName + "[" + join(ArrayString,",") + "]";
else
    String = string(Array);
end

% String = Array;
% String = string(Array);
if iscell(Array) && length(Array) ~= 1 && any(ismissing(String))
try
    Array = cell2mat(Array);
catch
end
end

if (length(Array) ~= 1 && ~ischar(Array)) && ~any(ismissing(String))
    % Array = string(Array);
    String = sprintf("[%s]",String);
elseif any(ismissing(String)) && ~isstruct(Array)
    String = sprintf("[%s]",Array);
elseif any(ismissing(String)) && isstruct(Array)
    String = "MissingStruct";
end

end

