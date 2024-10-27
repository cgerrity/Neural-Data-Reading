function cgg_plotCorrelation(PlotDataPathNameExt,Plotcfg,varargin)
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

if isfunction
Time_Start = CheckVararginPairs('Time_Start', -1.5, varargin{:});
else
if ~(exist('Time_Start','var'))
Time_Start=-1.5;
end
end

if isfunction
Time_End = CheckVararginPairs('Time_End', 1.5, varargin{:});
else
if ~(exist('Time_End','var'))
Time_End=1.5;
end
end

if isfunction
SamplingRate = CheckVararginPairs('SamplingRate', 1000, varargin{:});
else
if ~(exist('SamplingRate','var'))
SamplingRate=1000;
end
end

if isfunction
AlternateTitle = CheckVararginPairs('AlternateTitle', [], varargin{:});
else
if ~(exist('AlternateTitle','var'))
AlternateTitle=[];
end
end

if isfunction
WantPaperFormat = CheckVararginPairs('WantPaperFormat', false, varargin{:});
else
if ~(exist('WantPaperFormat','var'))
WantPaperFormat=false;
end
end

if isfunction
WantDecisionCentered = CheckVararginPairs('WantDecisionCentered', false, varargin{:});
else
if ~(exist('WantDecisionCentered','var'))
WantDecisionCentered=false;
end
end

if isfunction
SingleZLimits = CheckVararginPairs('SingleZLimits', [], varargin{:});
else
if ~(exist('SingleZLimits','var'))
SingleZLimits=[];
end
end

if isfunction
SinglePlotPath = CheckVararginPairs('SinglePlotPath', '', varargin{:});
else
if ~(exist('SinglePlotPath','var'))
SinglePlotPath='';
end
end

if isfunction
SaveName = CheckVararginPairs('SaveName', '', varargin{:});
else
if ~(exist('SaveName','var'))
SaveName='';
end
end

%%
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',WantPaperFormat,'WantDecisionCentered',WantDecisionCentered);
TimeOffset = cfg_Paper.Time_Offset;

wantDecisionIndicators = cfg_Paper.wantDecisionIndicators;
wantFeedbackIndicators = cfg_Paper.wantFeedbackIndicators;
DecisionIndicatorLabelOrientation = ...
    cfg_Paper.DecisionIndicatorLabelOrientation;
wantIndicatorNames = cfg_Paper.wantIndicatorNames;

Limit_Time = cfg_Paper.Limit_Time;

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
R_Correlation=m_PlotData.R_Correlation;

[~,NumSamples]=size(R_Correlation);

Time = Time_Start:1/SamplingRate:Time_End;
NumRecordingPoints = length(Time);

InIncrement=round(NumSamples/NumRecordingPoints);

DataWidth=1/SamplingRate;
WindowStride=InIncrement/SamplingRate;
ZLimits=[-1,1];

Y_Name='Channels';

PlotTitle=sprintf('Session: %s, Area: %s',SessionName,ProbeName);

if isempty(AlternateTitle)
PlotTitle=replace(PlotTitle,'_','-');
else
PlotTitle = AlternateTitle;
end

[fig,~,~]=cgg_plotHeatMapOverTime(R_Correlation,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle,'Y_Name',Y_Name,'InFigure',InFigure,'TimeOffset',TimeOffset,'wantDecisionIndicators',wantDecisionIndicators,'wantFeedbackIndicators',wantFeedbackIndicators,'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,'wantIndicatorNames',wantIndicatorNames);

if ~any(isnan(Limit_Time))
xlim(Limit_Time);
end
%%
if isempty(SaveName)
PlotNameExt=sprintf('Correlation_%s_%s.pdf',SessionName,ProbeName);
else
PlotNameExt=sprintf('%s.pdf',SaveName);
end
drawnow;

if isempty(SingleZLimits)

ZLimits=[-1,1];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
PlotPath=Plotcfg.SubSubFolder_1.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

ZLimits=[-0.5,0.5];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
PlotPath=Plotcfg.SubSubFolder_2.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

ZLimits=[-0.25,0.25];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
PlotPath=Plotcfg.SubSubFolder_3.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);
else
clim(SingleZLimits);
drawnow;
PlotPathNameExt=[SinglePlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);
end

if isempty(InFigure)
close all
end

end

