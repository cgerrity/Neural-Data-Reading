function cgg_plotLatentCorrelationAnalysis(CorrelationTable,cfg,varargin)
%CGG_PLOTLATENTCORRELATIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',false);

isfunction=exist('varargin','var');

if isfunction
Time_Start = CheckVararginPairs('Time_Start', cfg.Time_Start, varargin{:});
else
if ~(exist('Time_Start','var'))
Time_Start=cfg.Time_Start;
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
SamplingRate = CheckVararginPairs('SamplingRate', cfg.SamplingFrequency, varargin{:});
else
if ~(exist('SamplingRate','var'))
SamplingRate=cfg.SamplingFrequency;
end
end

if isfunction
DataWidth = CheckVararginPairs('DataWidth', cfg.DataWidth/SamplingRate, varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth=cfg.DataWidth/SamplingRate;
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', cfg.WindowStride/SamplingRate, varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride=cfg.WindowStride/SamplingRate;
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
WantLegend = CheckVararginPairs('WantLegend', false, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=false;
end
end

if isfunction
WantCI = CheckVararginPairs('WantCI', true, varargin{:});
else
if ~(exist('WantCI','var'))
WantCI=true;
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
TileSpacing = CheckVararginPairs('TileSpacing', "tight", varargin{:});
else
if ~(exist('TileSpacing','var'))
TileSpacing="tight";
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

Y_TickDir = cfg_Paper.TickDir_ChannelProportion;
X_TickDir = cfg_Paper.TickDir_Time;


YLimits_Proportion = cfg_Paper.Limit_LatentProportion;
Y_Tick_Size_Proportion = cfg_Paper.Tick_Size_LatentProportion;

YLimits_Correlation = cfg_Paper.Limit_LatentCorrelation;
Y_Tick_Size_Correlation = cfg_Paper.Tick_Size_LatentCorrelation;

XLimits = cfg_Paper.Limit_Time;
X_Tick_Size = cfg_Paper.Tick_Size_Time;

Y_Ticks_Proportion = YLimits_Proportion(1):Y_Tick_Size_Proportion:YLimits_Proportion(2);
Y_Ticks_Correlation = YLimits_Correlation(1):Y_Tick_Size_Correlation:YLimits_Correlation(2);
X_Ticks = XLimits(1):X_Tick_Size:XLimits(2);
X_Name_Figure = X_Name;
%%

LMVariables = CorrelationTable.LMVariable;
NumLMVariables = length(LMVariables);

for lmidx = 1:NumLMVariables


this_CorrelationTable = CorrelationTable(lmidx,:);
this_LMVariable = this_CorrelationTable.LMVariable;

%%

PlotTitle_Figure = this_LMVariable;

%%

Proportion = this_CorrelationTable.Proportion;
Correlation = this_CorrelationTable.Correlation;

if WantCI
    ProportionError = this_CorrelationTable.Proportion_CI;
    CorrelationError = this_CorrelationTable.Correlation_CI;
else
    ProportionError = this_CorrelationTable.Proportion_STE;
    CorrelationError = this_CorrelationTable.Correlation_STE;
end

%%

if wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.OuterPosition=[0,0,4,4];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
% PlotPaperSize=InFigure.Position;
PlotPaperSize=InFigure.OuterPosition;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
InFigure.PaperPosition=InFigure.OuterPosition*1.5;
InFigure.PaperPositionMode='manual';
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

TiledPlot = tiledlayout(2,1,'TileSpacing',TileSpacing);

title(TiledPlot,PlotTitle_Figure,'FontSize',Title_Size);
xlabel(TiledPlot,X_Name_Figure,'FontSize',X_Name_Size);

%% Proportion
this_Tile = nexttile(TiledPlot);

Y_Name = {'Proportion of','Significant Latent Variables'};
PlotTitle = '';
PlotNames={'Plot'};
X_Name = '';

[~,~,~] = cgg_plotTimeSeriesPlot(Proportion,...
        'Time_Start',Time_Start,'Time_End',Time_End,...
        'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
        'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
        'PlotTitle',PlotTitle,'PlotNames',PlotNames,...
        'wantDecisionIndicators',wantDecisionIndicators,...
        'wantSubPlot',wantSubPlot,...
        'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Y_Ticks',Y_Ticks_Proportion,'X_Ticks',X_Ticks,...
        'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
        'DataTransform',DataTransform,'ErrorMetric',ProportionError,...
        'Line_Width',Line_Width,'WantLegend',WantLegend,...
        'Title_Size',Title_Size,'Error_FaceAlpha',Error_FaceAlpha,...
        'Error_EdgeAlpha',Error_EdgeAlpha,'Legend_Size',Legend_Size,...
        'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,...
        'X_Tick_Label_Size',X_Tick_Label_Size,...
        'Y_Tick_Label_Size',Y_Tick_Label_Size);

ylim(YLimits_Proportion);
% xlim(XLimits);

%% Correlation
this_Tile = nexttile(TiledPlot);

Y_Name = {'Absolute Correlation Strength'};
PlotTitle = '';
PlotNames={'Plot'};
X_Name = '';

[~,~,~] = cgg_plotTimeSeriesPlot(Correlation,...
        'Time_Start',Time_Start,'Time_End',Time_End,...
        'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
        'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
        'PlotTitle',PlotTitle,'PlotNames',PlotNames,...
        'wantDecisionIndicators',wantDecisionIndicators,...
        'wantSubPlot',wantSubPlot,...
        'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Y_Ticks',Y_Ticks_Correlation,'X_Ticks',X_Ticks,...
        'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
        'DataTransform',DataTransform,'ErrorMetric',CorrelationError,...
        'Line_Width',Line_Width,'WantLegend',WantLegend,...
        'Title_Size',Title_Size,'Error_FaceAlpha',Error_FaceAlpha,...
        'Error_EdgeAlpha',Error_EdgeAlpha,'Legend_Size',Legend_Size,...
        'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,...
        'X_Tick_Label_Size',X_Tick_Label_Size,...
        'Y_Tick_Label_Size',Y_Tick_Label_Size);

ylim(YLimits_Correlation);
% xlim(XLimits);

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Correlation');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Latent-Correlation-Analysis_LM-%s',this_LMVariable);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

end

end

