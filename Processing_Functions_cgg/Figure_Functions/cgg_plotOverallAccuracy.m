function cgg_plotOverallAccuracy(FullTable,cfg)
%CGG_PLOTOVERALLACCURACY Summary of this function goes here
%   Detailed explanation goes here

%%
cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Line_Width = cfg_Plotting.Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

RangeAccuracyUpper = cfg_Plotting.RangeAccuracyUpper;
RangeAccuracyLower = cfg_Plotting.RangeAccuracyLower;

ErrorCapSize = cfg_Plotting.ErrorCapSize;

Tick_Size = 2;

BarWidth  = 12;

Y_Upper=0;
Y_Lower=1;
Y_Limit_Set = [0,0.35];
Y_Tick_Label_Size = 36;
Y_Tick_Size = 0.05;
%%

% Decoders=FullTable.Properties.RowNames;
LoopNames=FullTable.Properties.RowNames;

% [NumDecoders,~]=size(FullTable);
[NumLoops,~]=size(FullTable);

%%

ExtraSaveTerm=cfg.ExtraSaveTerm;

RandomChance=cfg.RandomChance;
MostCommon=cfg.MostCommon;

Accuracy_All=FullTable.(cfg_Names.TableNameAccuracy);

% Decoders_Cat = categorical(Decoders);
% Decoders_Cat = reordercats(Decoders_Cat,Decoders);

LoopNames_Cat = categorical(LoopNames);
LoopNames_Cat = reordercats(LoopNames_Cat,LoopNames);

fig_accuracy=figure;
fig_accuracy.Units="normalized";
fig_accuracy.Position=[0,0,1,1];
fig_accuracy.Units="inches";
fig_accuracy.PaperUnits="inches";
PlotPaperSize=fig_accuracy.Position;
PlotPaperSize(1:2)=[];
fig_accuracy.PaperSize=PlotPaperSize;

if NumLoops<8
PlotColor(1,:)=[0 0.4470 0.7410];
PlotColor(2,:)=[0.8500 0.3250 0.0980];
PlotColor(3,:)=[0.9290 0.6940 0.1250];
PlotColor(4,:)=[0.4940 0.1840 0.5560];
PlotColor(5,:)=[0.4660 0.6740 0.1880];
PlotColor(6,:)=[0.3010 0.7450 0.9330];
PlotColor(7,:)=[0.6350 0.0780 0.1840];
else
PlotColor=turbo(NumLoops);
end
% p_Mean = gobjects(NumDecoders+1,1);
% p_Error = gobjects(NumDecoders,1);
p_Mean = gobjects(NumLoops+1,1);
p_Error = gobjects(NumLoops,1);

% InvalidPlots = false(NumDecoders,1);
InvalidPlots = false(NumLoops,1);



% Values=cell(NumDecoders,1);
% ColorOrder=cell(NumDecoders,1);
Values=cell(NumLoops,1);
ColorOrder=cell(NumLoops,1);
%%
hold on
% for didx=1:NumDecoders
for lidx=1:NumLoops

    this_Accuracy=Accuracy_All{lidx};

    if ~isempty(this_Accuracy)

[NumFolds,NumIterations]=size(this_Accuracy);

Y_Value_Final=this_Accuracy(:,NumIterations);

Values{lidx}=Y_Value_Final;

XValues=1:NumIterations;
YValues=this_Accuracy;

[this_p_Mean,this_p_Error] = cgg_plotLinePlotWithShadedError(XValues,YValues,PlotColor(lidx,:));

    this_p_Mean.LineWidth = Line_Width;
    % this_p_Mean.DisplayName = Decoders{lidx};
    this_p_Mean.DisplayName = LoopNames{lidx};

    ColorOrder{lidx}=this_p_Mean.Color;

    p_Mean(lidx)=this_p_Mean;
    p_Error(lidx)=this_p_Error;
    else
        InvalidPlots(lidx)=true;
    end

    Y_Upper=max([Y_Upper;YValues(:)]);
    Y_Lower=min([Y_Lower;YValues(:)]);

end

YLimLower=Y_Lower*(1-RangeFactorLower);
YLimUpper=Y_Upper*(1+RangeFactorUpper);

YLimLower=max([0,YLimLower]);
YLimUpper=min([1,YLimUpper]);

YLimLower=RangeAccuracyLower;
YLimUpper=RangeAccuracyUpper;

p_Random=yline(RandomChance);
p_MostCommon=yline(MostCommon);

p_MostCommon.LineWidth = Line_Width;
p_Random.LineWidth = Line_Width;
p_MostCommon.DisplayName = 'Most Common';
p_Random.DisplayName = 'Random Chance';

