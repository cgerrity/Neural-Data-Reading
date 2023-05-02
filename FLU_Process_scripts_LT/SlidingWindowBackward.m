function smoothedData = SlidingWindowBackward(data, window)

smoothedData = zeros(length(data),1);
for i = 1:length(data)
    smoothedData(i) = nanmean(data(max([1, i-window+1]):i));
end