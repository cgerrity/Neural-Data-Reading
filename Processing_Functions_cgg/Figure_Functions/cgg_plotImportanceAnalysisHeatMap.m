function [fig_plot,p_Plots,c_Plot,Tiled] = cgg_plotImportanceAnalysisHeatMap(...
    InData,ProbeAreas,Time_Start,DataWidth,WindowStride,FilterColumn,...
    FilterValue,wantOnePlot)
%CGG_PLOTIMPORTANCEANALYSISHEATMAP Summary of this function goes here
%   Detailed explanation goes here

[NumChannels,~,NumAreas] = size(InData);

MaxChannel=NumChannels;

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
Tick_Size_Channels=cfg_Plotting.Tick_Size_Channels;
Line_Width=cfg_Plotting.Line_Width;

Main_Title_Size=cfg_Plotting.Main_Title_Size;
Main_SubTitle_Size=cfg_Plotting.Main_SubTitle_Size;
Main_SubSubTitle_Size=cfg_Plotting.Main_SubSubTitle_Size;

X_Name='Time (s)';

%%
if wantOnePlot
Y_Name='Areas';

% YRange=repmat()

LastChannel=MaxChannel-Tick_Size_Channels;

Y_Ticks_Base=[1,Tick_Size_Channels:Tick_Size_Channels:LastChannel];
Y_Ticks=[];
for aidx=1:NumAreas
Y_Ticks=[Y_Ticks,Y_Ticks_Base+MaxChannel*(aidx-1)];
end

Y_TickLabel=repmat([1,Tick_Size_Channels:Tick_Size_Channels:LastChannel],[1,NumAreas]);

[fig_plot,p_Plots,c_Plot] = cgg_plotHeatMapOverTime(InData,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,'Y_Ticks',Y_Ticks,'Y_TickLabel',Y_TickLabel);

for aidx=1:(NumAreas-1)
yline(MaxChannel*aidx+0.5,'LineWidth',Line_Width/2);
end

else
%%
wantSubPlot=true;
Y_Name=ProbeAreas{:,:};

fig_Sub_plot=figure;
fig_Sub_plot.WindowState='maximized';
fig_Sub_plot.PaperSize=[20 10];

Tiled=tiledlayout(NumAreas,1);
Tiled.TileSpacing = 'compact';
Tiled.Padding = 'compact';

fig_plot=[];
p_Plots=[];
c_Plot=[];
ZLimits=[min(InData(:)),max(InData(:))];
for aidx=1:NumAreas
    % this_subplot=subplot(NumAreas,1,aidx);
    nexttile
    this_Y_Name=Y_Name{aidx};
    this_InData=InData(:,:,aidx);
    
[this_fig_plot,this_p_Plots,this_c_Plot] = cgg_plotHeatMapOverTime(this_InData,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',this_Y_Name,'wantSubPlot',wantSubPlot,'ZLimits',ZLimits);

this_c_Plot.Visible='off';
this_fig_plot.XLabel.Visible='off';
this_fig_plot.Title.Visible='off';

if aidx>1
this_fig_plot.Children(1).Label='';
this_fig_plot.Children(2).Label='';
this_fig_plot.Children(3).Label='';
end

% this_p_Plots

fig_plot=[fig_plot;this_fig_plot];
p_Plots=[p_Plots;this_p_Plots];
c_Plot=[c_Plot;this_c_Plot];

% figure(fig_Sub_plot);
% axcp = copyobj(this_fig_plot,fig_Sub_plot);
%  set(axcp,'Position',get(this_subplot,'position'));
% ax2 = copyobj(ax1,fig_Sub_plot);
% subplot(NumAreas,1,aidx,this_fig_plot);
end

Main_Title='Importance Analysis by Area';
Main_SubTitle=sprintf('Trial Variable: %s',FilterColumn);
Main_SubSubTitle=sprintf('Variable Value: %d',FilterValue);

Main_Title=['{\' sprintf(['fontsize{%d}' Main_Title '}'],Main_Title_Size)];
Main_SubTitle=['{\' sprintf(['fontsize{%d}' Main_SubTitle '}'],Main_SubTitle_Size)];
Main_SubSubTitle=['{\' sprintf(['fontsize{%d}' Main_SubSubTitle '}'],Main_SubSubTitle_Size)];

Full_Title={Main_Title,Main_SubTitle,Main_SubSubTitle};

title(Tiled,Full_Title);
xlabel(Tiled,'Time (s)');
ylabel(Tiled,'Area');

drawnow;

cb = colorbar;
cb.Layout.Tile = 'east';
clim([0,1]);

fig_plot=fig_Sub_plot;

end

end

