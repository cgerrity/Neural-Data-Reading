function cgg_plotCoefficientValuesRegression(InputTable,SignificanceValue,AreaName,Plotcfg,varargin)
%CGG_PLOTSIGNIFICANTREGRESSION Summary of this function goes here
%   Detailed explanation goes here

%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
wantSignificant = CheckVararginPairs('wantSignificant', true, varargin{:});
else
if ~(exist('wantSignificant','var'))
wantSignificant=true;
end
end

%%

% AreaName='ACC';

Removed_Coefficients=[6,9];

%%

P_Value=InputTable{:,"P_Value"};
P_Value_NaN=isnan(P_Value);

P_Value_Coefficients=InputTable{:,"P_Value_Coefficients"};
P_Value_Coefficients_NaN=isnan(P_Value_Coefficients);

R_Value_Adjusted=InputTable{:,"R_Value_Adjusted"};
B_Value_Coefficients=InputTable{:,"B_Value_Coefficients"};

SignificantModel = P_Value < SignificanceValue;
SignificantCoefficients = P_Value_Coefficients < SignificanceValue;

if wantSignificant
R_Value_Adjusted(~SignificantModel)=NaN;
B_Value_Coefficients(~SignificantCoefficients)=NaN;
end

SignificantModel = double(SignificantModel);
R_Value_Adjusted(P_Value_NaN) = NaN;

SignificantCoefficients = double(SignificantCoefficients);
B_Value_Coefficients(P_Value_Coefficients_NaN) = NaN;

B_Value_Coefficients(:,:,Removed_Coefficients)=[];

%%
Time_Start=-1.5;
Time_End=1.5;
SamplingRate=1000;
DataWidth=1/SamplingRate;
WindowStride=1/SamplingRate;
X_Name = 'Time (s)';
Y_Name_Model = 'Explained Variance';
Y_Name_Coefficients = 'Beta Values';
PlotTitle_Model = sprintf('Explained Variance for %s',AreaName);
PlotTitle_Coefficients = sprintf('Beta Values for %s',AreaName);
wantDecisionIndicators = true;
wantSubPlot = true;
wantFeedbackIndicators = true;
DecisionIndicatorLabelOrientation='aligned';

switch AreaName
    case 'ACC'
        if wantSignificant
        YLimits_Model = [0,0.05];
        YLimits_Coefficients = [-0.5,1.5];
        else
        YLimits_Model = [0,0.02];
        % YLimits_Coefficients = [-0.25,0.5];
        YLimits_Coefficients = [-0.05,0.3];
        end
    case 'PFC'
        if wantSignificant
        YLimits_Model = [0,0.05];
        YLimits_Coefficients = [-1,1];
        else
        YLimits_Model = [0,0.02];
        YLimits_Coefficients = [-0.25,0.5];
        end
    case 'CD'
        if wantSignificant
        YLimits_Model = [0,0.05];
        YLimits_Coefficients = [-0.5,1.5];
        else
        YLimits_Model = [0,0.02];
        YLimits_Coefficients = [-0.25,0.5];
        end
    otherwise
        if wantSignificant
        YLimits_Model = [0,0.05];
        YLimits_Coefficients = [-1,1];
        else
        YLimits_Model = [0,0.02];
        YLimits_Coefficients = [-0.25,0.5];
        end
end

PlotNames = {'EC-Shared','EC-NonShared','EE-Shared','EE-NonShared','CC-Shared','CC-NonShared','CE-Shared','CE-NonShared','First'};
PlotNames(Removed_Coefficients) = [];

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

[fig,~,~] = cgg_plotTimeSeriesPlot(R_Value_Adjusted,'Time_Start',Time_Start,'Time_End',Time_End,'SamplingRate',SamplingRate,'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name_Model,'PlotTitle',PlotTitle_Model,'wantDecisionIndicators',wantDecisionIndicators,'wantSubPlot',wantSubPlot,'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,'wantFeedbackIndicators',wantFeedbackIndicators);

ylim(YLimits_Model);
legend('off');

nexttile

[fig,~,~] = cgg_plotTimeSeriesPlot(B_Value_Coefficients,'Time_Start',Time_Start,'Time_End',Time_End,'SamplingRate',SamplingRate,'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name_Coefficients,'PlotTitle',PlotTitle_Coefficients,'wantDecisionIndicators',wantDecisionIndicators,'wantSubPlot',wantSubPlot,'PlotNames',PlotNames,'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,'wantFeedbackIndicators',wantFeedbackIndicators);

ylim(YLimits_Coefficients);
%%

PlotNameExt=sprintf('Coefficient_Values_%s.pdf',AreaName);

PlotPath=Plotcfg.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];

% saveas(fig,PlotPathNameExt);
exportgraphics(fig,PlotPathNameExt,'ContentType','vector');

% PlotNameExt=sprintf('Coefficient_Values_%s.svg',AreaName);
% PlotPathNameExt=[PlotPath filesep PlotNameExt];
% saveas(fig,PlotPathNameExt);
% 
% PlotName=sprintf('Coefficient_Values_%s',AreaName);
% PlotPathName=[PlotPath filesep PlotName];
% saveas(fig,PlotPathName,'svg');
% saveas(fig,PlotPathName,'epsc');

end

