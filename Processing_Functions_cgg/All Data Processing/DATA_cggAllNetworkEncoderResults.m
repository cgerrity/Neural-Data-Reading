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
WantResults = false;
WantAnalysis = false;
WantDelay = false;

%%
FilterColumn_All = {}; ColumnCounter = 1;
% FilterColumn_All{ColumnCounter}={'All'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
FilterColumn_All{ColumnCounter}={'Learned'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Trials From Learning Point Category'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Prediction Error Category'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Gain','Loss'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Gain'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Loss'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Correct Trial'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Learned','Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Previous Trial Effect'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Previous Trial Effect','Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Previous Trial Effect','Learned'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Learned','Gain','Loss'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Trials From Learning Point Category','Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Prediction Error Category','Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Prediction Error Category','Learned'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Prediction Error Category','Learned','Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Previous'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Previous','Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Previous','Learned'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Multi Trials From Learning Point'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Dimensionality','Multi Trials From Learning Point'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Gain','Loss','Multi Trials From Learning Point'};

%%
FilterColumn_All(randperm(length(FilterColumn_All))) = FilterColumn_All;
%%
for fidx = 1:length(FilterColumn_All)
    FilterColumn = FilterColumn_All{fidx};
    fprintf('### Running Trial Filter for %s!\n',string(join(FilterColumn)));
    [FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'WantResults',WantResults);
end