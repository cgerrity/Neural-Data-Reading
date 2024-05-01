function [fig_plot,p_Plots,c_Plot] = cgg_plotHeatMapOverTime(InData,varargin)
%CGG_PLOTHEATMAPOVERTIME Summary of this function goes here
%   Detailed explanation goes here

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
Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;

Tick_Size_Channels=cfg_Plotting.Tick_Size_Channels;
Tick_Size_Time=cfg_Plotting.Tick_Size_Time;

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
c_Plot=colorbar('vert');
c_Plot.Label.String = Z_Name;
c_Plot.Label.FontSize = Y_Name_Size;
clim([ZLower,ZUpper]);

xticks(Time_Start:Tick_Size_Time:this_Time(end));
yticks(Y_Ticks);

fig_plot.CurrentAxes.YAxis.TickLabel=Y_TickLabel;

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
    cgg_plotDecisionEpochIndicators(DecisionIndicatorColors);
end
hold off

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

