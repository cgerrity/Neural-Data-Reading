%% FIGURE_cggPaperFigures

clc; clear; close all;
%%
EVType = 'Absolute Prediction Error';
Epoch = 'Decision';
Version = 'Paper'; % Paper, Dissertation

InIncrement = 1;
WantPlotExplainedVariance = false;
WantPlotCorrelation = false;

WantCI = true;
% This is to test that I am on the Charlie Branch

SignificanceValue = 0.05;
SignificanceMimimum = [];
% Time_ROI = [0.95,1.15];
NeighborhoodSize = 30;
NeighborhoodSize_Small = 15;

Learning_Model_Variables = {'Absolute Prediction Error',...
    'Positive Prediction Error','Negative Prediction Error','Outcome',...
    'Error Trace','Choice Probability WM','Choice Probability RL',...
    'Choice Probability CMB','Value RL','Value WM','WM Weight',...
    'Adaptive Beta'};

Variable_Figure_1 = 'Previous Trial Effect';

PlotSubFolders = {'Figure 1', 'Figure 2', 'Figure 3'};

ROINames = {'Stimulation','Feedback'};
ROITimes = [[0.3,0.6];[0.95,1.15]];

%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);

switch Version
    case 'Paper'
Save_Folder = 'Final Paper Figures';
Time_ROI = [0.95,1.15];
WantDecisionCentered = false;
    case 'Dissertation'
Save_Folder = 'Dissertation Figures';
Time_ROI = [0.95,1.15]-cfg_Paper.Time_Offset;
ROITimes = ROITimes - cfg_Paper.Time_Offset;
WantDecisionCentered = true;
    otherwise
Save_Folder = 'Final Paper Figures';
Time_ROI = [0.95,1.15];
WantDecisionCentered = false;
end
%%

if ~isempty(SignificanceMimimum)
Save_Folder = sprintf('%s ~ Significance Minimum - %.3f',Save_Folder,SignificanceMimimum);
end
if ~(SignificanceValue == 0.05)
Save_Folder = sprintf('%s ~ Alpha - %.3f',Save_Folder,SignificanceValue);
end
%%

[~,~,temporaryfolder_base,~] = cgg_getBaseFolders();

ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',Save_Folder,'PlotSubFolder',PlotSubFolders);
PlotPath = cfg_Results.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.path;

%%
for ridx = 1:length(ROINames)

ROIName = ROINames{ridx};
Time_ROI = ROITimes(ridx,:);

%% Figure 1
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

[InputCell,CoefficientNames] = ...
    cgg_procAllSessionRegressionToVariable(Variable_Figure_1,Epoch,InIncrement,...
    WantPlotExplainedVariance,WantPlotCorrelation);

PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',Variable_Figure_1,'Time_ROI',Time_ROI,'NeighborhoodSize',[],'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);

%%

WantLegend = true;
Y_Name_Size = 10;
Legend_Size = 4;
X_Tick_Label_Size = 8;
Y_Tick_Label_Size = 8;
TileSpacing = "tight";

AllMonkeyIndices = strcmp(PlotTable{:,"Monkey"},"All");
ACCIndices = strcmp(PlotTable{:,"Area"},"ACC");
CDIndices = strcmp(PlotTable{:,"Area"},"CD");
PFCIndices = strcmp(PlotTable{:,"Area"},"PFC");

switch Version
    case 'Paper'
AreaIndices = ACCIndices | CDIndices;
WantLarge = false;
    case 'Dissertation'
AreaIndices = ACCIndices | CDIndices | PFCIndices;
WantLarge = true;
    otherwise
end

TableIndices = AllMonkeyIndices & AreaIndices;
TableIndices = find(TableIndices);

for idx = 1:length(TableIndices)
this_TableIDX = TableIndices(idx);
AreaName = PlotTable{this_TableIDX,"Area"};
PlotData = PlotTable{this_TableIDX,"PlotData"};
PlotData = PlotData{1};

cgg_plotPaperFigureBetaValues(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName,'PlotNames',CoefficientNames,'WantLegend',WantLegend,'PlotTitle',AreaName,'X_Name','','WantLarge',WantLarge);
close all
cgg_plotPaperFigureModelProportion(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName,'PlotTitle',AreaName);
close all

