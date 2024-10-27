function cgg_plotVariableToData(InputTable,SignificanceValue,AreaName,PlotInformation,Plotcfg)
%CGG_PLOTVARIABLETODATA Summary of this function goes here
%   Detailed explanation goes here

%%

X_Name = 'Time (s)';

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

PlotVariable = PlotInformation.PlotVariable;

%%
if PlotInformation.WantProportionSignificant
PlotTitle_Significance = ' Proportion Significant';
else
    PlotTitle_Significance = '';
   YLimits = NaN;
Y_Ticks = NaN; 
end
PlotTitle_Model = sprintf('%s%s for %s',PlotVariable,PlotTitle_Significance,AreaName);

%%

if PlotInformation.WantDifference
YLimits = NaN;
Y_Ticks = NaN; 
end
%%
switch PlotVariable
    case 'Model'
        P_Value = InputTable{:,"P_Value"};
        R_Value = InputTable{:,"R_Value_Adjusted"};
        PlotNames = {''};
        WantLegend = false;
        Y_Name = {'Explained Variance'};
        DataTransform='';
    case 'Coefficient'
        P_Value=InputTable{:,"P_Value_Coefficients"};
        R_Value = InputTable{:,"B_Value_Coefficients"};
        PlotNames = PlotInformation.CoefficientNames;
        WantLegend = true;
        Y_Name = {'Beta Value'};
        DataTransform='';
    case 'Correlation'
        P_Value=InputTable{:,"P_Correlation"};
        R_Value = InputTable{:,"R_Correlation"};
        PlotNames = {''};
        WantLegend = false;
        Y_Name = {'Correlation'};
        DataTransform={@(x) atanh(x),@(x) tanh(x)}; % Fisher Z Transform
    otherwise
end

%%
NumChannels = height(InputTable);
[Dim_1,Dim_2] = size(P_Value);
NumSamples = Dim_1;
if Dim_1 == NumChannels
    NumSamples = Dim_2;
end

%%

P_Value_Positive = P_Value;
P_Value_Negative = P_Value;
R_Value_Positive = R_Value;
R_Value_Negative = R_Value;
P_Value_Positive(R_Value_Positive < 0) = NaN;
P_Value_Negative(R_Value_Negative > 0) = NaN;
R_Value_Positive(R_Value_Positive < 0) = NaN;
R_Value_Negative(R_Value_Negative > 0) = NaN;

if PlotInformation.WantSplitPositiveNegative
    PlotNames = {'Positive','Negative'};
    WantLegend = true;
end

P_Value_NaN=isnan(P_Value);
P_Value_Positive_NaN=isnan(P_Value_Positive);
P_Value_Negative_NaN=isnan(P_Value_Negative);

SignificantValues = P_Value < SignificanceValue;
SignificantValues_Positive = P_Value_Positive < SignificanceValue;
SignificantValues_Negative = P_Value_Negative < SignificanceValue;

% If Want Significant Values
if PlotInformation.WantSignificant
    R_Value(~SignificantValues)=NaN;
    R_Value_Positive(~SignificantValues) = NaN;
    R_Value_Negative(~SignificantValues) = NaN;
end

SignificantValues = double(SignificantValues);
SignificantValues(P_Value_NaN) = NaN;
R_Value(P_Value_NaN) = NaN;

SignificantValues_Positive = double(SignificantValues_Positive);
SignificantValues_Positive(P_Value_NaN) = NaN;
R_Value_Positive(P_Value_Positive_NaN) = NaN;

SignificantValues_Negative = double(SignificantValues_Negative);
SignificantValues_Negative(P_Value_NaN) = NaN;
R_Value_Negative(P_Value_Negative_NaN) = NaN;

%%

if strcmp(PlotVariable,'Correlation')
    R_Value_Negative = abs(R_Value_Negative);
end

PlotError = '';

if PlotInformation.WantProportionSignificant
    DataTransform='';
    if PlotInformation.WantSplitPositiveNegative
        if PlotInformation.WantDifference
            [PlotValue,PlotError] = cgg_getDifferenceSeries(SignificantValues_Positive,SignificantValues_Negative,NumSamples);
        else
            PlotValue = cat(3,SignificantValues_Positive,SignificantValues_Negative);
        end
    else
    PlotValue = SignificantValues;
    end
    Y_Name = {'Proportion of','Significant Channels'};
else
    if PlotInformation.WantSplitPositiveNegative
        if PlotInformation.WantDifference
            [PlotValue,PlotError] = cgg_getDifferenceSeries(R_Value_Positive,R_Value_Negative,NumSamples);
        else
            PlotValue = cat(3,R_Value_Positive,R_Value_Negative);
        end
    else
    PlotValue = R_Value;
    end
end


if PlotInformation.WantDifference
    WantLegend = false;
Y_Name{1} = ['Difference of ' Y_Name{1}];
end
%%

if strcmp(PlotVariable,'Coefficient') && PlotInformation.WantSplitPositiveNegative
    NumPlots = length(PlotInformation.CoefficientNames);
    HasMultiplePlots = true;
else
    NumPlots = 1;
    HasMultiplePlots = false;
end

%%
for pidx = 1:NumPlots
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

if HasMultiplePlots
this_PlotValueIDX = [pidx,pidx+NumPlots];
this_PlotValue = PlotValue(:,:,this_PlotValueIDX);
this_PlotVariable = PlotInformation.CoefficientNames{pidx};
else
this_PlotValue = PlotValue;
this_PlotVariable = PlotVariable;
end

%%

[fig,~,~] = cgg_plotTimeSeriesPlot(this_PlotValue,...
    'Time_Start',Time_Start,'Time_End',Time_End,...
    'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
    'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
    'PlotTitle',PlotTitle_Model,'PlotNames',PlotNames,...
    'wantDecisionIndicators',wantDecisionIndicators,...
    'wantSubPlot',wantSubPlot,...
    'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
    'wantFeedbackIndicators',wantFeedbackIndicators,...
    'wantIndicatorNames',wantIndicatorNames,...
    'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
    'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
    'DataTransform',DataTransform,'ErrorMetric',PlotError);

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

if isstruct(Plotcfg)
    PlotSignificanceName = replace(PlotTitle_Significance,' ' ,'_');
    PlotName=sprintf('%s%s%s_%s',PlotInformation.ExtraTerm,this_PlotVariable,PlotSignificanceName,AreaName);
    PlotPath=Plotcfg.path;
    PlotPathName=[PlotPath filesep PlotName];
    saveas(fig,[PlotPathName, '.fig']);
    exportgraphics(fig,[PlotPathName, '.pdf'],'ContentType','vector');
end

end % End pidx: Iteration through the plots
end

