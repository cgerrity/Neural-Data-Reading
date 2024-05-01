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

%%
RandomChance=cfg.RandomChance;
MostCommon=cfg.MostCommon;

ExtraSaveTerm=cfg.ExtraSaveTerm;

Time_Start=cfg.Time_Start;
SamplingFrequency=cfg.SamplingFrequency;
DataWidth=cfg.DataWidth/SamplingFrequency;
WindowStride=cfg.WindowStride/SamplingFrequency;
X_Name='Time (s)';
Y_Name='Accuracy';
PlotTitle='Accuracy Over Time';

Window_Accuracy_All=FullTable.('Window Accuracy');
PlotNames=FullTable.Properties.RowNames;

NumLoops=length(PlotNames);

[fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(Window_Accuracy_All,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames);

hold on
p_Random=yline(RandomChance);
p_MostCommon=yline(MostCommon);
hold off

p_MostCommon.LineWidth = Line_Width;
p_Random.LineWidth = Line_Width;
p_MostCommon.DisplayName = 'Most Common';
p_Random.DisplayName = 'Random Chance';

p_Plots(NumLoops+1)=p_MostCommon;
p_Plots(NumLoops+2)=p_Random;

legend(p_Plots,'Location','best','FontSize',Legend_Size);

YLimLower=RangeAccuracyLower;
YLimUpper=RangeAccuracyUpper;

ylim([YLimLower,YLimUpper]);

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