PlotFunc_Model = @(InFigure) cgg_plotPaperFigureModelProportion(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'PlotPath',[],'AreaName',AreaName,'PlotTitle',AreaName,'Y_Name_Size',Y_Name_Size,'X_Name','','X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size);
PlotFunc_Beta = @(InFigure) cgg_plotPaperFigureBetaValues(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'PlotPath',PlotPath,'AreaName',AreaName,'PlotNames',CoefficientNames,'WantLegend',WantLegend,'SaveName','Model-Beta','Y_Name_Size',Y_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size,'WantLarge',WantLarge);

PlotFunc = cell(1,2);
PlotFunc{1} = PlotFunc_Model;
PlotFunc{2} = PlotFunc_Beta;

TiledLayout = [2,1];
NextTileInformation = [1,1,1;2,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'TileSpacing',TileSpacing,'WantDecisionCentered',WantDecisionCentered);
close all

end

%% Figure 2
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_2');

[InputCell,~] = ...
    cgg_procAllSessionRegressionToVariable(EVType,Epoch,InIncrement,...
    WantPlotExplainedVariance,WantPlotCorrelation);

%%

% for ridx = 1:length(ROINames)
% 
% ROIName = ROINames{ridx};
% Time_ROI = ROITimes(ridx,:);

PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',EVType,'Time_ROI',Time_ROI,'NeighborhoodSize',NeighborhoodSize,'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);
PlotTable_Small = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',EVType,'Time_ROI',Time_ROI,'NeighborhoodSize',NeighborhoodSize_Small,'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);

%% 

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

cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName);
close all
if idx == length(TableIndices)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'Y_Name','','WantLegend',false,'PlotTitle',AreaName,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size);
elseif idx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','X_Name','','WantLegend',true,'PlotTitle',AreaName,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','X_Name','','WantLegend',false,'PlotTitle',AreaName,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size);
end
PlotFunc{idx} = this_PlotFunc;
end

TiledLayout = [NumPlots,1];
NextTileInformation = ones(NumPlots,3);
NextTileInformation(1:NumPlots,1) = 1:NumPlots;
% NextTileInformation = [1,1,1;2,1,1];
Y_Name = {'Proportion of','Significant Channels'};

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'Y_Name',Y_Name,'WantDecisionCentered',WantDecisionCentered);
close all

%%

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

cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'MonkeyName',this_MonkeyName,'WantLegend',true,'ROIName',ROIName);

close all
if midx == length(MonkeyNames)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'ROIName',ROIName);
elseif midx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'WantLegend',true,'ErrorCapSize',ErrorCapSize_Large,'SignificanceFontSize',SignificanceFontSize_Large,'ROIName',ROIName);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'ROIName',ROIName);
end
PlotFunc{midx} = this_PlotFunc;
end


TiledLayout = [2,3];
NextTileInformation = [1,2,2;3,1,1;6,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'WantDecisionCentered',WantDecisionCentered);
close all

%%

HomogenietyTable = cgg_plotPaperFigureTable(PlotTable,PlotPath,NeighborhoodSize,'ROIName',ROIName);
cgg_plotPaperFigureTable(PlotTable_Small,PlotPath,NeighborhoodSize_Small,'ROIName',ROIName);

% end
%%

PlotDataPath = cfg_Results.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.path;
PlotDataPath = [PlotDataPath filesep 'Plot Data' filesep EVType];

PlotACCNameExt = 'Regression_Data_ACC_001_Wo_Probe_01_23_02_21_006_01.mat';
PlotCDNameExt = 'Regression_Data_CD_001_Wo_Probe_01_23_02_13_003_01.mat';
PlotPFCNameExt = 'Regression_Data_PFC_001_Wo_Probe_01_23_02_13_003_01.mat';

PlotACCPathNameExt = [PlotDataPath filesep PlotACCNameExt];
PlotCDPathNameExt = [PlotDataPath filesep PlotCDNameExt];
PlotPFCPathNameExt = [PlotDataPath filesep PlotPFCNameExt];

