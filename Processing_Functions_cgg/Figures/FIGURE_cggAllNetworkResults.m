
clc; clear; close all;
%%

viewTesting = true;
Epoch = 'Decision';
Target = 'Dimension';
% Target = 'SharedFeatureCoding';
BaselineSelection = "MostCommon"; % "None", "RandomChance", "MostCommon"
wantRelativeAccuracy = true;
wantAccuracyMeasure = false;
wantAccuracyMaximum = true;

% ParameterofInterest = "ModelName";
% ParameterofInterestValue = "Variational GRU - Dropout 0.5";

% ParameterofInterest = "ClassifierName";
ParameterofInterest = "All";
ParameterofInterestValue = "Deep LSTM - Dropout 0.5";

ParameterSort = "ValidationAccuracy_Maximum";
% ParameterSort = "ValidationAccuracy";
TopResults = 30; % Integer or NaN

FontSize_Text = 10;
RowsPerTable = 10;

PauseTime = 15;

%%
% rootdir = '/nobackup/user/gerritcg/Data_Neural/Aggregate Data/Epoched Data/Decision/Encoding/Fold_1';

cfg_Session = DATA_cggAllSessionInformationConfiguration;
ResultsDir=cfg_Session(1).temporarydir;
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Encoding',true,'Target',Target,'PlotFolder','Network Results');

NetworkResultsDir = cfg_Results.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Encoding.Target.path;
PlotDir = cfg_Results.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.path;

%%
NetworkResults = cgg_getNetworkResultsTable(NetworkResultsDir);

NetworkResults = NetworkResults((~isnan(NetworkResults.OptimalIteration)),:);

%%
if ~strcmp(ParameterofInterest,"All")
RowsToRemove = (NetworkResults.(ParameterofInterest)==ParameterofInterestValue);

NetworkResults = NetworkResults(RowsToRemove,:);
end

if ~strcmp(ParameterSort,"None")
NetworkResults = sortrows(NetworkResults,ParameterSort,"descend");
if ~isnan(TopResults)
NetworkResults = NetworkResults(1:TopResults,:);
end
end
%%

DisplayType = "";
Y_Name = "";

if viewTesting
    DisplayType = DisplayType + "Testing";
    DataSource = "Testing";
else
    DisplayType = DisplayType + "Validation";
    DataSource = "Validation";
end
if wantRelativeAccuracy
    DisplayType = DisplayType + " - Relative";
    Y_Name = Y_Name + "Relative";
else
    DisplayType = DisplayType + " - Absolute";
end
DisplayType = DisplayType + " - " + BaselineSelection;
if wantAccuracyMaximum
    DisplayType = DisplayType + " - Maximum Accuracy";
    Measure = "Accuracy_Maximum";
elseif wantAccuracyMeasure
    DisplayType = DisplayType + " - Measure";
    Measure = "Accuracy_Measure";
else
    DisplayType = DisplayType + " - Accuracy";
    Measure = "Accuracy";
end
DisplayType = DisplayType + " - " + string(Target);

DataName = DataSource + Measure;
BaselineName = DataSource + BaselineSelection;

Y_Name = Y_Name + Measure;
if ~(BaselineSelection == "None")
Y_Name = Y_Name + " above Baseline";
end

%%
[NumModels,~] = size(NetworkResults);

DisplayParameterNames = ["ModelName","DataWidth","WindowStride","HiddenSizesString","InitialLearningRate","LossFactorReconstruction","LossFactorKL","MiniBatchSize","ClassifierName","ClassifierHiddenSizeString","Subset","OptimalIterationProgress"];
PlotNames = cellfun(@num2str,num2cell(1:NumModels),'UniformOutput',false);

Display_Network=cell(NumModels,length(DisplayParameterNames));

for pidx=1:NumModels

sel_Network = pidx;

