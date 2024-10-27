%% FIGURE_cggPaperFigures

clc; clear; close all;
%%
EVType = 'Absolute Prediction Error';
Epoch = 'Decision';
Version = 'Dissertation';

InIncrement = 1;
WantPlotExplainedVariance = false;
WantPlotCorrelation = false;

SignificanceValue = 0.05;
SignificanceMimimum = [];
% Time_ROI = [0.95,1.15];
NeighborhoodSize = 30;
NeighborhoodSize_Small = 15;

Learning_Model_Variables = {'Absolute Prediction Error','Outcome',...
    'Error Trace','Choice Probability WM','Choice Probability RL',...
    'Choice Probability CMB','Value RL','Value WM','WM Weight'};

Variable_Figure_1 = 'Previous Trial Effect';

PlotSubFolders = {'Figure 1', 'Figure 2', 'Figure 3'};

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
    case 'Dissertation'
AreaIndices = ACCIndices | CDIndices | PFCIndices;
    otherwise
end

TableIndices = AllMonkeyIndices & AreaIndices;
TableIndices = find(TableIndices);

for idx = 1:length(TableIndices)
this_TableIDX = TableIndices(idx);
AreaName = PlotTable{this_TableIDX,"Area"};
PlotData = PlotTable{this_TableIDX,"PlotData"};
PlotData = PlotData{1};

cgg_plotPaperFigureBetaValues(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName,'PlotNames',CoefficientNames,'WantLegend',WantLegend,'PlotTitle',AreaName,'X_Name','');
close all
cgg_plotPaperFigureModelProportion(PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',AreaName,'PlotTitle',AreaName);
close all

PlotFunc_Model = @(InFigure) cgg_plotPaperFigureModelProportion(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'PlotPath',[],'AreaName',AreaName,'PlotTitle',AreaName,'Y_Name_Size',Y_Name_Size,'X_Name','','X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size);
PlotFunc_Beta = @(InFigure) cgg_plotPaperFigureBetaValues(PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'PlotPath',PlotPath,'AreaName',AreaName,'PlotNames',CoefficientNames,'WantLegend',WantLegend,'SaveName','Model-Beta','Y_Name_Size',Y_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size);

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

cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'MonkeyName',this_MonkeyName,'WantLegend',true);

close all
if midx == length(MonkeyNames)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName);
elseif midx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'WantLegend',true,'ErrorCapSize',ErrorCapSize_Large,'SignificanceFontSize',SignificanceFontSize_Large);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName);
end
PlotFunc{midx} = this_PlotFunc;
end


TiledLayout = [2,3];
NextTileInformation = [1,2,2;3,1,1;6,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'WantDecisionCentered',WantDecisionCentered);
close all

%%

HomogenietyTable = cgg_plotPaperFigureTable(PlotTable,PlotPath,NeighborhoodSize);
cgg_plotPaperFigureTable(PlotTable_Small,PlotPath,NeighborhoodSize_Small);

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
PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable',this_Learning_Model_Variable,'Time_ROI',Time_ROI,'NeighborhoodSize',[],'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered);
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

AllMonkeyIndices = strcmp(PlotTableAll{:,"Monkey"},"All");
ACCIndices = strcmp(PlotTableAll{:,"Area"},"ACC");
CDIndices = strcmp(PlotTableAll{:,"Area"},"CD");
AreaIndices = ACCIndices | CDIndices;

TableIndices = AllMonkeyIndices & AreaIndices;

this_PlotTable = PlotTableAll(TableIndices,:);

cgg_plotPaperFigureROIAllLearningVariablesBar(this_PlotTable,'PlotPath',PlotPath);
close all
cgg_plotPaperFigureROIAllLearningVariablesDifferenceBar(this_PlotTable,'PlotPath',PlotPath);
close all


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

cgg_plotPaperFigureROIBar(this_PlotTable,'PlotPath',PlotPath,'MonkeyName',this_MonkeyName,'WantLegend',true,'WantMedium',WantMedium);

close all
if midx == length(MonkeyNames)
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'PlotPath',PlotPath,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'WantMedium',WantMedium);
elseif midx == 1
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'InFigure',InFigure,'WantLegend',true,'ErrorCapSize',ErrorCapSize_Large,'SignificanceFontSize',SignificanceFontSize_Large,'WantMedium',WantMedium);
else
this_PlotFunc = @(InFigure) cgg_plotPaperFigureROIBar(this_PlotTable,'InFigure',InFigure,'WantLegend',false,'ErrorCapSize',ErrorCapSize_Small,'SignificanceFontSize',SignificanceFontSize_Small,'WantBarNames',false,'Y_Name','','PlotTitle',this_MonkeyName,'WantMedium',WantMedium);
end
PlotFunc{midx} = this_PlotFunc;
end


TiledLayout = [2,3];
NextTileInformation = [1,2,2;3,1,1;6,1,1];

cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'WantDecisionCentered',WantDecisionCentered);
close all

%%

HomogenietyTable = cgg_plotPaperFigureTable(PlotTable,PlotPath,NeighborhoodSize);
cgg_plotPaperFigureTable(PlotTable_Small,PlotPath,NeighborhoodSize_Small);

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
