function cgg_plotDataDistribution(FullDataTable,InVariableName,InEpoch,InSavePlotCFG)
%CGG_PLOTDATADISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here


% fig_activity=figure;
% fig_activity.WindowState='maximized';
% fig_activity.PaperSize=[20 10];
fig_activity=figure;
fig_activity.Units="normalized";
fig_activity.Position=[0,0,1,1];
fig_activity.Units="inches";
fig_activity.PaperUnits="inches";
PlotPaperSize=fig_activity.Position;
PlotPaperSize(1:2)=[];
fig_activity.PaperSize=PlotPaperSize;
% InFigure.Visible='off';

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

Line_Width = cfg_Plotting.Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
X_Name_Size_Pie = cfg_Plotting.X_Name_Size_Pie;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;

Main_Title_Size = cfg_Plotting.Main_Title_Size;
Main_SubTitle_Size = cfg_Plotting.Main_SubTitle_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

Color_ACC = cfg_Plotting.Color_ACC;
Color_CD = cfg_Plotting.Color_CD;
Color_PFC = cfg_Plotting.Color_PFC;

%%

FullCount=FullDataTable.Count(strcmp(FullDataTable.Source,'Full Data'));
FullName=FullDataTable.FeatureValue(strcmp(FullDataTable.Source,'Full Data'));

DataTableNoFull=FullDataTable;
DataTableNoFull(strcmp(FullDataTable.Source,'Full Data'),:) = [];

%% Distribution Type Pie

subplot(2,2,3);

% p_Full=piechart(FullCount,FullName);
p_Full=piechart(FullCount);

p_Full.FontSize=X_Name_Size_Pie;

if length(FullName) > 6
p_Full.ColorOrder = hsv(length(FullName));
end

ColorOrder=p_Full.ColorOrder;
ColorOrder=[ColorOrder;ColorOrder;ColorOrder;ColorOrder];

% title('Fraction of Each Type')

% title('Fraction of Each Type','FontSize',Title_Size);

%% Trial Count Bar

subplot(2,2,1);

b_Full=bar(FullCount);
b_Full.FaceColor="flat";

[NumBars,~]=size(b_Full.CData(:,:));

b_Full.CData(:,:)=ColorOrder(1:NumBars,:);

CurrentAxes = gca;
XTick_IDX = CurrentAxes.XTick;

if length(XTick_IDX) < length(FullName)
% disp(FullName(XTick_IDX))
% xticklabels(FullName(XTick_IDX));
else
xticklabels(FullName);
end

% xticklabels(FullName);
% xlabel(InVariableName,'FontSize',X_Name_Size);
ylabel('Number of Trials','FontSize',Y_Name_Size);

% title('Count of Each Type','FontSize',Title_Size);

%%

subplot(2,2,[2,4])

b_Distribution=boxchart(DataTableNoFull.FeatureValue,DataTableNoFull.Difference,'GroupByColor',DataTableNoFull.Source,'Notch','on');

b_Distribution(1).LineWidth=2;
b_Distribution(2).LineWidth=2;

b_Distribution(1).BoxWidth=0.75;
b_Distribution(2).BoxWidth=0.75;

legend(b_Distribution,'Location','best','FontSize',Legend_Size);

ylabel('Difference','FontSize',Y_Name_Size);

% title('Spread of Partitions','FontSize',Title_Size);

%%

Main_Title=sprintf('Data Distribution for %s',InVariableName);
Main_SubTitle=sprintf('Epoch: %s',InEpoch);

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];

Full_Title={Main_Title,Main_SubTitle};

sgtitle(Full_Title);
drawnow;

%%

InVariableSaveName=replace(InVariableName,' ','_');

this_figure_save_name=[InSavePlotCFG.path filesep sprintf('Data_Distribution_Epoch_%s_Type_%s',InEpoch,InVariableSaveName)];

saveas(fig_activity,this_figure_save_name,'pdf');

close all

end

