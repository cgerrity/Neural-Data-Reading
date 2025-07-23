function Array = cgg_extractData(Array)
%CGG_EXTRACTDATA Summary of this function goes here
%   Detailed explanation goes here
% Ensure that the extractdata function works even when the data is not a
% dlarray. This function removes the need to creat if statements each time
% an array could be a dlarray and conversion to a regular array is
% required.
if isdlarray(Array)
Array = extractdata(Array);
end
end

