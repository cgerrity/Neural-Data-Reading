function cgg_plotImportanceAnalysisRanking(Difference_Accuracy,NumRankings,Time_Start,DataWidth,WindowStride,SmoothFactor,DecoderType,InSavePlotCFG)
%CGG_PLOTIMPORTANCEANALYSISRANKING Summary of this function goes here
%   Detailed explanation goes here
%%

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

Line_Width = cfg_Plotting.Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

Color_ACC = cfg_Plotting.Color_ACC;
Color_CD = cfg_Plotting.Color_CD;
Color_PFC = cfg_Plotting.Color_PFC;

%%

% [NumChannels,NumProbes,NumWindows] = size(Difference_Accuracy);

if numel(size(Difference_Accuracy))==3
[NumChannels,NumProbes,NumFolds,NumWindows] = size(Difference_Accuracy);
Type_Accuracy = 'Single';
elseif numel(size(Difference_Accuracy))==4
[NumChannels,NumProbes,NumWindows,NumFolds] = size(Difference_Accuracy);
Type_Accuracy = 'Windowed';
end

% ImportantAreaCount=NaN(NumWindows,3);
% Area_Names=cell(1,NumWindows);

ImportantAreaCount=NaN(NumFolds,NumWindows,3);
Area_Names=cell(NumFolds,NumWindows);

% for widx=1:NumWindows
% [ImportantAreaCount(widx,:),Area_Names{widx},Sorted_Values(:,widx)] = cgg_procImportanceAnalysisRanking(Difference_Accuracy(:,:,widx),NumRankings);
% end

for fidx=1:NumFolds
for widx=1:NumWindows
    if isequal(Type_Accuracy,'Single')
[ImportantAreaCount(fidx,widx,:),Area_Names{fidx,widx},Sorted_Values(:,fidx,widx)] = cgg_procImportanceAnalysisRanking(Difference_Accuracy(:,:,fidx,widx),NumRankings);
    elseif isequal(Type_Accuracy,'Windowed')
[ImportantAreaCount(fidx,widx,:),Area_Names{fidx,widx},Sorted_Values(:,fidx,widx)] = cgg_procImportanceAnalysisRanking(Difference_Accuracy(:,:,widx,fidx),NumRankings);
    end
end
end

ImportantAreaFraction = ImportantAreaCount/NumRankings;
%%
isAllAreasSame = all(all(cellfun(@(x) all(strcmp(x,Area_Names{1})),Area_Names,'UniformOutput',true)));

if isAllAreasSame
    Area_Names = Area_Names{1};
end

%%

NumAreas = numel(Area_Names);

PlotColors=cell(1,NumAreas);
PlotColors{strcmp(Area_Names,'ACC')} = Color_ACC;
PlotColors{strcmp(Area_Names,'CD')} = Color_CD;
PlotColors{strcmp(Area_Names,'PFC')} = Color_PFC;

if NumWindows==1

    ImportantAreaCount = squeeze(mean(ImportantAreaCount,1));

piechart(ImportantAreaCount,Area_Names);

% IA_Title=sprintf('Fraction of Top %d Most Impactful Channels By Area',NumRankings);
%     title(IA_Title,'FontSize',Title_Size);

%%

this_figure_save_name=[InSavePlotCFG.path filesep sprintf('Ranking_Top_%d_%s',NumRankings,DecoderType)];

saveas(fig_activity,this_figure_save_name,'pdf');

close all
else
    Time_Start_Adjusted = Time_Start+DataWidth/2;
    this_Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
    this_Data=smoothdata(ImportantAreaFraction,2,'gaussian',SmoothFactor);

    YMax=0;
    YMin=1;

    p_Ranking = NaN(1,NumAreas);
    hold on
    for aidx=1:NumAreas

    [this_p_Ranking,p_Error] = cgg_plotLinePlotWithShadedError(this_Time,this_Data(:,:,aidx),PlotColors{aidx});

    this_p_Ranking.LineWidth = Line_Width;
    this_p_Ranking.Color = PlotColors{aidx};
    this_p_Ranking.DisplayName = Area_Names{aidx};
    YMax = max([YMax,this_p_Ranking.YData]);
    YMin = min([YMin,this_p_Ranking.YData]);
    p_Ranking(aidx) = this_p_Ranking;
    end
    hold off

    YRange=YMax-YMin;
    YUpper=YMax+(RangeFactorUpper*YRange);
    YLower=YMin-(RangeFactorLower*YRange);

    cgg_plotDecisionEpochIndicators({'k','k','k'});

    legend(p_Ranking,'Location','best','FontSize',Legend_Size);

    xlabel('Time (s)','FontSize',X_Name_Size);
    ylabel('Fraction of Impactful Channels','FontSize',Y_Name_Size);
    IA_Title=sprintf('Fraction of Top %d Most Impactful Channels By Area',NumRankings);
    title(IA_Title,'FontSize',Title_Size);

    fig_activity.CurrentAxes.XAxis.FontSize=Label_Size;
    fig_activity.CurrentAxes.YAxis.FontSize=Label_Size;

    ylim([YLower,YUpper]);

%%

this_figure_save_name=[InSavePlotCFG.path filesep sprintf('Ranking_Over_Time_Top_%d_Smooth_%d_%s',NumRankings,SmoothFactor,DecoderType)];

saveas(fig_activity,this_figure_save_name,'pdf');

close all

end

end
