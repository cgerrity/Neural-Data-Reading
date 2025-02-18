function cgg_plotPaperFigureROIBar(PlotTable,varargin)
%CGG_PLOTPAPERFIGUREROIBAR Summary of this function goes here
%   Detailed explanation goes here

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
GroupNames = CheckVararginPairs('GroupNames', {'Positive','Negative'}, varargin{:});
else
if ~(exist('GroupNames','var'))
GroupNames={'Positive','Negative'};
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
WantLegend = CheckVararginPairs('WantLegend', false, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=false;
end
end

if isfunction
ErrorCapSize = CheckVararginPairs('ErrorCapSize', 10, varargin{:});
else
if ~(exist('ErrorCapSize','var'))
ErrorCapSize=10;
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
WantCI = CheckVararginPairs('WantCI', false, varargin{:});
else
if ~(exist('WantCI','var'))
WantCI=false;
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
WantMedium = CheckVararginPairs('WantMedium', false, varargin{:});
else
if ~(exist('WantMedium','var'))
WantMedium=false;
end
end

%%
[AreaNamesIDX,AreaNames] = findgroups(PlotTable.Area);

%%

NumAreas = length(AreaNames);

Plot_Bar = cell(NumAreas,1);
PlotError = cell(NumAreas,1);
PlotDifference = cell(NumAreas,1);
PlotDifference_STE = cell(NumAreas,1);
NumData = cell(NumAreas,1);
PlotDifference_P_Value = cell(NumAreas,1);
SaveAreaNames = string();

for aidx = 1:NumAreas
    this_AreaNamesIDX = AreaNamesIDX == aidx;
    AreaName = PlotTable{this_AreaNamesIDX,"Area"};
    SaveAreaNames = SaveAreaNames + AreaName;
    PlotData = PlotTable{this_AreaNamesIDX,"PlotData"};
    PlotData = PlotData{1};
    Plot_Bar{aidx} = [PlotData.ProportionPositive_ROI,...
        PlotData.ProportionNegative_ROI];
    if WantCI
    PlotError{aidx} = [PlotData.Positive_ROI_CI,...
        PlotData.Negative_ROI_CI];
    else
    PlotError{aidx} = [PlotData.Positive_ROI_STE,...
        PlotData.Negative_ROI_STE];
    end

    PlotDifference{aidx} = PlotData.ProportionDifference_Series_ROI;
    NumData{aidx} = PlotData.NumData;
    
    [PlotDifference{aidx},~,PlotDifference_STE{aidx},~] = ...
    cgg_getMeanSTDSeries(PlotData.ProportionDifference_Series_ROI,'NumSamples',1);

    PlotDifference_T = PlotDifference{aidx}/PlotDifference_STE{aidx};

    PlotDifference_P_Value{aidx} = tcdf(-abs(PlotDifference_T),NumData{aidx}-1) + tcdf(abs(PlotDifference_T),NumData{aidx}-1,'upper');
    
end

%%
% DataTransform = [];
% wantSubPlot = true;
%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);

wantPaperSized = cfg_Paper.wantPaperSized;

%%

Y_TickDir = cfg_Paper.TickDir_ChannelProportion;

if WantLarge
YLimits = cfg_Paper.Limit_ChannelProportion_Large;
Y_Tick_Size = cfg_Paper.Tick_Size_ChannelProportion_Large;
elseif WantMedium
YLimits = cfg_Paper.Limit_ChannelProportion_Medium;
Y_Tick_Size = cfg_Paper.Tick_Size_ChannelProportion_Medium;
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

for aidx = 1:NumAreas
    this_AreaNamesIDX = AreaNamesIDX(aidx);
    AreaName = PlotTable{this_AreaNamesIDX,"Area"};
    SignificanceTable(aidx,:) = {PlotDifference_P_Value{aidx},{"Positive"},{"Negative"},{AreaName},{AreaName}};
end

Combinations = nchoosek(1:NumAreas,2);

