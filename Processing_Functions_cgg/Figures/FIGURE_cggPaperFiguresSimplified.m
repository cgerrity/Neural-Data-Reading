%% FIGURE_cggPaperFigures

% clc; clear; close all;
%% User Parameters
% Set Directory where figures will be saved. If empty the figure is not
% saved.
PlotPath = '/Users/cgerrity/Downloads/TestFolder'; 
WantCloseEachFigure = true; % Close each figure after rendering and saving
%%
Version = 'Paper'; % Paper, Dissertation

WantCI = false;
WantSTD = false;
WantBonferroni = false;

NeighborhoodSize = 30;

%%

HasPlotTable = exist('PlotTableAll','var');

if HasPlotTable
[ROINames,~,ROIIDX] = unique(string(PlotTableAll{:,"ROI"}));
else
    return
end


%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);

switch Version
    case 'Paper'
        WantDecisionCentered = false;
    case 'Dissertation'
        WantDecisionCentered = true;
    otherwise
        WantDecisionCentered = false;
end

%%

%%
for ridx = 1:length(ROINames)
%%
ROIName = ROINames(ridx);
this_ROIIDX = ROIIDX == ridx;
PlotTableROI = PlotTableAll(this_ROIIDX,:);

[LM_Variables,~,LM_VariablesIDX] = unique(PlotTableROI{:,"Model_Variable"});

%% Figure 2
%%
if ridx == 1
for lidx = 1:length(LM_Variables)

%% Proportion Correlated (+/-) Per Area

LM_Variable = char(LM_Variables(lidx));
this_LM_VariablesIDX = LM_VariablesIDX == lidx;
PlotTable = PlotTableROI(this_LM_VariablesIDX,:); 

X_Tick_Label_Size = 12;
Y_Tick_Label_Size = 12;

AllMonkeyIndices = strcmp(PlotTable{:,"Monkey"},"All");
ACCIndices = strcmp(PlotTable{:,"Area"},"ACC");
CDIndices = strcmp(PlotTable{:,"Area"},"CD");
PFCIndices = strcmp(PlotTable{:,"Area"},"PFC");

switch Version
    case 'Paper'
AreaIndices = ACCIndices | CDIndices;
    case 'Dissertation'
AreaIndices = ACCIndices | CDIndices | PFCIndices;
    otherwise
end

TableIndices = AllMonkeyIndices & AreaIndices;
TableIndices = find(TableIndices);

NumPlots = length(TableIndices);

PlotFunc = cell(1,NumPlots);

for idx = 1:NumPlots
this_TableIDX = TableIndices(idx);
AreaName = PlotTable{this_TableIDX,"Area"};
PlotData = PlotTable{this_TableIDX,"PlotData"};
PlotData = PlotData{1};

cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName,'LM_Variable',['Pos-Neg-' LM_Variable]);
if WantCloseEachFigure
close all
end
if idx == length(TableIndices)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'Y_Name','','WantLegend',false,'PlotTitle',AreaName,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size,'LM_Variable',['Pos-Neg-' LM_Variable]);
elseif idx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','X_Name','','WantLegend',true,'PlotTitle',AreaName,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'LM_Variable',['Pos-Neg-' LM_Variable]);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','X_Name','','WantLegend',false,'PlotTitle',AreaName,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'LM_Variable',['Pos-Neg-' LM_Variable]);
end
PlotFunc{idx} = this_PlotFunc;
end

TiledLayout = [NumPlots,1];
NextTileInformation = ones(NumPlots,3);
NextTileInformation(1:NumPlots,1) = 1:NumPlots;
% NextTileInformation = [1,1,1;2,1,1];
Y_Name = {'Proportion of','Significant Channels'};

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'Y_Name',Y_Name,'WantDecisionCentered',WantDecisionCentered);

if WantCloseEachFigure
close all
end
%% Region Of Interest

ErrorCapSize_Small = 2;
ErrorCapSize_Large = 6;
SignificanceFontSize_Small = 3;
SignificanceFontSize_Large = 6;

[MonkeyNamesIDX,MonkeyNames] = findgroups(PlotTable.Monkey);

% this_PlotTable = PlotTable(TableIndices,:);

PlotFunc = cell(1,length(MonkeyNames));

for midx = 1:length(MonkeyNames)

    this_MonkeyIndices = MonkeyNamesIDX == midx;
    this_MonkeyName = MonkeyNames(midx);

this_TableIDX = this_MonkeyIndices & AreaIndices;
this_TableIDX = find(this_TableIDX);

this_PlotTable = PlotTable(this_TableIDX,:);

cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'MonkeyName',this_MonkeyName,'WantLegend',true,'ROIName',ROIName,'LM_Variable',LM_Variable);
if WantCloseEachFigure
close all
end
if midx == length(MonkeyNames)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'ROIName',ROIName,'LM_Variable',LM_Variable);
elseif midx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'WantLegend',true,'ErrorCapSize',ErrorCapSize_Large,'SignificanceFontSize',SignificanceFontSize_Large,'ROIName',ROIName,'LM_Variable',LM_Variable);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'ROIName',ROIName,'LM_Variable',LM_Variable);
end
PlotFunc{midx} = this_PlotFunc;
end


