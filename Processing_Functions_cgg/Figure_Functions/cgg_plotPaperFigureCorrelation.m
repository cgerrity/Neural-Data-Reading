function cgg_plotPaperFigureCorrelation(PlotData,varargin)
%CGG_PLOTPAPERFIGUREPROPORTIONCORRELATED Summary of this function goes here
%   Detailed explanation goes here
% cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);

isfunction=exist('varargin','var');

if isfunction
WantPaperFormat = CheckVararginPairs('WantPaperFormat', true, varargin{:});
else
if ~(exist('WantPaperFormat','var'))
WantPaperFormat=true;
end
end

if isfunction
WantDecisionCentered = CheckVararginPairs('WantDecisionCentered', false, varargin{:});
else
if ~(exist('WantDecisionCentered','var'))
WantDecisionCentered=false;
end
end

cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',WantPaperFormat,'WantDecisionCentered',WantDecisionCentered);

if isfunction
InFigure = CheckVararginPairs('InFigure', '', varargin{:});
else
if ~(exist('InFigure','var'))
InFigure='';
end
end

if isfunction
WantLarge = CheckVararginPairs('WantLarge', false, varargin{:});
else
if ~(exist('WantLarge','var'))
WantLarge=false;
end
end

if isfunction
Time_Start = CheckVararginPairs('Time_Start', -1.5, varargin{:});
else
if ~(exist('Time_Start','var'))
Time_Start=-1.5;
end
end

