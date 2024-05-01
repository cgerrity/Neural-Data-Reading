function cgg_plotSignificantRegression(InputTable,SignificanceValue,AreaName,Plotcfg)
%CGG_PLOTSIGNIFICANTREGRESSION Summary of this function goes here
%   Detailed explanation goes here

% AreaName='ACC';

Removed_Coefficients=[6,9];

%%

P_Value=InputTable{:,"P_Value"};
P_Value_NaN=isnan(P_Value);

P_Value_Coefficients=InputTable{:,"P_Value_Coefficients"};
P_Value_Coefficients_NaN=isnan(P_Value_Coefficients);


SignificantModel = P_Value < SignificanceValue;
SignificantModel = double(SignificantModel);
SignificantModel(P_Value_NaN) = NaN;

SignificantCoefficients = P_Value_Coefficients < SignificanceValue;
SignificantCoefficients = double(SignificantCoefficients);
SignificantCoefficients(P_Value_Coefficients_NaN) = NaN;

[NumChannels,NumTimePoints,~] = size(SignificantCoefficients);

SignificantCoefficients(:,:,Removed_Coefficients)=[];

SignificantCoefficients_Combined = NaN(NumChannels*2,NumTimePoints,4);

SignificantCoefficients_Combined(1:NumChannels,:,1) = SignificantCoefficients(:,:,1);
SignificantCoefficients_Combined((1:NumChannels)+NumChannels,:,1) = SignificantCoefficients(:,:,2);

SignificantCoefficients_Combined(1:NumChannels,:,2) = SignificantCoefficients(:,:,3);
SignificantCoefficients_Combined((1:NumChannels)+NumChannels,:,2) = SignificantCoefficients(:,:,4);

SignificantCoefficients_Combined(1:NumChannels,:,3) = SignificantCoefficients(:,:,5);

SignificantCoefficients_Combined(1:NumChannels,:,4) = SignificantCoefficients(:,:,6);
SignificantCoefficients_Combined((1:NumChannels)+NumChannels,:,4) = SignificantCoefficients(:,:,7);
%%
Time_Start=-1.5;
Time_End=1.5;
SamplingRate=1000;
DataWidth=1/SamplingRate;
WindowStride=1/SamplingRate;
X_Name = 'Time (s)';
Y_Name = 'Proportion of Significant Channels';
PlotTitle_Model = sprintf('Model Significance for %s',AreaName);
PlotTitle_Coefficients = sprintf('Coefficient Significance for %s',AreaName);
wantDecisionIndicators = true;
wantSubPlot = true;
wantFeedbackIndicators = true;
DecisionIndicatorLabelOrientation='aligned';
YLimits = [0,0.8];

PlotNames = {'EC-Shared','EC-NonShared','EE-Shared','EE-NonShared','CC-Shared','CC-NonShared','CE-Shared','CE-NonShared','First'};
PlotNames(Removed_Coefficients) = [];

PlotNames_Combined = {'EC','EE','CC','CE'};

%%

InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
% InFigure.Visible='off';

%%

Tiled_Plot=tiledlayout(1,2);

nexttile

[fig,~,~] = cgg_plotTimeSeriesPlot(SignificantModel,'Time_Start',Time_Start,'Time_End',Time_End,'SamplingRate',SamplingRate,'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle_Model,'wantDecisionIndicators',wantDecisionIndicators,'wantSubPlot',wantSubPlot,'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,'wantFeedbackIndicators',wantFeedbackIndicators);

ylim(YLimits);
legend('off');

nexttile

[fig,~,~] = cgg_plotTimeSeriesPlot(SignificantCoefficients_Combined,'Time_Start',Time_Start,'Time_End',Time_End,'SamplingRate',SamplingRate,'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle_Coefficients,'wantDecisionIndicators',wantDecisionIndicators,'wantSubPlot',wantSubPlot,'PlotNames',PlotNames_Combined,'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,'wantFeedbackIndicators',wantFeedbackIndicators);

ylim(YLimits);
%%

PlotNameExt=sprintf('Combined_Significance_%s.fig',AreaName);

PlotPath=Plotcfg.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];

saveas(fig,PlotPathNameExt);
% exportgraphics(fig,PlotPathNameExt,'ContentType','vector');

% PlotName=sprintf('Significance_%s',AreaName);
% PlotPathName=[PlotPath filesep PlotName];
% saveas(fig,PlotPathName,'svg');
% saveas(fig,PlotPathName,'epsc');

end

