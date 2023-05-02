function cgg_plotSelectTrialConditions(InData,InBaseline,...
    STD_ERROR_InData,STD_ERROR_InBaseline,InData_Time,InBaseline_Time,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,...
    InYLim,Smooth_Factor,InSavePlotCFG,InSaveName,varargin)
%CGG_PLOTSELECTTRIALCONDITIONS Summary of this function goes here
%   Detailed explanation goes here
%%% Plotting

xline_record=0;
xline_fixation=-0.7;
xline_choice=-0.4;
xline_width=4;

SubPlot_Fraction=0.2;
SubPlot_Total=50;
SubPlot_Separation_Fraction=0.05;

SubPlot_Separation=round(SubPlot_Total*SubPlot_Separation_Fraction);

SubPlot_Baseline=round(SubPlot_Fraction*(SubPlot_Total-SubPlot_Separation));
SubPlot_Data=(SubPlot_Total-SubPlot_Separation)-SubPlot_Baseline;

SubPlot_Baseline=round(SubPlot_Baseline);
SubPlot_Data=round(SubPlot_Data);

% Ensure that the total is exact
SubPlot_Separation=SubPlot_Total-(SubPlot_Baseline+SubPlot_Data);

SubPlot_Baseline_Range=1:SubPlot_Baseline;
SubPlot_Data_Range=SubPlot_Baseline+1+SubPlot_Separation:SubPlot_Total;

X_Name_Size=18;
Y_Name_Size=18;
Tick_Size=0.5;


fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

Plot_Colors = CheckVararginPairs('Plot_Colors', '', varargin{:});
NumPlot_Colors=length(Plot_Colors);
for cidx=1:NumPlot_Colors
    Plot_Colors{NumPlot_Colors+cidx}=Plot_Colors{cidx}*0.5;   
end

figure(fig_activity);

isManyPlot=iscell(InData);

if isManyPlot
    NumPlots=length(InData);
    [NumChannels,~]=size(InData{1});
else
    NumPlots=1;
    [NumChannels,~]=size(InData);
end

for cidx=1:NumChannels
    
    clf(fig_activity);

sel_channel=cidx;

for midx=1:NumPlots
if isManyPlot
    this_InData=InData{midx};
    this_STD_ERROR_InData=STD_ERROR_InData{midx};
    this_InBaseline=InBaseline{midx};
    this_STD_ERROR_InBaseline=STD_ERROR_InBaseline{midx};
    this_InData_Legend_Name=InData_Legend_Name{midx};
    this_InBaseline_Legend_Name=InBaseline_Legend_Name{midx};
else
    this_InData=InData;
    this_STD_ERROR_InData=STD_ERROR_InData;
    this_InBaseline=InBaseline;
    this_STD_ERROR_InBaseline=STD_ERROR_InBaseline;
    this_InData_Legend_Name=InData_Legend_Name;
    this_InBaseline_Legend_Name=InBaseline_Legend_Name;
end


this_Data=this_InData(sel_channel,:);
this_Data_STD=this_STD_ERROR_InData(sel_channel,:);
this_Data_Upper=this_Data+this_Data_STD;
this_Data_Lower=this_Data-this_Data_STD;

this_Data=smoothdata(this_Data,'movmean',Smooth_Factor);
this_Data_Upper=smoothdata(this_Data_Upper,'movmean',Smooth_Factor);
this_Data_Lower=smoothdata(this_Data_Lower,'movmean',Smooth_Factor);

this_Baseline=this_InBaseline(sel_channel,:);
this_Baseline_STD=this_STD_ERROR_InBaseline(sel_channel,:);
this_Baseline_Upper=this_Baseline+this_Baseline_STD;
this_Baseline_Lower=this_Baseline-this_Baseline_STD;

this_Baseline=smoothdata(this_Baseline,'movmean',Smooth_Factor);
this_Baseline_Upper=smoothdata(this_Baseline_Upper,'movmean',Smooth_Factor);
this_Baseline_Lower=smoothdata(this_Baseline_Lower,'movmean',Smooth_Factor);



subplot(1,SubPlot_Total,SubPlot_Data_Range);

hold on

if isempty(Plot_Colors)
p_Data(midx)=plot(InData_Time,this_Data,'LineWidth',4,'DisplayName', this_InData_Legend_Name);
else
p_Data(midx)=plot(InData_Time,this_Data,'Color',Plot_Colors{midx},'LineWidth',4,'DisplayName', this_InData_Legend_Name);
end
plot(InData_Time,this_Data_Upper,'Color',p_Data(midx).Color,'LineStyle',':','LineWidth',2);
plot(InData_Time,this_Data_Lower,'Color',p_Data(midx).Color,'LineStyle',':','LineWidth',2);


if verLessThan('matlab','9.5')
plot([xline_record,xline_record],InYLim,'LineWidth',xline_width,'Color','k');
plot([xline_fixation,xline_fixation],InYLim,'LineWidth',xline_width,'Color','k');
plot([xline_choice,xline_choice],InYLim,'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
xline(xline_fixation,'LineWidth',xline_width);
xline(xline_choice,'LineWidth',xline_width);
end

hold off

xlabel(InData_X_Name,'FontSize',X_Name_Size);
ylabel('Normalized Activity','FontSize',Y_Name_Size);
% this_Title_Data=sprintf(InData_Title,num2str(sel_channel));
% title(this_Title_Data);
this_Title_Data='Segment of Interest';
title(this_Title_Data,'FontSize',14);
% legend([p_Data]);

ylim(InYLim);
xlim([InData_Time(1),InData_Time(end)]);

xticks(InData_Time(1):Tick_Size:InData_Time(end));

% figure;
subplot(1,SubPlot_Total,SubPlot_Baseline_Range);

hold on

p_Baseline(midx)=plot(InBaseline_Time,this_Baseline,'Color',p_Data(midx).Color,'LineWidth',4,'DisplayName', this_InBaseline_Legend_Name);
plot(InBaseline_Time,this_Baseline_Upper,'Color',p_Data(midx).Color,'LineStyle',':','LineWidth',2);
plot(InBaseline_Time,this_Baseline_Lower,'Color',p_Data(midx).Color,'LineStyle',':','LineWidth',2);

if verLessThan('matlab','9.5')
plot([xline_record,xline_record],InYLim,'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
end

hold off

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Normalized Activity','FontSize',Y_Name_Size);
% this_Title_Baseline=sprintf(InBaseline_Title,num2str(sel_channel));
% title(this_Title_Baseline);
this_Title_Baseline='Baseline';
title(this_Title_Baseline,'FontSize',14);
% legend([p_Baseline]);

ylim(InYLim);
xlim([InBaseline_Time(1),InBaseline_Time(end)]);

xticks(InBaseline_Time(1):Tick_Size:InBaseline_Time(end));

% drawnow;

end
legend(p_Data);
legend(p_Baseline);

Main_Title=InData_Title;
Main_SubTitle=sprintf('Channel: %s',num2str(sel_channel));

Main_Title_Size=18;
Main_SubTitle_Size=14;

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];

Full_Title={Main_Title,Main_SubTitle};

if verLessThan('matlab','9.5')
title(Full_Title);
else
sgtitle(Full_Title);
end

drawnow;

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,num2str(sel_channel))];

saveas(fig_activity,this_figure_save_name,'pdf');

end

close all
end

