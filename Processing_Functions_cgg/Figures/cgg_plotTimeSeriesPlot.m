function [fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(InData,varargin)
%CGG_PLOTTIMESERIESPLOT Summary of this function goes here
%   Detailed explanation goes here

% fig_plot=figure;
% fig_plot.WindowState='maximized';
% fig_plot.PaperSize=[20 10];

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

% Line_Width = cfg_Plotting.Line_Width;

% X_Name_Size = cfg_Plotting.X_Name_Size;
% Y_Name_Size = cfg_Plotting.Y_Name_Size;
% Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;
% Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

MATLABPlotColors = cfg_Plotting.MATLABPlotColors;

%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
Time_Start = CheckVararginPairs('Time_Start', 0, varargin{:});
else
if ~(exist('Time_Start','var'))
Time_Start=0;
end
end

if isfunction
Time_End = CheckVararginPairs('Time_End', '', varargin{:});
else
if ~(exist('Time_End','var'))
Time_End='';
end
end

if isfunction
SamplingRate = CheckVararginPairs('SamplingRate', 1000, varargin{:});
else
if ~(exist('SamplingRate','var'))
SamplingRate=1000;
end
end

if isfunction
DataWidth = CheckVararginPairs('DataWidth', 100/SamplingRate, varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth=100/SamplingRate;
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', 50/SamplingRate, varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride=50/SamplingRate;
end
end

if isfunction
X_Name = CheckVararginPairs('X_Name', 'Time (s)', varargin{:});
else
if ~(exist('X_Name','var'))
X_Name='Time (s)';
end
end

if isfunction
Y_Name = CheckVararginPairs('Y_Name', 'Value', varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name='Value';
end
end

if iscell(Y_Name)
Y_Name_PlotTitle = Y_Name{1};
else
Y_Name_PlotTitle = Y_Name;
end

if isfunction
Y_Ticks = CheckVararginPairs('Y_Ticks', '', varargin{:});
else
if ~(exist('Y_Ticks','var'))
Y_Ticks='';
end
end

if isfunction
X_Ticks = CheckVararginPairs('X_Ticks', '', varargin{:});
else
if ~(exist('X_Ticks','var'))
X_Ticks='';
end
end

if isfunction
Y_Tick_Label_Size = CheckVararginPairs('Y_Tick_Label_Size', cfg_Plotting.Label_Size, varargin{:});
else
if ~(exist('Y_Tick_Label_Size','var'))
Y_Tick_Label_Size=cfg_Plotting.Label_Size;
end
end

if isfunction
X_Tick_Label_Size = CheckVararginPairs('X_Tick_Label_Size', cfg_Plotting.Label_Size, varargin{:});
else
if ~(exist('X_Tick_Label_Size','var'))
X_Tick_Label_Size=cfg_Plotting.Label_Size;
end
end

if isfunction
Y_TickDir = CheckVararginPairs('Y_TickDir', '', varargin{:});
else
if ~(exist('Y_TickDir','var'))
Y_TickDir='';
end
end

if isfunction
X_TickDir = CheckVararginPairs('X_TickDir', '', varargin{:});
else
if ~(exist('X_TickDir','var'))
X_TickDir='';
end
end

if isfunction
PlotTitle = CheckVararginPairs('PlotTitle', sprintf('%s over Time',Y_Name_PlotTitle), varargin{:});
else
if ~(exist('PlotTitle','var'))
PlotTitle=sprintf('%s over Time',Y_Name_PlotTitle);
end
end

if isfunction
DecisionIndicatorColors = CheckVararginPairs('DecisionIndicatorColors', {'k','k','k'}, varargin{:});
else
if ~(exist('DecisionIndicatorColors','var'))
DecisionIndicatorColors={'k','k','k'};
end
end

if isfunction
wantDecisionIndicators = CheckVararginPairs('wantDecisionIndicators', true, varargin{:});
else
if ~(exist('wantDecisionIndicators','var'))
wantDecisionIndicators=true;
end
end

if isfunction
PlotNames = CheckVararginPairs('PlotNames', {'Plot'}, varargin{:});
else
if ~(exist('PlotNames','var'))
PlotNames={'Plot'};
end
end

if isfunction
PlotColors = CheckVararginPairs('PlotColors', MATLABPlotColors, varargin{:});
else
if ~(exist('PlotColors','var'))
PlotColors=MATLABPlotColors;
end
end

if isfunction
wantTiled = CheckVararginPairs('wantTiled', false, varargin{:});
else
if ~(exist('wantTiled','var'))
wantTiled=false;
end
end

if isfunction
wantSubPlot = CheckVararginPairs('wantSubPlot', false, varargin{:});
else
if ~(exist('wantSubPlot','var'))
wantSubPlot=false;
end
end

if isfunction
InFigure = CheckVararginPairs('InFigure', '', varargin{:});
else
if ~(exist('InFigure','var'))
InFigure='';
end
end

if isfunction
DecisionIndicatorLabelOrientation = CheckVararginPairs('DecisionIndicatorLabelOrientation', 'horizontal', varargin{:});
else
if ~(exist('DecisionIndicatorLabelOrientation','var'))
DecisionIndicatorLabelOrientation='horizontal';
end
end

if isfunction
wantFeedbackIndicators = CheckVararginPairs('wantFeedbackIndicators', false, varargin{:});
else
if ~(exist('wantFeedbackIndicators','var'))
wantFeedbackIndicators=false;
end
end

if isfunction
wantIndicatorNames = CheckVararginPairs('wantIndicatorNames', true, varargin{:});
else
if ~(exist('wantIndicatorNames','var'))
wantIndicatorNames=true;
end
end

if isfunction
wantCI = CheckVararginPairs('wantCI', true, varargin{:});
else
if ~(exist('wantCI','var'))
wantCI=true;
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
YValues_STD = CheckVararginPairs('YValues_STD', '', varargin{:});
else
if ~(exist('YValues_STD','var'))
YValues_STD='';
end
end

if isfunction
CountPerSample = CheckVararginPairs('CountPerSample', '', varargin{:});
else
if ~(exist('CountPerSample','var'))
CountPerSample='';
end
end

if isfunction
DataTransform = CheckVararginPairs('DataTransform', '', varargin{:});
else
if ~(exist('DataTransform','var'))
DataTransform='';
end
end

if isfunction
ErrorMetric = CheckVararginPairs('ErrorMetric', '', varargin{:});
else
if ~(exist('ErrorMetric','var'))
ErrorMetric='';
end
end

if isfunction
Line_Width = CheckVararginPairs('Line_Width', cfg_Plotting.Line_Width, varargin{:});
else
if ~(exist('Line_Width','var'))
Line_Width=cfg_Plotting.Line_Width;
end
end

if isfunction
Title_Size = CheckVararginPairs('Title_Size', cfg_Plotting.Title_Size, varargin{:});
else
if ~(exist('Title_Size','var'))
Title_Size=cfg_Plotting.Title_Size;
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
X_Name_Size = CheckVararginPairs('X_Name_Size', cfg_Plotting.X_Name_Size, varargin{:});
else
if ~(exist('X_Name_Size','var'))
X_Name_Size=cfg_Plotting.X_Name_Size;
end
end

if isfunction
WantLegend = CheckVararginPairs('WantLegend', true, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=true;
end
end

if isfunction
Error_FaceAlpha = CheckVararginPairs('Error_FaceAlpha', cfg_Plotting.Error_FaceAlpha, varargin{:});
else
if ~(exist('Error_FaceAlpha','var'))
Error_FaceAlpha=cfg_Plotting.Error_FaceAlpha;
end
end

if isfunction
Error_EdgeAlpha = CheckVararginPairs('Error_EdgeAlpha', cfg_Plotting.Error_EdgeAlpha, varargin{:});
else
if ~(exist('Error_EdgeAlpha','var'))
Error_EdgeAlpha=cfg_Plotting.Error_EdgeAlpha;
end
end

if isfunction
Legend_Size = CheckVararginPairs('Legend_Size', cfg_Plotting.Legend_Size, varargin{:});
else
if ~(exist('Legend_Size','var'))
Legend_Size=cfg_Plotting.Legend_Size;
end
end

if isfunction
Indicator_Size = CheckVararginPairs('Indicator_Size', cfg_Plotting.Indicator_Size, varargin{:});
else
if ~(exist('Indicator_Size','var'))
Indicator_Size=cfg_Plotting.Indicator_Size;
end
end
%%
if ~isempty(InFigure)
fig_plot=InFigure;
clf(InFigure);
elseif ~wantSubPlot
fig_plot=figure;
fig_plot.Units="normalized";
fig_plot.Position=[0,0,1,1];
fig_plot.Units="inches";
fig_plot.PaperUnits="inches";
PlotPaperSize=fig_plot.Position;
PlotPaperSize(1:2)=[];
fig_plot.PaperSize=PlotPaperSize;
else
fig_plot=gcf;
end
%%

if wantTiled
    tiledlayout(1,1)
    nexttile
end

%% Get Information from Input Data
% Get the information like number of times series to average, number of
% windows, and number of plots

SameNumWindows=true;
if isnumeric(InData)
    [NumExamples,NumWindows,NumPlots] = size(InData);
elseif iscell(InData)
    NumPlots = length(InData);
    NumExamples=NaN(1,NumPlots);
    NumWindows=NaN(1,NumPlots);
    for pidx=1:NumPlots
        [NumExamples(pidx),NumWindows(pidx)] = size(InData{pidx});
    end
    if range(NumWindows) ~= 0
        SameNumWindows=false;
    else
        NumWindows=NumWindows(1);
    end
end

%%

if numel(PlotNames) < NumPlots
    NumPlotNames=numel(PlotNames);
    for pidx=1:NumPlots
        PlotNames{pidx}=PlotNames{mod(pidx-1,NumPlotNames)+1};
    end
end

if numel(PlotColors) < NumPlots
    PlotColors = repmat(PlotColors,1,ceil(NumPlots/numel(PlotColors)));
end

%%

if isempty(Time_End)
    Time_Start_Adjusted = Time_Start+DataWidth/2;
    if SameNumWindows
        this_Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
    else
        % Insert time for different window lengths
    end
else
    if SameNumWindows
        this_Time = linspace(Time_Start,Time_End,NumWindows);
    else
        % Insert time for different window lengths
    end
end

TimeOffset = Time_Start+1.5;

%% Plotting

p_Plots = NaN(1,NumPlots);
p_Error = NaN(1,NumPlots);

p_Plots = [];
p_Error = [];

YMax=-Inf;
YMin=Inf;

    for pidx=1:NumPlots


        if isnumeric(InData)
            this_Data=InData(:,:,pidx);
        elseif iscell(InData)
            this_Data=InData{pidx};
        end
        if isnumeric(ErrorMetric)
            this_ErrorMetric=ErrorMetric(:,:,pidx);
        elseif iscell(ErrorMetric)
            this_ErrorMetric=ErrorMetric{pidx};
        else
            this_ErrorMetric = ErrorMetric;
        end

    [this_p_Plot,this_p_Error] = cgg_plotLinePlotWithShadedError(this_Time,this_Data,PlotColors{pidx},'wantCI',wantCI,'SignificanceValue',SignificanceValue,'YValues_STD',YValues_STD,'CountPerSample',CountPerSample,'DataTransform',DataTransform,'ErrorMetric',this_ErrorMetric,'Error_FaceAlpha',Error_FaceAlpha,'Error_EdgeAlpha',Error_EdgeAlpha);

    this_p_Plot.LineWidth = Line_Width;
    this_p_Plot.Color = PlotColors{pidx};
    this_p_Plot.DisplayName = PlotNames{pidx};
    YMax = max([YMax,this_p_Plot.YData]);
    YMin = min([YMin,this_p_Plot.YData]);
    % p_Plots(pidx) = this_p_Plot;
    % p_Error(pidx) = this_p_Error;
    p_Plots = [p_Plots,this_p_Plot];
    p_Error = [p_Error,this_p_Error];
    end
    hold off

    YRange=YMax-YMin;
    YUpper=YMax+(RangeFactorUpper*YRange);
    YLower=YMin-(RangeFactorLower*YRange);

    if YUpper == YLower
        YUpper = YUpper + 0.00001;
    end

    if wantDecisionIndicators
    cgg_plotDecisionEpochIndicators(DecisionIndicatorColors,...
        'DecisionIndicatorLabelOrientation',...
        DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'TimeOffset',TimeOffset,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Line_Width',Line_Width,'Indicator_Size',Indicator_Size);
    end

    if WantLegend
    legend(p_Plots,'Location','best','FontSize',Legend_Size);
    end

    %%

    if iscell(Y_Name)
        Y_Label = cell(1,length(Y_Name));
        for yidx = 1:length(Y_Name)
            Y_Label{yidx} = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name{yidx});
        end
    else
        Y_Label = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name);
    end
    if iscell(X_Name)
        X_Label = cell(1,length(X_Name));
        for xidx = 1:length(X_Name)
            X_Label{xidx} = sprintf('{\\fontsize{%d}%s}',X_Name_Size,X_Name{xidx});
        end
    else
        X_Label = sprintf('{\\fontsize{%d}%s}',X_Name_Size,X_Name);
    end
    if iscell(PlotTitle)
        Title_Label = cell(1,length(PlotTitle));
        for tidx = 1:length(PlotTitle)
            Title_Label{tidx} = sprintf('{\\fontsize{%d}%s}',Title_Size,PlotTitle{tidx});
        end
    else
        Title_Label = sprintf('\\fontsize{%d}%s',Title_Size,PlotTitle);
    end

    % xlabel(X_Name,'FontSize',X_Name_Size);
    % ylabel(Y_Name,'FontSize',Y_Name_Size);
    % title(PlotTitle,'FontSize',Title_Size);
    xlabel(X_Label);
    ylabel(Y_Label);
    if ~isempty(PlotTitle)
    title(Title_Label);
    end

%%

    % fig_plot.CurrentAxes.XAxis.FontSize=X_Tick_Label_Size;
    % fig_plot.CurrentAxes.YAxis.FontSize=Y_Tick_Label_Size;

    ylim([YLower,YUpper]);
    if ~(isempty(Y_Ticks) || any(isnan(Y_Ticks)))
    yticks(Y_Ticks);
    end
    if ~(isempty(X_Ticks) || any(isnan(X_Ticks)))
    xticks(X_Ticks);
    end

    if ~isempty(Y_TickDir)
    fig_plot.CurrentAxes.YAxis.TickDirection=Y_TickDir;
    end
    if ~isempty(X_TickDir)
    fig_plot.CurrentAxes.XAxis.TickDirection=X_TickDir;
    end

    if isempty(X_Tick_Label_Size)
        xticklabels({});
    else
    fig_plot.CurrentAxes.XAxis.FontSize=X_Tick_Label_Size;
    end
    if isempty(Y_Tick_Label_Size)
        yticklabels({});
    else
    fig_plot.CurrentAxes.YAxis.FontSize=Y_Tick_Label_Size;
    end

end

