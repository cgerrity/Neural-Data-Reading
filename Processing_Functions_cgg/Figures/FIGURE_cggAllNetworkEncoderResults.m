
clc; clear; close all;
rng('shuffle');
%%
if ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
p=gcp("nocreate");
if isempty(p)
parpool(cores);
end
end
%% Parameters

EpochName = 'Decision';
WantAnalysis = true;

% FilterColumn={'Gain','Loss'};
% FilterColumn={'All'};
% FilterColumn={'Dimensionality'};
% FilterColumn={'Learned'};
% FilterColumn={'Correct Trial'};
% FilterColumn={'Gain','Loss','Dimensionality'};
% FilterColumn={'Correct Trial','Dimensionality'};
FilterColumn={'Shared Feature Coding'};
% FilterColumn={'Trials From Learning Point Category'};

% Split_TableRowNames = {'Not Learned', 'fewer than 5','-5 to -1','0 to 9','10 to 19', 'more than 20'};
Split_TableRowNames = {'EC-Shared', 'EC-NonShared','EE-Shared','EE-NonShared','CC-Shared', 'CC-NonShared','CE-Shared','CE-NonShared','First'};
% Split_TableRowNames = [];
%%
% [FullTable,cfg] = cgg_getResultsPlotsParameters(Epoch,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder);
[FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'Split_TableRowNames',Split_TableRowNames);

%% Overall Accuracy

cgg_plotOverallAccuracy(FullTable,cfg);

%% Split Accuracy

cgg_plotSplitAccuracy(FullTable,cfg);

%% Overall Windowed Accuracy

cgg_plotWindowedAccuracy(FullTable,cfg);

%% Split Windowed Accuracy

cgg_plotSplitWindowedAccuracy(FullTable,cfg);

%% Overall Importance Analysis

% cgg_plotOverallImportanceAnalysis;

%% Split Importance Analysis

% cgg_plotSplitImportanceAnalysis

%% Latent Correlation Analysis

% cgg_plotLatentCorrelationAnalysis(cfg.CorrelationTable,cfg);
