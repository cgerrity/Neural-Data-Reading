function NullTable = cgg_getNullTable(CM_Table,cfg_Epoch,cfg_Encoder,varargin)
%CGG_GETNULLTABLE Summary of this function goes here
%   Detailed explanation goes here

cfg_IA = PARAMETERS_cggImportanceAnalysis();
%%

isfunction=exist('varargin','var');

if isfunction
NumIter = CheckVararginPairs('NumIter', cfg_IA.NumIter, varargin{:});
else
if ~(exist('NumIter','var'))
NumIter=cfg_IA.NumIter;
end
end

if isfunction
MaxNumIter = CheckVararginPairs('MaxNumIter', cfg_IA.MaxNumIter, varargin{:});
else
if ~(exist('MaxNumIter','var'))
MaxNumIter=cfg_IA.MaxNumIter;
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
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

if isfunction
TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', NaN, varargin{:});
else
if ~(exist('TrialFilter_Value','var'))
TrialFilter_Value=NaN;
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='Overall';
end
end

if isfunction
WantMatchOverride = CheckVararginPairs('WantMatchOverride', false, varargin{:});
else
if ~(exist('WantMatchOverride','var'))
WantMatchOverride=false;
end
end

if isfunction
LockAgeMinimum = CheckVararginPairs('LockAgeMinimum', cfg_IA.LockAgeMinimum, varargin{:});
else
if ~(exist('LockAgeMinimum','var'))
LockAgeMinimum = cfg_IA.LockAgeMinimum;
end
end

if isfunction
MinimumWorkers = CheckVararginPairs('MinimumWorkers', cfg_IA.MinimumWorkers, varargin{:});
else
if ~(exist('MinimumWorkers','var'))
MinimumWorkers = cfg_IA.MinimumWorkers;
end
end

if isfunction
Identifiers_Table = CheckVararginPairs('Identifiers_Table', [], varargin{:});
else
if ~(exist('Identifiers_Table','var'))
Identifiers_Table=[];
end
end

%% Adjust minimum number of iterations for the number of workers
NumIter = cgg_getValueBasedOnNumberOfWorkers(NumIter,MinimumWorkers);
NumIter = round(NumIter);
%%
DataNumber = CM_Table.DataNumber;
Target = cfg_Encoder.Target;

IsQuaddle = false;
if strcmp(cfg_Encoder.Target,"Dimension")
    IsQuaddle = true;
end
if isfield(cfg_Encoder,'Subset') && isfield(cfg_Encoder,'wantSubset')
[~,~,SessionName] = cgg_verifySubset(cfg_Encoder.Subset,cfg_Encoder.wantSubset);
end

MatchType_Attention = MatchType;
AttentionalFilter = TargetFilter;

%%
this_NullTable = cgg_generateBlankNullTable('Target',Target,...
        'SessionName',SessionName,'TrialFilter',TrialFilter,...
        'TrialFilter_Value',TrialFilter_Value,...
        'TargetFilter',TargetFilter,'MatchType',MatchType,...
        'DataNumber',DataNumber);

%% Get the Null Table
NullTable = cgg_loadNullTable(cfg_Epoch,Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType);

