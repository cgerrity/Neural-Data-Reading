function [ValueCategories,CategoryNames] = cgg_calcTargetValueCategories(Identifiers_Table,varargin)
%CGG_CALCTARGETVALUECATEGORIES Calculates bin categories for RL Target values
%   separately for each dimensionality.

isfunction=exist('varargin','var');

if isfunction
NumBins = CheckVararginPairs('NumBins', 3, varargin{:});
else
if ~(exist('NumBins','var'))
NumBins=3;
end
end

if isfunction
RangeType = CheckVararginPairs('RangeType', 'EqualValue', varargin{:});
else
if ~(exist('RangeType','var'))
RangeType='EqualValue';
end
end

CategoryNames = {"Not Learned","Low","Medium","High"};
SplitVariableName = 'Dimensionality';

if isempty(Identifiers_Table)
    ValueCategories = [];
    return;
end

% Initialize the output array with zeros.
% 0 corresponds to "Not Learned" (or NaNs) based on the helper logic.
ValueCategories = zeros(height(Identifiers_Table), 1);

% Get the list of unique SplitVariables to loop over
uniqueSplitVariables = unique(Identifiers_Table.(SplitVariableName));

% Loop through each unique dimensionality
for spidx = 1:length(uniqueSplitVariables)
    thisSplitVariable = uniqueSplitVariables(spidx);
    
    % 1. Find the row indices corresponding to the current SplitVariable
    currentRows = Identifiers_Table.(SplitVariableName) == thisSplitVariable;
    
    % 2. Extract the 'Value RL Target' values for these specific rows
    VariableValues = Identifiers_Table.("Value RL Target")(currentRows);
    
    % 3. Calculate bins using the helper function
    % We request 3 bins ('EqualCount'), which returns 1 (Low), 2 (Med), 3 (High).
    % The helper returns 0 for NaNs.
    [BinnedVariable, ~] = cgg_calcBinsForVariable(VariableValues, NumBins, RangeType);
    
    % 4. Assign the calculated bins back to the specific rows in the main vector
    ValueCategories(currentRows) = BinnedVariable;
end

end