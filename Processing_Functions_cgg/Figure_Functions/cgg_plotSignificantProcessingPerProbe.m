function cgg_plotSignificantProcessingPerProbe(PlotDataPathNameExt,varargin)
%CGG_PLOTSIGNIFICANTPROCESSINGPERPROBE Summary of this function goes here
%   Detailed explanation goes here
%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
InFigure = CheckVararginPairs('InFigure', '', varargin{:});
else
if ~(exist('InFigure','var'))
InFigure='';
end
end

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Decision';
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
WantPaperFormat = CheckVararginPairs('WantPaperFormat', true, varargin{:});
else
if ~(exist('WantPaperFormat','var'))
WantPaperFormat=true;
end
end

if isfunction
WantDecisionCentered = CheckVararginPairs('WantDecisionCentered', true, varargin{:});
else
if ~(exist('WantDecisionCentered','var'))
WantDecisionCentered=true;
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
X_Name = CheckVararginPairs('X_Name', 'Time (s)', varargin{:});
else
if ~(exist('X_Name','var'))
X_Name='Time (s)';
end
end

if isfunction
Y_Name = CheckVararginPairs('Y_Name', {'Proportion of','Significant Channels'}, varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name={'Proportion of','Significant Channels'};
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
Y_Name_Size=cfg_Paper.Y_Name_Size;
end
end

if isfunction
X_Name_Size = CheckVararginPairs('X_Name_Size', cfg_Paper.X_Name_Size, varargin{:});
else
if ~(exist('X_Name_Size','var'))
X_Name_Size=cfg_Paper.X_Name_Size;
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
WantMedium = CheckVararginPairs('WantMedium', false, varargin{:});
else
if ~(exist('WantMedium','var'))
WantMedium=false;
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

Y_TickDir = cfg_Paper.TickDir_ChannelProportion;
X_TickDir = cfg_Paper.TickDir_Time;

YLimits = cfg_Paper.Limit_ChannelProportion_Regression;
Y_Tick_Size = cfg_Paper.Tick_Size_ChannelProportion_Regression;
XLimits = cfg_Paper.Limit_Time;

X_Tick_Size = cfg_Paper.Tick_Size_Time;

Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);
X_Ticks = XLimits(1):X_Tick_Size:XLimits(2);

%%
cfg_Parameters = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
Significance_Value = cfg_Parameters.Significance_Value;
Coefficient_Names = cfg_Parameters.Regression_Names;
WindowStride = cfg_Parameters.Increment_Time/SamplingRate;
DataWidth = 1/SamplingRate;

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

[~,PlotDataName,~]=fileparts(PlotDataPathNameExt);

AreaProbeNumberName=extractAfter(PlotDataName,"Regression_Results_");
AreaProbeNumberStrings=split(AreaProbeNumberName,"_");
MonkeySessionName=extractBefore(PlotDataName,"-Regression_Results_");
MonkeySessionStrings=split(MonkeySessionName,"_");

AreaNameIDX=1;
AreaProbeNumberIDX=2;
MonkeyIDX=1;
ExperimentIDX=1:3;
DateIDX=4;
SessionNumberIDX=5:6;

AreaName=join(AreaProbeNumberStrings(AreaNameIDX),'_');
AreaProbeNumber=join(AreaProbeNumberStrings(AreaProbeNumberIDX),'_');
MonkeyName=join(MonkeySessionStrings(MonkeyIDX),'_');
ExperimentName=join(MonkeySessionStrings(ExperimentIDX),'_');
DateName=join(MonkeySessionStrings(DateIDX),'-');
SessionNumber=join(MonkeySessionStrings(SessionNumberIDX),'-');

AreaSessionName = join([AreaName,AreaProbeNumber,ExperimentName,DateName,SessionNumber],'_');


ProbeName=join([AreaName,AreaProbeNumber],'_');
SessionName=join([ExperimentName,DateName,SessionNumber],'_');

