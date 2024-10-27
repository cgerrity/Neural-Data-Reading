function cgg_saveImportanceAnalysis(IA_Table,EpochDir,AnalysisTypeSubField,Fold,Session,varargin)
%CGG_SAVEIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', '', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='';
end
end

if isfunction
SaveTerm = CheckVararginPairs('SaveTerm', '', varargin{:});
else
if ~(exist('SaveTerm','var'))
SaveTerm='';
end
end

if isfunction
Attempts = CheckVararginPairs('Attempts', 3, varargin{:});
else
if ~(exist('Attempts','var'))
Attempts=3;
end
end

cfg = cgg_generateAnalysisFolders(EpochDir,...
    'AnalysisType','Importance Analysis',...
    'AnalysisTypeSubField',AnalysisTypeSubField,...
    'Fold',Fold,'Session',Session);

DirPath = cgg_getDirectory(cfg,'Session');

if ~isempty(MatchType)
IA_TableNameExt = sprintf('IA_Table%s_%s.mat',SaveTerm,MatchType);
IA_TableVariablesName = {'IA_Table'};
IA_TableVariables = {IA_Table};
else
RemovalTable = IA_Table(:,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);
IA_TableNameExt = sprintf('IA_Table%s.mat',SaveTerm);
IA_TableVariablesName = {'IA_Table','RemovalTable'};
IA_TableVariables = {IA_Table,RemovalTable};
end

IA_TablePathNameExt = [DirPath filesep IA_TableNameExt];

% cgg_saveVariableUsingMatfile(IA_TableVariables,IA_TableVariablesName,...
%     IA_TablePathNameExt);

SaveFunc = @() cgg_saveVariableUsingMatfile(IA_TableVariables,IA_TableVariablesName,IA_TablePathNameExt);
AlternateFunc = @() 1;
cgg_runAttemptFunction(SaveFunc,AlternateFunc,Attempts);

end

