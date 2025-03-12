function cgg_plotWindowedAccuracy(FullTable,cfg)
%CGG_PLOTWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here

%%
cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Line_Width = cfg_Plotting.Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

RangeAccuracyUpper = cfg_Plotting.RangeAccuracyUpper;
RangeAccuracyLower = cfg_Plotting.RangeAccuracyLower;

ErrorCapSize = cfg_Plotting.ErrorCapSize;

Tick_Size = 2;
Y_Tick_Label_Size = 24;
wantIndicatorNames = false;
Y_Name_Size = 24;
Legend_Size = 12;

%%
RandomChance=cfg.RandomChance;
MostCommon=cfg.MostCommon;

ExtraSaveTerm=cfg.ExtraSaveTerm;

Time_Start=cfg.Time_Start;
SamplingFrequency=cfg.SamplingFrequency;
DataWidth=cfg.DataWidth/SamplingFrequency;
WindowStride=cfg.WindowStride/SamplingFrequency;
X_Name='Time (s)';
Y_Name = 'Accuracy';
PlotTitle = 'Accuracy Over Time';
if contains(cfg.MatchType,'Scaled')
Y_Name = {'Scaled', 'Balanced Accuracy'};
PlotTitle = 'Normalized Accuracy Over Time';
end
PlotTitle = '';

Window_Accuracy_All=FullTable.('Window Accuracy');
PlotNames=FullTable.Properties.RowNames;

NumLoops=length(PlotNames);

MATLABPlotColors = cfg_Plotting.MATLABPlotColors;
PlotColors=MATLABPlotColors;
if length(PlotNames) == 6
PlotColors = num2cell(cfg_Plotting.Rainbow,2);
end


fig_plot=figure;
fig_plot.Units="normalized";
fig_plot.Position=[0,0,0.5,0.5];
fig_plot.Units="inches";
fig_plot.PaperUnits="inches";
PlotPaperSize=fig_plot.Position;
PlotPaperSize(1:2)=[];
fig_plot.PaperSize=PlotPaperSize;

RangeAccuracyLower = -0.05;
RangeAccuracyUpper = 0.2;
Tick_Size = 0.05;

Y_Ticks = 0:Tick_Size:RangeAccuracyUpper;

[fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(Window_Accuracy_All,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames,'wantIndicatorNames',wantIndicatorNames,'Y_Tick_Label_Size',Y_Tick_Label_Size,'X_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors,'InFigure',fig_plot,'Y_Name_Size',Y_Name_Size,'Y_Ticks',Y_Ticks);

hold on
p_Random=yline(RandomChance);
p_MostCommon=yline(MostCommon);
hold off

p_MostCommon.LineWidth = Line_Width;
p_Random.LineWidth = Line_Width;
p_MostCommon.DisplayName = 'Most Common';
p_Random.DisplayName = 'Random Chance';

% p_Plots(NumLoops+1)=p_MostCommon;
% p_Plots(NumLoops+2)=p_Random;

if NumLoops > 1
legend(p_Plots,'Location','northeast','FontSize',Legend_Size,'NumColumns',2);
legend('boxoff')
else
    legend([],'Location','northeast','FontSize',Legend_Size,'NumColumns',2);
    legend('boxoff')
    legend off;
end

YLimLower=RangeAccuracyLower;
YLimUpper=RangeAccuracyUpper;

% Current_Axis = gca;
% Current_Axis.YAxis.FontSize=Y_Tick_Label_Size;
% Current_Axis.XAxis.FontSize=Y_Tick_Label_Size;

ylim([YLimLower,YLimUpper]);
% ylim([0,1]);
% ylim([-0.05,0.3]);
drawnow;

%%

cfg_Plot = cgg_generateDecodingFolders('TargetDir',cfg.TargetDir,...
    'Epoch',cfg.Epoch,'Accuracy',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'Accuracy',true);
cfg_Plot.ResultsDir=cfg_tmp.TargetDir;

SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
SaveName=['Windowed_Accuracy' ExtraSaveTerm '_Type_' cfg.LoopType];

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[SavePath filesep SaveNameExt];

saveas(fig_plot,SavePathNameExt,'pdf');

close all

end

