function [DimensionPlots,TileIDX_Dimension,OutTiled_Plot] = cgg_plotClassificationProbabilities(PlotData,Time,InTiled_Plot,InTiledIDX,InSpan)
%CGG_PLOTCLASSIFICATIONPROBABILITIES Summary of this function goes here
%   Detailed explanation goes here

Line_Width_ProgressMonitor = 1;

%% Classification Proabilities

NumDimensions = length(PlotData);

DimensionPlots = cell(1,NumDimensions);
TileIDX_Dimension = cell(1,NumDimensions);

nexttile(InTiled_Plot,InTiledIDX,InSpan);
OutTiled_Plot=tiledlayout(InTiled_Plot,NumDimensions,1,"TileSpacing","none","Padding","tight");
OutTiled_Plot.Layout.Tile = InTiledIDX;
axis off

%%
for didx = 1:NumDimensions

this_PlotData = PlotData{didx};
this_ExampleIDX = 1;
this_Row = didx;

this_TileIDX=tilenum(OutTiled_Plot,this_Row,this_ExampleIDX);
nexttile(OutTiled_Plot,this_TileIDX,[1,1]);

p_DimensionTraining=plot(Time,this_PlotData,'DisplayName',sprintf('Dimension %d',didx),'LineWidth',Line_Width_ProgressMonitor);

ylim([0,1]);
set(gca,'YTick',[]);
if didx<NumDimensions
set(gca,'XTick',[]);
end

DimensionPlots{didx} = p_DimensionTraining;

TileIDX_Dimension{didx} = this_TileIDX;
end

end

