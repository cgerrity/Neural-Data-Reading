function cgg_plotPaperFigureROIAllLearningVariablesBar(PlotTable,varargin)
%CGG_PLOTPAPERFIGUREROIBAR Summary of this function goes here
%   Detailed explanation goes here
%%
[AreaNamesIDX,AreaNames] = findgroups(PlotTable.Area);
[LMNamesIDX,LMNames] = findgroups(PlotTable.Model_Variable);

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
X_TickFontSize = CheckVararginPairs('X_TickFontSize', 4, varargin{:});
else
if ~(exist('X_TickFontSize','var'))
X_TickFontSize=4;
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
ColorOrder = CheckVararginPairs('ColorOrder', [0,0.4470,7410;0.8500,0.3250,0.0980], varargin{:});
else
if ~(exist('ColorOrder','var'))
ColorOrder=[0,0.4470,7410;0.8500,0.3250,0.0980];
end
end

%%

NumAreas = length(AreaNames);
NumLM = length(LMNames);

Plot_Bar = cell(NumLM,1);
PlotError = cell(NumLM,1);
Plot_P_Value = cell(NumLM,1);
NumData = cell(NumLM,1);
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

    Plot_Bar{lidx}(aidx) = PlotData.ProportionAll_ROI;
    if WantCI
    PlotError{lidx}(aidx) = PlotData.All_ROI_CI;
    else
    PlotError{lidx}(aidx) = PlotData.All_ROI_STE;
    end
    Plot_P_Value{lidx}(aidx) = PlotData.All_ROI_P_Value;
    NumData{lidx}(aidx) = PlotData.NumData;    
end
end

%%
% DataTransform = [];
% wantSubPlot = true;
%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);

wantPaperSized = cfg_Paper.wantPaperSized;
Legend_Size = cfg_Paper.Legend_Size;

%%

Y_TickDir = cfg_Paper.TickDir_ChannelProportion;

if WantLarge
YLimits = cfg_Paper.Limit_ChannelProportion_Large;
Y_Tick_Size = cfg_Paper.Tick_Size_ChannelProportion_Large;
else
YLimits = cfg_Paper.Limit_ChannelProportion;
Y_Tick_Size = cfg_Paper.Tick_Size_ChannelProportion;
end

Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);

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

[~,~,InFigure] = cgg_plotBarGraphWithError(Plot_Bar,LMNames,'X_Name',Y_Name,'Y_Name','','PlotTitle',PlotTitle,'YRange',YLimits,'wantCI',wantCI,'SignificanceValue',SignificanceValue,'ColorOrder',ColorOrder,'IsGrouped',IsGrouped,'GroupNames',GroupNames,'ErrorMetric',PlotError,'WantLegend',WantLegend,'ErrorCapSize',ErrorCapSize,'SignificanceTable',SignificanceTable,'SignificanceFontSize',SignificanceFontSize,'WantBarNames',WantBarNames,'WantHorizontal',WantHorizontal,'X_TickFontSize',X_TickFontSize,'Legend_Size',Legend_Size,'LabelAngle',LabelAngle,'InFigure',InFigure);
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
    PlotName=sprintf('ROI_LM_Variables_Bar%s%s',ROIName,MonkeyName);
    PlotPathName=[PlotPath filesep PlotName];
    saveas(InFigure,[PlotPathName, '.fig']);
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end


end