Display_Network{sel_Network,1} = PlotNames{sel_Network};
Display_Network{sel_Network,2} = NetworkResults{sel_Network,DisplayParameterNames(1)};
Display_Network{sel_Network,3} = num2str(NetworkResults{sel_Network,DisplayParameterNames(2)});
Display_Network{sel_Network,4} = num2str(NetworkResults{sel_Network,DisplayParameterNames(3)});
% Display_Network{sel_Network,5} = ['\fontsize{6} ' num2str(All_ParametersTable{sel_Network,DisplayParameterNames(4)}{1})];
Display_Network{sel_Network,5} = num2str(NetworkResults{sel_Network,DisplayParameterNames(4)});
Display_Network{sel_Network,6} = num2str(NetworkResults{sel_Network,DisplayParameterNames(5)});
Display_Network{sel_Network,7} = num2str(NetworkResults{sel_Network,DisplayParameterNames(6)});
Display_Network{sel_Network,8} = num2str(NetworkResults{sel_Network,DisplayParameterNames(7)});
Display_Network{sel_Network,9} = num2str(NetworkResults{sel_Network,DisplayParameterNames(8)});
Display_Network{sel_Network,10} = num2str(NetworkResults{sel_Network,DisplayParameterNames(9)});
Display_Network{sel_Network,11} = num2str(NetworkResults{sel_Network,DisplayParameterNames(10)});
Display_Network{sel_Network,12} = num2str(NetworkResults{sel_Network,DisplayParameterNames(11)});
Display_Network{sel_Network,13} = sprintf('%.2f',NetworkResults{sel_Network,DisplayParameterNames(12)});

end
%%

InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;

TileNumbers_Bar = 2;
TileNumbers_Table = 2;

%%

Data = NetworkResults.(DataName);
if BaselineSelection == "None"
    Baseline_Subtract = zeros(size(Data));
    Baseline = zeros(size(Data));
else
    Baseline_Subtract = NetworkResults.(BaselineName);
    Baseline = NetworkResults.(BaselineName);
end
if ~wantRelativeAccuracy
    Baseline_Divide = ones(size(Data));
else
    Baseline_Divide = NetworkResults.(BaselineName);
end

BarData = (Data - Baseline_Subtract)./Baseline_Divide;
BarData_test = (Data - Baseline)./(1-Baseline);

switch DisplayType
    case "Testing - Relative - MostCommon - Accuracy - Dimension"
        YRange = [-0.05,0.04];
    case "Validation - Relative - MostCommon - Accuracy - Dimension"
        YRange = [-0.05,0.15];
    case "Testing - Absolute - MostCommon - Accuracy - Dimension"
        YRange = [-0.05,0.15];
    case "Validation - Absolute - MostCommon - Accuracy - Dimension"
        YRange = [-0.05,0.05];
    case "Testing - Absolute - MostCommon - Measure - Dimension"
        YRange = [-0.05,0.5];
    case "Validation - Absolute - MostCommon - Measure - Dimension"
        YRange = [-0.05,0.5];
    case "Testing - Absolute - None - Accuracy - Dimension"
        YRange = [0,1];
    case "Validation - Absolute - None - Accuracy - Dimension"
        YRange = [0,1];
    case "Testing - Relative - RandomChance - Accuracy - Dimension"
        YRange = [0,0.4];
    case "Validation - Relative - RandomChance - Accuracy - Dimension"
        YRange = [0,0.4];
    case "Testing - Absolute - RandomChance - Accuracy - Dimension"
        YRange = [0,0.2];
    case "Validation - Absolute - RandomChance - Accuracy - Dimension"
        YRange = [0,0.2];
    case "Testing - Relative - MostCommon - Maximum Accuracy - Dimension"
        YRange = [0,0.2];
    case "Validation - Relative - MostCommon - Maximum Accuracy - Dimension"
        YRange = [-0.05,0.15];
    otherwise
        YRange = [0,1];
end

%%

