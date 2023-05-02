function [binnedData, means, sems] = BinRmData(data, binSize)

nObs = size(data,2);
nBins = ceil(nObs / binSize);
if mod(nBins,1) ~= 0
    error('Specified bin size does not produce integer number of bins.');
end
% 
% binnedData = nan(size(data,1), nBins);
% 
% for i = 1:nBins
%     binnedData(:,i) = nanmean(data(:,(i-1)*binSize+1:i*binSize),2);
% end

binnedData = discretize(data, nBins, 'includededge', 'right');

means = nanmean(binnedData);
sems = nanstd(binnedData) ./ sqrt(sum(~isnan(binnedData)));