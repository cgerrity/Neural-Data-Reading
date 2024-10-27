function [outputArg1,outputArg2] = cgg_plotHeatMap(InData,varargin)
%CGG_PLOTHEATMAP Summary of this function goes here
%   Detailed explanation goes here
cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
X_Name = CheckVararginPairs('X_Name', 'X Value', varargin{:});
else
if ~(exist('X_Name','var'))
X_Name='X Value';
end
end

if iscell(X_Name)
X_Name_PlotTitle = X_Name{1};
else
X_Name_PlotTitle = X_Name;
end

if isfunction
Y_Name = CheckVararginPairs('Y_Name', 'Y Value', varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name='Y Value';
end
end

if iscell(Y_Name)
Y_Name_PlotTitle = Y_Name{1};
else
Y_Name_PlotTitle = Y_Name;
end

if isfunction
Z_Name = CheckVararginPairs('Z_Name', '', varargin{:});
else
if ~(exist('Z_Name','var'))
Z_Name='';
end
end

if isfunction
PlotTitle = CheckVararginPairs('PlotTitle', sprintf('%s vs %s',Y_Name_PlotTitle,X_Name_PlotTitle), varargin{:});
else
if ~(exist('PlotTitle','var'))
PlotTitle=sprintf('%s vs %s',Y_Name_PlotTitle,X_Name_PlotTitle);
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
Line_Width = CheckVararginPairs('Line_Width', cfg_Plotting.Line_Width, varargin{:});
else
if ~(exist('Line_Width','var'))
Line_Width=cfg_Plotting.Line_Width;
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
    [NumYAxis,NumXAxis,NumPlots] = size(InData);
elseif iscell(InData)
    NumPlots = size(InData);
    NumExamples=NaN(1,NumPlots);
    NumXAxis=NaN(1,NumPlots);
    for pidx=1:NumPlots
        [NumExamples(pidx),NumXAxis(pidx)] = size(InData{pidx});
    end
    if range(NumXAxis) ~= 0
        SameNumWindows=false;
    else
        NumXAxis=NumXAxis(1);
    end
end

%%

if isempty(YRange)
YRange=1:NumYAxis;
end
if isempty(Y_Ticks)
Y_Ticks=[1,Tick_Size_Y:Tick_Size_Y:NumYAxis];
end
if isempty(Y_TickLabel)
Y_TickLabel=[1,Tick_Size_Y:Tick_Size_Y:NumYAxis];
end

%%

if isempty(XRange)
XRange=1:NumXAxis;
end
if isempty(X_Ticks)
X_Ticks=[1,Tick_Size_X:Tick_Size_X:NumXAxis];
end
if isempty(X_TickLabel)
X_TickLabel=[1,Tick_Size_X:Tick_Size_X:NumXAxis];
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

p_Plots=imagesc(XRange,YRange,InData);

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
    cgg_plotDecisionEpochIndicators(DecisionIndicatorColors,...
        'DecisionIndicatorLabelOrientation',...
        DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'TimeOffset',TimeOffset,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Line_Width',Line_Width);
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

end