for cidx = 1:height(Combinations)
Area1 = Combinations(cidx,1);
Area2 = Combinations(cidx,2);

AreaNamesIDX1 = AreaNamesIDX(Area1);
AreaNamesIDX2 = AreaNamesIDX(Area2);

AreaName1 = PlotTable{AreaNamesIDX1,"Area"};
AreaName2 = PlotTable{AreaNamesIDX2,"Area"};

Difference1 = PlotDifference{Area1};
Difference2 = PlotDifference{Area2};

STE1 = PlotDifference_STE{Area1};
STE2 = PlotDifference_STE{Area2};

NumData1 = NumData{Area1};
NumData2 = NumData{Area2};

this_T = (Difference1-Difference2)/sqrt(STE1^2+STE2^2);
this_DF = ((STE1^2+STE2^2)^2)/(((STE1^2)^2)/(NumData1-1)+((STE2^2)^2)/(NumData2-1));

this_P_Value = tcdf(-abs(this_T),this_DF) + tcdf(abs(this_T),this_DF,'upper');

SignificanceTable(cidx+NumAreas,:) = {this_P_Value,{["Positive","Negative"]},{["Positive","Negative"]},{AreaName1},{AreaName2}};
end

% %%
% 
% TableVariables = [["P Value", "double"]; ...
%                   ["Group Name 1", "cell"]; ...
%                   ["Group Name 2", "cell"]; ...
%                   ["Bar Name 1", "cell"]; ...
%                   ["Bar Name 2", "cell"]];
% 
% NumVariables = size(TableVariables,1);
% SignificanceTable = table('Size',[0,NumVariables],...
%                           'VariableNames', TableVariables(:,1),...
%                           'VariableTypes', TableVariables(:,2));
% SignificanceTable(1,:) = {0.002,{"High"},{"Medium"},{"First"},{"First"}};
% SignificanceTable(2,:) = {0.01,{"High"},{"Medium"},{"Second"},{"Second"}};
% SignificanceTable(3,:) = {0.01,{["High","Medium"]},{["High","Medium"]},{"First"},{"Second"}};
% SignificanceTable(4,:) = {0.02,{"High"},{""},{"First"},{""}};

%%
wantCI = false;
IsGrouped = true;
ColorOrder = [0,0.4470,7410;0.8500,0.3250,0.0980];
WantHorizontal = false;

[~,~,InFigure] = cgg_plotBarGraphWithError(Plot_Bar,AreaNames,'X_Name','','Y_Name',Y_Name,'PlotTitle',PlotTitle,'YRange',YLimits,'wantCI',wantCI,'SignificanceValue',SignificanceValue,'ColorOrder',ColorOrder,'IsGrouped',IsGrouped,'GroupNames',GroupNames,'ErrorMetric',PlotError,'WantLegend',WantLegend,'ErrorCapSize',ErrorCapSize,'SignificanceTable',SignificanceTable,'SignificanceFontSize',SignificanceFontSize,'WantBarNames',WantBarNames,'WantHorizontal',WantHorizontal,'InFigure',InFigure);
% ylim([0,5]);
%%
    if ~(isempty(Y_Ticks) || any(isnan(Y_Ticks)))
    yticks(Y_Ticks);
    end

    % xticks([]);

    box off

    if ~isempty(Y_TickDir)
    InFigure.CurrentAxes.YAxis.TickDirection=Y_TickDir;
    end

%%

if ~isempty(PlotPath)
    if ~isempty(MonkeyName)
        MonkeyName = sprintf("-%s",MonkeyName);
    end
    if ~isempty(ROIName)
        ROIName = sprintf("-%s",ROIName);
    end
    PlotName=sprintf('ROI_Bar-%s%s%s',SaveAreaNames,ROIName,MonkeyName);
    PlotPathName=[PlotPath filesep PlotName];
    saveas(InFigure,[PlotPathName, '.fig']);
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
end


end

