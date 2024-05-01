function [outputArg1,outputArg2] = cgg_plotSignificantExaplainedVariance(InData,MatchArray,InIncrement,Probe_Order,AreaIDX,cfg,Plotcfg)
%CGG_PLOTSIGNIFICANTEXAPLAINEDVARIANCE Summary of this function goes here
%   Detailed explanation goes here


[P_Value,R_Value,P_Value_Coefficients,CoefficientNames,R_Value_Adjusted,B_Value_Coefficients] = cgg_procTrialVariableRegression(InData,MatchArray,InIncrement);

%%
sel_beta=9;
this_Beta=B_Value_Coefficients(:,:,sel_beta);
this_Beta_P_Value=P_Value_Coefficients(:,:,sel_beta);

SignificantMask=this_Beta_P_Value<0.05;
Significant_ExplainedVariance=NaN(size(this_Beta));
Significant_ExplainedVariance(SignificantMask)=this_Beta(SignificantMask);

Time_Start=-1.5;
DataWidth=1/1000;
WindowStride=InIncrement/1000;
ZLimits=[0,0.2];

Y_Name='Beta Value';

PlotTitle=sprintf('Session: %s, Area: %s, Beta: %d',cfg.SessionName,Probe_Order{AreaIDX},sel_beta);

PlotTitle=replace(PlotTitle,'_','-');

[fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(Significant_ExplainedVariance,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle,'Y_Name',Y_Name);

%%
ylim([0,0.05]);

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

