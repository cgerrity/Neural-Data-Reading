function Combinations = cgg_getCombinations(Set, NumElements, NumCombinations)
%CGG_GETCOMBINATIONS Summary of this function goes here
%   Detailed explanation goes here
% Thanks ChatGPT!
    % Get the number of unique elements in the set
    SetSize = length(Set);

    % Calculate the maximum possible number of combinations
    MaxCombinations = nchoosek(SetSize, NumElements);

    % If requested combinations exceed possible, return max possible combinations
    if NumCombinations >= MaxCombinations
        Combinations = nchoosek(Set, NumElements);
        return;
    end
    
    % Initialize the matrix to store combinations
    Combinations = zeros(NumCombinations, NumElements);

    % Use a set to track generated combinations (for uniqueness)
    Generated = containers.Map();

    %% Randomly generate combinations one by one
    Count = 0;
    while Count < NumCombinations
        % Randomly sample numEntries unique elements from vec
        RandCombination = sort(randsample(Set, NumElements));

        % Convert the combination to a string to check for uniqueness
        CombStr = mat2str(RandCombination);

        % If this combination is not generated yet, store it
        if ~isKey(Generated, CombStr)
            Count = Count + 1;
            Combinations(Count, :) = RandCombination;
            Generated(CombStr) = true; % Mark this combination as generated
        end
    end

   Combinations = unique(Combinations,'rows'); 
end

