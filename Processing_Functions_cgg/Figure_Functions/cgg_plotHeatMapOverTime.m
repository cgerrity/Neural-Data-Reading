function [fig_plot,p_Plots,c_Plot] = cgg_plotHeatMapOverTime(InData,varargin)
%CGG_PLOTHEATMAPOVERTIME Summary of this function goes here
%   Detailed explanation goes here

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
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

if isfunction
Z_Name = CheckVararginPairs('Z_Name', '', varargin{:});
else
if ~(exist('Z_Name','var'))
Z_Name='';
end
end

if isfunction
PlotTitle = CheckVararginPairs('PlotTitle', sprintf('%s over Time',Y_Name), varargin{:});
else
if ~(exist('PlotTitle','var'))
PlotTitle=sprintf('%s over Time',Y_Name);
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
YRange = CheckVararginPairs('YRange', '', varargin{:});
else
if ~(exist('YRange','var'))
YRange='';
end
end

if isfunction
Y_Ticks = CheckVararginPairs('Y_Ticks', '', varargin{:});
else
if ~(exist('Y_Ticks','var'))
Y_Ticks='';
end
end

if isfunction
Y_TickLabel = CheckVararginPairs('Y_TickLabel', '', varargin{:});
else
if ~(exist('Y_TickLabel','var'))
Y_TickLabel='';
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
ZLimits = CheckVararginPairs('ZLimits', '', varargin{:});
else
if ~(exist('ZLimits','var'))
ZLimits='';
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
TimeOffset = CheckVararginPairs('TimeOffset', 0, varargin{:});
else
if ~(exist('TimeOffset','var'))
TimeOffset=0;
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
Line_Width = CheckVararginPairs('Line_Width', cfg_Plotting.Line_Width, varargin{:});
else
if ~(exist('Line_Width','var'))
Line_Width=cfg_Plotting.Line_Width;
end
end

if isfunction
Tick_Size_Time = CheckVararginPairs('Tick_Size_Time', cfg_Plotting.Tick_Size_Time, varargin{:});
else
if ~(exist('Tick_Size_Time','var'))
Tick_Size_Time=cfg_Plotting.Tick_Size_Time;
end
end

if isfunction
Tick_Size_Z = CheckVararginPairs('Tick_Size_Z', cfg_Plotting.Tick_Size_Z, varargin{:});
else
if ~(exist('Tick_Size_Z','var'))
Tick_Size_Z=cfg_Plotting.Tick_Size_Z;
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
Title_Size = CheckVararginPairs('Title_Size', cfg_Plotting.Title_Size, varargin{:});
else
if ~(exist('Title_Size','var'))
Title_Size=cfg_Plotting.Title_Size;
end
end

%% Parameters

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

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
% Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;

Tick_Size_Channels=cfg_Plotting.Tick_Size_Channels;
% Tick_Size_Time=cfg_Plotting.Tick_Size_Time;

RangeFactorHeatUpper = cfg_Plotting.RangeFactorHeatUpper;
RangeFactorHeatLower = cfg_Plotting.RangeFactorHeatLower;

%% Get Information from Input Data
% Get the information like number of times series to average, number of
% windows, and number of plots

SameNumWindows=true;
if isnumeric(InData)
    [NumYAxis,NumWindows,NumPlots] = size(InData);
elseif iscell(InData)
    NumPlots = size(InData);
    NumExamples=NaN(1,NumPLots);
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

if isempty(Time_End)
    Time_Start_Adjusted = Time_Start+DataWidth/2+TimeOffset;
    if SameNumWindows
        this_Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
    else
        % Insert time for different window lengths
    end
else
    if SameNumWindows
        this_Time = linspace(Time_Start+TimeOffset,Time_End+TimeOffset,NumWindows);
    else
        % Insert time for different window lengths
    end
end

if isempty(YRange)
YRange=1:NumYAxis;
end
if isempty(Y_Ticks)
Y_Ticks=[1,Tick_Size_Channels:Tick_Size_Channels:NumYAxis];
end
if isempty(Y_TickLabel)
Y_TickLabel=[1,Tick_Size_Channels:Tick_Size_Channels:NumYAxis];
end

%%

if isempty(ZLimits)

ZMax=max(InData(:));
ZMin=min(InData(:));

if isnan(ZMax)
    ZMax=0;
end
if isnan(ZMin)
    ZMin=ZMax;
end

ZRange=ZMax-ZMin;
ZUpper=ZMax+(RangeFactorHeatUpper*ZRange);
ZLower=ZMin-(RangeFactorHeatLower*ZRange);
if ZUpper==ZLower


    ZUpper=ZUpper+0.00001;
end
else
ZUpper=ZLimits(2);
ZLower=ZLimits(1);
end
%%

p_Plots=imagesc(this_Time,YRange,InData);

% axis square;
fig_plot.CurrentAxes.YDir='normal';
fig_plot.CurrentAxes.XDir='normal';
fig_plot.CurrentAxes.XAxis.TickLength=[0,0];
fig_plot.CurrentAxes.YAxis.TickLength=[0,0];
fig_plot.CurrentAxes.XAxis.FontSize=Label_Size;
fig_plot.CurrentAxes.YAxis.FontSize=Label_Size;
view(2);
% c_Plot = colorbar('vert','FontSize',Label_Size,'Direction','reverse');
Z_Ticks = ZLower:Tick_Size_Z:ZUpper;
c_Plot=colorbar('vert');
c_Plot.Label.String = Z_Name;
c_Plot.Label.FontSize = Y_Name_Size;
c_Plot.FontSize = X_Tick_Label_Size;
c_Plot.Ticks = Z_Ticks;
clim([ZLower,ZUpper]);

X_Ticks = Time_Start:Tick_Size_Time:this_Time(end);

xticks(X_Ticks);
if ~isnan(Y_Ticks)
yticks(Y_Ticks);
end

if ~isnan(Y_TickLabel)
fig_plot.CurrentAxes.YAxis.TickLabel=Y_TickLabel;
end

% fig_plot.CurrentAxes.YDir='normal';
% fig_plot.CurrentAxes.XDir='normal';

% Y_Name_Sub='ACC          PFC          CD';
% 
% Y_Name_Full=['{\' sprintf(['fontsize{%d}' Y_Name '}'],Y_Name_Size)];
% Y_Name_Full_Sub=['{\' sprintf(['fontsize{%d}' Y_Name_Sub '}'],Y_Name_Size)];
% % 
% Y_Name_Full_Title={Y_Name_Full};

xlabel(X_Name,'FontSize',X_Name_Size);
ylabel(Y_Name,'FontSize',Y_Name_Size);
% ylabel(Y_Name_Full_Title);

hold on
if wantDecisionIndicators
    cgg_plotDecisionEpochIndicators(DecisionIndicatorColors,...
        'DecisionIndicatorLabelOrientation',...
        DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'TimeOffset',TimeOffset,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Line_Width',Line_Width);
end
hold off

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

Main_Title=PlotTitle;
% Main_SubTitle=sprintf('Area: %s Trials:',InArea_Label);
% Main_SubTitle=sprintf('Area: %s',InArea_Label);
% Main_SubSubTitle=sprintf('Trials:');

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Title_Size)];

Full_Title={Main_Title};

title(Full_Title);

drawnow;

if wantSubPlot
fig_plot=gca;
end

%%
end

