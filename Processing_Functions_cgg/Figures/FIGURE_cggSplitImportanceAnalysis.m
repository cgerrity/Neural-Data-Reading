

% if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
clc; clear; close all;
% end

Epoch = 'Decision';
FoldStart = 1; FoldEnd = 1;
NumFolds = numel(FoldStart:FoldEnd); 
SamplingFrequency=1000;
wantSubset = true;
wantStratifiedPartition = true;

% MetricWanted='Importance';
% SubMetricWanted='CM_Table_IA';

VariableName='Correct Trial';

X_Name='Time (s)';
Y_Name='Accuracy';

wantOnePlot=false;

FilterColumn=VariableName;

%%
% if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
% [Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset);
% end
% 
% InputIdentifiers=cell2mat(Identifiers);
% InputNames=cellstr(IdentifierName);
% InputNames{strcmp(InputNames,'Data Number')}='DataNumber';
% 
% Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);

%%

cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

DataWidth = cfg_Decoder.DataWidth/SamplingFrequency;
WindowStride = cfg_Decoder.WindowStride/SamplingFrequency;

Decoders = cfg_Decoder.Decoder;
IADecoderIDX=strcmp(Decoders,cfg_Decoder.IADecoder);
Decoders=Decoders(IADecoderIDX);
NumDecoders = length(Decoders);
Decoder = Decoders{1};

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Sessions(1).temporarydir;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir);
cfg.ResultsDir=cfg_tmp.TargetDir;

if wantSubset
    if wantStratifiedPartition
Partition_NameExt = 'KFoldPartition_Subset.mat';
    else
Partition_NameExt = 'KFoldPartition_Subset_NS.mat';
    end
else
    if wantStratifiedPartition
Partition_NameExt = 'KFoldPartition.mat';
    else
Partition_NameExt = 'KFoldPartition_NS.mat';
    end
end

%%

if exist('Identifiers_Table','var')
[OutTable_Cell,TypeValues_Cell,Identifiers_Table] = ...
    cgg_procSplitImportanceAnalysisAcrossFolds(VariableName,Epoch,...
    Decoder,FoldStart,FoldEnd,wantSubset,cfg,'Identifiers_Table',...
    Identifiers_Table);
else
[OutTable_Cell,TypeValues_Cell,Identifiers_Table] = ...
    cgg_procSplitImportanceAnalysisAcrossFolds(VariableName,Epoch,...
    Decoder,FoldStart,FoldEnd,wantSubset,cfg);
end

%%

cgg_plotImportantAnalysisPlots(OutTable_Cell,TypeValues_Cell,VariableName,Epoch,Decoder,cfg);

for tidx=1:numel(TypeValues_Cell{1})
cgg_plotImportantAnalysisPlots(OutTable_Cell,TypeValues_Cell,VariableName,Epoch,Decoder,cfg,'SingleType',tidx);
end

%%
% this_PlotData=cell(NumDecoders,NumFolds);
% this_Identifiers=cell(NumDecoders,NumFolds);
% 
% ClassNames=[];
% 
% OutTable_Cell=cell(1,NumFolds);
% TypeValues_Cell=cell(1,NumFolds);

% %%
% 
% % for didx=1:NumDecoders
% for fidx=FoldStart:FoldEnd
% 
%     Fold = fidx;
% 
% 
%     if wantSubset
% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',[Decoder,'_Subset'],'Fold',Fold,...
%     'ImportanceAnalysis',true);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch,'Decoder',[Decoder,'_Subset'],'Fold',Fold,...
%     'ImportanceAnalysis',true);
% cfg.ResultsDir=cfg_tmp.TargetDir;
%     else
% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold,'ImportanceAnalysis',true);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold,'ImportanceAnalysis',true);
% cfg.ResultsDir=cfg_tmp.TargetDir;
%     end
% 
% this_cfg_Decoder = cgg_generateDecoderVariableSaveNames(Decoder,cfg,wantSubset);
% 
% m_Partition = matfile(this_cfg_Decoder.Partition,'Writable',false);
% KFoldPartition=m_Partition.KFoldPartition;
% KFoldPartition=KFoldPartition(1);
% 
% this_MetricPathNameExt=this_cfg_Decoder.(MetricWanted);
% 
% m_Metric = matfile(this_MetricPathNameExt,'Writable',false);
% this_CM_Table_IA = m_Metric.(SubMetricWanted);
% 
% this_ClassNames=this_CM_Table_IA.CM_Table{1}{1}.TrueValue;
% this_ClassNames=unique(this_ClassNames);
% ClassNames=unique([ClassNames;this_ClassNames]);
% 
% % m_Classes = matfile(this_cfg_Decoder.Accuracy,'Writable',false);
% % this_ClassData = m_Classes.Each_Prediction;
% % 
% % if iscell(this_ClassData)
% % this_ClassData = cgg_gatherConfusionMatrixCellToTable(this_ClassData);
% % end
% 
% this_TestingIDX=test(KFoldPartition,fidx);
% 
% % this_Identifiers{didx,fidx}=Identifiers(this_TestingIDX);
% % 
% % InputIdentifiers=cell2mat(Identifiers(this_TestingIDX));
% % InputNames=cellstr(IdentifierName);
% % InputNames{strcmp(InputNames,'Data Number')}='DataNumber';
% 
% this_Identifiers_Table=Identifiers_Table(this_TestingIDX,:);
% 
% [OutTable_Cell{fidx},TypeValues_Cell{fidx}] = cgg_procImportanceAnalysisFromTable(this_CM_Table_IA,ClassNames,this_Identifiers_Table,'FilterColumn',FilterColumn);
% 
% end
% 
% % this_ClassNames=cell2mat(transpose(cellfun(@(x2) cell2mat(x2),this_PlotData{1,fidx},'UniformOutput',false)));
% 
% % this_ClassNames=this_CM_Table_IA.CM_Table{1}{1}.TrueValue;
% % this_ClassNames=unique(this_ClassNames);
% % ClassNames=unique([ClassNames;this_ClassNames]);
% % end

