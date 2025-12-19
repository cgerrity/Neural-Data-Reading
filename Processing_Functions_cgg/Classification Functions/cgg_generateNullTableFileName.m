function [NullTablePath,NullTableName,OldNullTablePath] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,varargin)
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

if isfunction
LabelClassFilter = CheckVararginPairs('LabelClassFilter', '', varargin{:});
else
if ~(exist('LabelClassFilter','var'))
LabelClassFilter='';
end
end
%%
if isempty(TargetFilter)
TargetFilter = "Overall";
end
[TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Unpack');
TrialFilter_Value_Name = cgg_setNaming(cgg_getSplitTableRowNames(TrialFilter,TrialFilter_Value),'WantUnderline',false,'SurroundDeliminator',{'[',']'});
TrialFilter_Name = cgg_setNaming(cgg_generateExtraSaveTerm('FilterColumn',TrialFilter),'WantUnderline',false);

NullTableName = sprintf("Target-%s_(%s)_(TrialFilter-%s-%s)_(TargetFilter-%s)_(MatchType-%s)",Target,SessionName,TrialFilter_Name,TrialFilter_Value_Name,TargetFilter,MatchType);

% %% Match Type Baseline
% IsBaseline = strcmp(MatchType,'Scaled-BalancedAccuracy') || strcmp(MatchType,'Scaled-MicroAccuracy');
%%
NullTablePath = [];
if isstruct(cfg)
    if isfield(cfg,'ResultsDir')
        EpochDir = cgg_getDirectory(cfg.ResultsDir,'Epoch');
    else
        EpochDir = cgg_getDirectory(cfg,'Epoch');
    end

AnalysisType = 'Analysis Data';
if ~isempty(char(LabelClassFilter))
    cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType,'AnalysisTypeSubField',SessionName,'AnalysisTypeSubSubField',LabelClassFilter);
    NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisTypeSubSubField');
    cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType,'AnalysisTypeSubField',LabelClassFilter,'WantDirectory',false);
    OldNullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisTypeSubField');
else
    cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType,'AnalysisTypeSubField',SessionName);
    NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisTypeSubField');
    OldNullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisType');
end

% if ~isempty(char(LabelClassFilter)) && IsBaseline
%     cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType,'AnalysisTypeSubField',LabelClassFilter);
%     NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisTypeSubField');
% elseif ~isempty(char(LabelClassFilter)) && ~IsBaseline
%     cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType,'AnalysisTypeSubField',MatchType,'AnalysisTypeSubField',LabelClassFilter);
%     NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisTypeSubSubField');
% elseif isempty(char(LabelClassFilter)) && ~IsBaseline
%     cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType,'AnalysisTypeSubField',MatchType);
%     NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisTypeSubField');
% else
%     cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType);
%     NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisType');
% end

end

end

