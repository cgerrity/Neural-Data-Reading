function cgg_runImportanceAnalysis(PassTableEntry,cfg_Epoch,cfg_Encoder,varargin)
%CGG_RUNIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

if ismember("Method", PassTableEntry.Properties.VariableNames)
Method = PassTableEntry.Method;
end

[IsComplete,HasFlag,InProgress,~,~,~] = ...
    cgg_checkAnyImportanceAnalysis(PassTableEntry,cfg_Epoch);

ContinueAnalysis = (~IsComplete || HasFlag) && ~InProgress;

[IAPathName,RemovalTablePathName,IATestPathName] = ...
    cgg_generateImportanceAnalysisFileNames(PassTableEntry,cfg_Epoch,...
    'WantDirectory',true);

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

fprintf('   *** Running Importance Analysis Method: ');
switch Method
    case 'Rank'
        fprintf('Rank\n');
        % cgg_runRankImportanceAnalysis
    case 'Random'
        fprintf('Random\n');
        % cgg_runRandomImportanceAnalysis
    case 'Sequential'
        fprintf('Sequential\n');
        % cgg_runSequentialImportanceAnalysis
    case 'Block'
        fprintf('Block\n');
        cgg_runBlockImportanceAnalysis(PassTableEntry,cfg_Epoch,cfg_Encoder);
    otherwise
        fprintf('No Method Selected\n');
end

% Clean up the lock file after processing (whether successful or not)
if isfile(LockFilePathNameExt)
  delete(LockFilePathNameExt);
end

end

