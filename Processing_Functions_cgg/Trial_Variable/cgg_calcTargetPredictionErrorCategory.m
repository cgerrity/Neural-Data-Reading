function [PredictionErrorCategories,CategoryNames] = cgg_calcTargetPredictionErrorCategory(Identifiers_Table,varargin)
%CGG_CALCTARGETPREDICTIONERRORCATEGORY Summary of this function goes here
%   Detailed explanation goes here

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
% NumBins = 3;
% RangeType = 'EqualValue';
SplitVariableName = 'Dimensionality';
TargetVariableName = 'Prediction Error Target';

if isempty(Identifiers_Table)
    PredictionErrorCategories = [];
    return;
end

% Initialize the output array with zeros.
% 0 corresponds to "Not Learned" (or NaNs).
PredictionErrorCategories = zeros(height(Identifiers_Table), 1);

% Get the list of unique SplitVariables (Dimensionality) to loop over
uniqueSplitVariables = unique(Identifiers_Table.(SplitVariableName));

% Loop through each unique SplitVariable
for spidx = 1:length(uniqueSplitVariables)
    thisSplitVariable = uniqueSplitVariables(spidx);
    
    % Identify rows for this specific SplitVariable
    splitMask = Identifiers_Table.(SplitVariableName) == thisSplitVariable;
    
    % --- Split 1: Positive Values (>= 0) ---
    % We bin positive errors separately so "Low" means "Low Positive"
    posMask = splitMask & (Identifiers_Table.(TargetVariableName) >= 0);
    
    if any(posMask)
        posValues = Identifiers_Table.(TargetVariableName)(posMask);
        [posBins, ~] = cgg_calcBinsForVariable(posValues, NumBins, RangeType);
        PredictionErrorCategories(posMask) = posBins;
    end
    
    % --- Split 2: Negative Values (< 0) ---
    % We bin negative errors separately based on ABSOLUTE value.
    % "Low" means "Low Absolute Value" (closest to 0).
    % "High" means "High Absolute Value" (most negative).
    negMask = splitMask & (Identifiers_Table.(TargetVariableName) < 0);
    
    if any(negMask)
        negValues = Identifiers_Table.(TargetVariableName)(negMask);
        % Use absolute values for binning so 1=Small Error, 3=Large Error
        [negBins, ~] = cgg_calcBinsForVariable(abs(negValues), NumBins, RangeType);
        PredictionErrorCategories(negMask) = negBins;
    end
end