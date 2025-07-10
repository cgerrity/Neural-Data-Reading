function cgg_plotWindowedAccuracy(FullTable,cfg,varargin)
%CGG_PLOTWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsAttentional = CheckVararginPairs('IsAttentional', false, varargin{:});
else
if ~(exist('IsAttentional','var'))
IsAttentional=false;
end
end

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
% Y_Tick_Label_Size = 24;
Y_Tick_Label_Size = 18;
wantIndicatorNames = false;
Y_Name_Size = 20;
% Legend_Size = 12;
Legend_Size = 14;
X_Name_Size = Y_Name_Size;

%%
RandomChance=cfg.RandomChance;
MostCommon=cfg.MostCommon;
Stratified=cfg.Stratified;

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
if contains(cfg.MatchType,'MicroAccuracy')
Y_Name{2} = 'Accuracy';
end
PlotTitle = 'Normalized Accuracy Over Time';
end
PlotTitle = '';
if isfield(cfg,'PlotTitle')
if ~isempty(cfg.PlotTitle)
PlotTitle = cfg.PlotTitle;
end
end

Window_Accuracy_All=FullTable.('Window Accuracy');
PlotNames=FullTable.Properties.RowNames;
% disp(PlotNames)
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
RangeAccuracyUpper = 0.3;
% RangeAccuracyLower = -0.05;
% RangeAccuracyUpper = 1;
% RangeAccuracyLower = 0.5;
% RangeAccuracyUpper = 0.8;
Tick_Size = 0.1;
Tick_Size_X = 0.5;

if IsAttentional
RangeAccuracyLower = -0.05;
RangeAccuracyUpper = 0.5;
Tick_Size = 0.1;
end

Y_Ticks = 0:Tick_Size:RangeAccuracyUpper;
X_Ticks = cfg.Time_Start:Tick_Size_X:cfg.Time_End;

[fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(Window_Accuracy_All,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames,'wantIndicatorNames',wantIndicatorNames,'Y_Tick_Label_Size',Y_Tick_Label_Size,'X_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors,'InFigure',fig_plot,'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks);

hold on
p_Random=yline(RandomChance);
p_MostCommon=yline(MostCommon);
% p_Stratified=yline(Stratified);
hold off

p_MostCommon.LineWidth = Line_Width;
p_Random.LineWidth = Line_Width;
% p_Stratified.LineWidth = Line_Width;
p_MostCommon.DisplayName = 'Most Common';
p_Random.DisplayName = 'Random Chance';
% p_Stratified.DisplayName = 'Stratified';

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
xlim([cfg.Time_Start,cfg.Time_End]);
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
exportgraphics(fig_plot,SavePathNameExt,'ContentType','vector');
% saveas(fig_plot,SavePathNameExt,'pdf');

% SaveNameExt=[SaveName '.png'];
% SavePathNameExt=[SavePath filesep SaveNameExt];
% saveas(fig_plot,SavePathNameExt,'png');

close all

end

