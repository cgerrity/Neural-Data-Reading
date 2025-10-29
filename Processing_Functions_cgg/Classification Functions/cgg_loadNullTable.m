function NullTable = cgg_loadNullTable(cfg,Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType)
%CGG_LOADNULLTABLE Summary of this function goes here
%   Detailed explanation goes here

%%
[NullTablePath,NullTableName] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'cfg',cfg);
NullTableNameExt = NullTableName + ".mat";
%%
% EpochDir = cgg_getDirectory(cfg,'Epoch');
% 
% AnalysisType = 'Analysis Data';
% cfg_Analysis = cgg_generateAnalysisFolders_v2(EpochDir,'AnalysisType',AnalysisType);

% NullTablePath = cgg_getDirectory(cfg_Analysis,'AnalysisType');

%%

NullTablePathNameExt = fullfile(NullTablePath, ...
    NullTableNameExt);

%%

if isfile(NullTablePathNameExt)
    NullTable = load(NullTablePathNameExt);
    NullTable = NullTable.NullTable;
else
    NullTable = cgg_generateBlankNullTable('Target',Target,...
        'SessionName',SessionName,'TrialFilter',TrialFilter,...
        'TrialFilter_Value',TrialFilter_Value,...
        'TargetFilter',TargetFilter,'MatchType',MatchType);
end

end

