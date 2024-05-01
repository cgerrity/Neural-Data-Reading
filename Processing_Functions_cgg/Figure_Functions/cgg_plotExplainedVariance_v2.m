function cgg_plotExplainedVariance_v2(PlotDataPathNameExt,Plotcfg,varargin)
%CGG_PLOTEXPLAINEDVARIANCE Summary of this function goes here
%   Detailed explanation goes here

%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
InFigure = CheckVararginPairs('InFigure', '', varargin{:});
else
if ~(exist('InFigure','var'))
InFigure='';
end
end

%%

% Get Probe and Session Name from filename

[~,PlotDataName,~]=fileparts(PlotDataPathNameExt);
AreaSessionName=extractAfter(PlotDataName,"Regression_Data_");
AreaSessionStrings=split(AreaSessionName,"_");

AreaNameIDX=1;
AreaProbeNumberIDX=2;
ExperimentIDX=3:5;
DateIDX=6:8;
SessionNumberIDX=9:10;

AreaName=join(AreaSessionStrings(AreaNameIDX),'_');
AreaProbeNumber=join(AreaSessionStrings(AreaProbeNumberIDX),'_');
ExperimentName=join(AreaSessionStrings(ExperimentIDX),'_');
DateName=join(AreaSessionStrings(DateIDX),'-');
SessionNumber=join(AreaSessionStrings(SessionNumberIDX),'-');

ProbeName=join([AreaName,AreaProbeNumber],'_');
SessionName=join([ExperimentName,DateName,SessionNumber],'_');

ProbeName=ProbeName{1};
SessionName=SessionName{1};

%%

m_PlotData=matfile(PlotDataPathNameExt,"Writable",false);
R_Value_Adjusted=m_PlotData.R_Value_Adjusted;

[~,NumSamples]=size(R_Value_Adjusted);

InIncrement=round(NumSamples/3001);

Time_Start=-1.5;
DataWidth=1/1000;
WindowStride=InIncrement/1000;
ZLimits=[0,0.2];

Y_Name='Channels';

PlotTitle=sprintf('Session: %s, Area: %s',SessionName,ProbeName);

PlotTitle=replace(PlotTitle,'_','-');

[fig,~,~]=cgg_plotHeatMapOverTime(R_Value_Adjusted,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle,'Y_Name',Y_Name,'InFigure',InFigure);
% [fig,~,~]=cgg_plotHeatMapOverTime(R_Value,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle,'Y_Name',Y_Name);


%%
% PlotNameExt=sprintf('Explained_Variance_%s_%s_ESA.pdf',cfg(sidx).SessionName,Probe_Order{sel_area});
PlotNameExt=sprintf('Explained_Variance_%s_%s.pdf',SessionName,ProbeName);
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

if isempty(InFigure)
close all
end

end

