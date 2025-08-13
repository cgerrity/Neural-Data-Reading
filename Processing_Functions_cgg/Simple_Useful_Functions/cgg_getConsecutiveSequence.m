function consecutive_sequences = cgg_getConsecutiveSequence(X)
%CGG_GETCONSECUTIVESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
X = X(:);
breaks = find(diff(X) ~= 1); % Finds indices where the sequence breaks
start_indices = [1; breaks + 1]; % Start of each sequence
end_indices = [breaks; numel(X)]; % End of each sequence

consecutive_sequences = cell(1, length(start_indices));
for i = 1:length(start_indices)
    consecutive_sequences{i} = X(start_indices(i):end_indices(i));
end

end