ProbeName=ProbeName{1};
SessionName=SessionName{1};

%%
m_PlotData=matfile(PlotDataPathNameExt,"Writable",false);
CriteriaArray=m_PlotData.CriteriaArray;
P_Value_Coefficients = m_PlotData.P_Value_Coefficients;
%%


NaNValues = isnan(CriteriaArray);
% P_Value = m_PlotData.P_Value;
% P_Value(NaNValues) = NaN;
CriteriaCoefficients = P_Value_Coefficients < Significance_Value;
CriteriaCoefficients = double(CriteriaCoefficients);
for vidx = 1:size(CriteriaCoefficients,3)
    this_CriteriaCoefficients = CriteriaCoefficients(:,:,vidx);
    this_CriteriaCoefficients(NaNValues) = NaN;
    CriteriaCoefficients(:,:,vidx) = this_CriteriaCoefficients;
end

%% Model Significance

% Time_Start = -1.5;
% WindowStride = cfg_Parameters.Increment_Time/SamplingRate;
% DataWidth = 1/SamplingRate;
% SamplingRate = SamplingRate/cfg_Parameters.Increment_Time;
ZLimits = [0,1];
DecisionIndicatorColors = {'w','r','b'};
Y_Name = 'Channel';
PlotTitle = 'Model Significance';
[InFigure,~,~]=cgg_plotHeatMapOverTime(CriteriaArray, ...
    'Time_Start',Time_Start,'DataWidth',DataWidth, ...
    'WindowStride',WindowStride,'ZLimits',ZLimits, ...
    'DecisionIndicatorColors',DecisionIndicatorColors, ...
    'Y_Name',Y_Name,'PlotTitle',PlotTitle,'InFigure',InFigure, ...
    'Title_Size',Title_Size,'wantIndicatorNames',false);

colormap([0,0,0;0,1,0]);
colorbar('off');

if ~isempty(PlotPath)
    PlotName=sprintf('%s_%s_Significance_%s',SessionName,ProbeName,'Model');
    PlotPathName=[PlotPath filesep PlotName];
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end

%% Coefficient Significance

NumCoefficients = size(CriteriaCoefficients,3);

for cidx = 1:NumCoefficients
% sel_cidx = 2;
PlotTitle = char(Coefficient_Names(cidx));
this_CriteriaCoefficients = CriteriaCoefficients(:,:,cidx);
[InFigure,~,~]=cgg_plotHeatMapOverTime(this_CriteriaCoefficients, ...
    'Time_Start',Time_Start,'DataWidth',DataWidth, ...
    'WindowStride',WindowStride,'ZLimits',ZLimits, ...
    'DecisionIndicatorColors',DecisionIndicatorColors, ...
    'Y_Name',Y_Name,'PlotTitle',PlotTitle,'InFigure',InFigure, ...
    'Title_Size',Title_Size,'wantIndicatorNames',false);

colormap([0,0,0;0,1,0]);
colorbar('off');
drawnow;
% pause(1);

if ~isempty(PlotPath)
    PlotName=sprintf('%s_%s_Significance_%s',SessionName,ProbeName,PlotTitle);
    PlotPathName=[PlotPath filesep PlotName];
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end
end

%%

[NumChannels,NumSamples] = size(CriteriaArray);


[Model,Model_STD,Model_STE,Model_CI] = ...
    cgg_getMeanSTDSeries(CriteriaArray,'NumCollapseDimension',NumChannels);

Plot_Series = cell(1,1);
PlotError = cell(1,1);
Plot_Series{1} = Model;
if WantCI
PlotError{1} = Model_STE;
else
PlotError{1} = Model_CI;
end


PlotTitle = 'Model Proportion Significant';
% [Coefficients,Coefficients_STD,Coefficients_STE,Coefficients_CI] = ...
%     cgg_getMeanSTDSeries(CriteriaCoefficients,'NumCollapseDimension',NumChannels);

