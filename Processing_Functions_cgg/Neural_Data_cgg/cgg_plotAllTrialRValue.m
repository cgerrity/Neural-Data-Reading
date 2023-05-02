function cgg_plotAllTrialRValue(InP_ValueData,InP_ValueBaseline,InData_Time,InBaseline_Time,InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,InSavePlotCFG,InSaveName,InSaveDescriptor,Significance_Value,varargin)
%CGG_PLOTSELECTTRIALCONDITIONS Summary of this function goes here
%   Detailed explanation goes here
%%% Plotting

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

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

figure(fig_activity);
    
    clf(fig_activity);
    
%%
    


%% Single Plots Plots

this_Plot_Data=InP_ValueData;
this_Plot_Baseline=InP_ValueBaseline;

this_Plot_Data=this_Plot_Data*1;
this_Plot_Baseline=this_Plot_Baseline*1;

    [NumChannels,~]=size(this_Plot_Data);

% this_InData_Legend_Name=InData_Legend_Name;
% this_InBaseline_Legend_Name=InBaseline_Legend_Name;
this_InSaveDescriptor=InSaveDescriptor;

subplot(1,SubPlot_Total,SubPlot_Data_Range);
s_Data = surf(InData_Time,1:NumChannels,this_Plot_Data,'Edgecolor','none');
view(2);
% zlim(InYLim);
colorbar('vert');
% colormap(map);
% caxis(InYLim);
xline(0,'LineWidth',4);
xline(-0.4,'LineWidth',4);
xline(-0.7,'LineWidth',4);
xlim([InData_Time(1),InData_Time(end)]);
ylim([1,NumChannels]);
% zlim(InYLim);

xlabel(InData_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
% this_Title_Data=sprintf(InData_Title,'All');
% this_SubTitle_Data=sprintf('Activity of %s',this_Plot_Descriptor);
% subtitle(this_SubTitle_Data);
% title(this_Title_Data,'FontSize',18);
this_Title_Data='Segment of Interest';
title(this_Title_Data,'FontSize',14);

subplot(1,SubPlot_Total,SubPlot_Baseline_Range);
s_Baseline = surf(InBaseline_Time,1:NumChannels,this_Plot_Baseline,'Edgecolor','none');
view(2);
% zlim(InYLim);
colorbar('vert');
% colormap(map);
% caxis(InYLim);
xline(0,'LineWidth',4);
xlim([InBaseline_Time(1),InBaseline_Time(end)]);
ylim([1,NumChannels]);
% zlim(InYLim);

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
% this_Title_Baseline=sprintf(InBaseline_Title,'All');
% title(this_Title_Baseline,'FontSize',18);
% this_SubTitle_Baseline=sprintf('Activity of %s',this_Plot_Descriptor);
% subtitle(this_SubTitle_Baseline);
this_Title_Baseline='Baseline';
title(this_Title_Baseline,'FontSize',14);

Main_Title=InData_Title;
% Main_SubTitle=sprintf('Significance of %s',this_InData_Legend_Name);

Main_Title_Size=18;
% Main_SubTitle_Size=14;

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
% Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];

% Full_Title={Main_Title,Main_SubTitle};
Full_Title={Main_Title};

sgtitle(Full_Title);
drawnow;

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'All_Channels_Significance') this_InSaveDescriptor];

saveas(fig_activity,this_figure_save_name,'pdf');


close all
end

