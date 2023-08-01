function cgg_plotChannelCorrelations(InData,InArea,InTrials,InSavePlotCFG,InSaveName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

X_Name_Size=18;
Y_Name_Size=18;
Main_Title_Size=18;
Main_SubTitle_Size=14;
Main_SubSubTitle_Size=8;

YLim_Lower=0;
YLim_Upper=1;

YLim_Lower_Zoomx2=0.5;
YLim_Upper_Zoomx2=1;
% YLim_Lower_Zoomx2=0;
% YLim_Upper_Zoomx2=0.1;

YLim_Lower_Zoomx4=0.75;
YLim_Upper_Zoomx4=1;
% YLim_Lower_Zoomx4=0;
% YLim_Upper_Zoomx4=0.01;

Tick_Size=8;

fig_mean=figure;
% fig_mean.WindowState='maximized';
% fig_mean.PaperSize=[20 10];

figure(fig_mean);

InArea_Label=replace(InArea,'_',' ');

this_DataCorr=corrcoef(InData');

[NumChannels,~]=size(this_DataCorr);

imagesc(this_DataCorr)
axis square;
fig_mean.CurrentAxes.YDir='normal';
view(2);
c_Baseline=colorbar('vert');
c_Baseline.Label.String = 'Correlation';
c_Baseline.Label.FontSize = Y_Name_Size;
caxis([YLim_Lower,YLim_Upper]);

xticks(0:Tick_Size:NumChannels);
yticks(0:Tick_Size:NumChannels);

xlabel('Channel Number','FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);

Main_Title='Correlation of Each Channel';
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

% Full_Title={Main_Title,Main_SubTitle,Main_SubSubTitle};

title(Full_Title);

% if verLessThan('matlab','9.5')
% title(Full_Title);
% else
% sgtitle(Full_Title);
% end

drawnow;

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Zoomx1',InArea)];

saveas(fig_mean,this_figure_save_name,'pdf');

% Zoomx2
caxis([YLim_Lower_Zoomx2,YLim_Upper_Zoomx2]);
drawnow;
this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Zoomx2',InArea)];
saveas(fig_mean,this_figure_save_name,'pdf');

% Zoomx4
caxis([YLim_Lower_Zoomx4,YLim_Upper_Zoomx4]);
drawnow;
this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'Zoomx4',InArea)];
saveas(fig_mean,this_figure_save_name,'pdf');

close all
end

