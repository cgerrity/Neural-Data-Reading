function [IsComplete,HasFlag,InProgress,IsReady,IsFinished,HasTest] = ...
    cgg_checkAnyImportanceAnalysis(PassTableEntry,cfg_Epoch,varargin)
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

%%

[IAPathName,RemovalTablePathName,IATestPathName] = ...
    cgg_generateImportanceAnalysisFileNames(PassTableEntry,cfg_Epoch);

IAPathName = char(IAPathName);
IATestPathName = char(IATestPathName);
RemovalTablePathName = char(RemovalTablePathName);

IAPathNameExt = [IAPathName '.mat'];
LockPathNameExt = [IAPathName '.lock'];
FlagPathNameExt = [IAPathName '.flag'];
FinishedPathNameExt = [IAPathName '.finished'];
IATestPathNameExt = [IATestPathName '.mat'];
RemovalTablePathNameExt = [RemovalTablePathName '.mat'];

% Check if the IA Table exists to determine if the specified one is
% complete with no flags. The lock file will exist if the process is
% ongoing. The ablation is ready if the removal table exists. Finished
% indicates that the method has finished ablating all the relevant inputs.
IsComplete = isfile(IAPathNameExt);
HasFlag = isfile(FlagPathNameExt);
InProgress = isfile(LockPathNameExt);
IsReady = isfile(RemovalTablePathNameExt);
HasTest = isfile(IATestPathNameExt);
IsFinished = isfile(FinishedPathNameExt);

% If file has been locked for more than the minimum time set the InProgress
% to false. This can happen if the run was interupted in the middle and was
% unable to delete the lock file. If this is the case then set the
% InPorgress to false and delete the old lock file.
if InProgress
LockAge = cgg_getFileAge(LockPathNameExt, 'hours');
InProgress = LockAge < LockAgeMinimum;
    if ~InProgress
        try
        delete(LockPathNameExt);
        catch
        end
    end
end


end

