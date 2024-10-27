function IA_Table_Metric = cgg_calcImportanceAnalysis(IA_Table_Metric,varargin)
%CGG_CALCIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
BaselineArea = CheckVararginPairs('BaselineArea', NaN, varargin{:});
else
if ~(exist('BaselineArea','var'))
BaselineArea=NaN;
end
end

if isfunction
BaselineChannel = CheckVararginPairs('BaselineChannel', NaN, varargin{:});
else
if ~(exist('BaselineChannel','var'))
BaselineChannel=NaN;
end
end

if isfunction
BaselineLatent = CheckVararginPairs('BaselineLatent', NaN, varargin{:});
else
if ~(exist('BaselineLatent','var'))
BaselineLatent=NaN;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end
%% Get Baseline Entry

Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(IA_Table_Metric, ...
    BaselineArea,BaselineChannel,BaselineLatent);

Baseline_Accuracy = IA_Table_Metric.Accuracy(Baseline_IDX);
Baseline_Window = IA_Table_Metric.WindowAccuracy(Baseline_IDX,:);

Accuracy = IA_Table_Metric.Accuracy;
WindowAccuracy = IA_Table_Metric.WindowAccuracy;

IsScaled = contains(MatchType,'Scaled');

if IsScaled
% if the baseline metric is scaled and less than 0 we do not want to look
% at these values.
Baseline_Accuracy(Baseline_Accuracy < 0) = NaN;
Baseline_Window(Baseline_Window < 0) = NaN;

% Set all metrics to be at least 0. This way a very very poor metric value
% does not appear to have more importance.
Accuracy(Accuracy < 0) = 0;
WindowAccuracy(WindowAccuracy < 0) = 0;
end

%% Calculate the Importance

Overall_Importance = Accuracy-Baseline_Accuracy;
Window_Importance = WindowAccuracy-Baseline_Window;

Overall_RelativeImportance = Overall_Importance./Baseline_Accuracy;
Window_RelativeImportance = Window_Importance./Baseline_Window;

[PointWiseImportance,PointWiseImportanceIDX] = ...
    min(Window_Importance,[],2);
[RelativePointWiseImportance,RelativePointWiseImportanceIDX]...
    = min(Window_RelativeImportance,[],2);

[~,RankPointWise] = sort(PointWiseImportance,1,"ascend","MissingPlacement","last");
[~,RankPointWise] = sort(RankPointWise,1,"ascend","MissingPlacement","last");
[~,RankRelativePointWise] = sort(RelativePointWiseImportance,1,"ascend","MissingPlacement","last");
[~,RankRelativePointWise] = sort(RankRelativePointWise,1,"ascend","MissingPlacement","last");

[Peak,PeakIDX] = max(WindowAccuracy,[],2);
Baseline_Peak = Peak(Baseline_IDX);

PeakIA = Peak - Baseline_Peak;

[~,RankPeak] = sort(PeakIA,1,"ascend","MissingPlacement","last");
[~,RankPeak] = sort(RankPeak,1,"ascend","MissingPlacement","last");

%%

IA_Table_Metric.Overall_Importance = Overall_Importance;
IA_Table_Metric.Window_Importance = Window_Importance;
IA_Table_Metric.Overall_RelativeImportance = Overall_RelativeImportance;
IA_Table_Metric.Window_RelativeImportance = Window_RelativeImportance;
IA_Table_Metric.PointWiseImportance = PointWiseImportance;
IA_Table_Metric.PointWiseImportanceIDX = PointWiseImportanceIDX;
IA_Table_Metric.RelativePointWiseImportance = RelativePointWiseImportance;
IA_Table_Metric.RelativePointWiseImportanceIDX = RelativePointWiseImportanceIDX;
IA_Table_Metric.Peak = Peak;
IA_Table_Metric.PeakIA = PeakIA;
IA_Table_Metric.PeakIDX = PeakIDX;
IA_Table_Metric.RankPointWise = RankPointWise;
IA_Table_Metric.RankRelativePointWise = RankRelativePointWise;
IA_Table_Metric.RankPeak = RankPeak;

end

