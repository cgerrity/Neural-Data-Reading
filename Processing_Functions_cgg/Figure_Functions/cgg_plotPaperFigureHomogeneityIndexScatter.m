function cgg_plotPaperFigureHomogeneityIndexScatter(PlotTable,varargin)
%CGG_PLOTPAPERFIGUREROIBAR Summary of this function goes here
%   Detailed explanation goes here
%%
[AreaNamesIDX,AreaNames] = findgroups(PlotTable.Area);
[LMNamesIDX,LMNames] = findgroups(PlotTable.Model_Variable);
% [MonkeyNamesIDX,MonkeyNames] = findgroups(PlotTable.Monkey);

%%

isfunction=exist('varargin','var');

if isfunction
InFigure = CheckVararginPairs('InFigure', '', varargin{:});
else
if ~(exist('InFigure','var'))
InFigure='';
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
Y_Name = CheckVararginPairs('Y_Name', {'Homogeneity Index'}, varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name={'Homogeneity Index'};
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
GroupNames = CheckVararginPairs('GroupNames', cellstr(AreaNames), varargin{:});
else
if ~(exist('GroupNames','var'))
GroupNames=cellstr(AreaNames);
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
MonkeyName = CheckVararginPairs('MonkeyName', '', varargin{:});
else
if ~(exist('MonkeyName','var'))
MonkeyName='';
end
end

if isfunction
ROIName = CheckVararginPairs('ROIName', '', varargin{:});
else
if ~(exist('ROIName','var'))
ROIName='';
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
WantLegend = CheckVararginPairs('WantLegend', true, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=true;
end
end

if isfunction
ErrorCapSize = CheckVararginPairs('ErrorCapSize', 2, varargin{:});
else
if ~(exist('ErrorCapSize','var'))
ErrorCapSize=2;
end
end

if isfunction
SignificanceFontSize = CheckVararginPairs('SignificanceFontSize', 6, varargin{:});
else
if ~(exist('SignificanceFontSize','var'))
SignificanceFontSize=6;
end
end

if isfunction
WantBarNames = CheckVararginPairs('WantBarNames', true, varargin{:});
else
if ~(exist('WantBarNames','var'))
WantBarNames=true;
end
end

if isfunction
X_TickFontSize = CheckVararginPairs('X_TickFontSize', 8, varargin{:});
else
if ~(exist('X_TickFontSize','var'))
X_TickFontSize=8;
end
end

if isfunction
WantLarge = CheckVararginPairs('WantLarge', true, varargin{:});
else
if ~(exist('WantLarge','var'))
WantLarge=true;
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
WantAbsolute = CheckVararginPairs('WantAbsolute', false, varargin{:});
else
if ~(exist('WantAbsolute','var'))
WantAbsolute=false;
end
end

if isfunction
NeighborhoodSize = CheckVararginPairs('NeighborhoodSize', '', varargin{:});
else
if ~(exist('NeighborhoodSize','var'))
NeighborhoodSize='';
end
end

if isfunction
WantCorrelationMeasure = CheckVararginPairs('WantCorrelationMeasure', false, varargin{:});
else
if ~(exist('WantCorrelationMeasure','var'))
WantCorrelationMeasure=false;
end
end

if isfunction
ColorOrder = CheckVararginPairs('ColorOrder', [0,0.4470,7410;0.8500,0.3250,0.0980], varargin{:});
else
if ~(exist('ColorOrder','var'))
ColorOrder=[0,0.4470,7410;0.8500,0.3250,0.0980];
end
end

if isfunction
WantScatter = CheckVararginPairs('WantScatter', true, varargin{:});
else
if ~(exist('WantScatter','var'))
WantScatter=true;
end
end

%%

NumAreas = length(AreaNames);
NumLM = length(LMNames);

Plot_Bar = cell(NumLM,1);
PlotError = cell(NumLM,1);
Plot_P_Value = cell(NumLM,1);
NumData = cell(NumLM,1);
Plot_Confidence = cell(NumLM,1);
% PlotDifference = cell(NumLM,1);
% PlotDifference_STE = cell(NumLM,1);
% PlotDifference_P_Value = cell(NumLM,1);
% SaveAreaNames = string();

for lidx = 1:NumLM
    this_LMNamesIDX = LMNamesIDX == lidx;
for aidx = 1:NumAreas
    this_AreaNamesIDX = AreaNamesIDX == aidx;
    this_TableIDX = this_LMNamesIDX & this_AreaNamesIDX;
    this_PlotTable = PlotTable(this_TableIDX,:);
    % AreaName = this_PlotTable{1,"Area"};
    % SaveAreaNames = SaveAreaNames + AreaName;
    PlotData = this_PlotTable{1,"PlotData"};
    PlotData = PlotData{1};

    if WantCorrelationMeasure
    Plot_Bar{lidx}(aidx) = PlotData.HomogeneityIndex_Correlation;
        if WantCI
        PlotError{lidx}(aidx) = PlotData.HomogeneityIndex_Correlation_CI;
        else
        PlotError{lidx}(aidx) = PlotData.HomogeneityIndex_Correlation_STE;
        end
    Plot_P_Value{lidx}(aidx) = PlotData.HomogeneityIndex_Correlation_P_Value;
    Plot_Confidence{lidx}(aidx,:) = PlotData.ConfidenceRange_Correlation;
    else
    Plot_Bar{lidx}(aidx) = PlotData.HomogeneityIndex;
        if WantCI
        PlotError{lidx}(aidx) = PlotData.HomogeneityIndex_CI;
        else
        PlotError{lidx}(aidx) = PlotData.HomogeneityIndex_STE;
        end
    Plot_P_Value{lidx}(aidx) = PlotData.HomogeneityIndex_P_Value;
    Plot_Confidence{lidx}(aidx,:) = PlotData.ConfidenceRange;
    end

    if WantAbsolute
    Plot_Bar{lidx}(aidx) = abs(Plot_Bar{lidx}(aidx));
    end

    NumData{lidx}(aidx) = PlotData.NumData;    
end
end

%%
% DataTransform = [];
% wantSubPlot = true;

%% Rank Ordering

[~,RankOrder] = sort(cellfun(@(x) max(abs(x)),Plot_Bar),"ascend");

Plot_Bar = Plot_Bar(RankOrder);
LMNames = LMNames(RankOrder);
PlotError = PlotError(RankOrder);
Plot_P_Value = Plot_P_Value(RankOrder);
Plot_Confidence = Plot_Confidence(RankOrder);
%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);

wantPaperSized = cfg_Paper.wantPaperSized;
Legend_Size = cfg_Paper.Legend_Size;

%%

Y_TickDir = cfg_Paper.TickDir_Correlation;

% if WantLarge
% YLimits = cfg_Paper.Limit_ChannelProportion_Large;
% Y_Tick_Size = cfg_Paper.Tick_Size_ChannelProportion_Large;
% else
if WantCorrelationMeasure
YLimits = cfg_Paper.Limit_HomogeneityIndex_Correlation;
Y_Tick_Size = cfg_Paper.Tick_Size_HomogeneityIndex_Correlation;
else
YLimits = cfg_Paper.Limit_HomogeneityIndex;
Y_Tick_Size = cfg_Paper.Tick_Size_HomogeneityIndex;
end

if WantAbsolute
    YLimits(1) = 0;
end
% end

Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);

