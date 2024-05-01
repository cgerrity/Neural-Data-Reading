
clc; clear; close all;
%%

viewTesting = false;
Epoch = 'Decision';
wantRelativeAccuracy = false;
wantAccuracyMeasure = true;

ParameterofInterest = "ModelName";
ParameterofInterestValue = "Variational GRU - Dropout 0.5";

ParameterSort = "MiniBatchSize";

FontSize_Text = 4;
RowsPerTable = 30;

%%
% rootdir = '/nobackup/user/gerritcg/Data_Neural/Aggregate Data/Epoched Data/Decision/Encoding/Fold_1';

cfg_Session = DATA_cggAllSessionInformationConfiguration;
ResultsDir=cfg_Session(1).temporarydir;
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Encoding',true);

Encoding_Dir = cfg_Results.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Encoding.path;

%%
NetworkResults = cgg_getNetworkResultsTable(Encoding_Dir);

%%
if ~strcmp(ParameterofInterest,"All")
RowsToRemove = (NetworkResults.(ParameterofInterest)==ParameterofInterestValue);

NetworkResults = NetworkResults(RowsToRemove,:);
end

if ~strcmp(ParameterSort,"None")
NetworkResults = sortrows(NetworkResults,ParameterSort);
end
%%

% %%
% 
% filelist = dir(fullfile(Encoding_Dir, '**/EncodingParameters.yaml'));  %get list of files and folders in any subfolder
% filelist = filelist(~[filelist.isdir]);
% 
% FolderList = {filelist.folder};
% 
% %%
% NumFolders = length(FolderList);
% 
% All_Accuracy = NaN(1,NumFolders);
% All_MostCommon = NaN(1,NumFolders);
% All_Iteration = NaN(1,NumFolders);
% All_CurrentIteration = NaN(1,NumFolders);
% All_Parameters = cell(1,NumFolders);
% 
% for fidx = 1:length(FolderList)
%     this_PathNameExt = [FolderList{fidx} filesep 'Optimal_Results.mat'];
%     this_CurrentPathNameExt = [FolderList{fidx} filesep 'CurrentIteration.mat'];
% 
%     if isfile(this_PathNameExt)
%         m_Optimal_Results = matfile(this_PathNameExt,"Writable",false);
%         m_Current = matfile(this_CurrentPathNameExt,"Writable",false);
%         this_TestAccuracy = m_Optimal_Results.TestingAccuracy;
%         this_TestMostCommon = m_Optimal_Results.TestingMostCommon;
%         this_ValidationAccuracy = m_Optimal_Results.ValidationAccuracy;
%         this_ValidationMostCommon = m_Optimal_Results.ValidationMostCommon;
%         this_Iteration = m_Optimal_Results.Iteration;
%         this_CurrentIteration = m_Current.CurrentIteration;
% 
%         if viewTesting
%     All_Accuracy(fidx) = this_TestAccuracy;
%     All_MostCommon(fidx) = this_TestMostCommon;
%         else
%     All_Accuracy(fidx) = this_ValidationAccuracy;
%     All_MostCommon(fidx) = this_ValidationMostCommon;
%         end
%     All_Iteration(fidx) = this_Iteration;
%     All_CurrentIteration(fidx) = this_CurrentIteration;
% 
%     end
%     this_YAMLPathNameExt = [FolderList{fidx} filesep 'EncodingParameters.yaml'];
%     result = ReadYaml(this_YAMLPathNameExt);
%     result.HiddenSizes = {cell2mat(result.HiddenSizes)};
%     result.ModelName = string(result.ModelName);
%     All_Parameters{fidx} = result;
% end
% 


%%

% AccuracyOverBaseline = All_Accuracy - All_MostCommon;
% AccuracyOverBaseline_Relative = AccuracyOverBaseline./(1-All_MostCommon);
% NaNIndices = isnan(AccuracyOverBaseline);
% AccuracyOverBaseline = num2cell(AccuracyOverBaseline);
% AccuracyOverBaseline_Relative = num2cell(AccuracyOverBaseline_Relative);
% % PlotNames = cellfun(@num2str,num2cell(1:NumFolders),'UniformOutput',false);
% 
% 
% All_Parameters(NaNIndices)=[];
% AccuracyOverBaseline(NaNIndices)=[];
% AccuracyOverBaseline_Relative(NaNIndices)=[];
% All_Iteration(NaNIndices)=[];
% All_CurrentIteration(NaNIndices)=[];
% % PlotNames(NaNIndices)=[];
% PlotNames = cellfun(@num2str,num2cell(1:length(AccuracyOverBaseline)),'UniformOutput',false);
% 
% All_Parameters = cellfun(@struct2table,All_Parameters,UniformOutput=false);
% All_ParametersTable = All_Parameters{1};
% 
% for pidx = 2:length(All_Parameters)
%     this_Table = All_Parameters{pidx};
%     % this_Table(:,"ModelName") = string(this_Table{:,"ModelName"});
% All_ParametersTable =[All_ParametersTable;this_Table];
% end

[NumModels,~] = size(NetworkResults);

DisplayParameterNames = ["ModelName","DataWidth","WindowStride","HiddenSizes_1","HiddenSizes_2","HiddenSizes_3","InitialLearningRate","LossFactorReconstruction","LossFactorKL","MiniBatchSize","Subset","OptimalIterationProgress"];
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

if wantRelativeAccuracy
    Y_Name = 'Relative Accuracy above Baseline';
    if viewTesting
        BarData = NetworkResults.RelativeTestingAccuracyAboveBaseline;
        YRange = [-0.05,0.04];
    else
        BarData = NetworkResults.RelativeValidationAccuracyAboveBaseline;
        YRange = [-0.05,0.15];
    end
else
    Y_Name = 'Accuracy above Baseline';
    if viewTesting
        BarData = NetworkResults.TestingAccuracyAboveBaseline;
        YRange = [-0.025,0.025];
    else
        BarData = NetworkResults.ValidationAccuracyAboveBaseline;
        YRange = [-0.05,0.05];
    end
end

if wantAccuracyMeasure
    Y_Name = 'Accuracy Measure';
    if viewTesting
        BarData = NetworkResults.TestingAccuracy_Measure;
        YRange = [0.4,0.5];
    else
        BarData = NetworkResults.ValidationAccuracy_Measure;
        YRange = [0.4,0.5];
    end
end

BarData = num2cell(BarData);

TiledPlot = tiledlayout(TileNumbers_Bar+TileNumbers_Table,1);
nexttile(1,[TileNumbers_Bar,1]);

[b_Plot] = cgg_plotBarGraphWithError(BarData,PlotNames,'YRange',YRange,'Y_Name',Y_Name);

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
pause(60);
close all
