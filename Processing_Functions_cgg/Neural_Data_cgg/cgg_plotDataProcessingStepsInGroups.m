function cgg_plotDataProcessingStepsInGroups(InData,InData_Time,X_Name,Y_Name,InData_Title,InYLim,Channel_Group,InSavePlotCFG,InSaveName,InSaveArea,varargin)
%cgg_plotDataProcessingStepsInGroups Summary of this function goes here
%   Detailed explanation goes here
%%% Plotting

X_Name_Size=18;
Y_Name_Size=18;
Tick_Size=0.05;
Y_Tick_Skip=8;
Plot_Line_Width=1;

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

InArea_Label=replace(InSaveArea,'_',' ');

figure(fig_activity);

% [NumChannels,~]=size(InData);

% for cidx=1:NumChannels
    
clf(fig_activity);

this_Y_Range=InYLim(2)-InYLim(1);

% this_Data=smoothdata(this_Data,'movmean',Smooth_Factor);

ColorMap=turbo(length(Channel_Group));
Y_Offsets=ones(length(Channel_Group),1);

for gidx=1:length(Channel_Group)
    if gidx==1
        hold on
    end
    
this_Y_Offset=-(gidx-1)*this_Y_Range;
sel_channel=Channel_Group(gidx);
this_Data=InData(sel_channel,:)+this_Y_Offset;

p_Data{gidx}=plot(InData_Time,this_Data,'LineWidth',Plot_Line_Width,...
    'Color',ColorMap(gidx,:),'DisplayName',['Channel ' num2str(sel_channel)]);
Y_Offsets(gidx)=this_Data(1);
end
hold off

xlabel(X_Name,'FontSize',X_Name_Size);
ylabel(Y_Name,'FontSize',Y_Name_Size);
% legend('Location','northeast');
% legend([p_Data]);

this_InYLim=[InYLim(1)-this_Y_Range*((length(Channel_Group)-1)*1+1),InYLim(1)+this_Y_Range*((length(Channel_Group)-1)*0+4)];

ylim(this_InYLim);
xlim([InData_Time(1),InData_Time(end)]);

xticks(InData_Time(1):Tick_Size:InData_Time(end));

YTicks_IDX=fliplr([1,Y_Tick_Skip:Y_Tick_Skip:length(Channel_Group)]);

% Convert the array of numbers to a cell array of strings
YTicks_Names = cellfun(@num2str, num2cell(YTicks_IDX), 'UniformOutput', false);

YTicks=Y_Offsets(YTicks_IDX);

yticks(YTicks);
yticklabels(YTicks_Names);

% Adjust y-axis tick marks
ax = gca; % Get the current axes handle
ax.YAxis.TickLength = [0.01, 0.01]; % Set tick length
ax.YAxis.TickDirection = 'out';   % Set tick direction

% drawnow;

Main_Title=InData_Title;
Main_SubTitle=sprintf('Channel: %s',num2str(Channel_Group(1)));
for gidx=2:length(Channel_Group)
%     if gidx<33
        Main_SubTitle=sprintf([Main_SubTitle ', %s'],num2str(Channel_Group(gidx)));
%     elseif gidx==33
%         Main_SubTitle_2='33';
%     else
%         Main_SubTitle_2=sprintf([Main_SubTitle_2 ', %s'],num2str(Channel_Group(gidx)));
%     end
end

Main_Title_Size=18;
% Main_SubTitle_Size=10;
Main_SubTitle_Size=8;

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title ': ' InArea_Label '}'],Main_Title_Size)];
% Main_SubTitle=['{\' sprintf(['fontsize{%d}' InArea_Label '}'],Main_SubTitle_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];

Full_Title={Main_Title,Main_SubTitle};

% if exist('Main_SubTitle_2','var')
%     Main_SubTitle_2=['{\' sprintf(['fontsize{%d}' Main_SubTitle_2 '}'],Main_SubSubTitle_Size)];
%     Full_Title={Main_Title,Main_SubTitle,Main_SubTitle_2};
% end

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