if isfunction
Time_End = CheckVararginPairs('Time_End', 1.5, varargin{:});
else
if ~(exist('Time_End','var'))
Time_End=1.5;
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
DataWidth = CheckVararginPairs('DataWidth', 1/SamplingRate, varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth=1/SamplingRate;
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', 1/SamplingRate, varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride=1/SamplingRate;
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
Y_Name = CheckVararginPairs('Y_Name', 'Correlation', varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name='Correlation';
end
end

if isfunction
PlotTitle = CheckVararginPairs('PlotTitle', '', varargin{:});
else
if ~(exist('PlotTitle','var'))
PlotTitle='';
end
end

if isfunction
PlotNames = CheckVararginPairs('PlotNames', {'Positive','Negative'}, varargin{:});
else
if ~(exist('PlotNames','var'))
PlotNames={'Positive','Negative'};
end
end

if isfunction
PlotPath = CheckVararginPairs('PlotPath', [], varargin{:});
else
if ~(exist('PlotPath','var'))
PlotPath=[];
end
end

if isfunction
AreaName = CheckVararginPairs('AreaName', '', varargin{:});
else
if ~(exist('AreaName','var'))
AreaName='';
end
end

if isfunction
WantLegend = CheckVararginPairs('WantLegend', false, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=false;
end
end

if isfunction
SeparatePlotName = CheckVararginPairs('SeparatePlotName', '', varargin{:});
else
if ~(exist('SeparatePlotName','var'))
SeparatePlotName='';
end
end

if isfunction
WantCI = CheckVararginPairs('WantCI', false, varargin{:});
else
if ~(exist('WantCI','var'))
WantCI=false;
end
end

if isfunction
SaveName = CheckVararginPairs('SaveName', '', varargin{:});
else
if ~(exist('SaveName','var'))
SaveName='';
end
end

if isfunction
Title_Size = CheckVararginPairs('Title_Size', cfg_Paper.Title_Size, varargin{:});
else
if ~(exist('Title_Size','var'))
Title_Size=cfg_Paper.Title_Size;
end
end

if isfunction
Legend_Size = CheckVararginPairs('Legend_Size', cfg_Paper.Legend_Size, varargin{:});
else
if ~(exist('Legend_Size','var'))
Legend_Size=cfg_Paper.Legend_Size;
end
end

if isfunction
Y_Name_Size = CheckVararginPairs('Y_Name_Size', cfg_Paper.Y_Name_Size, varargin{:});
else
if ~(exist('Y_Name_Size','var'))
Y_Name_Size=cfg_Plotting.Y_Name_Size;
end
end

if isfunction
X_Name_Size = CheckVararginPairs('X_Name_Size', cfg_Paper.X_Name_Size, varargin{:});
else
if ~(exist('X_Name_Size','var'))
X_Name_Size=cfg_Plotting.X_Name_Size;
end
end

if isfunction
Y_Tick_Label_Size = CheckVararginPairs('Y_Tick_Label_Size', cfg_Paper.Label_Size, varargin{:});
else
if ~(exist('Y_Tick_Label_Size','var'))
Y_Tick_Label_Size=cfg_Paper.Label_Size;
end
end

if isfunction
X_Tick_Label_Size = CheckVararginPairs('X_Tick_Label_Size', cfg_Paper.Label_Size, varargin{:});
else
if ~(exist('X_Tick_Label_Size','var'))
X_Tick_Label_Size=cfg_Paper.Label_Size;
end
end

if isfunction
Indicator_Size = CheckVararginPairs('Indicator_Size', cfg_Paper.Indicator_Size, varargin{:});
else
if ~(exist('Indicator_Size','var'))
Indicator_Size=cfg_Paper.Indicator_Size;
end
end

if isfunction
PlotColors = CheckVararginPairs('PlotColors', cfg_Paper.MATLABPlotColors, varargin{:});
else
if ~(exist('PlotColors','var'))
PlotColors=cfg_Paper.MATLABPlotColors;
end
end

if isfunction
WantLatent = CheckVararginPairs('WantLatent', false, varargin{:});
else
if ~(exist('WantLatent','var'))
WantLatent=false;
end
end

if isfunction
WantFig = CheckVararginPairs('WantFig', true, varargin{:});
else
if ~(exist('WantFig','var'))
WantFig=true;
end
end
%%
DataTransform = [];
wantSubPlot = true;
%%

Time_Start=Time_Start + cfg_Paper.Time_Offset;
Time_End=Time_End + cfg_Paper.Time_Offset;

wantDecisionIndicators = cfg_Paper.wantDecisionIndicators;
wantFeedbackIndicators = cfg_Paper.wantFeedbackIndicators;
DecisionIndicatorLabelOrientation = ...
    cfg_Paper.DecisionIndicatorLabelOrientation;
wantIndicatorNames = cfg_Paper.wantIndicatorNames;
wantPaperSized = cfg_Paper.wantPaperSized;
%%

Line_Width = cfg_Paper.Line_Width;
% Title_Size = cfg_Paper.Title_Size;
Error_FaceAlpha = cfg_Paper.Error_FaceAlpha;
Error_EdgeAlpha = cfg_Paper.Error_EdgeAlpha;
% Legend_Size = cfg_Paper.Legend_Size;

Y_TickDir = cfg_Paper.TickDir_Correlation;
X_TickDir = cfg_Paper.TickDir_Time;

if WantLatent
YLimits = cfg_Paper.Limit_LatentCorrelation;
Y_Tick_Size = cfg_Paper.Tick_Size_LatentCorrelation;
elseif WantLarge
YLimits = cfg_Paper.Limit_Correlation_Large;
Y_Tick_Size = cfg_Paper.Tick_Size_Correlation;
else
YLimits = cfg_Paper.Limit_Correlation;
Y_Tick_Size = cfg_Paper.Tick_Size_Correlation;
end
XLimits = cfg_Paper.Limit_Time;

X_Tick_Size = cfg_Paper.Tick_Size_Time;

Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);
X_Ticks = XLimits(1):X_Tick_Size:XLimits(2);
%%

% Plot_Series = cell(2,1);
% PlotError = cell(2,1);
if iscell(PlotData)
    NumPlots = length(PlotData);
    Plot_Series = cell(NumPlots,1);
    PlotError = cell(NumPlots,1);
    for aidx = 1:NumPlots
        Plot_Series{aidx} = PlotData{aidx}.CorrelationAll;
        if WantCI
        PlotError{aidx} = PlotData{aidx}.CorrelationAll_CI;
        else
        PlotError{aidx} = PlotData{aidx}.CorrelationAll_STE;
        end
    end
% Plot_Series{1} = PlotData{1}.CorrelationAll;
% Plot_Series{2} = PlotData{2}.CorrelationAll;
% if WantCI
% PlotError{1} = PlotData{1}.CorrelationAll_CI;
% PlotError{2} = PlotData{2}.CorrelationAll_CI;
% else
% PlotError{1} = PlotData{1}.CorrelationAll_STE;
% PlotError{2} = PlotData{2}.CorrelationAll_STE;
% end
else
Plot_Series = cell(2,1);
PlotError = cell(2,1);
Plot_Series{1} = PlotData.ProportionPositive;
Plot_Series{2} = PlotData.ProportionNegative;
if WantCI
PlotError{1} = PlotData.Positive_CI;
PlotError{2} = PlotData.Negative_CI;
else
PlotError{1} = PlotData.Positive_STE;
PlotError{2} = PlotData.Negative_STE;
end
end

%%

if ~isempty(InFigure)
    
elseif wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
clf(InFigure);
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
clf(InFigure);
end

%%


[~,~,~] = cgg_plotTimeSeriesPlot(Plot_Series,...
        'Time_Start',Time_Start,'Time_End',Time_End,...
        'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
        'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
        'PlotTitle',PlotTitle,'PlotNames',PlotNames,...
        'wantDecisionIndicators',wantDecisionIndicators,...
        'wantSubPlot',wantSubPlot,...
        'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
        'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
        'DataTransform',DataTransform,'ErrorMetric',PlotError,...
        'Line_Width',Line_Width,'WantLegend',WantLegend,...
        'Title_Size',Title_Size,'Error_FaceAlpha',Error_FaceAlpha,...
        'Error_EdgeAlpha',Error_EdgeAlpha,'Legend_Size',Legend_Size,...
        'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,...
        'X_Tick_Label_Size',X_Tick_Label_Size,...
        'Y_Tick_Label_Size',Y_Tick_Label_Size, ...
        'Indicator_Size',Indicator_Size,'PlotColors',PlotColors);

ylim(YLimits);
if ~any(isnan(XLimits))
xlim(XLimits);
end

%%

if ~isempty(PlotPath)
    if ~isempty(AreaName)
        AreaName = sprintf("-%s",AreaName);
    end
    if isempty(SeparatePlotName)
    PlotName=sprintf('Correlation%s',AreaName);
    else
        PlotName = SeparatePlotName;
    end
    PlotPathName=[PlotPath filesep PlotName];
    if WantFig
    saveas(InFigure,[PlotPathName, '.fig']);
    end
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end


end

