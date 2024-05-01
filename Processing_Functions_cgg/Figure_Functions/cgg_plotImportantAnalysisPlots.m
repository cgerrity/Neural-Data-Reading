function cgg_plotImportantAnalysisPlots(OutTable_Cell,TypeValues_Cell,VariableName,Epoch,Decoder,INcfg,varargin)
%CGG_PLOTIMPORTANTANALYSISPLOTS Summary of this function goes here
%   Detailed explanation goes here
%%

isfunction=exist('varargin','var');

if isfunction
SingleType = CheckVararginPairs('SingleType', '', varargin{:});
else
if ~(exist('SingleType','var'))
SingleType='';
end
end

%%

New_Y_Name_Size=20;

cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

SamplingFrequency = cfg_Decoder.SamplingFrequency;

DataWidth = cfg_Decoder.DataWidth/SamplingFrequency;
WindowStride = cfg_Decoder.WindowStride/SamplingFrequency;

cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

wantOnePlot = false;

FilterColumn=VariableName;

%%

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

%%

[ProbeAreas,~,OutTableAreaIndices] = unique(OutTable_Cell{1}(:,"AreaRemoved"),'stable');


AreaIndices=false(numel(OutTableAreaIndices),numel(ProbeAreas)-1);
ProbeAreas_tmp=ProbeAreas;
AreaCounter=0;
for aidx=1:numel(ProbeAreas_tmp)
    
    if ~strcmp(ProbeAreas_tmp{aidx,:},"None")
        AreaCounter=AreaCounter+1;
        AreaIndices(:,AreaCounter)=OutTableAreaIndices==aidx;
    else
        ProbeAreas(aidx,:)=[];
    end
end

%%

NumChannels=sum(AreaIndices(:,1));
NumFolds=numel(OutTable_Cell);
NumWindows=length(OutTable_Cell{1}.UnfilteredWindowAccuracy{1});
NumAreas=numel(ProbeAreas);
NumTypes=length(TypeValues_Cell{1});

TypeValues=TypeValues_Cell{1};

TypeRange=1:NumTypes;

if ~isempty(SingleType)
TypeRange=SingleType:SingleType;
NumTypes=numel(TypeRange);
end

Tiled=gobjects(NumTypes,1);
fig_plot=gobjects(NumTypes,1);
p_Plot=gobjects(NumAreas,NumTypes);
c_Plot=gobjects(NumAreas,NumTypes);
fig_plot_Accuracy=gobjects(NumTypes,1);
p_Plots_Accuracy=gobjects(NumTypes,1);
for tidx=1:NumTypes
SplitValue=TypeRange(tidx);
FilterValue=TypeValues(SplitValue);

InData=NaN(NumChannels,NumWindows,NumAreas,NumFolds);
SplitAccuracy=NaN(NumFolds,NumWindows);

for fidx=1:NumFolds
OutTable=OutTable_Cell{fidx};
OutTableSelectIAValue=OutTable(:,["FilteredWindowPercent","AreaRemoved","ChannelRemoved"]);

BaseIDX=OutTable.AreaRemoved=="None";
this_SplitAccuracy=OutTable.FilteredWindowAccuracy;
SplitAccuracy(fidx,:)=this_SplitAccuracy{BaseIDX,SplitValue};

for aidx=1:NumAreas
InData(:,:,aidx,fidx)=cell2mat(OutTableSelectIAValue.FilteredWindowPercent(AreaIndices(:,aidx),SplitValue));
end

end

InData=mean(InData,4);

% Make Most important the higher values
InData=-InData;

[InData_Min,MinIDX]=min(InData,[],2);
[InData_Max,MaxIDX]=max(InData,[],2);

InData_ReRanged=(InData-InData_Min)./(InData_Max-InData_Min);

% [~,Rearranged_Order]=sort(MinIDX,1);
[~,Rearranged_Order]=sort(MaxIDX,1);

InData_ReArranged=NaN(size(InData_ReRanged));
for aidx=1:NumAreas
InData_ReArranged(:,:,aidx)=InData_ReRanged(Rearranged_Order(:,1,aidx),:,aidx);
end

% InData_ReArranged=InData_ReRanged;

[fig_plot_tmp,p_Plots_tmp,c_Plot_tmp,Tiled_tmp] = cgg_plotImportanceAnalysisHeatMap(InData_ReArranged,ProbeAreas,Time_Start,DataWidth,WindowStride,FilterColumn,FilterValue,wantOnePlot);