cgg_plotCorrelation(PlotACCPathNameExt,[],'AlternateTitle','ACC','WantPaperFormat',true,'SingleZLimits',[-0.25,0.25],'SinglePlotPath',PlotPath,'SaveName','ACC_Correlation','WantDecisionCentered',WantDecisionCentered);
cgg_plotCorrelation(PlotCDPathNameExt,[],'AlternateTitle','CD','WantPaperFormat',true,'SingleZLimits',[-0.25,0.25],'SinglePlotPath',PlotPath,'SaveName','CD_Correlation','WantDecisionCentered',WantDecisionCentered);
cgg_plotCorrelation(PlotPFCPathNameExt,[],'AlternateTitle','PFC','WantPaperFormat',true,'SingleZLimits',[-0.25,0.25],'SinglePlotPath',PlotPath,'SaveName','PFC_Correlation','WantDecisionCentered',WantDecisionCentered);

%% Figure 3
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_3');

Y_Name_Size = 14;
X_Name_Size = 14;
Legend_Size = 4;
X_Tick_Label_Size = 12;
Y_Tick_Label_Size = 12;

PlotTableAll = [];
for lidx = 1:length(Learning_Model_Variables)
    this_Learning_Model_Variable = Learning_Model_Variables{lidx};
[InputCell,~] = ...
    cgg_procAllSessionRegressionToVariable(this_Learning_Model_Variable,Epoch,InIncrement,...
    WantPlotExplainedVariance,WantPlotCorrelation);
% PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',this_Learning_Model_Variable,'Time_ROI',Time_ROI,'NeighborhoodSize',[],'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);
PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',this_Learning_Model_Variable,'Time_ROI',Time_ROI,'NeighborhoodSize',NeighborhoodSize,'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);
PlotTableAll = [PlotTableAll;PlotTable];

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

cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',['LM-' this_Learning_Model_Variable],'PlotTitle',this_Learning_Model_Variable,'PlotNames',PlotNames,'WantLegend',true,'WantLarge',true,'PlotColors',PlotColors);
close all
cgg_plotPaperFigureCorrelation(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',['LM-' this_Learning_Model_Variable],'PlotTitle',this_Learning_Model_Variable,'PlotNames',PlotNames,'WantLegend',true,'PlotColors',PlotColors);
close all

PlotFunc{1} = @(InFigure) cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','WantLegend',true,'X_Name','','PlotTitle','','PlotNames',PlotNames,'WantLarge',true,'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors);
PlotFunc{2} = @(InFigure) cgg_plotPaperFigureCorrelation(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'Y_Name','','WantLegend',false,'PlotNames',PlotNames,'SeparatePlotName',['LM-Stacked-' this_Learning_Model_Variable],'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors);

TiledLayout = [2,1];
NextTileInformation = [1,1,1;2,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'FigureTitle',this_Learning_Model_Variable,'WantDecisionCentered',WantDecisionCentered);
close all

end
%%

[MonkeyNamesIDX,MonkeyNames] = findgroups(PlotTableAll.Monkey);

for midx = 1:length(MonkeyNames)

MonkeyName = MonkeyNames(midx);

AllMonkeyIndices = strcmp(PlotTableAll{:,"Monkey"},MonkeyName);
ACCIndices = strcmp(PlotTableAll{:,"Area"},"ACC");
CDIndices = strcmp(PlotTableAll{:,"Area"},"CD");
AreaIndices = ACCIndices | CDIndices;

TableIndices = AllMonkeyIndices & AreaIndices;

this_PlotTable = PlotTableAll(TableIndices,:);

ColorOrder = cell2mat(PlotColors');
% ColorOrder(2,:) = [];

if strcmp(MonkeyName,"All")
MonkeyName = '';
end

cgg_plotPaperFigureROIAllLearningVariablesBar(this_PlotTable,'PlotPath',PlotPath,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName,'ROIName',ROIName);
close all
cgg_plotPaperFigureROIAllLearningVariablesDifferenceBar(this_PlotTable,'PlotPath',PlotPath,'ColorOrder',[],'MonkeyName',MonkeyName,'ROIName',ROIName);
close all
cgg_plotPaperFigureHomogeneityIndexScatter(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',false,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',false,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName,'ROIName',ROIName,'WantCI',WantCI);
close all
% close all
% cgg_plotPaperFigureHomogeneityIndexBar(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',false,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',false,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName);
% close all
% cgg_plotPaperFigureHomogeneityIndexBar(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',true,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',false,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName);
% close all
% cgg_plotPaperFigureHomogeneityIndexBar(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',false,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',true,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName);
% close all
% cgg_plotPaperFigureHomogeneityIndexBar(this_PlotTable,'PlotPath',PlotPath,'WantAbsolute',true,'NeighborhoodSize',NeighborhoodSize,'WantCorrelationMeasure',true,'ColorOrder',ColorOrder,'MonkeyName',MonkeyName);
% close all
end
%% All Variables: Figure 2
PlotSubFolders = 'Figure 2 Other Variables';
WantMedium = true;

for lmidx = 1:length(Learning_Model_Variables)

this_EVType = Learning_Model_Variables{lmidx};
PlotSubSubFolder = this_EVType;

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',Save_Folder, ...
    'PlotSubFolder',PlotSubFolders,'PlotSubSubFolder',PlotSubSubFolder);
PlotPath = cgg_getDirectory(cfg_Results,'SubSubFolder_1');

[InputCell,~] = ...
    cgg_procAllSessionRegressionToVariable(this_EVType,Epoch,InIncrement,...
    WantPlotExplainedVariance,WantPlotCorrelation);

%%

PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',this_EVType,'Time_ROI',Time_ROI,'NeighborhoodSize',NeighborhoodSize,'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);
PlotTable_Small = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',this_EVType,'Time_ROI',Time_ROI,'NeighborhoodSize',NeighborhoodSize_Small,'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);

