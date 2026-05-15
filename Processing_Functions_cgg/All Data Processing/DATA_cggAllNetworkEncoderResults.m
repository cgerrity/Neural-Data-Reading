clc; clear; close all;
rng('shuffle');
%%
cgg_getParallelPool('WantThreads',true);
% if ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
% cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
% p=gcp("nocreate");
% if isempty(p)
% parpool(cores);
% end
% end
%% Parameters

EpochName = 'Decision';
WantResults = true;
WantAnalysis = rand(1)>0.95;
WantDelay = false;
WantLabelClassFilter = rand(1)>0.95;

%%
WantedExtra = false(1,2);
%%
FilterColumn_All = {}; ColumnCounter = 1;
%     FilterColumn_All{ColumnCounter}={'All'};
%     WantedExtra(ColumnCounter,:) = [true, true];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Dimensionality'};
%     WantedExtra(ColumnCounter,:) = [true, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Learned'};
%     WantedExtra(ColumnCounter,:) = [true, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Trials From Learning Point Category'};
%     WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Prediction Error Category'};
%     WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    FilterColumn_All{ColumnCounter}={'Gain','Loss'};
    WantedExtra(ColumnCounter,:) = [true, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Gain'};
%     WantedExtra(ColumnCounter,:) = [true, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Loss'};
%     WantedExtra(ColumnCounter,:) = [true, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Correct Trial'};
%     WantedExtra(ColumnCounter,:) = [false, false];
ColumnCounter = ColumnCounter + 1;
    FilterColumn_All{ColumnCounter}={'Learned','Dimensionality'};
    WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Previous Trial Effect'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Previous Trial Effect','Dimensionality'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Previous Trial Effect','Learned'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Learned','Gain','Loss'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Trials From Learning Point Category','Dimensionality'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Prediction Error Category','Dimensionality'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Prediction Error Category','Learned'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Prediction Error Category','Learned','Dimensionality'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
%     FilterColumn_All{ColumnCounter}={'Previous'};
%     WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Previous','Dimensionality'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Previous','Learned'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Multi Trials From Learning Point'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Dimensionality','Multi Trials From Learning Point'};
    % WantedExtra(ColumnCounter,:) = [false, false];
% ColumnCounter = ColumnCounter + 1;
    % FilterColumn_All{ColumnCounter}={'Gain','Loss','Multi Trials From Learning Point'};
    % WantedExtra(ColumnCounter,:) = [false, false];
ColumnCounter = ColumnCounter + 1;
    FilterColumn_All{ColumnCounter}={'Value Difference Category'};
    WantedExtra(ColumnCounter,:) = [true, false];
ColumnCounter = ColumnCounter + 1;
    FilterColumn_All{ColumnCounter}={'Target Value Category'};
    WantedExtra(ColumnCounter,:) = [true, false];
ColumnCounter = ColumnCounter + 1;
    FilterColumn_All{ColumnCounter}={'Target Prediction Error Category'};
    WantedExtra(ColumnCounter,:) = [true, false];

%%
FilterPermutation = randperm(length(FilterColumn_All));
FilterColumn_All(FilterPermutation) = FilterColumn_All;
WantedExtra(FilterPermutation,:) = WantedExtra;
%%
for fidx = 1:length(FilterColumn_All)
    FilterColumn = FilterColumn_All{fidx};
    WantUseNullTable = true;
    this_WantAnalysis = WantedExtra(fidx,1);
    this_WantLabelClassFilter = WantedExtra(fidx,2);
    fprintf('### Running Trial Filter for %s!\n',string(join(FilterColumn)));
    [FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',this_WantAnalysis,'WantResults',WantResults,'WantUseNullTable',WantUseNullTable,'WantLabelClassFilter',this_WantLabelClassFilter);
end