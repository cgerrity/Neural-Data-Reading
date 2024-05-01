function OutputTable = cgg_getAreaRegressionValues(InputTable,PlotDataPathNameExt,AreaNameCheck)
%CGG_GETAREAREGRESSIONVALUES Summary of this function goes here
%   Detailed explanation goes here
% Get Area and Session Name from filename

OutputTable=InputTable;

%%
[~,PlotDataName,~]=fileparts(PlotDataPathNameExt);
AreaSessionName=extractAfter(PlotDataName,"Regression_Data_");
AreaSessionStrings=split(AreaSessionName,"_");

AreaNameIDX=1;
% AreaProbeNumberIDX=2;
% ExperimentIDX=3:5;
% DateIDX=6:8;
% SessionNumberIDX=9:10;

AreaName=join(AreaSessionStrings(AreaNameIDX),'_');
% AreaProbeNumber=join(AreaSessionStrings(AreaProbeNumberIDX),'_');
% ExperimentName=join(AreaSessionStrings(ExperimentIDX),'_');
% DateName=join(AreaSessionStrings(DateIDX),'-');
% SessionNumber=join(AreaSessionStrings(SessionNumberIDX),'-');

% ProbeName=join([AreaName,AreaProbeNumber],'_');
% SessionName=join([ExperimentName,DateName,SessionNumber],'_');

% ProbeName=ProbeName{1};
% SessionName=SessionName{1};

%%

if strcmp(AreaName,AreaNameCheck)

m_PlotData=matfile(PlotDataPathNameExt,"Writable",false);
B_Value_Coefficients=m_PlotData.B_Value_Coefficients;
% CoefficientNames=m_PlotData.CoefficientNames;
P_Value=m_PlotData.P_Value;
P_Value_Coefficients=m_PlotData.P_Value_Coefficients;
R_Value_Adjusted=m_PlotData.R_Value_Adjusted;

this_Table = table(B_Value_Coefficients,P_Value,P_Value_Coefficients,R_Value_Adjusted);

    if isempty(OutputTable)
        OutputTable=this_Table;
    else
        OutputTable=[OutputTable;this_Table];
    end

end

end