[~,~,~] = cgg_plotTimeSeriesPlot(Plot_Series,...
        'Time_Start',Time_Start,'Time_End',Time_End,...
        'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
        'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
        'PlotTitle',PlotTitle,'PlotNames',PlotNames,...
        'wantDecisionIndicators',wantDecisionIndicators,...
        'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
        'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
        'ErrorMetric',PlotError,...
        'Line_Width',Line_Width,'WantLegend',WantLegend,...
        'Title_Size',Title_Size,'Error_FaceAlpha',Error_FaceAlpha,...
        'Error_EdgeAlpha',Error_EdgeAlpha,'Legend_Size',Legend_Size,...
        'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,...
        'X_Tick_Label_Size',X_Tick_Label_Size,...
        'Y_Tick_Label_Size',Y_Tick_Label_Size, ...
        'Indicator_Size',Indicator_Size,'PlotColors',PlotColors,'InFigure',InFigure);

ylim(YLimits);
if ~any(isnan(XLimits))
xlim(XLimits);
end

if ~isempty(PlotPath)
    PlotName=sprintf('%s_%s_Proportion-Correlated_%s',SessionName,ProbeName,'Model');
    PlotPathName=[PlotPath filesep PlotName];
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end

% [InFigure,~,~] = cgg_plotTimeSeriesPlot(Plot_Series,'ErrorMetric',Model_STE,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'InFigure',InFigure);

%%
for cidx = 1:NumCoefficients
% sel_cidx = 2;
CoefficientSaveName = char(Coefficient_Names(cidx));
this_CriteriaCoefficients = CriteriaCoefficients(:,:,cidx);
[this_Coefficient,this_Coefficient_STD,this_Coefficient_STE,this_Coefficient_CI] = ...
    cgg_getMeanSTDSeries(this_CriteriaCoefficients,'NumCollapseDimension',NumChannels);
% [InFigure,~,~] = cgg_plotTimeSeriesPlot(this_Coefficient,'ErrorMetric',this_Coefficient_STE,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'InFigure',InFigure,'PlotTitle',PlotTitle);

Plot_Series = cell(1,1);
PlotError = cell(1,1);
Plot_Series{1} = this_Coefficient;
if WantCI
PlotError{1} = this_Coefficient_STE;
else
PlotError{1} = this_Coefficient_CI;
end

% [Coefficients,Coefficients_STD,Coefficients_STE,Coefficients_CI] = ...
%     cgg_getMeanSTDSeries(CriteriaCoefficients,'NumCollapseDimension',NumChannels);
PlotTitle = CoefficientSaveName;
[~,~,~] = cgg_plotTimeSeriesPlot(Plot_Series,...
        'Time_Start',Time_Start,'Time_End',Time_End,...
        'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
        'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
        'PlotTitle',PlotTitle,'PlotNames',PlotNames,...
        'wantDecisionIndicators',wantDecisionIndicators,...
        'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
        'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
        'ErrorMetric',PlotError,...
        'Line_Width',Line_Width,'WantLegend',WantLegend,...
        'Title_Size',Title_Size,'Error_FaceAlpha',Error_FaceAlpha,...
        'Error_EdgeAlpha',Error_EdgeAlpha,'Legend_Size',Legend_Size,...
        'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,...
        'X_Tick_Label_Size',X_Tick_Label_Size,...
        'Y_Tick_Label_Size',Y_Tick_Label_Size, ...
        'Indicator_Size',Indicator_Size,'PlotColors',PlotColors,'InFigure',InFigure);

ylim(YLimits);
if ~any(isnan(XLimits))
xlim(XLimits);
end

%%

if ~isempty(PlotPath)
    PlotName=sprintf('%s_%s_Proportion-Correlated_%s',SessionName,ProbeName,CoefficientSaveName);
    PlotPathName=[PlotPath filesep PlotName];
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end

end


end

