function cgg_plotSignificanceAcrossTime(InP_ValueData,InP_ValueBaseline,InData_Time,InBaseline_Time,InData_X_Name,InBaseline_X_Name,InData_Title,InArea,InRegressor,InModel,InSavePlotCFG,InSaveName,Significance_Value,Minimum_Length,varargin)
%cgg_plotSignificanceAcrossTime Summary of this function goes here
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

InArea_Label=replace(InArea,'_',' ');
InRegressor_Label=replace(InRegressor,'_',' ');
InModel_Label=replace(InModel,'_',' ');

Connected_Channels = CheckVararginPairs('Connected_Channels', NaN, varargin{:});

%%

% this_Plot_Data=InP_ValueData<Significance_Value;
% this_Plot_Baseline=InP_ValueBaseline<Significance_Value;

[this_Plot_Data] = cgg_procSignificanceOverChannels(InP_ValueData,Significance_Value,Minimum_Length);
[this_Plot_Baseline] = cgg_procSignificanceOverChannels(InP_ValueBaseline,Significance_Value,Minimum_Length);

this_Plot_Data=this_Plot_Data*1;
this_Plot_Baseline=this_Plot_Baseline*1;

[NumChannels,~]=size(this_Plot_Data);

    if ~any(isnan(Connected_Channels))
        Disconnected_Channels=1:NumChannels;
        Disconnected_Channels(Connected_Channels)=[];
        this_Plot_Data(Disconnected_Channels,:)=NaN;
        this_Plot_Baseline(Disconnected_Channels,:)=NaN;
        NumChannels=length(Connected_Channels);
    end

this_Plot_Data=sum(this_Plot_Data,1,'omitnan')/NumChannels;
this_Plot_Baseline=sum(this_Plot_Baseline,1,'omitnan')/NumChannels;
    
    clf(fig_activity);
  

subplot(1,SubPlot_Total,SubPlot_Data_Range);

hold on

if isempty(Plot_Colors)
% p_Data=plot(InData_Time,this_Plot_Data,'LineWidth',4,'DisplayName', this_InData_Legend_Name);
p_Data=plot(InData_Time,this_Plot_Data,'LineWidth',4);

else
% p_Data=plot(InData_Time,this_Plot_Data,'Color',Plot_Colors,'LineWidth',4,'DisplayName', this_InData_Legend_Name);
p_Data=plot(InData_Time,this_Plot_Data,'Color',Plot_Colors,'LineWidth',4);
end


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
ylabel('Fraction of Significant Channels','FontSize',Y_Name_Size);
% this_Title_Data=sprintf(InData_Title,num2str(sel_channel));
% title(this_Title_Data);
this_Title_Data='Segment of Interest';
title(this_Title_Data,'FontSize',14);
% legend([p_Data]);

ylim([0,1]);
xlim([InData_Time(1),InData_Time(end)]);

xticks(InData_Time(1):Tick_Size:InData_Time(end));

% figure;
subplot(1,SubPlot_Total,SubPlot_Baseline_Range);

hold on

% p_Baseline=plot(InBaseline_Time,this_Plot_Baseline,'Color',p_Data.Color,'LineWidth',4,'DisplayName', this_InBaseline_Legend_Name);
p_Baseline=plot(InBaseline_Time,this_Plot_Baseline,'Color',p_Data.Color,'LineWidth',4);

if verLessThan('matlab','9.5')
plot([xline_record,xline_record],InYLim,'LineWidth',xline_width,'Color','k');
else
xline(xline_record,'LineWidth',xline_width);
end

hold off

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Fraction of Significant Channels','FontSize',Y_Name_Size);
% this_Title_Baseline=sprintf(InBaseline_Title,num2str(sel_channel));
% title(this_Title_Baseline);
this_Title_Baseline='Baseline';
title(this_Title_Baseline,'FontSize',14);
% legend([p_Baseline]);

ylim([0,1]);
xlim([InBaseline_Time(1),InBaseline_Time(end)]);

xticks(InBaseline_Time(1):Tick_Size:InBaseline_Time(end));

% drawnow;
% legend(p_Data);
% legend(p_Baseline);

Main_Title=sprintf('%s',InData_Title);
% Main_SubTitle=sprintf(InArea_Label);
Main_SubTitle=sprintf('%s Model: %s',InArea_Label,InModel_Label);
Main_SubSubTitle=sprintf('(Parameter: %s; p-Value = %.3f; Minimum Length = %d ms)',InRegressor_Label,Significance_Value,Minimum_Length);

Main_Title_Size=18;
Main_SubTitle_Size=14;
Main_SubSubTitle_Size=12;

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];
Main_SubSubTitle=['{\' sprintf(['fontsize{%d}' Main_SubSubTitle '}'],Main_SubSubTitle_Size)];

% Full_Title={Main_Title,Main_SubTitle};
Full_Title={Main_Title,Main_SubTitle,Main_SubSubTitle};
% Full_Title={Main_Title};

if verLessThan('matlab','9.5')
title(Full_Title);
else
sgtitle(Full_Title);
end

drawnow;

this_figure_save_name=[InSavePlotCFG.Regression.path filesep sprintf(InSaveName)];

saveas(fig_activity,this_figure_save_name,'pdf');

close all
end

