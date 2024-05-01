function ClassPlots = cgg_plotSingleClassificationProbability(PlotData,Time,InTiled_Plot,SubTiled_Plot,InTiledIDX,SubTiledIDX,InSpan,LastDim)
%CGG_PLOTCLASSIFICATIONPROBABILITIES Summary of this function goes here
%   Detailed explanation goes here

Line_Width_ProgressMonitor = 1;

%% Classification Proability

NumClasses = height(PlotData);

nexttile(InTiled_Plot,InTiledIDX,InSpan);
SubTiled_Plot.Layout.Tile = InTiledIDX;

nexttile(SubTiled_Plot,SubTiledIDX,[1,1]);

ClassPlots = cell(1,NumClasses);

%%

this_Data = PlotData{:,"Data"};
Name = PlotData{:,"Name"};
% if iscell(this_Data)
%     this_Data = this_Data{1};
% end
% if iscell(this_Name)
%     this_Name = this_Name{1};
% end

%%

this_Name = Name(1);
if iscell(this_Name)
this_Name = this_Name{1};
end
if isnumeric(this_Name)
this_Name = num2str(this_Name);
end

p_ClassTraining=plot(Time,this_Data{1},'DisplayName',this_Name,'LineWidth',Line_Width_ProgressMonitor);

ClassPlots{1} = p_ClassTraining;

hold on
for cidx = 2:NumClasses

this_Name = Name(cidx);
if iscell(this_Name)
this_Name = this_Name{1};
end
if isnumeric(this_Name)
this_Name = num2str(this_Name);
end

this_PlotData = this_Data{cidx};

p_ClassTraining=plot(Time,this_PlotData,'DisplayName',this_Name,'LineWidth',Line_Width_ProgressMonitor);

ClassPlots{cidx} = p_ClassTraining;



end

hold off

set(gca,'YTick',[]);

% if ~(LastDim && cidx == NumClasses)
if ~(LastDim)
set(gca,'XTick',[]);
end

ylim([0,1]);

this_legend = legend;
this_legend.Location = "best";

end

