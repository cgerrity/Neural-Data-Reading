function cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,wantPaperSized,varargin)
%CGG_PLOTSINGLEPAPERSUBFIGURE Summary of this function goes here
%   Detailed explanation goes here

% cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',wantPaperSized);

isfunction=exist('varargin','var');

if isfunction
WantPaperFormat = CheckVararginPairs('WantPaperFormat', true, varargin{:});
else
if ~(exist('WantPaperFormat','var'))
WantPaperFormat=true;
end
end

if isfunction
WantDecisionCentered = CheckVararginPairs('WantDecisionCentered', false, varargin{:});
else
if ~(exist('WantDecisionCentered','var'))
WantDecisionCentered=false;
end
end

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',WantPaperFormat,'WantDecisionCentered',WantDecisionCentered);

if isfunction
FigureTitle = CheckVararginPairs('FigureTitle', '', varargin{:});
else
if ~(exist('FigureTitle','var'))
FigureTitle='';
end
end

if isfunction
FigureTitle_Size = CheckVararginPairs('FigureTitle_Size', cfg_Plotting.Title_Size, varargin{:});
else
if ~(exist('FigureTitle_Size','var'))
FigureTitle_Size=cfg_Plotting.Title_Size;
end
end

if isfunction
Y_Name = CheckVararginPairs('Y_Name', '', varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name='';
end
end

if isfunction
Y_Name_Size = CheckVararginPairs('Y_Name_Size', cfg_Plotting.Y_Name_Size, varargin{:});
else
if ~(exist('Y_Name_Size','var'))
Y_Name_Size=cfg_Plotting.Y_Name_Size;
end
end

if isfunction
TileSpacing = CheckVararginPairs('TileSpacing', "tight", varargin{:});
else
if ~(exist('TileSpacing','var'))
TileSpacing="tight";
end
end

if wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.OuterPosition=[0,0,4,4];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
% PlotPaperSize=InFigure.Position;
PlotPaperSize=InFigure.OuterPosition;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
InFigure.PaperPosition=InFigure.OuterPosition*1.5;
InFigure.PaperPositionMode='manual';
clf(InFigure);
else
InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
% InFigure.Visible='off';
clf(InFigure);
end

%%
NumPlots = length(PlotFunc);

% TiledPlot = tiledlayout(TiledLayout(1),TiledLayout(2));
TiledPlot = tiledlayout(TiledLayout(1),TiledLayout(2),'TileSpacing',TileSpacing);

if ~isempty(FigureTitle)
title(TiledPlot,FigureTitle,'FontSize',FigureTitle_Size);
end

if ~isempty(Y_Name)
ylabel(TiledPlot,Y_Name,'FontSize',Y_Name_Size);
end

for pidx = 1:NumPlots
this_Tile = nexttile(NextTileInformation(pidx,1),NextTileInformation(pidx,2:3));
this_PlotFunc = PlotFunc{pidx};
this_PlotFunc(InFigure);
end

end

