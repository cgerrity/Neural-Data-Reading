function cgg_plotChannelClusteringAlongProbe_v2(InData,NumGroups,InArea,InTrials,InSavePlotCFG,InSaveName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Y_Name_Size=18;
X_Name_Size=18;
Main_Title_Size=18;
Main_SubTitle_Size=14;
Main_SubSubTitle_Size=8;

Tick_Size=8;

fig_cluster=figure;

figure(fig_cluster);

InArea_Label=replace(InArea,'_',' ');

%%
Main_Title='Clustering of Each Channel';
% Main_SubTitle=sprintf('Area: %s Trials:',InArea_Label);
Main_SubTitle=sprintf('Area: %s',InArea_Label);
Main_SubSubTitle=sprintf('Trials:');

for tidx=1:length(InTrials)
    if tidx==1
    Main_SubSubTitle=[Main_SubSubTitle,sprintf(' %d',InTrials(tidx))];
    elseif tidx<16
    Main_SubSubTitle=[Main_SubSubTitle,sprintf(', %d',InTrials(tidx))];
    elseif tidx==16
    Main_SubSubTitle=[Main_SubSubTitle,','];
    Main_SubSubTitle_2=[];
    Main_SubSubTitle_2=[Main_SubSubTitle_2,sprintf('%d',InTrials(tidx))];
    else
    Main_SubSubTitle_2=[Main_SubSubTitle_2,sprintf(', %d',InTrials(tidx))];
    end
end

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];
Main_SubSubTitle=['{\' sprintf(['fontsize{%d}' Main_SubSubTitle '}'],Main_SubSubTitle_Size)];

if exist('Main_SubSubTitle_2','var')
    Main_SubSubTitle_2=['{\' sprintf(['fontsize{%d}' Main_SubSubTitle_2 '}'],Main_SubSubTitle_Size)];
    Full_Title={Main_Title,Main_SubTitle,Main_SubSubTitle,Main_SubSubTitle_2};
else
    Full_Title={Main_Title,Main_SubTitle,Main_SubSubTitle};
end
%%

NumReplicates=10;
InDistance='sqeuclidean';
[Group_Labels,Data_Reduced,Group_Distance] = cgg_procChannelClustering_v3(InData,NumGroups,NumReplicates,InDistance);
%%
NumChannels=length(Group_Labels);

clr = hsv(NumGroups);

% clr=[clr(2,:);clr(1,:)];

% Group_Switch=59;
% if mean(Group_Labels(Group_Switch:NumChannels))<1.5
%     Group_Labels_tmp=Group_Labels;
%     Group_Distance_tmp=Group_Distance;
%     Group_Labels_tmp(Group_Labels==1)=2;
%     Group_Labels_tmp(Group_Labels==2)=1;
%     Group_Distance_tmp(1,:)=Group_Distance(2,:);
%     Group_Distance_tmp(2,:)=Group_Distance(1,:);
%     
%     Group_Labels=Group_Labels_tmp;
%     Group_Distance=Group_Distance_tmp;
% end

figure(fig_cluster);
drawnow;
gscatter(Group_Distance(:,1),Group_Distance(:,2),Group_Labels,clr);

textX=Group_Distance(:,1);
textY=Group_Distance(:,2);
for xidx=1:NumChannels
    text(textX(xidx), textY(xidx), num2str(Group_Labels(xidx)), 'FontSize', 4, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end

xlabel('K-Means Distance 1','FontSize',X_Name_Size);
ylabel('K-Means Distance 2','FontSize',Y_Name_Size);
title(Full_Title);
legend('off');
drawnow;

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Distance',NumGroups,InArea)];

saveas(fig_cluster,this_figure_save_name,'pdf');

clf
drawnow;
figure(fig_cluster);
gscatter(Data_Reduced(:,1),Data_Reduced(:,2),Group_Labels,clr);

textX=Data_Reduced(:,1);
textY=Data_Reduced(:,2);
for xidx=1:NumChannels
    text(textX(xidx), textY(xidx), num2str(Group_Labels(xidx)), 'FontSize', 4, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end

xlabel('tSNE Measure 1','FontSize',X_Name_Size);
ylabel('tSNE Measure 2','FontSize',Y_Name_Size);
title(Full_Title);
legend('off');
drawnow;

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Reduction',NumGroups,InArea)];

saveas(fig_cluster,this_figure_save_name,'pdf');

%%
clf
figure(fig_cluster);
gscatter(zeros(1,NumChannels),1:NumChannels,Group_Labels,clr);

xlim([-1,1]);
ylim([0,NumChannels+1]);
% axis equal;
daspect([1 2 1]);

yticks(0:Tick_Size:NumChannels);


ylabel('Channel Number','FontSize',Y_Name_Size);

title(Full_Title);
legend('off');

textX=zeros(1,NumChannels);
textY=1:NumChannels;
for xidx=1:NumChannels
    text(textX(xidx), textY(xidx), num2str(Group_Labels(xidx)), 'FontSize', 4, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end


set(gca, 'YAxisLocation', 'left', 'XTick', [], 'XTickLabel', [],'Box', 'off');
drawnow;
%%

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Probe',NumGroups,InArea)];

saveas(fig_cluster,this_figure_save_name,'pdf');

close all
end

