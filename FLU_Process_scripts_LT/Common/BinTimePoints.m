function [bins, edges, binnedTimes] = BinTimePoints(times, nBins, direction)

if strcmpi(direction, 'left')
    tempTimes = times * -1;
else
    tempTimes = times;
end

[bins, edges] = discretize(tempTimes, nBins, 'includededge', 'right');

%if there are a smaller number of time points than the number of bins,
%jam everything towards bin 1 (or the last bin if coming from the left).
if length(tempTimes) <= nBins
    for t = 1:length(tempTimes)
        if t <= nBins
            bins(t) = tempTimes(t);
            edges(t+1) = tempTimes(t);
        end
    end
end


if strcmpi(direction, 'left')
    bins = nBins - bins + 1;
    edges = flip(edges) * -1;
end

binnedTimes = cell(1,nBins);

for iBin = 1:nBins
    binnedTimes{iBin} = times(bins == iBin);
end