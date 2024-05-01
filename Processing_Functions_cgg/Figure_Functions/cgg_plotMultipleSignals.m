function [fig_plot,p_Plot] = cgg_plotMultipleSignals(InData,varargin)
%CGG_PLOTMULTIPLESIGNALS Summary of this function goes here
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
RangeCompressionFactor = CheckVararginPairs('RangeCompressionFactor', 0.25, varargin{:});
else
if ~(exist('RangeCompressionFactor','var'))
RangeCompressionFactor=0.25;
end
end

if isfunction
PriorFigure = CheckVararginPairs('PriorFigure', '', varargin{:});
else
if ~(exist('PriorFigure','var'))
PriorFigure='';
end
end

%% Parameters

if ~wantSubPlot
    if isempty(PriorFigure)
        fig_plot=figure;
        fig_plot.WindowState='maximized';
        fig_plot.PaperSize=[20 10];
    else
       fig_plot=PriorFigure;
       clf(fig_plot,'reset');
%        fig_plot.WindowState='maximized';
       fig_plot.PaperSize=[20 10];
    end
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

RangeFactorLower=0.1;
RangeFactorUpper=0.1;

RangeFactorHeatUpper = cfg_Plotting.RangeFactorHeatUpper;
RangeFactorHeatLower = cfg_Plotting.RangeFactorHeatLower;

if wantDecisionIndicators
FactorDecisionIndicators=0.1;
else
FactorDecisionIndicators=0;
end

%% Get Information from Input Data
% Get the information like number of times series to average, number of
% windows, and number of plots

SameNumWindows=true;
if isnumeric(InData)
    [NumYAxis,NumWindows,NumSamples] = size(InData);
    NumPlots=1;
elseif iscell(InData)
    NumPlots = length(InData);
    NumYAxis=NaN(1,NumPlots);
    NumWindows=NaN(1,NumPlots);
    NumSamples=NaN(1,NumPlots);
    for pidx=1:NumPlots
        [NumYAxis(pidx),NumWindows(pidx),NumSamples(pidx)] = size(InData{pidx});
    end
    if range(NumWindows) ~= 0
        SameNumWindows=false;
    else
        NumWindows=NumWindows(1);
    end
    if range(NumYAxis) ~= 0
        SameNumYAxis=false;
    else
        NumYAxis=NumYAxis(1);
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

if isempty(Y_Ticks)
Y_Ticks=[1,Tick_Size_Channels:Tick_Size_Channels:NumYAxis];
end
if isempty(Y_TickLabel)
Y_TickLabel=[1,Tick_Size_Channels:Tick_Size_Channels:NumYAxis];
end

%%

if NumPlots==1
SingleVectorData=InData(:);
else
SingleVectorData=[];
for pidx=1:NumPlots
SingleVectorData=[SingleVectorData; InData{pidx}(:)];
end
end

InYLim=[min(SingleVectorData),max(SingleVectorData)];

this_Y_Range=(InYLim(2)-InYLim(1))*RangeCompressionFactor;

if NumPlots==1
ColorMap=turbo(NumYAxis);
else
ColorMap=cfg_Plotting.MATLABPlotColors(1:NumPlots);
end

Y_Offsets=ones(NumYAxis,NumPlots);

p_Plot=gobjects(NumYAxis,NumPlots);

for gidx=1:NumYAxis
    if gidx==1
        hold on
    end
    
this_Y_Offset=+(gidx-1)*this_Y_Range;
sel_channel=gidx;

for pidx=1:NumPlots
    if NumPlots>1
        this_Data=InData{pidx}(sel_channel,:,:)+this_Y_Offset;
        this_Data=squeeze(this_Data);
        [p_Plot(gidx,pidx),~] = cgg_plotLinePlotWithShadedError(this_Time,this_Data,ColorMap{pidx});
    else
        this_Data=InData(sel_channel,:,:)+this_Y_Offset;
        this_Data=squeeze(this_Data);
        [p_Plot(gidx,pidx),~] = cgg_plotLinePlotWithShadedError(this_Time,this_Data,ColorMap(gidx,:));
    end

% p_Plot(gidx)=plot(this_Time,this_Data,...
%     'Color',ColorMap(gidx,:),'DisplayName',['Channel ' num2str(sel_channel)]);

p_Plot(gidx,pidx).DisplayName=['Channel ' num2str(sel_channel)];

this_Data_Start=p_Plot(gidx,pidx).YData(1);

if isnan(this_Data_Start)
Y_Offsets(gidx,pidx)=this_Y_Offset;
else
Y_Offsets(gidx,pidx)=this_Data_Start;
end
end
end
hold off

%%

Y_Offsets=mean(Y_Offsets,2);

% this_InYLim=[InYLim(1)-this_Y_Range*((NumYAxis-1)*1+1),InYLim(1)+this_Y_Range*((NumYAxis-1)*0+4)];

% this_InYLim=[Y_Offsets(1)-this_Y_Range*RangeFactorLower,Y_Offsets(end)+this_Y_Range*(RangeFactorUpper)];
this_InYLim=[Y_Offsets(1),Y_Offsets(end)];

this_YLimRange=this_InYLim(2)-this_InYLim(1);

UF=RangeFactorUpper+FactorDecisionIndicators;
LF=RangeFactorLower;

AdditionalUpper=-(UF*this_YLimRange)/(UF+LF-1);
AdditionalLower=-(LF*this_YLimRange)/(UF+LF-1);

this_InYLim(1)=this_InYLim(1)-AdditionalLower;
this_InYLim(2)=this_InYLim(2)+AdditionalUpper;

ylim(this_InYLim);
xlim([this_Time(1),this_Time(end)]);

% xticks(this_Time(1):Tick_Size:this_Time(end));

% YTicks_IDX=fliplr([1,Y_Tick_Skip:Y_Tick_Skip:length(Channel_Group)]);
YTicks_IDX=Y_Ticks;

% Convert the array of numbers to a cell array of strings
YTicks_Names = cellfun(@num2str, num2cell(Y_TickLabel), 'UniformOutput', false);

YTicks=Y_Offsets(YTicks_IDX);

yticks(YTicks);
yticklabels(YTicks_Names);

% Adjust y-axis tick marks
ax = gca; % Get the current axes handle
ax.YAxis.TickLength = [0.01, 0.01]; % Set tick length
ax.YAxis.TickDirection = 'out';   % Set tick direction

%%

hold on
if wantDecisionIndicators
    cgg_plotDecisionEpochIndicators(DecisionIndicatorColors);
end
hold off

xlabel(X_Name,'FontSize',X_Name_Size);
ylabel(Y_Name,'FontSize',Y_Name_Size);

Main_Title=PlotTitle;
% Main_SubTitle=sprintf('Area: %s Trials:',InArea_Label);
% Main_SubTitle=sprintf('Area: %s',InArea_Label);
% Main_SubSubTitle=sprintf('Trials:');

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Title_Size)];
Full_Title={Main_Title};
title(Full_Title);
drawnow;


end

