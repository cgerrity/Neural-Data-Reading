function [OutputTable,CoefficientNames] = cgg_getAreaRegressionValues(InputTable,PlotDataPathNameExt,AreaNameCheck,varargin)
%CGG_GETAREAREGRESSIONVALUES Summary of this function goes here
%   Detailed explanation goes here
% Get Area and Session Name from filename

isfunction=exist('varargin','var');

if isfunction
CommonRemovedChannels = CheckVararginPairs('CommonRemovedChannels', [], varargin{:});
else
if ~(exist('CommonRemovedChannels','var'))
CommonRemovedChannels=[];
end
end

OutputTable=InputTable;
CoefficientNames = [];
%%
[~,PlotDataName,~]=fileparts(PlotDataPathNameExt);

%%
IsFromAnalysis = contains(PlotDataName,"Regression_Data");

IsFromProcessing = contains(PlotDataName,"Regression_Results");

IsFromProcessing = IsFromProcessing && ~IsFromAnalysis;

%%


if ~IsFromProcessing
AreaSessionName=extractAfter(PlotDataName,"Regression_Data_");
AreaSessionStrings=split(AreaSessionName,"_");

AreaNameIDX=1;
% AreaProbeNumberIDX=2;
MonkeyIDX=3;
% ExperimentIDX=3:5;
% DateIDX=6:8;
% SessionNumberIDX=9:10;

AreaName=join(AreaSessionStrings(AreaNameIDX),'_');
% AreaProbeNumber=join(AreaSessionStrings(AreaProbeNumberIDX),'_');
MonkeyName=join(AreaSessionStrings(MonkeyIDX),'_');
% ExperimentName=join(AreaSessionStrings(ExperimentIDX),'_');
% DateName=join(AreaSessionStrings(DateIDX),'-');
% SessionNumber=join(AreaSessionStrings(SessionNumberIDX),'-');
else
AreaProbeNumberName=extractAfter(PlotDataName,"Regression_Results_");
AreaProbeNumberStrings=split(AreaProbeNumberName,"_");
MonkeySessionName=extractAfter(PlotDataName,"-Regression_Results_");
MonkeySessionStrings=split(MonkeySessionName,"_");

AreaNameIDX=1;
MonkeyIDX=1;

AreaName=join(AreaProbeNumberStrings(AreaNameIDX),'_');
MonkeyName=join(MonkeySessionStrings(MonkeyIDX),'_');
end

% ProbeName=join([AreaName,AreaProbeNumber],'_');
% SessionName=join([ExperimentName,DateName,SessionNumber],'_');

% ProbeName=ProbeName{1};
% SessionName=SessionName{1};
MonkeyName = string(MonkeyName{1});

%%

if strcmp(AreaName,AreaNameCheck)

m_PlotData=matfile(PlotDataPathNameExt,"Writable",false);
B_Value_Coefficients=m_PlotData.B_Value_Coefficients;
CoefficientNames=m_PlotData.CoefficientNames;
P_Value=m_PlotData.P_Value;
P_Value_Coefficients=m_PlotData.P_Value_Coefficients;
R_Value_Adjusted=m_PlotData.R_Value_Adjusted;
R_Correlation=m_PlotData.R_Correlation;
P_Correlation=m_PlotData.P_Correlation;

[NumChannels,~] = size(P_Value);

ChannelNumbers = 1:(NumChannels+length(CommonRemovedChannels));
ChannelNumbers(CommonRemovedChannels) = [];
ChannelNumbers = ChannelNumbers';

this_Table = table(B_Value_Coefficients,P_Value,P_Value_Coefficients,R_Value_Adjusted,R_Correlation,P_Correlation,ChannelNumbers);
this_Table.MonkeyName(:) = MonkeyName;
this_Table.AreaSessionName(:) = string(AreaSessionName);

    if isempty(OutputTable)
        OutputTable=this_Table;
    else
        OutputTable=[OutputTable;this_Table];
    end

end

end