% if wantRelativeAccuracy
%     Y_Name = 'Relative Accuracy above Baseline';
%     if viewTesting
%         BarDataName = "RelativeTestingAccuracyAboveBaseline";
%         BarData = NetworkResults.RelativeTestingAccuracyAboveBaseline;
%         YRange = [-0.05,0.04];
%     else
%         BarData = NetworkResults.RelativeValidationAccuracyAboveBaseline;
%         YRange = [-0.05,0.15];
%     end
% else
%     Y_Name = 'Accuracy above Baseline';
%     if viewTesting
%         BarData = NetworkResults.TestingAccuracyAboveBaseline;
%         YRange = [-0.025,0.025];
%     else
%         BarData = NetworkResults.ValidationAccuracyAboveBaseline;
%         YRange = [-0.05,0.05];
%     end
% end
% 
% if wantAccuracyMeasure
%     Y_Name = 'Accuracy Measure';
%     if viewTesting
%         BarData = NetworkResults.TestingAccuracy_Measure;
%         YRange = [0.4,0.5];
%     else
%         BarData = NetworkResults.ValidationAccuracy_Measure;
%         YRange = [0.4,0.5];
%     end
% end

BarData = num2cell(BarData);

TiledPlot = tiledlayout(TileNumbers_Bar+TileNumbers_Table,1);
nexttile(1,[TileNumbers_Bar,1]);

% SkipFactorPlotNames = 10;
% PlotNames_Reduced = PlotNames(1:SkipFactorPlotNames:length(PlotNames));

[b_Plot] = cgg_plotBarGraphWithError(BarData,PlotNames,'YRange',YRange,'Y_Name',Y_Name);

if strcmp(BaselineSelection,"None")
    RandomChanceName = DataSource + "RandomChance";
    RandomChanceName = DataSource + "MostCommon";
    RandomChanceMean = mean(NetworkResults.(RandomChanceName));
    yline(RandomChanceMean,"LineWidth",2);
end

nexttile(TileNumbers_Bar+1,[TileNumbers_Table,1]);
Ax = gca;
Ax.Visible = 0;

TextDisplayIncrement = 1/NumModels;


% for pidx = 1:length(All_Parameters)
%     this_TextDiplay = (pidx-1)*TextDisplayIncrement;
% text(this_TextDiplay,0.5, Display_Network(pidx,:),'Units','normalized','FontSize',FontSize_Text);
% end


% TextDisplayIncrement = 0.02;
[NumNetworks,NumColumns] = size(Display_Network);

NumTableDisplays = ceil(NumNetworks/RowsPerTable);

TextDisplayIncrement = 1/(NumTableDisplays*NumColumns);

for tidx = 1:NumTableDisplays
    this_Row_Start = 1+(tidx-1)*RowsPerTable;
    this_Row_End = RowsPerTable+(tidx-1)*RowsPerTable;
    if tidx==NumTableDisplays
        this_Row_End = NumNetworks;
    end
    this_Rows = this_Row_Start:this_Row_End;
for pidx = 1:NumColumns
    this_TextDiplay = (pidx-1)*TextDisplayIncrement+(tidx-1)*TextDisplayIncrement*NumColumns;
    text(this_TextDiplay,0.5, Display_Network(this_Rows,pidx),'Units','normalized','FontSize',FontSize_Text,'HorizontalAlignment','center');
end
end
% 
% text(0,0.5, Display_Network(1,:),'Units','normalized','FontSize',6);
% text(0.1,0.5, Display_Network(2,:),'Units','normalized','FontSize',6);
% text(0.2,0.5, Display_Network(3,:),'Units','normalized','FontSize',6);

% uitable('Data',All_ParametersTable,'ColumnName',All_ParametersTable.Properties.VariableNames);

% text(0,0.5, Information_Display,'Units','normalized','FontSize',Text_Size);
% text(0.7,0.5, InformationValue_Display,'Units','normalized','FontSize',Text_Size);


drawnow;

SavePathNameExt = [PlotDir filesep 'Network_Results-(' char(DisplayType) ').pdf'];
exportgraphics(InFigure,SavePathNameExt,'ContentType','vector');

pause(PauseTime);
close all
