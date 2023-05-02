function cgg_plotAllMeanValues(InBaseline,InBaseline_Legend_Name,...
    InBaseline_X_Name,InBaseline_Title,InYLim,InSavePlotCFG,InSaveName,...
    varargin)
%cgg_plotSelectMeanValues Summary of this function goes here
%   Detailed explanation goes here
%%% Plotting

X_Name_Size=18;
Y_Name_Size=18;
Tick_Size=25;

fig_mean=figure;
fig_mean.WindowState='maximized';
fig_mean.PaperSize=[20 10];
%%
Plot_Colors = CheckVararginPairs('Plot_Colors', '', varargin{:});
NumPlot_Colors=length(Plot_Colors);
for cidx=1:NumPlot_Colors
    Plot_Colors{NumPlot_Colors+cidx}=Plot_Colors{cidx}*0.5;   
end
%%
figure(fig_mean);

isManyPlot=iscell(InBaseline);

if isManyPlot
    NumPlots=length(InBaseline);
    [NumChannels,NumSamples,NumTrials]=size(InBaseline{1});
else
    NumPlots=1;
    [NumChannels,NumSamples,NumTrials]=size(InBaseline);
end

if verLessThan('matlab','9.5')
Mean_Baseline=squeeze(mean(InBaseline(:,:,:),2));
STD_Baseline=squeeze(std(InBaseline(:,:,:),0,2));
else
Mean_Baseline=squeeze(mean(InBaseline,2));
STD_Baseline=squeeze(std(InBaseline,0,2));
end

STD_ERROR_Baseline=STD_Baseline/sqrt(NumSamples);
    
    clf(fig_mean);
%%
for midx=1:NumPlots
    %%
if isManyPlot
    this_InBaseline_Legend_Name=InBaseline_Legend_Name{midx};
else
    this_InBaseline_Legend_Name=InBaseline_Legend_Name;
end

this_Baseline_Mean=Mean_Baseline;
% this_Baseline_Mean_STD_ERROR=STD_ERROR_Baseline(sel_channel,:);
% this_Baseline_Mean_Upper=this_Baseline_Mean+this_Baseline_Mean_STD_ERROR;
% this_Baseline_Mean_Lower=this_Baseline_Mean-this_Baseline_Mean_STD_ERROR;

this_Mean=mean(this_Baseline_Mean,'all');
% YLim_Upper=this_Mean+this_Range/2*InYLim_Factor;
% YLim_Lower=this_Mean-this_Range/2*InYLim_Factor;
YLim_Upper=this_Mean+InYLim(1);
YLim_Lower=this_Mean-InYLim(2);
%%
hold on

imagesc(this_Baseline_Mean)
fig_mean.CurrentAxes.YDir='normal';
view(2);
c_Baseline=colorbar('vert');
c_Baseline.Label.String = 'Mean Value';
c_Baseline.Label.FontSize = Y_Name_Size;
caxis([YLim_Lower,YLim_Upper]);

xlim([0.5,NumTrials+0.5]);
ylim([0.5,NumChannels+0.5]);
xticks(0:Tick_Size:NumTrials);

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
fig_mean.CurrentAxes.XAxis.TickLength = [0 0];
fig_mean.CurrentAxes.YAxis.TickLength = [0 0];
hold off
%%
end

Main_Title=InBaseline_Title;
Main_SubTitle=sprintf('Channel: %s','All');

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

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,'All_Channels')];

saveas(fig_mean,this_figure_save_name,'pdf');

close all
end

