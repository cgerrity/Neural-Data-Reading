function cfg = PARAMETERS_cggImportanceAnalysis(varargin)
%PARAMETERS_CGGIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', [], varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter=[];
end
end

if isfunction
LabelClassFilter = CheckVararginPairs('LabelClassFilter', '', varargin{:});
else
if ~(exist('LabelClassFilter','var'))
LabelClassFilter='';
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

% ZZZ = CheckVararginPairs('ZZZ', NaN, varargin{:});
%% Null Table Variables

% The maximum number of iterations to get for the Null Distributions
MaxNumIter = 1000;

if any(strcmp(TrialFilter,'Multi Trials From Learning Point'))
    MaxNumIter = 4;
elseif ~isempty(char(LabelClassFilter))
    MaxNumIter = 4;
elseif ~(strcmp(MatchType,'Scaled-BalancedAccuracy') ...
        || strcmp(MatchType,'Scaled-MicroAccuracy'))
    MaxNumIter = 4;
end

% The minimum number of iterations to get for each pass through of the null
% table
NumIter=100;

% Minimum number of iterations that should be done in parallel. If the
% number of iterations is less than this value each iteration is done in
% sequence.
MinimumParallelIter = 5;

% The minimum age of a lock file before it is removed and a new worker
% begins
LockAgeMinimum = 0.5; % Hour

% The minimum number of workers used to get a pass through of the null
% table. This will affect the number of iterations that larger pools of
% workers produce. The number of iterations will also be limited if
% previous runs have been performed.
% 
% If MinimumWorkers = 4; NumIter=100; and  MaxNumIter = 1000; with no
% previous runs
% 4 workers produces 100 iterations
% 2 workers produces 100 iterations
% 8 workers produces 200 iterations
% 16 workers produces 400 iterations
% 64 workers produces 1000 iterations
%
% If MinimumWorkers = 4; NumIter=100; and  MaxNumIter = 1000; with 700
% iterations already performed
% 4 workers produces 100 iterations
% 2 workers produces 100 iterations
% 8 workers produces 200 iterations
% 16 workers produces 300 iterations
% 64 workers produces 300 iterations
MinimumWorkers = 4; % The minimum number of workers is 4

%% Importance Analysis Variables

% The minimum number of workers used to get a pass through of the
% importance analysis. This will affect memory required that larger pools
% of workers produce.
% 
% If MinimumWorkers = 4; maxworkerMiniBatchSize=1;
% 2 workers has mini-batch size of 1
% 4 workers has mini-batch size of 1
% 8 workers has mini-batch size of 1
% 16 workers has mini-batch size of 2
% 32 workers has mini-batch size of 4
% 64 workers has mini-batch size of 8

MinimumWorkers_IA = 8; % Minimum number of workers for Importance Analysis

% Mini-batch size for MinimumWorkers_IA, determining the minimum
maxworkerMiniBatchSize = 1;
%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end


end