%% 

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

cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName,'WantMedium',WantMedium);
close all
if idx == length(TableIndices)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'Y_Name','','WantLegend',false,'PlotTitle',AreaName,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size,'WantMedium',WantMedium);
elseif idx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','X_Name','','WantLegend',true,'PlotTitle',AreaName,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'WantMedium',WantMedium);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureProportionCorrelated(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','X_Name','','WantLegend',false,'PlotTitle',AreaName,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'WantMedium',WantMedium);
end
PlotFunc{idx} = this_PlotFunc;
end

TiledLayout = [NumPlots,1];
NextTileInformation = ones(NumPlots,3);
NextTileInformation(1:NumPlots,1) = 1:NumPlots;
% NextTileInformation = [1,1,1;2,1,1];
Y_Name = {'Proportion of','Significant Channels'};

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'Y_Name',Y_Name,'WantDecisionCentered',WantDecisionCentered);
close all

%%

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

cgg_plotPaperFigureROIBar(this_PlotTable,'PlotPath',PlotPath,'MonkeyName',this_MonkeyName,'WantLegend',true,'WantMedium',WantMedium,'ROIName',ROIName);

close all
if midx == length(MonkeyNames)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'PlotPath',PlotPath,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'WantMedium',WantMedium,'ROIName',ROIName);
elseif midx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'InFigure',InFigure,'WantLegend',true,'ErrorCapSize',ErrorCapSize_Large,'SignificanceFontSize',SignificanceFontSize_Large,'WantMedium',WantMedium,'ROIName',ROIName);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'WantMedium',WantMedium,'ROIName',ROIName);
end
PlotFunc{midx} = this_PlotFunc;
end


TiledLayout = [2,3];
NextTileInformation = [1,2,2;3,1,1;6,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'WantDecisionCentered',WantDecisionCentered);
close all

%%

HomogenietyTable = cgg_plotPaperFigureTable(PlotTable,PlotPath,NeighborhoodSize,'ROIName',ROIName);
cgg_plotPaperFigureTable(PlotTable_Small,PlotPath,NeighborhoodSize_Small,'ROIName',ROIName);

%%

PlotDataPath = cfg_Results.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.path;
PlotDataPath = [PlotDataPath filesep 'Plot Data' filesep this_EVType];