%%

if ~isempty(InFigure)
    
elseif wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,6];
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

TableVariables = [["P Value", "double"]; ...
                  ["Group Name 1", "cell"]; ...
                  ["Group Name 2", "cell"]; ...
                  ["Bar Name 1", "cell"]; ...
                  ["Bar Name 2", "cell"]];

NumVariables = size(TableVariables,1);
SignificanceTable = table('Size',[0,NumVariables],...
                          'VariableNames', TableVariables(:,1),...
                          'VariableTypes', TableVariables(:,2));
Counter_SignigficanceTable = 0;
for lidx = 1:NumLM
    LMName = LMNames(lidx);
for aidx = 1:NumAreas
    AreaName = AreaNames(aidx);
    Counter_SignigficanceTable = Counter_SignigficanceTable + 1;
    SignificanceTable(Counter_SignigficanceTable,:) = {Plot_P_Value{lidx}(aidx),{AreaName},{""},{LMName},{""}};
end
end

SignificanceTable = [];
%%
wantCI = false;
IsGrouped = true;
% ColorOrder = [0,0.4470,7410;0.8500,0.3250,0.0980];
WantHorizontal = true;
LabelAngle = 45;

[~,~,InFigure] = cgg_plotBarGraphWithError(Plot_Bar,LMNames, ...
    'X_Name',Y_Name,'Y_Name','','PlotTitle',PlotTitle,'YRange',YLimits, ...
    'wantCI',wantCI,'SignificanceValue',SignificanceValue, ...
    'ColorOrder',ColorOrder,'IsGrouped',IsGrouped, ...
    'GroupNames',GroupNames,'ErrorMetric',PlotError, ...
    'WantLegend',WantLegend,'ErrorCapSize',ErrorCapSize, ...
    'SignificanceTable',SignificanceTable, ...
    'SignificanceFontSize',SignificanceFontSize, ...
    'WantBarNames',WantBarNames,'WantHorizontal',WantHorizontal, ...
    'X_TickFontSize',X_TickFontSize,'Legend_Size',Legend_Size, ...
    'LabelAngle',LabelAngle,'InFigure',InFigure, ...
    'WantScatter',WantScatter,'ConfidenceRange',Plot_Confidence);
% ylim([0,5]);
%%

    if ~(isempty(Y_Ticks) || any(isnan(Y_Ticks)))
    % yticks(Y_Ticks);
    xticks(Y_Ticks);
    end

    % xticks([]);

    box off

    if ~isempty(Y_TickDir)
    % InFigure.CurrentAxes.YAxis.TickDirection=Y_TickDir;
    InFigure.CurrentAxes.XAxis.TickDirection=Y_TickDir;
    end

%%

if ~isempty(PlotPath)
    if ~isempty(MonkeyName)
        MonkeyName = sprintf("-%s",MonkeyName);
    end
    if ~isempty(ROIName)
        ROIName = sprintf("-%s",ROIName);
    end
    if ~isempty(NeighborhoodSize)
        NeighborhoodSizeName = sprintf("-Size_%d",NeighborhoodSize);
    else
        NeighborhoodSizeName = '';
    end
    if WantCorrelationMeasure
        CorrelationName = "-Correlation";
    else
        CorrelationName = '';
    end
    if WantAbsolute
    PlotName=sprintf('Homogeneity_Index%s_Absolute%s_Bar%s%s',CorrelationName,ROIName,NeighborhoodSizeName,MonkeyName);
    else
    PlotName=sprintf('Homogeneity_Index%s_Bar%s%s%s',CorrelationName,ROIName,NeighborhoodSizeName,MonkeyName);
    end
    PlotPathName=[PlotPath filesep PlotName];
    saveas(InFigure,[PlotPathName, '.fig']);
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end


end