%% Issue with char/cell instead of string
if ischar(NullTable.Target) || iscell(NullTable.Target)
NullTable.Target = string(NullTable.Target);
end
if ischar(NullTable.MatchType) || iscell(NullTable.MatchType)
NullTable.MatchType = string(NullTable.MatchType);
end
if ischar(NullTable.TrialFilter) || iscell(NullTable.TrialFilter)
NullTable.TrialFilter = string(NullTable.TrialFilter);
end
if ischar(NullTable.SessionName) || iscell(NullTable.SessionName)
NullTable.SessionName = string(NullTable.SessionName);
end
if ischar(NullTable.TargetFilter) || iscell(NullTable.TargetFilter)
NullTable.TrialFilter = string(NullTable.TrialFilter);
end
%% Identify any issues with Null Tables with repeat DataNumbers
DataNumber_Prior = NullTable.DataNumber;
MatchingNullEntry = cellfun(@(x) isequal(sort(x),sort(DataNumber)),DataNumber_Prior,'UniformOutput',true);
MatchingNullEntry_Indices = find(MatchingNullEntry);
if length(MatchingNullEntry_Indices) > 1
    fprintf('   +++ Removing repeat entries!\n');
    NullTable(MatchingNullEntry_Indices(2:end),:) = [];

    IALockFileContent = 'Repeated Entries Detected';
    [NullTablePath,NullTableName] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'cfg',cfg_Epoch);
    NullTablePathName = fullfile(NullTablePath, NullTableName);
    [LockFileSuccess, LockPathNameExt] = cgg_generateLockFile(NullTablePathName, ...
        IALockFileContent);
    if LockFileSuccess
    NullTablePathNameExt = string(NullTablePathName) + ".mat";
    save(NullTablePathNameExt,"NullTable","-v7.3");
    fprintf('   +++ Saved Null Table After removing repeated entried!\n');
    if isfile(LockPathNameExt)
        delete(LockPathNameExt);
    end
    end
end
%% Identify if the specified data exists in the Null Table
DataNumber_Prior = NullTable.DataNumber;
MatchingNullEntry = cellfun(@(x) isequal(sort(x),sort(DataNumber)),DataNumber_Prior,'UniformOutput',true);
HasMatchingNullEntry = any(MatchingNullEntry);
%% Get Current Distribution Progress
if HasMatchingNullEntry
Current_NullTable = NullTable(MatchingNullEntry,:);
else
Current_NullTable = this_NullTable;
end

Current_BaselineChanceDistribution = Current_NullTable.BaselineChanceDistribution{1};
Current_ChanceDistribution = Current_NullTable.ChanceDistribution{1};

NumIter_Current_BaselineChanceDistribution = length(Current_BaselineChanceDistribution);
NumIter_Current_ChanceDistribution = length(Current_ChanceDistribution);
Min_NumIter_Current = min([NumIter_Current_BaselineChanceDistribution,...
    NumIter_Current_ChanceDistribution]);
Remaining_NumIter = MaxNumIter - Min_NumIter_Current;
NeedMoreIterations = 0 < Remaining_NumIter;

NumIter = min([Remaining_NumIter,NumIter]);
%% Determine if it is necessary to generate more distribution values
NeedNullDistribution = ~(HasMatchingNullEntry) || WantMatchOverride;
NeedNullDistribution = NeedNullDistribution || NeedMoreIterations;
%% Aquire Null Distribution
if NeedNullDistribution
%%
IALockFileContent = ['This file locks processes from getting the ' ...
    'corresponding null distribution. Until this file is deleted then no ' ...
    'process other than the one currently performing can obtain the ' ...
    'specified null distribution. If the lock file is older than a specified ' ...
    'time then lock file will be deleted and the process will get the distribution'];
%%
[NullTablePath,NullTableName] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'cfg',cfg_Epoch);
NullTablePathName = fullfile(NullTablePath, NullTableName);
[LockFileSuccess, LockPathNameExt] = cgg_generateLockFile(NullTablePathName, ...
        IALockFileContent);
IsLockedByOther = ~LockFileSuccess;
% If file has been locked for more than the minimum time set the InProgress
% to false. This can happen if the run was interupted in the middle and was
% unable to delete the lock file. If this is the case then set the
% LockFileSuccess to true, delete the old lock file and create a new lock
% file.
if IsLockedByOther
LockAge = cgg_getFileAge(LockPathNameExt, 'hours');
InProgress = LockAge < LockAgeMinimum;
    if ~InProgress
        try
        delete(LockPathNameExt);
        catch
        end
        [LockFileSuccess, ~] = cgg_generateLockFile(NullTablePathName, ...
        IALockFileContent);
        % In case of just absolute mess at this point, just return the
        % current state of the Null Distribution
        if ~LockFileSuccess
            return
        end
    else
        return
    end
