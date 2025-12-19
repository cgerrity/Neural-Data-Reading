
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
WantLabelClassFilter = true;
% MatchType='Scaled-MicroAccuracy';
% % MatchType='Scaled-BalancedAccuracy';
% MatchType_Attention=MatchType;
%%

cfg_OverwritePlot = struct();
cfg_OverwritePlot.TimeCut = [-1.25,1];
cfg_OverwritePlot.AccuracyCut = [-0.05,0.2];
cfg_OverwritePlot.PlotFolder = 'SFN Panels';
cfg_OverwritePlot.Line_Width_Indicator = 2;
cfg_OverwritePlot.WindowFigureSizeOverwrite = [5,5];
cfg_OverwritePlot.BarFigureSizeOverwrite = [7,9];
cfg_OverwritePlot.BarAccuracyCut = [0,0.5];
cfg_OverwritePlot.BarYTickSize = 0.1;
cfg_OverwritePlot.Line_Width_Significance = 2;
cfg_OverwritePlot.wantSignificanceBars = true;
cfg_OverwritePlot.wantCI = false;
cfg_OverwritePlot.AreaColors = {'#b4d996','#c7add3','#57caee'};
cfg_OverwritePlot.WantSubTitle = false;
cfg_OverwritePlot.WantTitle = "Stand In";
%%
FilterColumn_All = {}; ColumnCounter = 1;
% FilterColumn_All{ColumnCounter}={'All'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Dimensionality'};
% ColumnCounter = ColumnCounter + 1;
FilterColumn_All{ColumnCounter}={'Learned'};
% ColumnCounter = ColumnCounter + 1;
% FilterColumn_All{ColumnCounter}={'Trials From Learning Point Category'};
ColumnCounter = ColumnCounter + 1;
FilterColumn_All{ColumnCounter}={'Prediction Error Category'};
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

% SignificanceValues = [1,0.1,0.05,0.025,0.01,0.001,0.0005,0.0001];
SignificanceValues = 0.001;
% TimeRanges = {[],[-1.5,0],[0,1.5]};
TimeRanges = {[]};

%%
for fidx = 1:length(FilterColumn_All)
    FilterColumn = FilterColumn_All{fidx};
fprintf("%s\n",join(string(FilterColumn)));
% pause(randi(10));
% FilterColumn={'Gain','Loss'}; Split_TableRowNames = {'2/-3','2/-1','3/-3','3/-1'};
% FilterColumn={'Gain'}; Split_TableRowNames = {'Gain 2','Gain 3'};
% FilterColumn={'Loss'}; Split_TableRowNames = {'Loss -3','Loss -1'};
% FilterColumn={'All'}; Split_TableRowNames = {'Overall'};
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
[FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'WantResults',WantResults,'WantLabelClassFilter',WantLabelClassFilter);
% [FullTable,cfg] = cgg_getResultsPlotsParameters(Epoch,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder);
% [FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'Split_TableRowNames',Split_TableRowNames,'WantDelay',WantDelay);
% [FullTable,cfg] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn',FilterColumn,'WantAnalysis',WantAnalysis,'Split_TableRowNames',Split_TableRowNames,'WantDelay',WantDelay,'MatchType',MatchType,'MatchType_Attention',MatchType_Attention);

FullTable = cgg_procRemoveTableRows(FullTable, "Not Learned");
FullTable = cgg_procRemoveTableRows(FullTable, "Unlearned");
%%
% G = findgroups(Identifiers_Table.Block,Identifiers_Table.("Session Name"));
%  aaa = splitapply(@(x1){movmean(x1,[0,9])},Identifiers_Table.("Correct Trial"),G);
% hold on
% for i = 1:length(aaa)
% plot(aaa{i});
% end
% hold off
% 
% G = groupsummary(Identifiers_Table,["Session Name","Dimensionality","Block"],@(x) any(x==1),"Learned");
% G_2 = groupsummary(G,["Session Name","Dimensionality"],@(x) mean(x),"fun1_Learned");
% 
% G = findgroups(Identifiers_Table.Block);
%  aaa = splitapply(@(x1){movmean(x1,[0,5])},Identifiers_Table.("Absolute Prediction Error"),G);
% hold on
% for i = 1:length(aaa)
% plot(aaa{i});
% end
% hold off

% aaa = find(isnan(Identifiers_Table.("Previous Outcome Corrected")));
% 
% Trials = -5:1:25;
% LearningStuff = NaN(length(aaa),length(Trials));
% for tidx = 1:length(aaa)
%     this_TrialRange = Trials + aaa(tidx);
%     this_TrialRange(this_TrialRange <1) = NaN;
%     this_TrialRange(this_TrialRange >height(Identifiers_Table)) = NaN;
%     this_NaNIndices = isnan(this_TrialRange);
%     this_TrialRange(this_NaNIndices) = [];
%     this_LearningStuff = NaN(1,length(Trials));
%     this_LearningStuff(~this_NaNIndices) = Identifiers_Table{this_TrialRange,"Correct Trial"};
%     LearningStuff(tidx,:) = this_LearningStuff;
% end
% % plot(Trials,mean(LearningStuff,1,"omitmissing"));
% [this_p_Plot,this_p_Error] = cgg_plotLinePlotWithShadedError(Trials,LearningStuff,[0,0,0],'wantCI',false);
% ylim([0.2,1]);
% yline(0.8);
% sel_Block = 26;sel_Session = 19;this_Table = Identifiers_Table(Identifiers_Table.Block == sel_Block & Identifiers_Table.("Session Name") == sel_Session,:);aaa = this_Table.("Correct Trial");aaaa = [movemean(aaa,[0,9]),aaa];plot(aaaa); LP = find(aaaa(:,1) >= 0.8 & aaa == 1,1);

%% Overall Accuracy

% cgg_plotOverallAccuracy(FullTable,cfg);
% cgg_plotOverallAccuracy(FullTable_Filtered,cfg);

%% Split Accuracy

% cgg_plotSplitAccuracy(FullTable,cfg);
% cgg_plotSplitAccuracy(FullTable_Filtered,cfg);

%% Overall Windowed Accuracy

% cgg_plotWindowedAccuracy(FullTable,cfg);
% cgg_plotWindowedAccuracy(FullTable_Filtered,cfg);

%% Split Windowed Accuracy

% cgg_plotSplitWindowedAccuracy(FullTable,cfg);
% cgg_plotSplitWindowedAccuracy(FullTable_Filtered,cfg);

%% Overall Importance Analysis

% cgg_plotOverallImportanceAnalysis(cfg.RemovalPlotTable,cfg);

%% Split Importance Analysis

% cgg_plotSplitImportanceAnalysis

%% Attentional Analysis

% cgg_plotAttentionalSplitAccuracy(FullTable,cfg);
% cgg_plotAttentionalSplitAccuracy(FullTable_Filtered,cfg);
% cgg_plotAttentionalSplitWindowedAccuracy(FullTable,cfg);
% cgg_plotAttentionalSplitWindowedAccuracy(FullTable_Filtered,cfg);

%% Latent Correlation Analysis

% cgg_plotLatentCorrelationAnalysis(cfg.CorrelationTable,cfg);

%% Combined Sessions
for tidx = 1:length(TimeRanges)
    TimeRange = TimeRanges{tidx};
    this_FullTable = cgg_updateFullAccuracyTablePeak(FullTable,'TimeRange',TimeRange,'cfg_Encoder',cfg);
for idx = 1:length(SignificanceValues)
    SignificanceValue = SignificanceValues(idx);
    CombinedFullTable = cgg_getSpecifiedFullTableSessions(this_FullTable,'SignificanceValue',SignificanceValue,'WantAllFromGroup',false,'cfg_Encoder', cfg,'TimeRange',TimeRange,'WantAllFromBest',true,'WantBlockSingleArea',true);
    % if isempty(TimeRange)
    %     TimeRangeString = "";
    % else
    %     TimeRangeString = sprintf(", Time [%.2f to %.2f]",TimeRange);
    % end
    % fprintf("??? Number of Sessions %d For Significance %.4f, Trial Filter %s%s\n",length(CombinedFullTable.("Session Number"){1}),SignificanceValue,join(string(FilterColumn)),TimeRangeString);
    cgg_plotBlockImportanceAnalysis(CombinedFullTable,cfg,'cfg_OverwritePlot',cfg_OverwritePlot);
    % cgg_plotSplitAccuracy(CombinedFullTable,cfg,'cfg_OverwritePlot',cfg_OverwritePlot);
    % cgg_plotSplitWindowedAccuracy(CombinedFullTable,cfg,'cfg_OverwritePlot',cfg_OverwritePlot);
    % cgg_plotAttentionalSplitAccuracy(CombinedFullTable,cfg,'cfg_OverwritePlot',cfg_OverwritePlot);
    % cgg_plotAttentionalSplitWindowedAccuracy(CombinedFullTable,cfg,'cfg_OverwritePlot',cfg_OverwritePlot);
end

% for idx = 1:length(SignificanceValues)
%     SignificanceValue = SignificanceValues(idx);
%     CombinedFullTable = cgg_getSpecifiedFullTableSessions(FullTable_Filtered,'SignificanceValue',SignificanceValue,'cfg_Encoder',cfg,'TimeRange',TimeRange);
%     cgg_plotSplitAccuracy(CombinedFullTable,cfg);
%     cgg_plotSplitWindowedAccuracy(CombinedFullTable,cfg);
%     cgg_plotAttentionalSplitAccuracy(CombinedFullTable,cfg);
%     cgg_plotAttentionalSplitWindowedAccuracy(CombinedFullTable,cfg);
%     CombinedFullTable = cgg_getSpecifiedFullTableSessions(FullTable_Filtered,'SignificanceValue',SignificanceValue,'WantAllFromGroup',true,'cfg_Encoder',cfg,'TimeRange',TimeRange);
%     cgg_plotSplitAccuracy(CombinedFullTable,cfg);
%     cgg_plotSplitWindowedAccuracy(CombinedFullTable,cfg);
%     cgg_plotAttentionalSplitAccuracy(CombinedFullTable,cfg);
%     cgg_plotAttentionalSplitWindowedAccuracy(CombinedFullTable,cfg);
% end
end
end
%% Parameter Sweep
% [~,cfg,~] = cgg_getResultsPlotsParametersNetwork(EpochName,'FilterColumn','All','WantAnalysis',false,'WantResults',false);
% cgg_plotParameterSweep(cfg,'WantValidation',true);
% cgg_plotParameterSweep(cfg,'WantValidation',false);
