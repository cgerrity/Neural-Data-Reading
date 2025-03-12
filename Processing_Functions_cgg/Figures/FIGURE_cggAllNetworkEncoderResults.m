
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
WantAnalysis = false;
WantDelay = false;

% FilterColumn={'Gain','Loss'}; Split_TableRowNames = {'2/-3','2/-1','3/-3','3/-1'};
FilterColumn={'All'}; Split_TableRowNames = {'Overall'};
% FilterColumn={'Dimensionality'}; Split_TableRowNames = {'1-D','2-D','3-D'};
% FilterColumn={'Learned'}; Split_TableRowNames = {'Not Learned','Learning','Learned'};
% FilterColumn={'Correct Trial'}; Split_TableRowNames = {'Error','Correct'};
% FilterColumn={'Gain','Loss','Dimensionality'}; Split_TableRowNames = {'1-D 2/-3','2-D 2/-3','3-D 2/-3','1-D 2/-1','2-D 2/-1','3-D 2/-1','1-D 3/-3','2-D 3/-3','3-D 3/-3','1-D 3/-1','2-D 3/-1','3-D 3/-1'};
% FilterColumn={'Correct Trial','Dimensionality'}; Split_TableRowNames = {'1-D Error','2-D Error','3-D Error','1-D Correct','2-D Correct','3-D Correct'};
% FilterColumn={'Shared Feature Coding'}; Split_TableRowNames = {'EC-Shared', 'EC-NonShared','EE-Shared','EE-NonShared','CC-Shared', 'CC-NonShared','CE-Shared','CE-NonShared','First'};
% FilterColumn={'Trials From Learning Point Category'}; Split_TableRowNames = {'Not Learned', 'fewer than 5','-5 to -1','0 to 9','10 to 19', 'more than 20'};

%%
% [FullTable,cfg] = cgg_getResultsPlotsParameters(Epoch,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder);
[FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'Split_TableRowNames',Split_TableRowNames,'WantDelay',WantDelay);

%% Overall Accuracy

% cgg_plotOverallAccuracy(FullTable,cfg);

%% Split Accuracy

% cgg_plotSplitAccuracy(FullTable,cfg);

%% Overall Windowed Accuracy

cgg_plotWindowedAccuracy(FullTable,cfg);

%% Split Windowed Accuracy

cgg_plotSplitWindowedAccuracy(FullTable,cfg);

%% Overall Importance Analysis

% cgg_plotOverallImportanceAnalysis(cfg.RemovalPlotTable,cfg);

%% Split Importance Analysis

% cgg_plotSplitImportanceAnalysis

%% Latent Correlation Analysis

% cgg_plotLatentCorrelationAnalysis(cfg.CorrelationTable,cfg);

%% Parameter Sweep

% cgg_plotParameterSweep(cfg);