% p_Mean(NumDecoders+1)=p_Random;
p_Mean(NumLoops+1)=p_MostCommon;
p_Mean(NumLoops+2)=p_Random;

hold off

p_Mean(InvalidPlots)=[];
p_Error(InvalidPlots)=[];

% ValueNames=Decoders;
ValueNames=LoopNames;

% Values{NumDecoders+1}=RandomChance;
% ValueNames{NumDecoders+1}='Random Chance';
% ColorOrder{NumDecoders+1}=p_Random.Color;

Values(InvalidPlots)=[];
ValueNames(InvalidPlots)=[];
ColorOrder(InvalidPlots)=[];
ColorOrder=cell2mat(ColorOrder);

legend(p_Mean,'Location','best','FontSize',Legend_Size);

Y_Name = 'Accuracy';
if contains(cfg.MatchType,'Scaled')
Y_Name = 'Normalized Accuracy';
end

xlabel('Iteration','FontSize',X_Name_Size);
ylabel(Y_Name,'FontSize',Y_Name_Size);
Accuracy_Title=sprintf('Accuracy over %d Iterations and %d Folds',NumIterations,NumFolds);
title(Accuracy_Title,'FontSize',Title_Size);

xticks([1,Tick_Size:Tick_Size:NumIterations]);
ylim([YLimLower,YLimUpper]);
ylim([0,1]);

%%

cfg_Plot = cgg_generateDecodingFolders('TargetDir',cfg.TargetDir,...
    'Epoch',cfg.Epoch,'Accuracy',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'Accuracy',true);
cfg_Plot.ResultsDir=cfg_tmp.TargetDir;

drawnow;

SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
SaveName=['Accuracy_Over_Iterations' ExtraSaveTerm '_Type_' cfg.LoopType];

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[SavePath filesep SaveNameExt];

saveas(fig_accuracy,SavePathNameExt,'pdf');

close all

%% Bar Graph

fig_accuracy_bar=figure;
fig_accuracy_bar.Units="normalized";
fig_accuracy_bar.Position=[0,0,0.5,1];
fig_accuracy_bar.Units="inches";
fig_accuracy_bar.PaperUnits="inches";
PlotPaperSize=fig_accuracy_bar.Position;
PlotPaperSize(1:2)=[];
fig_accuracy_bar.PaperSize=PlotPaperSize;

LabelAngle = 30;
% ColorOrder = '';
if length(ValueNames) == 6
ColorOrder = cfg_Plotting.Rainbow;
end
% disp(isempty(ColorOrder))
[b_Plot] = cgg_plotBarGraphWithError(Values,ValueNames,'ColorOrder',ColorOrder,'X_TickFontSize',Y_Tick_Label_Size,'ErrorLineWidth',Line_Width,'ErrorCapSize',ErrorCapSize,'wantCI',true,'LabelAngle',LabelAngle,'InFigure',fig_accuracy_bar,'X_Name','','BarWidth',BarWidth);

% p_MostCommon=yline(MostCommon,"-",'Most Common');
% p_Random=yline(RandomChance,"-",'Random Chance');
% p_MostCommon.LineWidth = Line_Width;
% p_Random.LineWidth = Line_Width;
% 
% p_MostCommon.LabelOrientation = 'horizontal';
% p_MostCommon.LabelVerticalAlignment = 'middle';
% p_MostCommon.LabelHorizontalAlignment = 'left';
% p_MostCommon.FontSize = Label_Size;
% p_Random.LabelOrientation = 'horizontal';
% p_Random.LabelVerticalAlignment = 'middle';
% p_Random.LabelHorizontalAlignment = 'left';
% p_Random.FontSize = Label_Size;

Y_Name = 'Accuracy';
if contains(cfg.MatchType,'Scaled')
Y_Name = 'Scaled Balanced Accuracy';
end
Y_Label = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name);
% ylabel(Y_Name,'FontSize',Y_Name_Size);
ylabel(Y_Label);

Bar_Title=sprintf('Accuracy of %s over %d Folds',cfg.LoopTitle,NumFolds);
% title(Bar_Title,'FontSize',Title_Size);

% ylim([0,Y_Upper*(1+RangeFactorUpper)]);
% ylim([YLimLower,YLimUpper]);
% ylim([0,1]);
YLimits = Y_Limit_Set;
ylim(YLimits);

Current_Axis = gca;
Current_Axis.YAxis.FontSize=Y_Tick_Label_Size;
Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);

if ~(isempty(Y_Ticks) || any(isnan(Y_Ticks)))
yticks(Y_Ticks);
end

drawnow;
SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
SaveName=['Accuracy_Overall' ExtraSaveTerm '_Type_' cfg.LoopType];

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[SavePath filesep SaveNameExt];

saveas(fig_accuracy_bar,SavePathNameExt,'pdf');

close all

end

