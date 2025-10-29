function [IAPathName,RemovalTablePathName,IATestPathName] = ...
    cgg_generateImportanceAnalysisFileNames(PassTableEntry,cfg_Epoch,...
    varargin)
%CGG_GENERATEIMPORTANCEANALYSISFILENAMES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', false, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=false;
end
end
%%

if ismember("Method", PassTableEntry.Properties.VariableNames)
Method = PassTableEntry.Method;
end
if ismember("NumRemoved", PassTableEntry.Properties.VariableNames)
NumRemoved = PassTableEntry.NumRemoved;
end
if ismember("MatchType", PassTableEntry.Properties.VariableNames)
MatchType = PassTableEntry.MatchType;
end

%%

% TrialFilterName = cgg_setNaming(string(join(TrialFilter,'~')),'SurroundDeliminator',{'[',']'},'WantUnderline',false);
% TrialFilter_ValueName = cgg_getSplitTableRowNames(TrialFilter,TrialFilter_Value);
% TrialFilter_ValueName = cgg_setNaming(TrialFilter_ValueName,'SurroundDeliminator',{'(',')'});
% TrialFilterFolderName = string(TrialFilterName) + string(TrialFilter_ValueName);
% 
% if ~isempty(TimeRange)
%     TimeRangeString = sprintf("_Time-[%.2f~%.2f]",TimeRange);
% else
%     TimeRangeString = "";
% end
% 
% TargetFilterFolderName = string(TargetFilter) + TimeRangeString;

%%
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');
%%

% IAPath = fullfile(EpochDir_Results,'Analysis','Importance Analysis',...
%     RemovalType,SessionName,Target,TrialFilterFolderName,TargetFilterFolderName,Method,'Fold %d');
% IAPath = sprintf(IAPath,Fold);

IADir = fullfile(EpochDir_Results,'Analysis','Importance Analysis');

cfg_IA = cgg_generateImportanceAnalysisFolders(IADir,PassTableEntry,'WantDirectory',WantDirectory);
IAPath = cgg_getDirectory(cfg_IA,'Fold');

switch Method
    case 'Rank'
        IAName = sprintf('IA_Table_%s',MatchType);
        IATestName = sprintf('IA_Table-Test_%s',MatchType);
        RemovalTableName = sprintf('RemovalTable_%s',MatchType);
    case 'Block'
        IAName = sprintf('IA_Table_%s',MatchType);
        IATestName = sprintf('IA_Table-Test_%s',MatchType);
        RemovalTableName = sprintf('RemovalTable_%s',MatchType);
    otherwise
        IAName = sprintf('IA_Table-%d_%s',NumRemoved,MatchType);
        IATestName = sprintf('IA_Table-Test-%d_%s',NumRemoved,MatchType);
        RemovalTableName = sprintf('RemovalTable-%d_%s',NumRemoved,MatchType);
end

IAPathName = fullfile(IAPath,IAName);
IATestPathName = fullfile(IAPath,IATestName);
RemovalTablePathName = fullfile(IAPath,RemovalTableName);

IAPathName = char(IAPathName);
IATestPathName = char(IATestPathName);
RemovalTablePathName = char(RemovalTablePathName);

end

