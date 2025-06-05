function IndicesSorted = cgg_sortModelNamesForParameterSweep(SweepAllNames)
%CGG_SORTMODELNAMESFORPARAMETERSWEEP Summary of this function goes here
%   Detailed explanation goes here

BestIDX = contains(SweepAllNames,'*');
[~,IndicesSorted] = sort(SweepAllNames);

this_IDX = find(contains(SweepAllNames,'Logistic Regression'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'PCA'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'Feedforward'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'GRU'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'LSTM'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'Convolutional'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'Multi-Filter'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

this_IDX = find(contains(SweepAllNames,'Resnet'));
if ~isempty(this_IDX)
IndicesSorted(IndicesSorted == this_IDX) = [];
IndicesSorted = [IndicesSorted;this_IDX];
end

IndicesSorted(IndicesSorted == find(BestIDX)) = [];
IndicesSorted = [find(BestIDX);IndicesSorted];

end