% InSavePlotCFG = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Plots;

%%

% this_didx=1;
% fidx=1;
% 
% InputIdentifiers=cell2mat(this_Identifiers{this_didx,fidx});
% InputNames=cellstr(IdentifierName);
% InputNames{strcmp(InputNames,'Data Number')}='DataNumber';
% 
% Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);
% 
% CM_Table_IA=this_PlotData{this_didx,fidx};
% 
% [OutTable,TypeValues] = cgg_procImportanceAnalysisFromTable(CM_Table_IA,ClassNames,Identifiers_Table,'FilterColumn',FilterColumn);

% %%
% 
% [ProbeAreas,~,OutTableAreaIndices] = unique(OutTable_Cell{1}(:,"AreaRemoved"),'stable');
% 
% 
% AreaIndices=false(numel(OutTableAreaIndices),numel(ProbeAreas)-1);
% ProbeAreas_tmp=ProbeAreas;
% AreaCounter=0;
% for aidx=1:numel(ProbeAreas_tmp)
% 
%     if ~strcmp(ProbeAreas_tmp{aidx,:},"None")
%         AreaCounter=AreaCounter+1;
%         AreaIndices(:,AreaCounter)=OutTableAreaIndices==aidx;
%     else
%         ProbeAreas(aidx,:)=[];
%     end
% end
% 
% %%
% 
% NumChannels=sum(AreaIndices(:,1));
% NumWindows=length(OutTable_Cell{1, 1}.UnfilteredWindowAccuracy{1});
% NumAreas=numel(ProbeAreas);
% NumTypes=length(TypeValues_Cell{1});
% 
% % for
% fidx=1;
% BaseIDX=1;
% New_Y_Name_Size=20;
% % OutTable=OutTable_Cell{fidx};
% TypeValues=TypeValues_Cell{1};
% 
% % Tiled=[];
% % fig_plot=[];
% % p_Plot=[];
% % c_Plot=[];
% % fig_plot_Accuracy=[];
% % p_Plots_Accuracy=[];
% Tiled=gobjects(NumTypes,1);
% fig_plot=gobjects(NumTypes,1);
% p_Plot=gobjects(NumAreas,NumTypes);
% c_Plot=gobjects(NumAreas,NumTypes);
% fig_plot_Accuracy=gobjects(NumTypes,1);
% p_Plots_Accuracy=gobjects(NumTypes,1);
% for tidx=1:NumTypes
% SplitValue=tidx;
% 
% InData=NaN(NumChannels,NumWindows,NumAreas,NumFolds);
% SplitAccuracy=NaN(NumFolds,NumWindows);
% 
% for fidx=FoldStart:FoldEnd
% OutTable=OutTable_Cell{fidx};
% OutTableSelectIAValue=OutTable(:,["FilteredWindowPercent","AreaRemoved","ChannelRemoved"]);
% 
% this_SplitAccuracy=OutTable.FilteredWindowAccuracy;
% SplitAccuracy(fidx,:)=this_SplitAccuracy{BaseIDX,SplitValue};
% % SplitAccuracy(fidx,:)=OutTable.FilteredWindowAccuracy{SplitValue};
% 
% for aidx=1:NumAreas
% InData(:,:,aidx,fidx)=cell2mat(OutTableSelectIAValue.FilteredWindowPercent(AreaIndices(:,aidx),SplitValue));
% end
% % [NumChannels,NumWindows,NumProbes,NumFolds] = size(InData);
% end
% 
% InData=mean(InData,4);
% 
% FilterValue=TypeValues(tidx);
% 
% [InData_Min,MinIDX]=min(InData,[],2);
% [InData_Max,MaxIDX]=max(InData,[],2);
% 
% InData_ReRanged=(InData-InData_Min)./(InData_Max-InData_Min);
% 
% [~,Rearranged_Order]=sort(MinIDX,1);
% 
% % Rearranged_Order=[];
% % for aidx=1:NumAreas
% %     this_Channels=(1:MaxChannel)+MaxChannel*(aidx-1);
% % [~,Rearranged_Order_tmp]=sort(MinIDX(this_Channels));
% % Rearranged_Order_tmp=Rearranged_Order_tmp+MaxChannel*(aidx-1);
% % 
% % Rearranged_Order=[Rearranged_Order;Rearranged_Order_tmp];
% % end
% InData_ReArranged=NaN(size(InData_ReRanged));
% for aidx=1:NumAreas
% InData_ReArranged(:,:,aidx)=InData_ReRanged(Rearranged_Order(:,1,aidx),:,aidx);
% end
% 
% 
% % InData_ReArranged=InData_ReRanged;
% 
% [fig_plot_tmp,p_Plots_tmp,c_Plot_tmp,Tiled_tmp] = cgg_plotImportanceAnalysisHeatMap(InData_ReArranged,ProbeAreas,Time_Start,DataWidth,WindowStride,FilterColumn,FilterValue,wantOnePlot);
% 
% % Tiled=[Tiled,Tiled_tmp];
% % fig_plot=[fig_plot,fig_plot_tmp];
% % p_Plot=[p_Plot,p_Plots_tmp];
% % c_Plot=[c_Plot,c_Plot_tmp];
% 
% % Remove Labels from Decision Indicators
% fig_plot_tmp.Children.Children(NumAreas*2).Children(1).Label='';
% fig_plot_tmp.Children.Children(NumAreas*2).Children(2).Label='';
% fig_plot_tmp.Children.Children(NumAreas*2).Children(3).Label='';
% 
% % Remove Title from each Plot
% fig_plot_tmp.Children.Title.String='';
% 
% % Remove Tiled Y Label
% fig_plot_tmp.Children.YLabel.String='';
% 
% % Change Area Font Size
% for aidx=1:NumAreas
% p_Plots_tmp(aidx).Parent.YLabel.FontSize=New_Y_Name_Size;
% end
% 
% % Delete the colobar for all but the right most plot
% if tidx<NumTypes
% delete(fig_plot_tmp.Children.Children(1))
% end
% 
% Tiled(tidx)=Tiled_tmp;
% fig_plot(tidx)=fig_plot_tmp;
% p_Plot(:,tidx)=p_Plots_tmp;
% c_Plot(:,tidx)=c_Plot_tmp;
% 
% % Accuracy Plots
% 
% this_OutTable=OutTable(OutTable.AreaRemoved=="None",:);
% 
% X_Name='Time (s)';
% Y_Name='Accuracy';
% 
% PlotTitle=sprintf('Accuracy split by %s for Decoder: %s',VariableName,Decoder);
% PlotNames=cell(1);
% PlotNames{1}=num2str(FilterValue);
% 
% [fig_plot_Accuracy_tmp,p_Plots_Accuracy_tmp,~] = cgg_plotTimeSeriesPlot(SplitAccuracy,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames,'wantTiled',true);
% ylim([0,1]);
% 
% % Modifications to the constant Line for the Accuracy Plot
% % fig_plot_Accuracy_tmp.Children.Children(2).Children(1).Label='';
% % fig_plot_Accuracy_tmp.Children.Children(2).Children(2).Label='';
% % fig_plot_Accuracy_tmp.Children.Children(2).Children(3).Label='';
% fig_plot_Accuracy_tmp.Children.Children(2).Children(1).FontSize=8;
% fig_plot_Accuracy_tmp.Children.Children(2).Children(2).FontSize=8;
% fig_plot_Accuracy_tmp.Children.Children(2).Children(3).FontSize=8;
% 
% % Delete Legend
% delete(fig_plot_Accuracy_tmp.Children.Children(1));
% 
% % Increase Y Label Font Size
% fig_plot_Accuracy_tmp.Children.Children.YLabel.FontSize=New_Y_Name_Size;
% 
% % Change Title to Split Name
% fig_plot_Accuracy_tmp.Children.Children.Title.String=sprintf('%s Value %d',VariableName,FilterValue);
% 
% % fig_plot_Accuracy=[fig_plot_Accuracy,fig_plot_Accuracy_tmp];
% % p_Plots_Accuracy=[p_Plots_Accuracy,p_Plots_Accuracy_tmp];
% fig_plot_Accuracy(tidx)=fig_plot_Accuracy_tmp;
% p_Plots_Accuracy(tidx)=p_Plots_Accuracy_tmp;
% 
% end
% 
% %
% 
% fig_Sub_plot=figure;
% fig_Sub_plot.WindowState='maximized';
% fig_Sub_plot.PaperSize=[20 10];
% 
% FullTiled=tiledlayout(2,NumTypes);
% FullTiled.TileSpacing = 'compact';
% FullTiled.Padding = 'compact';
% 
% % this_SubPlot_1=subplot(2,1,1);
% 
% % nexttile
% % child1 = copyobj(fig_plot(1).Children, FullTiled);
% 
% for tidx=1:NumTypes
% 
% % Heat Map
% 
% this_fig=fig_plot(tidx);
% childHeat = copyobj(this_fig.Children, FullTiled);
% 
% % Move Corbar to right on rightmost plot
% if tidx==NumTypes
% childHeat.Children(1).Layout.Tile = 'east';
% end
% 
% % Remove Labels from Decision Indicators
% % childHeat.Children(NumAreas*2).Children(1).Label='';
% % childHeat.Children(NumAreas*2).Children(2).Label='';
% % childHeat.Children(NumAreas*2).Children(3).Label='';
% % child1.Children(1).Visible = 'off';
% 
% % Delete the colobar for all bu the right most plot
% % if tidx<NumTypes
% % delete(childHeat.Children(1))
% % end
% 
% childHeat.Layout.Tile = NumTypes+tidx;
% drawnow;
% 
% % Accuracy Plot
% 
% % Replace Title with Split Name 
% 
% 
% 
% this_fig=fig_plot_Accuracy(tidx);
% childAccuracy = copyobj(this_fig.Children, FullTiled);
% childAccuracy.Layout.Tile = tidx;
% 
% % Modifications to the constant Line for the Accuracy Plot
% % childAccuracy.Children(2).Children(1).Label='';
% % childAccuracy.Children(2).Children(2).Label='';
% % childAccuracy.Children(2).Children(3).Label='';
% % childAccuracy.Children(2).Children(1).FontSize=8;
% % childAccuracy.Children(2).Children(2).FontSize=8;
% % childAccuracy.Children(2).Children(3).FontSize=8;
% % childAccuracy.Children(2).Children(1).LabelOrientation='aligned';
% % childAccuracy.Children(2).Children(2).LabelOrientation='aligned';
% % childAccuracy.Children(2).Children(3).LabelOrientation='aligned';
% 
% drawnow;
% 
% % Ranking Plot
% 
% end
% % close(this_fig);
% % nexttile
% 
% % this_fig=fig_plot(2);
% % child2 = copyobj(this_fig.Children, FullTiled); 
% % child2.Layout.Tile = 4;
% % child2.Children(1).Layout.Tile = 'east';
% % drawnow;
% % close(this_fig);
% 
% % close(this_fig);
% 
% % this_fig=fig_plot_accuracy(2);
% % child4 = copyobj(this_fig.Children, FullTiled); 
% % child4.Layout.Tile = 2;
% % drawnow;
% % close(this_fig);
% 
% % close([fig_plot_accuracy,fig_plot])
% 
% drawnow;
% 
% for tidx=1:NumTypes
% this_fig=fig_plot(tidx); close(this_fig);
% this_fig=fig_plot_Accuracy(tidx); close(this_fig);
% end

%%

% this_OutTable=OutTable(OutTable.AreaRemoved=="None",:);
% 
% X_Name='Time (s)';
% Y_Name='Accuracy';
% 
% PlotTitle=sprintf('Accuracy split by %s for Decoder: %s',VariableName,Decoder);
% PlotNames=cell(1);
% PlotNames{1}=num2str(TypeValues(tidx));
% 
% SplitAccuracy=this_OutTable.FilteredWindowAccuracy{SplitValue};
% 
% [fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(SplitAccuracy,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames);

% this_SubPlot_1=subplot(2,1,1);
% axcp_1 = copyobj(Tiled(1),this_SubPlot_1);
% 
% this_SubPlot_2=subplot(2,1,2);
% axcp_2 = copyobj(Tiled(2),this_SubPlot_2);
% set(axcp,'Position',get(this_subplot,'position'));

% axcp = copyobj(this_fig_plot,fig_Sub_plot);
%  set(axcp,'Position',get(this_subplot,'position'));
% ax2 = copyobj(ax1,fig_Sub_plot);

