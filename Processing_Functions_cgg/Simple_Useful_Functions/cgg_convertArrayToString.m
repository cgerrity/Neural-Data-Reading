function String = cgg_convertArrayToString(Array)
%CGG_CONVERTARRAYTOSTRING Summary of this function goes here
%   Detailed explanation goes here

% String = Array;
String = string(Array);

if (length(Array) ~= 1 && ~ischar(Array))
    Array = string(Array);
    String = sprintf("[%s]",Array);
elseif ismissing(String)
    String = sprintf("[%s]",Array);
end

end

