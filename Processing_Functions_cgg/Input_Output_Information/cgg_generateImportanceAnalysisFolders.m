function cfg = cgg_generateImportanceAnalysisFolders(IADir,PassTableEntry,varargin)
%CGG_GENERATEIMPORTANCEANALYSISFOLDERS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=true;
end
end

cfg=struct();
cfg.IA.path=IADir;
%%

if ismember("Method", PassTableEntry.Properties.VariableNames)
Method = PassTableEntry.Method;
end
% if ismember("NumRemoved", PassTableEntry.Properties.VariableNames)
% NumRemoved = PassTableEntry.NumRemoved;
% end
if ismember("RemovalType", PassTableEntry.Properties.VariableNames)
RemovalType = PassTableEntry.RemovalType;
end
if ismember("Fold", PassTableEntry.Properties.VariableNames)
Fold = PassTableEntry.Fold;
end
if ismember("SessionName", PassTableEntry.Properties.VariableNames)
SessionName = PassTableEntry.SessionName;
end
if ismember("Target", PassTableEntry.Properties.VariableNames)
Target = PassTableEntry.Target;
end
% if ismember("MatchType", PassTableEntry.Properties.VariableNames)
% MatchType = PassTableEntry.MatchType;
% end
if ismember("TrialFilter", PassTableEntry.Properties.VariableNames)
TrialFilter = PassTableEntry.TrialFilter;
end
if ismember("TrialFilter_Value", PassTableEntry.Properties.VariableNames)
TrialFilter_Value = PassTableEntry.TrialFilter_Value;
end
if ismember("TargetFilter", PassTableEntry.Properties.VariableNames)
TargetFilter = PassTableEntry.TargetFilter;
end
if ismember("TimeRange", PassTableEntry.Properties.VariableNames)
TimeRange = PassTableEntry.TimeRange;
end

%%
[TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Unpack');
%%

TrialFilterName = cgg_setNaming(string(join(TrialFilter,'~')),'SurroundDeliminator',{'[',']'},'WantUnderline',false);
TrialFilter_ValueName = cgg_getSplitTableRowNames(TrialFilter,TrialFilter_Value);
TrialFilter_ValueName = cgg_setNaming(TrialFilter_ValueName,'SurroundDeliminator',{'(',')'});
TrialFilterFolderName = string(TrialFilterName) + string(TrialFilter_ValueName);

if ~isempty(TimeRange)
    TimeRangeString = sprintf("_Time-[%.2f~%.2f]",TimeRange);
else
    TimeRangeString = "";
end

TargetFilterFolderName = string(TargetFilter) + TimeRangeString;

FoldName = sprintf("Fold_%d",Fold);

%%

%% Removal Type Folder

% Make the Removal Type folder.
cfg_tmp=cfg.IA;
[cfg_tmp,~] = cgg_generateFolderAndPath(RemovalType,'RemovalType',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA=cfg_tmp;

%% Session Name Folder

% Make the Session Name folder.
cfg_tmp=cfg.IA.RemovalType;
[cfg_tmp,~] = cgg_generateFolderAndPath(SessionName,'SessionName',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA.RemovalType=cfg_tmp;

%% Target Folder

% Make the Target folder.
cfg_tmp=cfg.IA.RemovalType.SessionName;
[cfg_tmp,~] = cgg_generateFolderAndPath(Target,'Target',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA.RemovalType.SessionName=cfg_tmp;

%% Trial Filter Folder

% Make the Trial Filter folder.
cfg_tmp=cfg.IA.RemovalType.SessionName.Target;
[cfg_tmp,~] = cgg_generateFolderAndPath(TrialFilterFolderName,'TrialFilter',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA.RemovalType.SessionName.Target=cfg_tmp;

%% Target Filter Folder

% Make the Target Filter folder.
cfg_tmp=cfg.IA.RemovalType.SessionName.Target.TrialFilter;
[cfg_tmp,~] = cgg_generateFolderAndPath(TargetFilterFolderName,'TargetFilter',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA.RemovalType.SessionName.Target.TrialFilter=cfg_tmp;

%% Method Folder

% Make the Method folder.
cfg_tmp=cfg.IA.RemovalType.SessionName.Target.TrialFilter.TargetFilter;
[cfg_tmp,~] = cgg_generateFolderAndPath(Method,'Method',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA.RemovalType.SessionName.Target.TrialFilter.TargetFilter=cfg_tmp;

%% Fold Folder

% Make the Fold folder.
cfg_tmp=cfg.IA.RemovalType.SessionName.Target.TrialFilter.TargetFilter.Method;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp,'WantDirectory',WantDirectory);
cfg.IA.RemovalType.SessionName.Target.TrialFilter.TargetFilter.Method=cfg_tmp;
end