PlotACCNameExt = 'Regression_Data_ACC_001_Wo_Probe_01_23_02_21_006_01.mat';
PlotCDNameExt = 'Regression_Data_CD_001_Wo_Probe_01_23_02_13_003_01.mat';
PlotPFCNameExt = 'Regression_Data_PFC_001_Wo_Probe_01_23_02_13_003_01.mat';

PlotACCPathNameExt = [PlotDataPath filesep PlotACCNameExt];
PlotCDPathNameExt = [PlotDataPath filesep PlotCDNameExt];
PlotPFCPathNameExt = [PlotDataPath filesep PlotPFCNameExt];

cgg_plotCorrelation(PlotACCPathNameExt,[],'AlternateTitle','ACC','WantPaperFormat',true,'SingleZLimits',[-0.25,0.25],'SinglePlotPath',PlotPath,'SaveName','ACC_Correlation','WantDecisionCentered',WantDecisionCentered);
cgg_plotCorrelation(PlotCDPathNameExt,[],'AlternateTitle','CD','WantPaperFormat',true,'SingleZLimits',[-0.25,0.25],'SinglePlotPath',PlotPath,'SaveName','CD_Correlation','WantDecisionCentered',WantDecisionCentered);
cgg_plotCorrelation(PlotPFCPathNameExt,[],'AlternateTitle','PFC','WantPaperFormat',true,'SingleZLimits',[-0.25,0.25],'SinglePlotPath',PlotPath,'SaveName','PFC_Correlation','WantDecisionCentered',WantDecisionCentered);

end

%% Full Neighborhood Scan 

PlotTable_Neighborhood = [];

for lmidx = 1:length(Learning_Model_Variables)

this_EVType = Learning_Model_Variables{lmidx};
[InputCell,~] = ...
    cgg_procAllSessionRegressionToVariable(this_EVType,Epoch,InIncrement,...
    WantPlotExplainedVariance,WantPlotCorrelation);

for hidx = 0:64
    fprintf('LM Variable %s - Neighborhood Size %d\n',this_EVType,hidx);
this_PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',this_EVType,'Time_ROI',Time_ROI,'NeighborhoodSize',hidx,'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);
this_PlotTable.NeighborHoodSize = repmat(hidx,[height(this_PlotTable),1]);
PlotTable_Neighborhood = [PlotTable_Neighborhood;this_PlotTable];
end
end

%%

HomogeneityIndex = cellfun(@(x) x.HomogeneityIndex,PlotTable_Neighborhood.PlotData,'UniformOutput',true);
HomogeneityIndex_STE = cellfun(@(x) x.HomogeneityIndex_STE,PlotTable_Neighborhood.PlotData,'UniformOutput',true);
HomogeneityIndex_CI = cellfun(@(x) x.HomogeneityIndex_CI,PlotTable_Neighborhood.PlotData,'UniformOutput',true);
HomogeneityIndex_Correlation = cellfun(@(x) x.HomogeneityIndex_Correlation,PlotTable_Neighborhood.PlotData,'UniformOutput',true);
HomogeneityIndex_Correlation_STE = cellfun(@(x) x.HomogeneityIndex_Correlation_STE,PlotTable_Neighborhood.PlotData,'UniformOutput',true);
HomogeneityIndex_Correlation_CI = cellfun(@(x) x.HomogeneityIndex_Correlation_CI,PlotTable_Neighborhood.PlotData,'UniformOutput',true);

PlotTable_Neighborhood.HomogeneityIndex = HomogeneityIndex;
PlotTable_Neighborhood.HomogeneityIndex_STE = HomogeneityIndex_STE;
PlotTable_Neighborhood.HomogeneityIndex_CI = HomogeneityIndex_CI;
PlotTable_Neighborhood.HomogeneityIndex_Correlation = HomogeneityIndex_Correlation;
PlotTable_Neighborhood.HomogeneityIndex_Correlation_STE = HomogeneityIndex_Correlation_STE;
PlotTable_Neighborhood.HomogeneityIndex_Correlation_CI = HomogeneityIndex_Correlation_CI;

