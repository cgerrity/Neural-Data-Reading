function cgg_plotBlockImportanceAnalysis(FullTable,cfg,varargin)
%CGG_PLOTBLOCKIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantSameSessionNumbers = CheckVararginPairs('WantSameSessionNumbers', true, varargin{:});
else
if ~(exist('WantSameSessionNumbers','var'))
WantSameSessionNumbers=true;
end
end

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
end
end

if isfield(cfg_OverwritePlot,'AreaColors')
cfg_OverwritePlot.PlotColorsOverwrite = cfg_OverwritePlot.AreaColors;
end

for seidx = 1:height(FullTable)
SubsetName = FullTable.Properties.RowNames{seidx};
cgg_plotBlockAccuracy(FullTable,cfg,'SubsetName',SubsetName,'WantSameSessionNumbers',WantSameSessionNumbers,'cfg_OverwritePlot',cfg_OverwritePlot);
cgg_plotBlockWindowedAccuracy(FullTable,cfg,'SubsetName',SubsetName,'WantSameSessionNumbers',WantSameSessionNumbers,'cfg_OverwritePlot',cfg_OverwritePlot);
cgg_plotSplitBlockAccuracy(FullTable,cfg,'WantSameSessionNumbers',WantSameSessionNumbers,'cfg_OverwritePlot',cfg_OverwritePlot);
end
end

