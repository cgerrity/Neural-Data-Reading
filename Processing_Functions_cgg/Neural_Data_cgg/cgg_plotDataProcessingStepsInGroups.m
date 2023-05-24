function cgg_plotDataProcessingStepsInGroups(InData,InData_Time,X_Name,Y_Name,InData_Title,InYLim,Channel_Group,InSavePlotCFG,InSaveName,InSaveArea,varargin)
%cgg_plotDataProcessingStepsInGroups Summary of this function goes here
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

% [NumChannels,~]=size(InData);

% for cidx=1:NumChannels
    
clf(fig_activity);

this_Y_Range=InYLim(2)-InYLim(1);

% this_Data=smoothdata(this_Data,'movmean',Smooth_Factor);

ColorMap=turbo(length(Channel_Group));
for gidx=1:length(Channel_Group)
    if gidx==1
        hold on
    end
    
sel_channel=Channel_Group(gidx);
this_Data=InData(sel_channel,:)-(gidx-1)*this_Y_Range;

p_Data{gidx}=plot(InData_Time,this_Data,'LineWidth',Plot_Line_Width,...
    'Color',ColorMap(gidx,:),'DisplayName',['Channel ' num2str(sel_channel)]);

end
hold off

xlabel(X_Name,'FontSize',X_Name_Size);
ylabel(Y_Name,'FontSize',Y_Name_Size);
legend('Location','northeast');
% legend([p_Data]);

this_InYLim=[InYLim(1)-this_Y_Range*((length(Channel_Group)-1)*1+0.5),InYLim(1)+this_Y_Range*((length(Channel_Group)-1)*0+1.5)];

ylim(this_InYLim);
xlim([InData_Time(1),InData_Time(end)]);

xticks(InData_Time(1):Tick_Size:InData_Time(end));

% drawnow;

Main_Title=InData_Title;
Main_SubTitle=sprintf(' Channel: %s',num2str(Channel_Group(1)));
for gidx=2:length(Channel_Group)
Main_SubTitle=sprintf([Main_SubTitle ', %s'],num2str(Channel_Group(gidx)));
end

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

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Group')];

saveas(fig_activity,this_figure_save_name,'pdf');

% end

close all
end