%%
PlotSubFolders = 'Homogeneity Index';
this_LMVariables = unique(PlotTable_Neighborhood{:,"Model_Variable"});
NumLM = length(this_LMVariables);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',Save_Folder, ...
    'PlotSubFolder',PlotSubFolders);
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

for lmidx = 1:NumLM

this_EVType = this_LMVariables{lmidx};
% PlotSubSubFolder = this_EVType;

LMIndices = strcmp(PlotTable_Neighborhood{:,"Model_Variable"},this_EVType);

this_PlotTable_Neighborhood = PlotTable_Neighborhood(LMIndices,:);

AllMonkeyIndices = strcmp(this_PlotTable_Neighborhood{:,"Monkey"},"All");

TableIndices = AllMonkeyIndices;
TableIndices = find(TableIndices);

PlotTable_Neighborhood_All = this_PlotTable_Neighborhood(TableIndices,:);

ACCIndices = strcmp(PlotTable_Neighborhood_All{:,"Area"},"ACC");
CDIndices = strcmp(PlotTable_Neighborhood_All{:,"Area"},"CD");
PFCIndices = strcmp(PlotTable_Neighborhood_All{:,"Area"},"PFC");

ACCIndices = find(ACCIndices);
CDIndices = find(CDIndices);
PFCIndices = find(PFCIndices);

PlotTable_Neighborhood_All_ACC = PlotTable_Neighborhood_All(ACCIndices,:);
PlotTable_Neighborhood_All_CD = PlotTable_Neighborhood_All(CDIndices,:);
PlotTable_Neighborhood_All_PFC = PlotTable_Neighborhood_All(PFCIndices,:);

Neighborhood_ACC = PlotTable_Neighborhood_All_ACC.HomogeneityIndex;
NeighborhoodSize_ACC = PlotTable_Neighborhood_All_ACC.NeighborHoodSize;
Neighborhood_STE_ACC = PlotTable_Neighborhood_All_ACC.HomogeneityIndex_STE;
Neighborhood_CI_ACC = PlotTable_Neighborhood_All_ACC.HomogeneityIndex_CI;
Neighborhood_CD = PlotTable_Neighborhood_All_CD.HomogeneityIndex;
NeighborhoodSize_CD = PlotTable_Neighborhood_All_CD.NeighborHoodSize;
Neighborhood_STE_CD = PlotTable_Neighborhood_All_CD.HomogeneityIndex_STE;
Neighborhood_CI_CD = PlotTable_Neighborhood_All_CD.HomogeneityIndex_CI;
Neighborhood_PFC = PlotTable_Neighborhood_All_PFC.HomogeneityIndex;
NeighborhoodSize_PFC = PlotTable_Neighborhood_All_PFC.NeighborHoodSize;
Neighborhood_STE_PFC = PlotTable_Neighborhood_All_PFC.HomogeneityIndex_STE;
Neighborhood_CI_PFC = PlotTable_Neighborhood_All_PFC.HomogeneityIndex_CI;

Neighborhood_Correlation_ACC = PlotTable_Neighborhood_All_ACC.HomogeneityIndex_Correlation;
NeighborhoodSize_Correlation_ACC = PlotTable_Neighborhood_All_ACC.NeighborHoodSize;
Neighborhood_Correlation_STE_ACC = PlotTable_Neighborhood_All_ACC.HomogeneityIndex_Correlation_STE;
Neighborhood_Correlation_CI_ACC = PlotTable_Neighborhood_All_ACC.HomogeneityIndex_Correlation_CI;
Neighborhood_Correlation_CD = PlotTable_Neighborhood_All_CD.HomogeneityIndex_Correlation;
NeighborhoodSize_Correlation_CD = PlotTable_Neighborhood_All_CD.NeighborHoodSize;
Neighborhood_Correlation_STE_CD = PlotTable_Neighborhood_All_CD.HomogeneityIndex_Correlation_STE;
Neighborhood_Correlation_CI_CD = PlotTable_Neighborhood_All_CD.HomogeneityIndex_Correlation_CI;
Neighborhood_Correlation_PFC = PlotTable_Neighborhood_All_PFC.HomogeneityIndex_Correlation;
NeighborhoodSize_Correlation_PFC = PlotTable_Neighborhood_All_PFC.NeighborHoodSize;
Neighborhood_Correlation_STE_PFC = PlotTable_Neighborhood_All_PFC.HomogeneityIndex_Correlation_STE;
Neighborhood_Correlation_CI_PFC = PlotTable_Neighborhood_All_PFC.HomogeneityIndex_Correlation_CI;