% Remove Labels from Decision Indicators
fig_plot_tmp.Children.Children(NumAreas*2).Children(1).Label='';
fig_plot_tmp.Children.Children(NumAreas*2).Children(2).Label='';
fig_plot_tmp.Children.Children(NumAreas*2).Children(3).Label='';

% Remove Title from each Plot
fig_plot_tmp.Children.Title.String='';

% Remove Tiled Y Label
fig_plot_tmp.Children.YLabel.String='';

% Change Area Font Size
for aidx=1:NumAreas
p_Plots_tmp(aidx).Parent.YLabel.FontSize=New_Y_Name_Size;
end

% Delete the colobar for all but the right most plot
if tidx<NumTypes
delete(fig_plot_tmp.Children.Children(1))
end

Tiled(tidx)=Tiled_tmp;
fig_plot(tidx)=fig_plot_tmp;
p_Plot(:,tidx)=p_Plots_tmp;
c_Plot(:,tidx)=c_Plot_tmp;

% Accuracy Plots

X_Name='Time (s)';
Y_Name='Accuracy';

PlotTitle=sprintf('Accuracy split by %s for Decoder: %s',VariableName,Decoder);
PlotNames=cell(1);
PlotNames{1}=num2str(FilterValue);

[fig_plot_Accuracy_tmp,p_Plots_Accuracy_tmp,~] = cgg_plotTimeSeriesPlot(SplitAccuracy,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames,'wantTiled',true);
ylim([0,1]);

% Modifications to the constant Line for the Accuracy Plot
% fig_plot_Accuracy_tmp.Children.Children(2).Children(1).Label='';
% fig_plot_Accuracy_tmp.Children.Children(2).Children(2).Label='';
% fig_plot_Accuracy_tmp.Children.Children(2).Children(3).Label='';
fig_plot_Accuracy_tmp.Children.Children(2).Children(1).FontSize=8;
fig_plot_Accuracy_tmp.Children.Children(2).Children(2).FontSize=8;
fig_plot_Accuracy_tmp.Children.Children(2).Children(3).FontSize=8;

% Delete Legend
delete(fig_plot_Accuracy_tmp.Children.Children(1));

% Increase Y Label Font Size
fig_plot_Accuracy_tmp.Children.Children.YLabel.FontSize=New_Y_Name_Size;

% Change Title to Split Name
fig_plot_Accuracy_tmp.Children.Children.Title.String=sprintf('%s Value %d',VariableName,FilterValue);

fig_plot_Accuracy(tidx)=fig_plot_Accuracy_tmp;
p_Plots_Accuracy(tidx)=p_Plots_Accuracy_tmp;

end

fig_All_IA=figure;
fig_All_IA.WindowState='maximized';
fig_All_IA.PaperSize=[20 10];

FullTiled=tiledlayout(2,NumTypes);
FullTiled.TileSpacing = 'compact';
FullTiled.Padding = 'compact';

for tidx=1:NumTypes

% Heat Map

this_fig=fig_plot(tidx);
childHeat = copyobj(this_fig.Children, FullTiled);

% Move Corbar to right on rightmost plot
if tidx==NumTypes
childHeat.Children(1).Layout.Tile = 'east';
end

childHeat.Layout.Tile = NumTypes+tidx;
drawnow;

% Accuracy Plot

this_fig=fig_plot_Accuracy(tidx);
childAccuracy = copyobj(this_fig.Children, FullTiled);
childAccuracy.Layout.Tile = tidx;

drawnow;

% Ranking Plot

end

drawnow;

for tidx=1:NumTypes
this_fig=fig_plot(tidx); close(this_fig);
this_fig=fig_plot_Accuracy(tidx); close(this_fig);
end

%%

TargetDir=INcfg.TargetDir.path;
ResultsDir=INcfg.ResultsDir.path;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'ImportanceAnalysis',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'ImportanceAnalysis',true);
cfg.ResultsDir=cfg_tmp.TargetDir;

SavePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ImportanceAnalysis.path;
SaveName=sprintf('Importance_Split_%s',VariableName);

if ~(isempty(SingleType))
SaveName=sprintf([SaveName '_Value_%d'],FilterValue);
end

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[SavePath filesep SaveNameExt];

saveas(fig_All_IA,SavePathNameExt,'pdf');

close all

end

