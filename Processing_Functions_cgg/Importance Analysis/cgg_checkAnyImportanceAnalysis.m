function [IsComplete,HasFlag,InProgress,IsReady,IsFinished] = ...
    cgg_checkAnyImportanceAnalysis(Method,NumRemoved,RemovalType,Fold,...
    EpochDir,varargin)
%CGG_CHECKANYIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
LockAgeMinimum = CheckVararginPairs('LockAgeMinimum', 2, varargin{:});
else
if ~(exist('LockAgeMinimum','var'))
LockAgeMinimum = 2;
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='Subset';
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', 'All', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='All';
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='Overall';
end
end

%%

[IAPathName,RemovalTablePathName] = ...
    cgg_generateImportanceAnalysisFileNames(Method,NumRemoved,...
    RemovalType,Fold,EpochDir,SessionName,MatchType,TrialFilter, ...
    TargetFilter);

IAPathName = char(IAPathName);
RemovalTablePathName = char(RemovalTablePathName);

IAPathNameExt = [IAPathName '.mat'];
LockPathNameExt = [IAPathName '.lock'];
FlagPathNameExt = [IAPathName '.flag'];
FinishedPathNameExt = [IAPathName '.finished'];
RemovalTablePathNameExt = [RemovalTablePathName '.mat'];

% Check if the IA Table exists to determine if the specified one is
% complete with no flags. The lock file will exist if the process is
% ongoing. The ablation is ready if the removal table exists. Finished
% indicates that the method has finished ablating all the relevant inputs.
IsComplete = isfile(IAPathNameExt);
HasFlag = isfile(FlagPathNameExt);
InProgress = isfile(LockPathNameExt);
IsReady = isfile(RemovalTablePathNameExt);
IsFinished = isfile(FinishedPathNameExt);

% If file has been locked for more than the minimum time set the InProgress
% to false. This can happen if the run was interupted in the middle and was
% unable to delete the lock file. If this is the case then set the
% InPorgress to false and delete the old lock file.
if InProgress
LockAge = cgg_getFileAge(LockPathNameExt, 'hours');
InProgress = LockAge < LockAgeMinimum;
    if ~InProgress
        delete(LockPathNameExt);
    end
end


end