TiledLayout = [2,3];
NextTileInformation = [1,2,2;3,1,1;6,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'WantDecisionCentered',WantDecisionCentered);
if WantCloseEachFigure
close all
end
end
end
%%

%% Figure 3

Y_Name_Size = 14;
X_Name_Size = 14;
Legend_Size = 4;
X_Tick_Label_Size = 12;
Y_Tick_Label_Size = 12;
if ridx == 1
for lidx = 1:length(LM_Variables)
    LM_Variable = char(LM_Variables(lidx));
this_LM_VariablesIDX = LM_VariablesIDX == lidx;
PlotTable = PlotTableROI(this_LM_VariablesIDX,:);
%%

AllMonkeyIndices = strcmp(PlotTable{:,"Monkey"},"All");
ACCIndices = strcmp(PlotTable{:,"Area"},"ACC");
CDIndices = strcmp(PlotTable{:,"Area"},"CD");
PFCIndices = strcmp(PlotTable{:,"Area"},"PFC");
AllACCIndices = ACCIndices & AllMonkeyIndices;
AllCDIndices = CDIndices & AllMonkeyIndices;
AllPFCIndices = PFCIndices & AllMonkeyIndices;

PlotTable_ACC = PlotTable(AllACCIndices,:);
PlotTable_CD = PlotTable(AllCDIndices,:);
PlotTable_PFC = PlotTable(AllPFCIndices,:);

PlotData_ACC = PlotTable_ACC.PlotData;
PlotData_ACC = PlotData_ACC{1};
PlotData_CD = PlotTable_CD.PlotData;
PlotData_CD = PlotData_CD{1};
PlotData_PFC = PlotTable_PFC.PlotData;
PlotData_PFC = PlotData_PFC{1};

PlotFunc = cell(1,2);

switch Version
    case 'Paper'
this_PlotData = {PlotData_ACC,PlotData_CD};
PlotNames = {'ACC','CD'};
PlotColors = {cfg_Paper.Color_ACC,cfg_Paper.Color_CD};
    case 'Dissertation'
this_PlotData = {PlotData_ACC,PlotData_PFC,PlotData_CD};
PlotNames = {'ACC','PFC','CD'};
PlotColors = {cfg_Paper.Color_ACC,cfg_Paper.Color_PFC,cfg_Paper.Color_CD};
    otherwise
this_PlotData = {PlotData_ACC,PlotData_CD};
PlotNames = {'ACC','CD'};
PlotColors = {cfg_Paper.Color_ACC,cfg_Paper.Color_CD};
end

cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',['LM-' LM_Variable],'PlotTitle',LM_Variable,'PlotNames',PlotNames,'WantLegend',true,'WantLarge',true,'PlotColors',PlotColors);
cgg_plotPaperFigureCorrelation(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',['LM-' LM_Variable],'PlotTitle',LM_Variable,'PlotNames',PlotNames,'WantLegend',true,'PlotColors',PlotColors);

if WantCloseEachFigure
close all
end

PlotFunc{1} = @(InFigure) cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','WantLegend',true,'X_Name','','PlotTitle','','PlotNames',PlotNames,'WantLarge',true,'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors);
PlotFunc{2} = @(InFigure) cgg_plotPaperFigureCorrelation(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'Y_Name','','WantLegend',false,'PlotNames',PlotNames,'SeparatePlotName',['LM-Stacked-' LM_Variable],'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors);

TiledLayout = [2,1];
NextTileInformation = [1,1,1;2,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'FigureTitle',LM_Variable,'WantDecisionCentered',WantDecisionCentered);

if WantCloseEachFigure
close all
end
end
end
%% Homogeneity Index

[MonkeyNamesIDX,MonkeyNames] = findgroups(PlotTableROI.Monkey);

for midx = 1:length(MonkeyNames)

MonkeyName = MonkeyNames(midx);

AllMonkeyIndices = strcmp(PlotTableROI{:,"Monkey"},MonkeyName);
ACCIndices = strcmp(PlotTableROI{:,"Area"},"ACC");
CDIndices = strcmp(PlotTableROI{:,"Area"},"CD");
AreaIndices = ACCIndices | CDIndices;

TableIndices = AllMonkeyIndices & AreaIndices;

this_PlotTable = PlotTableROI(TableIndices,:);

ColorOrder = cell2mat(PlotColors');
% ColorOrder(2,:) = [];

if strcmp(MonkeyName,"All")
MonkeyName = '';
end

cgg_plotPaperFigureROIAllLearningVariablesBar(this_PlotTable,'PlotPath',PlotPath,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName,'ROIName',ROIName);
cgg_plotPaperFigureROIAllLearningVariablesDifferenceBar(this_PlotTable,'PlotPath',PlotPath,'ColorOrder',[],'MonkeyName',MonkeyName,'ROIName',ROIName);
cgg_plotPaperFigureHomogeneityIndexScatter(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',false,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',false,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName,'ROIName',ROIName,'WantCI',WantCI,'WantSTD',WantSTD,'WantBonferroni',WantBonferroni);
cgg_plotPaperFigureHomogeneityIndexBox(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',false,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',false,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName,'ROIName',ROIName,'WantCI',WantCI,'WantSTD',WantSTD,'WantBonferroni',WantBonferroni);

if WantCloseEachFigure
close all
end
end

end

