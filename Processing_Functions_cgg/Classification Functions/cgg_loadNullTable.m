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
NumOldPaths = 1;
if iscell(OldNullTablePath)
    NumOldPaths = length(OldNullTablePath);
end
OldNullTablePathNameExt = cell(NumOldPaths,1);

for oidx = NumOldPaths:-1:1 % Most recent Old Path is listed first so switch the order
    if iscell(OldNullTablePath)
    this_OldPath = OldNullTablePath{oidx};
    else
    this_OldPath = OldNullTablePath;
    end
OldNullTablePathNameExt{oidx} = fullfile(this_OldPath, ...
NullTableNameExt);
end

%%

for oidx = 1:NumOldPaths
if isfile(OldNullTablePathNameExt{oidx})
    fprintf('   !!! Moving Null Table from old location to new\n');
    fprintf('   !!! (%s)\n',NullTableName);
    fprintf('   !!! Old: %s\n',OldNullTablePathNameExt{oidx});
    fprintf('   !!! New: %s\n',NullTablePathNameExt);
    [~, ~] = movefile(OldNullTablePathNameExt{oidx}, NullTablePathNameExt);
end
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

