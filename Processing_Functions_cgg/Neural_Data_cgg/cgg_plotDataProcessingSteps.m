function cgg_plotDataProcessingSteps(InData,InData_Time,X_Name,Y_Name,InData_Title,InYLim,Smooth_Factor,InSavePlotCFG,InSaveName,InSaveArea,varargin)
%CGG_PLOTSELECTTRIALCONDITIONS Summary of this function goes here
%   Detailed explanation goes here
%%% Plotting

X_Name_Size=18;
Y_Name_Size=18;
Tick_Size=0.05;
Plot_Line_Width=2;

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

figure(fig_activity);

[NumChannels,~]=size(InData);

for cidx=1:NumChannels
    
clf(fig_activity);

sel_channel=cidx;

this_Data=InData(sel_channel,:);

% this_Data=smoothdata(this_Data,'movmean',Smooth_Factor);

p_Data=plot(InData_Time,this_Data,'LineWidth',Plot_Line_Width);

xlabel(X_Name,'FontSize',X_Name_Size);
ylabel(Y_Name,'FontSize',Y_Name_Size);
% legend([p_Data]);

ylim(InYLim);
xlim([InData_Time(1),InData_Time(end)]);

xticks(InData_Time(1):Tick_Size:InData_Time(end));

% drawnow;

Main_Title=InData_Title;
Main_SubTitle=sprintf(' Channel: %s',num2str(sel_channel));

Main_Title_Size=18;
Main_SubTitle_Size=14;

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' InSaveArea Main_SubTitle '}'],Main_SubTitle_Size)];

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

