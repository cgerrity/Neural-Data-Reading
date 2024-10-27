function cgg_plotMultiplePlotWrapper(PlotFunc,InputTable,AdditionalTerm,wantPaperSized)
%CGG_PLOTMULTIPLEPLOTWRAPPER Summary of this function goes here
%   Detailed explanation goes here

if wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
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

NumPlots = length(PlotFunc);

TiledPlot = tiledlayout(NumPlots,1);

for pidx = 1:NumPlots
this_Tile = nexttile;
this_PlotFunc = PlotFunc{pidx};
this_PlotFunc(InputTable,AdditionalTerm,InFigure);
end

end

