function cgg_plotSelectMeanValues(InBaseline,InBaseline_Legend_Name,...
    InBaseline_X_Name,InBaseline_Title,InYLim,InSavePlotCFG,InSaveName,...
    varargin)
%cgg_plotSelectMeanValues Summary of this function goes here
%   Detailed explanation goes here
%%% Plotting

X_Name_Size=18;
Y_Name_Size=18;
Tick_Size=25;
Mean_Smooth_Factor=50;

fig_mean=figure;
fig_mean.WindowState='maximized';
fig_mean.PaperSize=[20 10];

Plot_Colors = CheckVararginPairs('Plot_Colors', '', varargin{:});
NumPlot_Colors=length(Plot_Colors);
for cidx=1:NumPlot_Colors
    Plot_Colors{NumPlot_Colors+cidx}=Plot_Colors{cidx}*0.5;   
end

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

for cidx=1:NumChannels
    
    clf(fig_mean);

sel_channel=cidx;

for midx=1:NumPlots
if isManyPlot
    this_InBaseline_Legend_Name=InBaseline_Legend_Name{midx};
else
    this_InBaseline_Legend_Name=InBaseline_Legend_Name;
end

this_Baseline_Mean=Mean_Baseline(sel_channel,:);
this_Baseline_Mean_STD_ERROR=STD_ERROR_Baseline(sel_channel,:);
this_Baseline_Mean_Upper=this_Baseline_Mean+this_Baseline_Mean_STD_ERROR;
this_Baseline_Mean_Lower=this_Baseline_Mean-this_Baseline_Mean_STD_ERROR;

this_Baseline_Mean_Smoothed=smoothdata(this_Baseline_Mean,2,'movmean',Mean_Smooth_Factor);

this_y=[];
this_x=[];

this_y=this_Baseline_Mean';
this_x=1:NumTrials;
this_x=this_x';
this_x=[this_x,ones(size(this_x))];

[Coefficients,~,~,~,~] = regress(this_y,this_x);

this_Baseline_Fit=this_x*Coefficients;

hold on

if isempty(Plot_Colors)
p_Baseline(midx)=plot(1:NumTrials,this_Baseline_Mean,'LineWidth',4,'DisplayName', this_InBaseline_Legend_Name);
else
p_Baseline(midx)=plot(1:NumTrials,this_Baseline_Mean,'Color',Plot_Colors{midx},'LineWidth',4,'DisplayName', this_InBaseline_Legend_Name);
end
plot(1:NumTrials,this_Baseline_Mean_Upper,'Color',p_Baseline(midx).Color,'LineStyle',':','LineWidth',2);
plot(1:NumTrials,this_Baseline_Mean_Lower,'Color',p_Baseline(midx).Color,'LineStyle',':','LineWidth',2);
p_Baseline_Smoothed(midx)=plot(1:NumTrials,this_Baseline_Mean_Smoothed,'LineWidth',4,'DisplayName', 'Smoothed Mean Values');
p_Baseline_Fit(midx)=plot(1:NumTrials,this_Baseline_Fit,'LineWidth',4,'DisplayName', 'Fit Values');

hold off

xlabel(InBaseline_X_Name,'FontSize',X_Name_Size);
ylabel('Mean Value','FontSize',Y_Name_Size);

% this_Range=max(this_Baseline_Mean)-min(this_Baseline_Mean);
this_Mean=mean(this_Baseline_Mean);
% YLim_Upper=this_Mean+this_Range/2*InYLim_Factor;
% YLim_Lower=this_Mean-this_Range/2*InYLim_Factor;
YLim_Upper=this_Mean+InYLim(1);
YLim_Lower=this_Mean-InYLim(2);

ylim([YLim_Lower,YLim_Upper]);
xlim([1,NumTrials]);

xticks(0:Tick_Size:NumTrials);

end
legend([p_Baseline,p_Baseline_Smoothed,p_Baseline_Fit]);

Main_Title=InBaseline_Title;
Main_SubTitle=sprintf('Channel: %s',num2str(sel_channel));

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

this_figure_save_name=[InSavePlotCFG.path filesep sprintf(InSaveName,num2str(sel_channel))];

saveas(fig_mean,this_figure_save_name,'pdf');

end

close all
end

