function smoothedData = SlidingWindowForward(data, window)

smoothedData = zeros(length(data),1);
for i = 1:length(data)
    smoothedData(i) = nanmean(data(i:min([length(data), i+window-1])));
end