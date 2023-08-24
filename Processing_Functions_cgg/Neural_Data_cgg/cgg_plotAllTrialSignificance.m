function OutP_ValueData = cgg_plotAllTrialSignificance(InP_ValueData,InP_ValueBaseline,InData_Time,InBaseline_Time,InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,InArea,InRegressor,InModel,InSavePlotCFG,InSaveName,InSaveDescriptor,Significance_Value,Minimum_Length,InIncrement,varargin)
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

InArea_Label=replace(InArea,'_',' ');
InRegressor_Label=replace(InRegressor,'_',' ');
InModel_Label=replace(InModel,'_',' ');
    
    clf(fig_activity);
    
%%

map = [0 0 0;0 1 0];
% map = [0 0 0;1 0 0;0 1 0];
%%    
Connected_Channels = CheckVararginPairs('Connected_Channels', NaN, varargin{:});

Sampling_Period_Data=mean(abs(InData_Time(2:end)-InData_Time(1:end-1)))*1000; %Get the sampling period in ms
Sampling_Period_Baseline=mean(abs(InBaseline_Time(2:end)-InBaseline_Time(1:end-1)))*1000; %Get the sampling period in ms
Minimum_Length_Data_Samples=round(Minimum_Length/Sampling_Period_Data);
Minimum_Length_Baseline_Samples=round(Minimum_Length/Sampling_Period_Baseline);

%% Single Plots Plots
 


% this_Plot_Data=InP_ValueData;
% this_Plot_Baseline=InP_ValueBaseline;
% 


% this_Plot_Data=InP_ValueData<Significance_Value;
% this_Plot_Baseline=InP_ValueBaseline<Significance_Value;

[this_Plot_Data] = cgg_procSignificanceOverChannels(InP_ValueData,Significance_Value,Minimum_Length_Data_Samples);
[this_Plot_Baseline] = cgg_procSignificanceOverChannels(InP_ValueBaseline,Significance_Value,Minimum_Length_Baseline_Samples);

if ~(any(this_Plot_Data))
    map_Data=[0,0,0];
else
    map_Data=map;
end
if ~(any(this_Plot_Baseline))
    map_Baseline=[0,0,0];
else
    map_Baseline=map;
end


this_Plot_Data=this_Plot_Data*1;
this_Plot_Baseline=this_Plot_Baseline*1;

    [NumChannels,~]=size(this_Plot_Data);
    
    if ~any(isnan(Connected_Channels))
        Disconnected_Channels=1:NumChannels;
        Disconnected_Channels(Connected_Channels)=[];
        this_Plot_Data(Disconnected_Channels,:)=NaN;
        this_Plot_Baseline(Disconnected_Channels,:)=NaN;
    end

% this_InData_Legend_Name=InData_Legend_Name;
% this_InBaseline_Legend_Name=InBaseline_Legend_Name;
this_InSaveDescriptor=InSaveDescriptor;

subplot(1,SubPlot_Total,SubPlot_Data_Range);
imagesc(InData_Time,1:NumChannels,this_Plot_Data)
fig_activity.CurrentAxes.YDir='normal';
% s_Data = surf(InData_Time,1:NumChannels,this_Plot_Data,'Edgecolor','none');
view(2);
% zlim(InYLim);
% colorbar('vert');
colormap(map_Data);
% caxis(InYLim);
xline(0,'LineWidth',4,'Color','w');
xline(-0.4,'LineWidth',4,'Color','b');
xline(-0.7,'LineWidth',4,'Color','r');
xlim([InData_Time(1),InData_Time(end)]);
ylim([1-0.5,NumChannels+0.5]);
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
imagesc(InBaseline_Time,1:NumChannels,this_Plot_Baseline)
fig_activity.CurrentAxes.YDir='normal';
% s_Baseline = surf(InBaseline_Time,1:NumChannels,this_Plot_Baseline,'Edgecolor','none');
view(2);
% zlim(InYLim);
% colorbar('vert');
colormap(map_Baseline);
% caxis(InYLim);
xline(0,'LineWidth',4);
xlim([InBaseline_Time(1),InBaseline_Time(end)]);
ylim([1-0.5,NumChannels+0.5]);
% zlim(InYLim);

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
% this_Title_Baseline=sprintf(InBaseline_Title,'All');
% title(this_Title_Baseline,'FontSize',18);
% this_SubTitle_Baseline=sprintf('Activity of %s',this_Plot_Descriptor);
% subtitle(this_SubTitle_Baseline);
this_Title_Baseline='Baseline';
title(this_Title_Baseline,'FontSize',14);

Main_Title=sprintf('%s',InData_Title);
% Main_SubTitle=sprintf(InArea_Label);
Main_SubTitle=sprintf('%s Model: %s',InArea_Label,InModel_Label);
Main_SubSubTitle=sprintf('(Parameter: %s; p-Value = %.3f; Minimum Length = %d ms; Increment = %d ms)',InRegressor_Label,Significance_Value,Minimum_Length,InIncrement);

Main_Title_Size=18;
Main_SubTitle_Size=14;
Main_SubSubTitle_Size=12;

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];
Main_SubSubTitle=['{\' sprintf(['fontsize{%d}' Main_SubSubTitle '}'],Main_SubSubTitle_Size)];

% Full_Title={Main_Title,Main_SubTitle};
Full_Title={Main_Title,Main_SubTitle,Main_SubSubTitle};
% Full_Title={Main_Title};

sgtitle(Full_Title);
drawnow;

this_figure_save_name=[InSavePlotCFG.Regression.path filesep sprintf(InSaveName,'All_Channels_Significance') this_InSaveDescriptor];

saveas(fig_activity,this_figure_save_name,'pdf');

close all

OutP_ValueData=this_Plot_Data;
end