end
%%
if LockFileSuccess
fprintf('   +++ Generated Lock File!\n');
end
%% Threads based parallel environment

% FIXME: Check if Identifiers_Table is the same for both ways. If so
% preload the Identifiers_Table. This will allow for threads to work and
% may also speed up the processes based environment
% if isa(gcp('nocreate'), 'parallel.ThreadPool')
% 
% % disp('Outside Iterations');
% % head(Identifiers_Table)
% % disp(size(Identifiers_Table));
% % delete(gcp('nocreate'))
% % cgg_getParallelPool('WantThreads',false);
% end

cgg_getParallelPool('RequireChange', true,'WantThreads',false);

if isfield(cfg_Encoder,'Subset') && isfield(cfg_Encoder,'wantSubset')
[~,wantSubset,~] = cgg_verifySubset(cfg_Encoder.Subset,cfg_Encoder.wantSubset);
end
if isfield(cfg_Encoder,'Epoch')
Epoch = cfg_Encoder.Epoch;
end
if isempty(Identifiers_Table)
Identifiers_Table = cgg_getIdentifiersTable(cfg_Epoch,wantSubset,...
    'Epoch',Epoch,'Subset',SessionName);
end

% Identifiers_Table = [];

%% Run through each iteration
BaselineChanceDistribution = NaN(1,NumIter);
ChanceDistribution = NaN(1,NumIter);
this_CM_Table = CM_Table(:,["DataNumber","TrueValue","Window_1"]);

waitbar = parallel.pool.Constant(cgg_getWaitBar(...
    'All_Iterations',NumIter,'Process','Null Distribution',...
    'DisplayIndents', 3));

parfor idx = 1:NumIter
[BaselineChanceDistribution(idx),ChanceDistribution(idx)] = ...
    cgg_procCompleteMetric(this_CM_Table,cfg_Epoch,'WantOutputChance',true,...
    'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,...
    'MatchType',MatchType,'IsQuaddle',IsQuaddle,...
    'MatchType_Attention',MatchType_Attention,...
    'AttentionalFilter',AttentionalFilter,'Subset',SessionName,...
    'cfg_Encoder',cfg_Encoder,'WantFilteredChance',true,...
    'WantSpecificChance',true,'WantUseNullTable',false,...
    'Identifiers_Table',Identifiers_Table);
waitbar.Value.update();
end

%% Append the new distribution with the current distribution
% The current distribution will be empty if it has not been run before.
BaselineChanceDistribution = [Current_BaselineChanceDistribution, BaselineChanceDistribution];
ChanceDistribution = [Current_ChanceDistribution, ChanceDistribution];

this_NullTable.BaselineChanceDistribution = {BaselineChanceDistribution};
this_NullTable.ChanceDistribution = {ChanceDistribution};
%% Add to Null Table
% Add the row to the Null Table. If the entry exists, then overwrite it. If
% there is a non-empty Null Table add it to the bottom. Otherwise it is the
% new Null Table.
if HasMatchingNullEntry
    NullTable(MatchingNullEntry,:) = this_NullTable;
    fprintf('   +++ Updating Existing Null Table Entry by %d Iterations!\n',NumIter);
elseif ~isempty(NullTable.DataNumber{1})
    NullTable = [NullTable; this_NullTable];
    fprintf('   +++ Appending Null Table Entry with %d Iterations!\n',NumIter);
else
    NullTable = this_NullTable;
    fprintf('   +++ Starting a new Null Table with %d Iterations!\n',NumIter);
end

%% Save Null Table

NullTablePathNameExt = string(NullTablePathName) + ".mat";
save(NullTablePathNameExt,"NullTable","-v7.3");
fprintf('   +++ Saved Null Table!\n');
%% Unlock
if isfile(LockPathNameExt)
    delete(LockPathNameExt);
end
fprintf('   +++ Removing Lock File!\n');
% fprintf('*** Complete Null Table Pass on %s!\n',Split_TableRowNames(tidx));
end % End of NeedNullDistribution

end % End of function

