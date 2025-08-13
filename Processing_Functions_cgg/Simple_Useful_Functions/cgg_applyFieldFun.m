function [result] = cgg_applyFieldFun(func, struct1, struct2)
%CGG_APPLYFIELDFUN Summary of this function goes here

%
% Syntax:
%   result = applyToMatchingFields(func, struct1, struct2)
%
% Inputs:
%   func    - Function handle to apply to matching fields
%   struct1 - First input structure
%   struct2 - Second input structure
%
% Output:
%   result  - Structure with same field names containing function results

% Get field names from both structures
fields1 = fieldnames(struct1);
fields2 = fieldnames(struct2);

% Find matching field names
matchingFields = intersect(fields1, fields2);

% Initialize result structure
result = struct();

% Apply function to each matching field
for i = 1:length(matchingFields)
    fieldName = matchingFields{i};
    result.(fieldName) = func(struct1.(fieldName), struct2.(fieldName));
end
end

