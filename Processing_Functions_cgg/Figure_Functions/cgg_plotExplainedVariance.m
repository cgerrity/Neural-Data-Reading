function cgg_plotExplainedVariance(InData,MatchArray,InIncrement,Probe_Order,AreaIDX,cfg,Plotcfg)
%CGG_PLOTEXPLAINEDVARIANCE Summary of this function goes here
%   Detailed explanation goes here



[~,~,~,~,R_Value_Adjusted,~] = cgg_procTrialVariableRegression(InData,MatchArray,InIncrement);


Time_Start=-1.5;
DataWidth=1/1000;
WindowStride=InIncrement/1000;
ZLimits=[0,0.2];

Y_Name='Channels';

PlotTitle=sprintf('Session: %s, Area: %s',cfg.SessionName,Probe_Order{AreaIDX});

PlotTitle=replace(PlotTitle,'_','-');

[fig,~,~]=cgg_plotHeatMapOverTime(R_Value_Adjusted,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle,'Y_Name',Y_Name);
% [fig,~,~]=cgg_plotHeatMapOverTime(R_Value,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle,'Y_Name',Y_Name);

% PlotNameExt=sprintf('Explained_Variance_%s_%s_ESA.pdf',cfg(sidx).SessionName,Probe_Order{sel_area});
PlotNameExt=sprintf('Explained_Variance_%s_%s.pdf',cfg.SessionName,Probe_Order{AreaIDX});
drawnow;

ZLimits=[0,0.2];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
% PlotPath=Plotcfg.Zoom_1.path;
PlotPath=Plotcfg.SubSubFolder_1.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

ZLimits=[0,0.1];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
% PlotPath=Plotcfg.Zoom_2.path;
PlotPath=Plotcfg.SubSubFolder_2.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

ZLimits=[0,0.05];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
% PlotPath=Plotcfg.Zoom_3.path;
PlotPath=Plotcfg.SubSubFolder_3.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

close all


end

