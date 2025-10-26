function [NullTablePath,NullTableName] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,varargin)
%CGG_GENERATENULLTABLEFILENAME Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
cfg = CheckVararginPairs('cfg', [], varargin{:});
else
if ~(exist('cfg','var'))
cfg=[];
end
end
%%
if isempty(TargetFilter)
TargetFilter = "Overall";
end
TrialFilter_Value_Name = cgg_setNaming(cgg_getSplitTableRowNames(TrialFilter,TrialFilter_Value),'WantUnderline',false,'SurroundDeliminator',{'[',']'});
TrialFilter_Name = cgg_setNaming(cgg_generateExtraSaveTerm('FilterColumn',TrialFilter),'WantUnderline',false);

NullTableName = sprintf("Target-%s_(%s)_(TrialFilter-%s-%s)_(TargetFilter-%s)_(MatchType-%s)",Target,SessionName,TrialFilter_Name,TrialFilter_Value_Name,TargetFilter,MatchType);

%%
NullTablePath = [];
if isstruct(cfg)
    if isfield(cfg,'ResultsDir')
        EpochDir = cgg_getDirectory(cfg.ResultsDir,'Epoch');
    else
        EpochDir = cgg_getDirectory(cfg,'Epoch');
    end

AnalysisType = 'Analysis Data';
cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType);

NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisType');
end

end

