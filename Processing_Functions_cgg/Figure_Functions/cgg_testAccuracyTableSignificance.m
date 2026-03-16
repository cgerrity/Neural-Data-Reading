function [IsSignificant,Significance] = cgg_testAccuracyTableSignificance(AccuracyTable,varargin)
%CGG_TESTACCURACYTABLESIGNIFICANCE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
ChanceLevel = CheckVararginPairs('ChanceLevel', 0, varargin{:});
else
if ~(exist('ChanceLevel','var'))
ChanceLevel=0;
end
end

if isfunction
TimeRange = CheckVararginPairs('TimeRange', [], varargin{:});
else
if ~(exist('TimeRange','var'))
TimeRange=[];
end
end

if isfunction
cfg_Encoder = CheckVararginPairs('cfg_Encoder', struct(), varargin{:});
else
if ~(exist('cfg_Encoder','var'))
cfg_Encoder=struct();
end
end

if isfunction
cfg_Epoch = CheckVararginPairs('cfg_Epoch', struct(), varargin{:});
else
if ~(exist('cfg_Epoch','var'))
cfg_Epoch=struct();
end
end

if isfunction
Subset = CheckVararginPairs('Subset', {}, varargin{:});
else
if ~(exist('Subset','var'))
Subset={};
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', '', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='';
end
end

if isfunction
TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', [], varargin{:});
else
if ~(exist('TrialFilter_Value','var'))
TrialFilter_Value=[];
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', '', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='';
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', '', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='';
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
WantDebug = CheckVararginPairs('WantDebug', false, varargin{:});
else
if ~(exist('WantDebug','var'))
WantDebug=false;
end
end

%%
SessionName = Subset;
%% Get Timeline for Time Range specification

if ~isempty(TimeRange)
    if isfield(cfg_Encoder,'Time_Start') && ...
        isfield(cfg_Encoder,'SamplingRate') && ...
        isfield(cfg_Encoder,'DataWidth') && ...
        isfield(cfg_Encoder,'WindowStride') && ...
        isfield(cfg_Encoder,'Time_End')
Time = cgg_getTime(cfg_Encoder.Time_Start,cfg_Encoder.SamplingRate,...
    cfg_Encoder.DataWidth,cfg_Encoder.WindowStride,NaN,0,...
    'Time_End',cfg_Encoder.Time_End);
    end
end

%%

Information_Table = cgg_generateBlankInformationTable(...
    'DataNumber',AccuracyTable.DataNumber{1},...
    'SessionName',SessionName,'TrialFilter',TrialFilter,...
    'TrialFilter_Value',TrialFilter_Value,'MatchType',MatchType,...
    'TargetFilter',TargetFilter,'LabelClassFilter',LabelClassFilter);

MetricFunc = @(x) mean(x, "all", "omitnan");

Threshold = cgg_calcNullThreshold(Information_Table,MetricFunc,'cfg_Encoder',cfg_Encoder,'cfg_Epoch',cfg_Epoch,'Alpha',SignificanceValue);
%%
this_Window_Accuracy = AccuracyTable.('Window Accuracy'){1};
[~,NumWindows] = size(this_Window_Accuracy);

% [Series_Mean,~,~,Series_CI] = ...
%     cgg_getMeanSTDSeries(this_Window_Accuracy,...
%     'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
[Series_Mean,~,~,~] = ...
    cgg_getMeanSTDSeries(this_Window_Accuracy,...
    'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);

% this_TestSignal = Series_Mean - Series_CI;
this_TestSignal_Permutation = Series_Mean;

if exist("Time","var") && ~isempty(TimeRange)
TimeRangeIndices = Time > min(TimeRange) & Time < max(TimeRange);
% this_TestSignal(~TimeRangeIndices) = [];
this_TestSignal_Permutation(~TimeRangeIndices) = [];
end

% Significance_TTest = this_TestSignal > ChanceLevel;
Significance = this_TestSignal_Permutation > Threshold;

if WantDebug
if iscell(TrialFilter_Value)
fprintf('??? TrialFilter: %s; TrialFilterValue: %d; TargetFilter: %s\n',string(TrialFilter),TrialFilter_Value{1},string(TargetFilter));
else
fprintf('??? TrialFilter: %s; TrialFilterValue: %d; TargetFilter: %s\n',string(TrialFilter),TrialFilter_Value,string(TargetFilter));
end
% figure; plot(this_TestSignal); yline(0); ylim([-0.05,0.2]);
fig_debug = figure;
plot(this_TestSignal_Permutation);
yline(Threshold);
ylim([-0.05,0.2]);
close(fig_debug);
end
% IsSignificant = any(this_TestSignal > ChanceLevel);
IsSignificant = any(Significance);
% fprintf('??? Significance Level: %f\n',SignificanceValue);
% close all
end

