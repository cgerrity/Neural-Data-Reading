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

if isfunction
IsBlock = CheckVararginPairs('IsBlock', false, varargin{:});
else
if ~(exist('IsBlock','var'))
IsBlock=false;
end
end

if isfunction
IsLabelClass = CheckVararginPairs('IsLabelClass', false, varargin{:});
else
if ~(exist('IsLabelClass','var'))
IsLabelClass=false;
end
end

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
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

if IsAttentional
    Legend_Size = 12;
end

%% Plotting Overwrites from Standard
TimeCut = [];
AccuracyCut = [];
OverwritePlotFolder = '';
Line_Width_Indicator = [];
FigureSizeOverwrite = [];
wantCI = [];
wantSignificanceBars = [];
Line_Width_Significance = [];
PlotColorsOverwrite = [];
WantSubTitle = [];
WantTitle = [];
LineStyle = [];

if isfield(cfg_OverwritePlot,'TimeCut')
TimeCut = cfg_OverwritePlot.TimeCut;
end
if isfield(cfg_OverwritePlot,'AccuracyCut')
AccuracyCut = cfg_OverwritePlot.AccuracyCut;
end
if isfield(cfg_OverwritePlot,'PlotFolder')
OverwritePlotFolder = cfg_OverwritePlot.PlotFolder;
end
if isfield(cfg_OverwritePlot,'Line_Width_Indicator')
Line_Width_Indicator = cfg_OverwritePlot.Line_Width_Indicator;
end
if isfield(cfg_OverwritePlot,'WindowFigureSizeOverwrite')
FigureSizeOverwrite = cfg_OverwritePlot.WindowFigureSizeOverwrite;
end
if isfield(cfg_OverwritePlot,'wantCI')
wantCI = cfg_OverwritePlot.wantCI;
end
if isfield(cfg_OverwritePlot,'wantSignificanceBars')
wantSignificanceBars = cfg_OverwritePlot.wantSignificanceBars;
end
if isfield(cfg_OverwritePlot,'Line_Width_Significance')
Line_Width_Significance = cfg_OverwritePlot.Line_Width_Significance;
end
if isfield(cfg_OverwritePlot,'PlotColorsOverwrite')
PlotColorsOverwrite = cfg_OverwritePlot.PlotColorsOverwrite;
end
if isfield(cfg_OverwritePlot,'WantSubTitle')
WantSubTitle = cfg_OverwritePlot.WantSubTitle;
end
if isfield(cfg_OverwritePlot,'WantTitle')
WantTitle = cfg_OverwritePlot.WantTitle;
end
if isfield(cfg_OverwritePlot,'LineStyle')
LineStyle = cfg_OverwritePlot.LineStyle;
end

%
ExtraInputs = {};

if ~isempty(Line_Width_Indicator)
    Line_Width = Line_Width_Indicator;
ExtraInputs{end+1} = 'Line_Width_Indicator';
ExtraInputs{end+1} = Line_Width_Indicator;
end
if ~isempty(wantCI)
ExtraInputs{end+1} = 'wantCI';
ExtraInputs{end+1} = wantCI;
end
if ~isempty(wantSignificanceBars)
ExtraInputs{end+1} = 'wantSignificanceBars';
ExtraInputs{end+1} = wantSignificanceBars;
end
if ~isempty(Line_Width_Significance)
ExtraInputs{end+1} = 'Line_Width_Significance';
ExtraInputs{end+1} = Line_Width_Significance;
end

%%

cfg.LoopType = cgg_setNaming(cfg.LoopType);
ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);

% RandomChance=cfg.RandomChance;
% MostCommon=cfg.MostCommon;
Stratified=cfg.Stratified;

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

% MATLABPlotColors = cfg_Plotting.MATLABPlotColors;
% PlotColors=MATLABPlotColors;
% if length(PlotNames) == 6
% PlotColors = num2cell(cfg_Plotting.Rainbow,2);
% end

if length(PlotNames) == 6
PlotColors = num2cell(cfg_Plotting.Rainbow,2);
elseif length(PlotNames)<8
PlotColors=cfg_Plotting.MATLABPlotColors;
else
PlotColors=num2cell(turbo(length(PlotNames)),2);
end

if ~isempty(PlotColorsOverwrite)
    PlotColors=PlotColorsOverwrite;
end


