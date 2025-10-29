function PermutedArray = cgg_getWeightedPermutation(Array,Weights)
%CGG_GETWEIGHTEDPERMUTATION Summary of this function goes here
%   Detailed explanation goes here
% Permutes the elements of a vector A based on the weights W.
% A: a vector of elements to permute.
% W: a vector of positive weights corresponding to each element in A.

% Check that the inputs are valid vectors of the same length
if ~isvector(Array) || ~isvector(Weights) || numel(Array) ~= numel(Weights) || ~isnumeric(Weights)
    error('Inputs must be vectors of the same length, and weights must be numeric.');
end
if any(Weights < 0)
    error('Weights must be non-negative.');
end

PermutedArray = zeros(size(Array)); % Pre-allocate the output array

ZeroWeights = Weights == 0;
NumZeroWeights = sum(ZeroWeights);
PermutedArray(end-NumZeroWeights+1:end) = Array(ZeroWeights);
Array(ZeroWeights) = [];
Weights(ZeroWeights) = [];

n = numel(Array);
remaining_elements = Array;
remaining_weights = Weights;

%% Perform a Fisher-Yates-style shuffle with weighting
for i = 1:n
    % Sample an element's index based on the remaining weights
    current_idx = randsample(1:numel(remaining_elements), 1, true, remaining_weights);

    % Move the selected element to the output array
    PermutedArray(i) = remaining_elements(current_idx);

    % Remove the selected element and its weight from the pool
    remaining_elements(current_idx) = [];
    remaining_weights(current_idx) = [];
end

end
