%% FIGURE_cggPaperFigures

clc; clear; close all;
%%

Epoch = 'Decision';
WantPlot = false;
Version = 'Dissertation';
WantDecisionCentered = true;
WantBonferroni = false;
%%
% cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);
% Time_ROI = [0.95,1.15]-cfg_Paper.Time_Offset;
% WantDecisionCentered = true;
% SignificanceValue = 0.05;
% SignificanceMimimum = [];
% SamplingRate = 40;

%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',true);
%%
AreaNameCheck={'ACC','PFC','CD'};
PlottingSubFolders = {'Combined','Single'};

%%

[~,outputfolder_base,temporaryfolder_base,~] = cgg_getBaseFolders();

% MainDir=[outputfolder_base filesep 'Data_Neural'];
ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Processing','PlotSubFolder',PlottingSubFolders);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

PlotPath=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.path;

%%

[InputCell,CoefficientNames,PlotTable] = cgg_procRegressionResultsFromProcessing(Epoch,'WantPlot',WantPlot,'WantBonferroni',WantBonferroni);

% PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,'Model_Variable','Processing','Time_ROI',Time_ROI,'NeighborhoodSize',[],'SignificanceValue',SignificanceValue,'SignificanceMimimum',SignificanceMimimum,'WantDecisionCentered',WantDecisionCentered,'SamplingRate',SamplingRate,'WantPlot',WantPlot);

%%
%% Figure 3

Y_Name_Size = 14;
X_Name_Size = 14;
Legend_Size = 4;
X_Tick_Label_Size = 12;
Y_Tick_Label_Size = 12;

[VariableNamesIDX,VariableNames] = findgroups(PlotTable.Model_Variable);

for vidx = 1:length(VariableNames)
    this_Variable = VariableNames{vidx};


    if WantBonferroni
    WantLarge = false;
    WantExtraSmall = true;
    else
    WantLarge = true;
    WantExtraSmall = false;
    end

    if strcmp(this_Variable,'Model')
        WantExtraLarge = true;
    else
        WantExtraLarge = false;
    end
    if strcmp(this_Variable,'Intercept')
        WantSmall = true;
        WantExtraSmall = false;
    else
        WantSmall = false;
    end

this_PlotTable = PlotTable(VariableNamesIDX == vidx,:);
%%

AllMonkeyIndices = strcmp(this_PlotTable{:,"Monkey"},"All");
ACCIndices = strcmp(this_PlotTable{:,"Area"},"ACC");
CDIndices = strcmp(this_PlotTable{:,"Area"},"CD");
PFCIndices = strcmp(this_PlotTable{:,"Area"},"PFC");
AllACCIndices = ACCIndices & AllMonkeyIndices;
AllCDIndices = CDIndices & AllMonkeyIndices;
AllPFCIndices = PFCIndices & AllMonkeyIndices;

PlotTable_ACC = this_PlotTable(AllACCIndices,:);
PlotTable_CD = this_PlotTable(AllCDIndices,:);
PlotTable_PFC = this_PlotTable(AllPFCIndices,:);

PlotData_ACC = PlotTable_ACC.PlotData;
PlotData_ACC = PlotData_ACC{1};
PlotData_CD = PlotTable_CD.PlotData;
PlotData_CD = PlotData_CD{1};
PlotData_PFC = PlotTable_PFC.PlotData;
PlotData_PFC = PlotData_PFC{1};

%%

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

%%
cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',this_Variable,'PlotTitle',this_Variable,'PlotNames',PlotNames,'WantLegend',true,'WantLarge',WantLarge,'PlotColors',PlotColors,'WantExtraLarge',WantExtraLarge,'WantExtraSmall',WantExtraSmall,'WantSmall',WantSmall);
close all
%%

% cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',['LM-' this_Variable],'PlotTitle',this_Variable,'PlotNames',PlotNames,'WantLegend',true,'WantLarge',true,'PlotColors',PlotColors);
% close all
% cgg_plotPaperFigureCorrelation(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'AreaName',['LM-' this_Variable],'PlotTitle',this_Variable,'PlotNames',PlotNames,'WantLegend',true,'PlotColors',PlotColors);
% close all
% 
% PlotFunc{1} = @(InFigure) cgg_plotPaperFigureProportionCorrelated(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'InFigure',InFigure,'Y_Name','','WantLegend',true,'X_Name','','PlotTitle','','PlotNames',PlotNames,'WantLarge',true,'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',[],'Y_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors);
% PlotFunc{2} = @(InFigure) cgg_plotPaperFigureCorrelation(this_PlotData,'WantDecisionCentered',WantDecisionCentered,'PlotPath',PlotPath,'InFigure',InFigure,'Y_Name','','WantLegend',false,'PlotNames',PlotNames,'SeparatePlotName',['LM-Stacked-' this_Variable],'Y_Name_Size',Y_Name_Size,'X_Name_Size',X_Name_Size,'Legend_Size',Legend_Size,'X_Tick_Label_Size',X_Tick_Label_Size,'Y_Tick_Label_Size',Y_Tick_Label_Size,'PlotColors',PlotColors);
% 
% TiledLayout = [2,1];
% NextTileInformation = [1,1,1;2,1,1];
% 
% cgg_plotSinglePaperSubFigure(PlotFunc,TiledLayout,NextTileInformation,true,'FigureTitle',this_Variable,'WantDecisionCentered',WantDecisionCentered);
% close all

end
%%