fig_plot=figure;
if isempty(FigureSizeOverwrite)
fig_plot.Units="normalized";
fig_plot.Position=[0,0,0.5,0.5];
else
fig_plot.Units="inches";
fig_plot.Position=[0,0,FigureSizeOverwrite];
end
fig_plot.Units="inches";
fig_plot.PaperUnits="inches";
PlotPaperSize=fig_plot.Position;
PlotPaperSize(1:2)=[];
fig_plot.PaperSize=PlotPaperSize;
drawnow;

% RangeAccuracyLower = -0.25;
RangeAccuracyUpper = 0.3;
RangeAccuracyLower = -0.05;
% RangeAccuracyUpper = 1;
% RangeAccuracyLower = 0.5;
% RangeAccuracyUpper = 0.8;
Tick_Size = 0.1;
Tick_Size_X = 0.5;

% if IsBlock
% RangeAccuracyLower = -0.01;
% RangeAccuracyUpper = 0.10;
% Tick_Size = 0.1;
% end

if IsAttentional
RangeAccuracyLower = -0.05;
RangeAccuracyUpper = 0.5;
Tick_Size = 0.1;
end

switch IsLabelClass
    case 'Label'
    RangeAccuracyLower = -0.1;
    RangeAccuracyUpper = 0.4;
    Tick_Size = 0.1;
    case 'Class'
    RangeAccuracyLower = -0.5;
    RangeAccuracyUpper = 1;
    Tick_Size = 0.1;
end

% if IsAttentional && IsBlock
% RangeAccuracyLower = -0.05;
% RangeAccuracyUpper = 0.2;
% Tick_Size = 0.1;
% end

WantCombined = any(ismember('Session Number', FullTable.Properties.VariableNames));
CountPerSample = '';
PlotSubTitle = '';
NumSessions = [];
IsGrouped = false;

if WantCombined
    NumSessions = cellfun(@(x) length(x),FullTable.("Session Number"));
    IsGrouped = all(diff(NumSessions) == 0);
    if IsGrouped
        PlotSubTitle = sprintf('[N = %d]',NumSessions(1));
    end
    if IsAttentional
RangeAccuracyLower = -0.05;
RangeAccuracyUpper = 0.3;
Tick_Size = 0.1;
    else
RangeAccuracyLower = -0.05;
RangeAccuracyUpper = 0.1;
Tick_Size = 0.05;
    end
    switch IsLabelClass
    case 'Label'
    RangeAccuracyLower = -0.1;
    RangeAccuracyUpper = 0.4;
    Tick_Size = 0.1;
    case 'Class'
    RangeAccuracyLower = -0.5;
    RangeAccuracyUpper = 1;
    Tick_Size = 0.1;
    end
    % CountPerSample = FullTable.NumSessions;
end
if isfield(cfg,'IA_Type')
    if isempty(PlotSubTitle)
        PlotSubTitle = sprintf('%s',cfg.IA_Type);
    else
        PlotSubTitle = sprintf('%s %s',cfg.IA_Type,PlotSubTitle);
    end
end

if ~isempty(WantSubTitle)
    if ~WantSubTitle
        PlotSubTitle = '';
    end
end

if ~isempty(WantTitle)
    if ischar(WantTitle) || isstring(WantTitle)
        PlotTitle = WantTitle;
    elseif ~WantTitle
        PlotTitle = '';
    end
end

if ~isempty(AccuracyCut)
    RangeAccuracyUpper = AccuracyCut(2);
    RangeAccuracyLower = AccuracyCut(1);
end

YLimLower=RangeAccuracyLower;
YLimUpper=RangeAccuracyUpper;

Y_Ticks = 0:Tick_Size:RangeAccuracyUpper;
X_Ticks = cfg.Time_Start:Tick_Size_X:cfg.Time_End;

SignificanceType = 'greater';

YLimits = [YLimLower,YLimUpper];

%%

[fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(Window_Accuracy_All,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames,'wantIndicatorNames',wantIndicatorNames,'Y_Tick_Label_Size',Y_Tick_Label_Size,'X_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors,'InFigure',fig_plot,'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,'CountPerSample',CountPerSample,'PlotSubTitle',PlotSubTitle,'SignificanceType',SignificanceType,'YLimits',YLimits,ExtraInputs{:});

hold on
% p_Random=yline(RandomChance);
% p_MostCommon=yline(MostCommon);
p_Stratified=yline(Stratified);
if isMATLABReleaseOlderThan("R2024a")
    uistack(p_Stratified,'bottom')
    cgg_setGraphicsLayer(p_Stratified,'Back');
else
    p_Stratified.Layer = 'bottom';
end
hold off

% p_MostCommon.LineWidth = Line_Width;
% p_Random.LineWidth = Line_Width;
p_Stratified.LineWidth = Line_Width;
p_Stratified.Alpha = 1;
p_Stratified.Color = [0.3,0.3,0.3];
% p_MostCommon.DisplayName = 'Most Common';
% p_Random.DisplayName = 'Random Chance';
p_Stratified.DisplayName = 'Stratified';

% p_Plots(NumLoops+1)=p_MostCommon;
% p_Plots(NumLoops+2)=p_Random;

NumColumns = 2;
if NumLoops < 4
    NumColumns = 1;
end

if ~isempty(LineStyle)
    for pidx = 1:length(p_Plots)
        this_LineStyle = LineStyle{pidx};
        if ~isempty(char(this_LineStyle))
        p_Plots(pidx).LineStyle = this_LineStyle;
        end
    end
end

if ~IsGrouped && ~isempty(NumSessions)
    for pidx = 1:length(p_Plots)
        p_Plots(pidx).DisplayName = sprintf("%s \\fontsize{%d}[N = %d]",p_Plots(pidx).DisplayName,round(Legend_Size/3),NumSessions(pidx));
    end
end

if NumLoops > 1
    legend(p_Plots,'Location','northeast','FontSize',Legend_Size,'NumColumns',NumColumns);
    legend('boxoff')
else
    legend([],'Location','northeast','FontSize',Legend_Size,'NumColumns',NumColumns);
    legend('boxoff')
    legend off;
end

% Current_Axis = gca;
% Current_Axis.YAxis.FontSize=Y_Tick_Label_Size;
% Current_Axis.XAxis.FontSize=Y_Tick_Label_Size;

% ylim([YLimLower,YLimUpper]);
xlim([cfg.Time_Start,cfg.Time_End]);
% ylim([0,1]);
% ylim([-0.05,0.3]);

if ~isempty(TimeCut)
    xlim(TimeCut);
end
% if ~isempty(AccuracyCut)
%     ylim(AccuracyCut);
% end

drawnow;

%%
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Sessions(1).temporarydir;

thisPlotFolder = 'Network Results';

if IsBlock
    thisPlotFolder = 'Block IA';
elseif IsLabelClass
    thisPlotFolder = 'Label-Class';
elseif ~isempty(OverwritePlotFolder)
    thisPlotFolder = OverwritePlotFolder;
end

cfg_Plot = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',cfg.Epoch,'PlotFolder',thisPlotFolder,'PlotSubFolder',cfg.Subset);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder',thisPlotFolder,'PlotSubFolder',cfg.Subset);
cfg_Plot.ResultsDir=cfg_tmp.TargetDir;

% if IsBlock
% cfg_Plot = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Block IA','PlotSubFolder',cfg.Subset);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Block IA','PlotSubFolder',cfg.Subset);
% cfg_Plot.ResultsDir=cfg_tmp.TargetDir; 
% else
% cfg_Plot = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Network Results','PlotSubFolder',cfg.Subset);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Network Results','PlotSubFolder',cfg.Subset);
% cfg_Plot.ResultsDir=cfg_tmp.TargetDir;
% end

% SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
% SavePath = cgg_getDirectory(cfg_Plot.ResultsDir,'SubFolder_1');
SavePath = string(cgg_getDirectory(cfg_Plot.ResultsDir,'SubFolder_1'));

% SaveName=['Windowed-Accuracy' cfg.LoopType ExtraSaveTerm];
SaveName="Windowed-Accuracy" + string(cfg.LoopType) + string(ExtraSaveTerm);

SaveNameExt=SaveName + ".pdf";
% SavePathNameExt=[SavePath filesep SaveNameExt];
SavePathNameExt=fullfile(SavePath, SaveNameExt);
exportgraphics(fig_plot,SavePathNameExt,'ContentType','vector');
% saveas(fig_plot,SavePathNameExt,'pdf');

% SaveNameExt=[SaveName '.png'];
% SavePathNameExt=[SavePath filesep SaveNameExt];
% saveas(fig_plot,SavePathNameExt,'png');

close(fig_plot);
% close all

end

