function cgg_plotLabelClass(FullTable,cfg,varargin)
%CGG_PLOTLABELCLASS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
WantSameSessionNumbers = CheckVararginPairs('WantSameSessionNumbers', false, varargin{:});
else
if ~(exist('WantSameSessionNumbers','var'))
WantSameSessionNumbers=false;
end
end

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
end
end

if isfunction
WantConsistentSize = CheckVararginPairs('WantConsistentSize', true, varargin{:});
else
if ~(exist('WantConsistentSize','var'))
WantConsistentSize=true;
end
end

if isfield(cfg_OverwritePlot,'AreaColors')
cfg_OverwritePlot.PlotColorsOverwrite = cfg_OverwritePlot.AreaColors;
end

if WantConsistentSize
cfg_OverwritePlot.WindowFigureSizeOverwrite = [10,10];
cfg_OverwritePlot.BarFigureSizeOverwrite = [14,18];
end

% for seidx = 1:height(FullTable)
% SubsetName = FullTable.Properties.RowNames{seidx};
cgg_plotLabelClassAccuracy(FullTable,cfg,'WantSameSessionNumbers',WantSameSessionNumbers,'cfg_OverwritePlot',cfg_OverwritePlot);
cgg_plotLabelClassWindowedAccuracy(FullTable,cfg,'WantSameSessionNumbers',WantSameSessionNumbers,'cfg_OverwritePlot',cfg_OverwritePlot);
cgg_plotSplitLabelClassAccuracy(FullTable,cfg,'WantSameSessionNumbers',WantSameSessionNumbers,'cfg_OverwritePlot',cfg_OverwritePlot);
% end
end

