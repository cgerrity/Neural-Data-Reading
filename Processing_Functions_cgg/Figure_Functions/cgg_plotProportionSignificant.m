function cgg_plotProportionSignificant(InputTable,SignificanceValue,AreaName,PlotInformation,Plotcfg)
%CGG_PLOTPROPORTIONSIGNIFICANT Summary of this function goes here
%   Detailed explanation goes here

%%

X_Name = 'Time (s)';
Y_Name = {'Proportion of','Significant Channels'};

%%

Time_Start = PlotInformation.Time_Start;
Time_End = PlotInformation.Time_End;
SamplingRate = PlotInformation.SamplingRate;
DataWidth = PlotInformation.DataWidth;
WindowStride = PlotInformation.WindowStride;
DataWidth=DataWidth/SamplingRate;
WindowStride=WindowStride/SamplingRate;

PlotParameters = PlotInformation.PlotParameters;

Time_Start=Time_Start + PlotParameters.Time_Offset;
Time_End=Time_End + PlotParameters.Time_Offset;

YLimits = PlotParameters.Limit_ChannelProportion;
XLimits = PlotParameters.Limit_Time;

Y_Tick_Size = PlotParameters.Tick_Size_ChannelProportion;
X_Tick_Size = PlotParameters.Tick_Size_Time;

Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);
X_Ticks = XLimits(1):X_Tick_Size:XLimits(2);

WantTitle = PlotParameters.WantTitle;

Y_TickDir = PlotParameters.TickDir_ChannelProportion;
X_TickDir = PlotParameters.TickDir_Time;

wantDecisionIndicators = PlotParameters.wantDecisionIndicators;
wantSubPlot = PlotParameters.wantSubPlot;
wantFeedbackIndicators = PlotParameters.wantFeedbackIndicators;
DecisionIndicatorLabelOrientation = ...
    PlotParameters.DecisionIndicatorLabelOrientation;
wantIndicatorNames = PlotParameters.wantIndicatorNames;
wantPaperSized = PlotParameters.wantPaperSized;

%%
switch PlotInformation.PlotVariable
    case 'Model Significance'
        P_Value = InputTable{:,"P_Value"};
        PlotTitle_Model = sprintf('Model Significance for %s',AreaName);
        PlotNames = '';
        WantLegend = false;
    case 'Coefficient Significance'
        P_Value=InputTable{:,"P_Value_Coefficients"};
        PlotTitle_Model = sprintf('Coefficient Significance for %s',AreaName);
        PlotNames = PlotParameters.CoefficientNames;
        WantLegend = true;
    case 'Correlation Significance'
        P_Value=InputTable{:,"P_Correlation"};
        PlotTitle_Model = sprintf('Correlation Significance for %s',AreaName);
        PlotNames = '';
        WantLegend = false;
    case 'Correlation Significance'
        P_Value=InputTable{:,"P_Correlation"};
        PlotTitle_Model = sprintf('Correlation Significance for %s',AreaName);
        PlotNames = '';
        WantLegend = false;
    otherwise
end

P_Value_NaN=isnan(P_Value);

PlotValue = P_Value < SignificanceValue;
PlotValue = double(PlotValue);
PlotValue(P_Value_NaN) = NaN;

%%
close all

if wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
else
InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
% InFigure.Visible='off';
end

clf(InFigure);

%%

[fig,~,~] = cgg_plotTimeSeriesPlot(PlotValue,...
    'Time_Start',Time_Start,'Time_End',Time_End,...
    'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
    'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
    'PlotTitle',PlotTitle_Model,...
    'wantDecisionIndicators',wantDecisionIndicators,...
    'wantSubPlot',wantSubPlot,...
    'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
    'wantFeedbackIndicators',wantFeedbackIndicators,...
    'wantIndicatorNames',wantIndicatorNames,...
    'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
    'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir);

if ~any(isnan(YLimits))
ylim(YLimits);
end
if ~any(isnan(XLimits))
xlim(XLimits);
end
if ~WantTitle
title('');
end
if ~WantLegend
legend('off');
end

%%

if ~(isnan(Plotcfg) || isempty(Plotcfg))
    PlotVariableName = replace(PlotInformation.PlotVariable,' ' ,'_');
    PlotName=sprintf('%s_%s',PlotVariableName,AreaName);
    PlotPath=Plotcfg.path;
    PlotPathName=[PlotPath filesep PlotName];
    saveas(fig,[PlotPathName, '.fig']);
    exportgraphics(fig,[PlotPathName, '.pdf'],'ContentType','vector');
end

end

