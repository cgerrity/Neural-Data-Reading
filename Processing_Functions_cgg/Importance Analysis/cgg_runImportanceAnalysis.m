function cgg_runImportanceAnalysis(PassTableEntry,EpochDir,varargin)
%CGG_RUNIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here


RemovalType = PassTableEntry.RemovalType;
TrialFilter = PassTableEntry.TrialFilter;
TargetFilter = PassTableEntry.TargetFilter;
Method = PassTableEntry.Method;
Fold = PassTableEntry.Fold;
NumRemoved = PassTableEntry.NumRemoved;
SessionName = PassTableEntry.SessionName;
MatchType = PassTableEntry.MatchType;


[IsComplete,HasFlag,InProgress,~,~] = ...
    cgg_checkAnyImportanceAnalysis(Method,NumRemoved,RemovalType,Fold,...
    EpochDir,'SessionName',SessionName,'MatchType',MatchType, ...
    'TrialFilter',TrialFilter,'TargetFilter',TargetFilter,varargin{:});

ContinueAnalysis = (~IsComplete || HasFlag) && ~InProgress;

[IAPathName,RemovalTablePathName] = ...
    cgg_generateImportanceAnalysisFileNames(Method,NumRemoved,...
    RemovalType,Fold,EpochDir,SessionName,MatchType,TrialFilter, ...
    TargetFilter);

IALockFileContent = ['This file locks processes from performing the' ...
    'corresponding ablation. Until this file is deleted then no ' ...
    'process other than the one currently performing can do the ' ...
    'specified ablation. If the lock file is older than a specified ' ...
    'time then the cgg_checkAnyImportanceAnalysis function will ' ...
    'delete the lock file when it checks for currently working ' ...
    'processes.'];

% If the file is complete
if ~ContinueAnalysis
    return
else
    [LockFileSuccess, LockFilePathNameExt] = cgg_generateLockFile(IAPathName, ...
        IALockFileContent);
end

% If lock file was not successfully written then end the analysis
if ~LockFileSuccess 
    return
end

switch Method
    case Rank
        % cgg_runRankImportanceAnalysis
    case Random
        % cgg_runRandomImportanceAnalysis
    case Sequetial
        % cgg_runSequentialImportanceAnalysis
end

% Clean up the lock file after processing (whether successful or not)
if exist(LockFilePathNameExt, 'file')
  delete(LockFilePathNameExt);
end

end

