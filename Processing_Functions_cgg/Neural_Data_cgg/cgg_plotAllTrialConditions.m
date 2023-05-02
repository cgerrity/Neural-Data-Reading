function cgg_plotAllTrialConditions(InData,InBaseline,...
    STD_ERROR_InData,STD_ERROR_InBaseline,InData_Time,InBaseline_Time,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,...
    InYLim,Smooth_Factor,InSavePlotCFG,InSaveName,InSaveDescriptor,varargin)
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

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

figure(fig_activity);

isManyPlot=iscell(InData);

if isManyPlot
    NumPlots=length(InData);
    [NumChannels,~]=size(InData{1});
else
    NumPlots=1;
    [NumChannels,~]=size(InData);
end
    
    clf(fig_activity);
%%
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
    this_InBaseline_Legend_Name=InBaseline_Legend_Name{midx};
end


this_Data=this_InData(:,:);
this_Data_STD=this_STD_ERROR_InData(:,:);
this_Data_Upper=this_Data+this_Data_STD;
this_Data_Lower=this_Data-this_Data_STD;

this_Data=smoothdata(this_Data,2,'movmean',Smooth_Factor);
this_Data_Upper=smoothdata(this_Data_Upper,2,'movmean',Smooth_Factor);
this_Data_Lower=smoothdata(this_Data_Lower,2,'movmean',Smooth_Factor);

this_Baseline=this_InBaseline(:,:);
this_Baseline_STD=this_STD_ERROR_InBaseline(:,:);
this_Baseline_Upper=this_Baseline+this_Baseline_STD;
this_Baseline_Lower=this_Baseline-this_Baseline_STD;

this_Baseline=smoothdata(this_Baseline,2,'movmean',Smooth_Factor);
this_Baseline_Upper=smoothdata(this_Baseline_Upper,2,'movmean',Smooth_Factor);
this_Baseline_Lower=smoothdata(this_Baseline_Lower,2,'movmean',Smooth_Factor);


tmp_Data{midx}=this_Data;
tmp_Baseline{midx}=this_Baseline;

end

%% Single Plots Plots

for midx=1:NumPlots
    
    this_Plot_Data=tmp_Data{midx};
    this_Plot_Baseline=tmp_Baseline{midx};
    
    this_InData_Legend_Name=InData_Legend_Name{midx};
    this_InBaseline_Legend_Name=InBaseline_Legend_Name{midx};
    this_InSaveDescriptor=InSaveDescriptor{midx};

subplot(1,SubPlot_Total,SubPlot_Data_Range);
s_Data = surf(InData_Time,1:NumChannels,this_Plot_Data,'Edgecolor','none');
view(2);
zlim(InYLim);
colorbar('vert');
caxis(InYLim);

if verLessThan('matlab','9.5')
plot([xline_record,xline_record],[1,NumChannels],'LineWidth',xline_width,'Color','k');
plot([xline_fixation,xline_fixation],[1,NumChannels],'LineWidth',xline_width,'Color','k');
plot([xline_choice,xline_choice],[1,NumChannels],'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
xline(xline_fixation,'LineWidth',xline_width);
xline(xline_choice,'LineWidth',xline_width);
end

xlim([InData_Time(1),InData_Time(end)]);
ylim([1,NumChannels]);
zlim(InYLim);

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
zlim(InYLim);
colorbar('vert');
caxis(InYLim);

if verLessThan('matlab','9.5')
plot([xline_record,xline_record],[1,NumChannels],'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
end

xlim([InBaseline_Time(1),InBaseline_Time(end)]);
ylim([1,NumChannels]);
zlim(InYLim);

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
% this_Title_Baseline=sprintf(InBaseline_Title,'All');
% title(this_Title_Baseline,'FontSize',18);
% this_SubTitle_Baseline=sprintf('Activity of %s',this_Plot_Descriptor);
% subtitle(this_SubTitle_Baseline);
this_Title_Baseline='Baseline';
title(this_Title_Baseline,'FontSize',14);

Main_Title=InData_Title;
Main_SubTitle=sprintf('Activity of %s',this_InData_Legend_Name);

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

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'All_Channels_') this_InSaveDescriptor];

saveas(fig_activity,this_figure_save_name,'pdf');

end

%% Difference Plots

if NumPlots==2

Data_Difference=tmp_Data{2}-tmp_Data{1};
Baseline_Difference=tmp_Baseline{2}-tmp_Baseline{1};

subplot(1,SubPlot_Total,SubPlot_Data_Range);
s_Data = surf(InData_Time,1:NumChannels,Data_Difference,'Edgecolor','none');
view(2);
colorbar('vert');

if verLessThan('matlab','9.5')
plot([xline_record,xline_record],[1,NumChannels],'LineWidth',xline_width,'Color','k');
plot([xline_fixation,xline_fixation],[1,NumChannels],'LineWidth',xline_width,'Color','k');
plot([xline_choice,xline_choice],[1,NumChannels],'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
xline(xline_fixation,'LineWidth',xline_width);
xline(xline_choice,'LineWidth',xline_width);
end

xlim([InData_Time(1),InData_Time(end)]);
ylim([1,NumChannels]);

xlabel(InData_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
% this_Title_Data=sprintf(InData_Title,'All');
% title(this_Title_Data);
% this_SubTitle_Data=sprintf('Difference of %s and %s',InData_Legend_Name{1},InData_Legend_Name{2});
% subtitle(this_SubTitle_Data);
this_Title_Data='Segment of Interest';
title(this_Title_Data,'FontSize',14);


subplot(1,SubPlot_Total,SubPlot_Baseline_Range);
s_Baseline = surf(InBaseline_Time,1:NumChannels,Baseline_Difference,'Edgecolor','none');
view(2);
colorbar('vert');

if verLessThan('matlab','9.5')
plot([xline_record,xline_record],[1,NumChannels],'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
end

xlim([InBaseline_Time(1),InBaseline_Time(end)]);
ylim([1,NumChannels]);

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
% this_Title_Baseline=sprintf(InBaseline_Title,'All');
% title(this_Title_Baseline);
% this_SubTitle_Baseline=sprintf('Difference of %s and %s',InData_Legend_Name{1},InData_Legend_Name{2});
% subtitle(this_SubTitle_Baseline);
this_Title_Baseline='Baseline';
title(this_Title_Baseline,'FontSize',14);

Main_Title=InData_Title;
Main_SubTitle=sprintf('Difference of %s and %s',InData_Legend_Name{1},InData_Legend_Name{2});

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

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'All_Channels_Difference')];

saveas(fig_activity,this_figure_save_name,'pdf');

end

close all
end

