
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
WantDelay = false;
% MatchType='Scaled-MicroAccuracy';
% % MatchType='Scaled-BalancedAccuracy';
% MatchType_Attention=MatchType;

% FilterColumn={'Gain','Loss'}; Split_TableRowNames = {'2/-3','2/-1','3/-3','3/-1'};
% FilterColumn={'Gain'}; Split_TableRowNames = {'Gain 2','Gain 3'};
% FilterColumn={'Loss'}; Split_TableRowNames = {'Loss -3','Loss -1'};
FilterColumn={'All'}; Split_TableRowNames = {'Overall'};
% FilterColumn={'Dimensionality'}; Split_TableRowNames = {'1-D','2-D','3-D'};
% FilterColumn={'Learned'}; Split_TableRowNames = {'Not Learned','Learning','Learned'};
% FilterColumn={'Correct Trial'}; Split_TableRowNames = {'Error','Correct'};
% FilterColumn={'Gain','Loss','Dimensionality'}; Split_TableRowNames = {'1-D 2/-3','2-D 2/-3','3-D 2/-3','1-D 2/-1','2-D 2/-1','3-D 2/-1','1-D 3/-3','2-D 3/-3','3-D 3/-3','1-D 3/-1','2-D 3/-1','3-D 3/-1'};
% FilterColumn={'Correct Trial','Dimensionality'}; Split_TableRowNames = {'1-D Error','2-D Error','3-D Error','1-D Correct','2-D Correct','3-D Correct'};
% FilterColumn={'Shared Feature Coding'}; Split_TableRowNames = {'EC-Shared', 'EC-NonShared','EE-Shared','EE-NonShared','CC-Shared', 'CC-NonShared','CE-Shared','CE-NonShared','First'};
% FilterColumn={'Trials From Learning Point Category'}; Split_TableRowNames = {'Not Learned', 'fewer than 5','-5 to -1','0 to 9','10 to 19', 'more than 20'};
% FilterColumn={'Fine Grain Trials From Learning Point Category'}; Split_TableRowNames = {'Not Learned', 'fewer than 20','-20 to -16','-15 to -11','-10 to -6','-5','-4','-3','-2','-1','0','1','2','3','4','5','6','7','8','9','10 to 11','12 to 14','15 to 17','18 to 19','20 to 29','more than 30'};
% FilterColumn={'Learned','Correct Trial'}; Split_TableRowNames = {'Not Learned - Error','Not Learned - Correct','Learning - Error','Learning - Correct','Learned - Error','Learned - Correct'};
% FilterColumn={'Learned','Dimensionality'}; Split_TableRowNames = {'3-D Not Learned','1-D Learning','2-D Learning','3-D Learning','1-D Learned','2-D Learned','3-D Learned'};
% FilterColumn={'Previous Trial','Correct Trial'}; Split_TableRowNames = {'EE','EC','CE','CC'};
% FilterColumn={'Learned','Gain','Loss'}; Split_TableRowNames = []; % Split_TableRowNames = {'3-D Not Learned','1-D Learning','2-D Learning','3-D Learning','1-D Learned','2-D Learned','3-D Learned'};
% FilterColumn={'Trials From Learning Point Category','Dimensionality'}; Split_TableRowNames = []; % Split_TableRowNames = {'Not Learned', 'fewer than 5','-5 to -1','0 to 9','10 to 19', 'more than 20'};
% FilterColumn={'Trials From Learning Point Category'}; Split_TableRowNames = {'Not Learned', 'fewer than 25','-25 to -21','-20 to -11','-10 to -1', 'more than 0'};
% FilterColumn={'Prediction Error Category'}; Split_TableRowNames = {'Unlearned','Low','Medium','High'};

% FilterColumn={'Prediction Error Category','Dimensionality'}; Split_TableRowNames = [];
%%
% [FullTable,cfg] = cgg_getResultsPlotsParameters(Epoch,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder);
[FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'Split_TableRowNames',Split_TableRowNames,'WantDelay',WantDelay);
% [FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'Split_TableRowNames',Split_TableRowNames,'WantDelay',WantDelay,'MatchType',MatchType,'MatchType_Attention',MatchType_Attention);

%%
% G = findgroups(Identifiers_Table.Block);
%  aaa = splitapply(@(x1){movmean(x1,[0,11])},Identifiers_Table.("Correct Trial"),G);
% hold on
% for i = 1:length(aaa)
% plot(aaa{i});
% end
% hold off

% G = findgroups(Identifiers_Table.Block);
%  aaa = splitapply(@(x1){movmean(x1,[0,5])},Identifiers_Table.("Absolute Prediction Error"),G);
% hold on
% for i = 1:length(aaa)
% plot(aaa{i});
% end
% hold off

%% Overall Accuracy

% cgg_plotOverallAccuracy(FullTable,cfg);

%% Split Accuracy

% cgg_plotSplitAccuracy(FullTable,cfg);

%% Overall Windowed Accuracy

% cgg_plotWindowedAccuracy(FullTable,cfg);

%% Split Windowed Accuracy

% cgg_plotSplitWindowedAccuracy(FullTable,cfg);

%% Overall Importance Analysis

% cgg_plotOverallImportanceAnalysis(cfg.RemovalPlotTable,cfg);

%% Split Importance Analysis

% cgg_plotSplitImportanceAnalysis

%% Attentional Analysis

cgg_plotAttentionalSplitWindowedAccuracy(FullTable,cfg);

%% Latent Correlation Analysis

% cgg_plotLatentCorrelationAnalysis(cfg.CorrelationTable,cfg);

%% Parameter Sweep

% cgg_plotParameterSweep(cfg,'WantValidation',true);
% cgg_plotParameterSweep(cfg,'WantValidation',false);
