function String = cgg_convertArrayToString(Array)
%CGG_CONVERTARRAYTOSTRING Summary of this function goes here
%   Detailed explanation goes here

if isstruct(Array)
    String = join(string(table2cell(struct2table(Array)))," ~ ");
else
    String = string(Array);
end

% String = Array;
% String = string(Array);

if (length(Array) ~= 1 && ~ischar(Array))
    % Array = string(Array);
    String = sprintf("[%s]",String);
elseif ismissing(String)
    String = sprintf("[%s]",Array);
end

end

