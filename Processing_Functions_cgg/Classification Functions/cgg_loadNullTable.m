function NullTable = cgg_loadNullTable(cfg,Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,varargin)
%CGG_LOADNULLTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
LabelClassFilter = CheckVararginPairs('LabelClassFilter', '', varargin{:});
else
if ~(exist('LabelClassFilter','var'))
LabelClassFilter='';
end
end

%%
[NullTablePath,NullTableName,OldNullTablePath] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'cfg',cfg,'LabelClassFilter',LabelClassFilter);
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
OldNullTablePathNameExt = fullfile(OldNullTablePath, ...
    NullTableNameExt);

%%

if isfile(OldNullTablePathNameExt)
    fprintf('   !!! Moving Null Table from old location to new\n');
    fprintf('   !!! (%s)\n',NullTableName);
    fprintf('   !!! Old: %s\n',OldNullTablePathNameExt);
    fprintf('   !!! New: %s\n',NullTablePathNameExt);
    [~, ~] = movefile(OldNullTablePathNameExt, NullTablePathNameExt);
end

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

