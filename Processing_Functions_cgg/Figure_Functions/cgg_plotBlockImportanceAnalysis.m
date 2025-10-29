function cgg_plotBlockImportanceAnalysis(FullTable,cfg)
%CGG_PLOTBLOCKIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here


for seidx = 1:height(FullTable)
SubsetName = FullTable.Properties.RowNames{seidx};
cgg_plotBlockAccuracy(FullTable,cfg,'SubsetName',SubsetName);
cgg_plotBlockWindowedAccuracy(FullTable,cfg,'SubsetName',SubsetName);
cgg_plotSplitBlockAccuracy(FullTable,cfg);
end
end

