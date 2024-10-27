function cgg_saveLatentCorrelationAnalysis(Correlation,P_Value,EpochDir,LMVariableFolder,Fold,Session,varargin)
%CGG_SAVELATENTCORRELATIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
IsTable = CheckVararginPairs('IsTable', false, varargin{:});
else
if ~(exist('IsTable','var'))
IsTable=false;
end
end

cfg = cgg_generateAnalysisFolders(EpochDir,...
    'AnalysisType','Correlation',...
    'AnalysisTypeSubField',LMVariableFolder,...
    'Fold',Fold,'Session',Session);

DirPath = cgg_getDirectory(cfg,'Session');

if ~IsTable
CorrelationNameExt = 'Correlation.mat';
CorrelationVariablesName = {'Correlation','P_Value'};
CorrelationVariables = {Correlation,P_Value};
else
CorrelationNameExt = 'CorrelationTable.mat';
CorrelationVariablesName = {'Correlation'};
CorrelationVariables = {Correlation};
end

CorrelationPathNameExt = [DirPath filesep CorrelationNameExt];

cgg_saveVariableUsingMatfile(CorrelationVariables,CorrelationVariablesName,...
    CorrelationPathNameExt);

end