InData_X = cell(1,3);
InData_Y = cell(1,3);
InData_Error = cell(1,3);
InData_Correlation_X = cell(1,3);
InData_Correlation_Y = cell(1,3);
InData_Correlation_Error = cell(1,3);

InData_X{1} = NeighborhoodSize_ACC;
InData_X{2} = NeighborhoodSize_CD;
InData_X{3} = NeighborhoodSize_PFC;
InData_Y{1} = Neighborhood_ACC;
InData_Y{2} = Neighborhood_CD;
InData_Y{3} = Neighborhood_PFC;
InData_Error{1} = Neighborhood_STE_ACC;
InData_Error{2} = Neighborhood_STE_CD;
InData_Error{3} = Neighborhood_STE_PFC;

InData_Correlation_X{1} = NeighborhoodSize_Correlation_ACC;
InData_Correlation_X{2} = NeighborhoodSize_Correlation_CD;
InData_Correlation_X{3} = NeighborhoodSize_Correlation_PFC;
InData_Correlation_Y{1} = Neighborhood_Correlation_ACC;
InData_Correlation_Y{2} = Neighborhood_Correlation_CD;
InData_Correlation_Y{3} = Neighborhood_Correlation_PFC;
InData_Correlation_Error{1} = Neighborhood_Correlation_STE_ACC;
InData_Correlation_Error{2} = Neighborhood_Correlation_STE_CD;
InData_Correlation_Error{3} = Neighborhood_Correlation_STE_PFC;

PlotTitle = 'Neighborhood Scan';
X_Name = 'Neighborhood Size';
Y_Name = 'Homogeneity Index';
PlotNames = {'ACC','CD','PFC'};

PlotColors = {cfg_Paper.Color_ACC,cfg_Paper.Color_PFC,cfg_Paper.Color_CD};

Legend_Size = 42;
Title_Size = 50;
Y_Tick_Label_Size = 42;
X_Tick_Label_Size = 42;
Y_Name_Size = 42;
X_Name_Size = 56;

[InFigure,~,~] = cgg_plotLinePlot(InData_X,InData_Y, ...
    'ErrorMetric',InData_Error,'PlotTitle',PlotTitle, ...
    'X_Name',X_Name,'Y_Name',Y_Name, ...
    'PlotNames',PlotNames,'Legend_Size',Legend_Size, ...
    'PlotColors',PlotColors,'Title_Size',Title_Size, ...
    'Y_Tick_Label_Size',Y_Tick_Label_Size, ...
    'X_Tick_Label_Size',X_Tick_Label_Size, ...
    'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size);
if ~isempty(ROIName)
    this_ROIName = sprintf("-%s",ROIName);
end
PlotName=sprintf('Homogeneity-Index-Scan_LM-Variable%s-%s',this_ROIName,this_EVType);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

[InFigure,~,~] = cgg_plotLinePlot(InData_Correlation_X,InData_Correlation_Y, ...
    'ErrorMetric',InData_Correlation_Error,'PlotTitle',PlotTitle, ...
    'X_Name',X_Name,'Y_Name',Y_Name, ...
    'PlotNames',PlotNames,'Legend_Size',Legend_Size, ...
    'PlotColors',PlotColors,'Title_Size',Title_Size, ...
    'Y_Tick_Label_Size',Y_Tick_Label_Size, ...
    'X_Tick_Label_Size',X_Tick_Label_Size, ...
    'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size);

PlotName=sprintf('Homogeneity-Index-Correlation-Scan_LM-Variable%s-%s',this_ROIName,this_EVType);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all
end
% plot(NeighborhoodSize_ACC,Neighborhood_ACC);
% hold on
% plot(NeighborhoodSize_CD,Neighborhood_CD);
% plot(NeighborhoodSize_PFC,Neighborhood_PFC);
% hold off

end

