function RemovalPlotTable = cgg_getRemovalPlotTable(RemovalPlotTable,IA_Table_Fold,Name,RemovalType,cfg,varargin)
%CGG_GETREMOVALPLOTTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SmoothWindow = CheckVararginPairs('SmoothWindow', [30,0], varargin{:});
else
if ~(exist('SmoothWindow','var'))
SmoothWindow=[30,0];
end
end

if isfunction
TimeOffset = CheckVararginPairs('TimeOffset', 0, varargin{:});
else
if ~(exist('TimeOffset','var'))
TimeOffset=0;
end
end
%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;
[Probe_Dimensions,Probe_Areas,~,~] = cgg_getProbeDimensions(Probe_Order);
Probe_Areas = Probe_Areas';

%%

TableVariables = [["Name", "string"]; ...
    ["Removal Type", "string"]; ...
    ["Units Removed", "double"]; ...
    ["Accuracy", "double"]; ...
    ["Error STE", "double"]; ...
    ["Error CI", "double"]; ...
    ["Window Accuracy", "double"]; ...
    ["Area Percent", "double"]; ...
    ["Area Relative Percent", "double"]; ...
    ["Area Names", "cell"]; ...
    ["Peak Time", "double"]; ...
    ["Peak Time STE", "double"]; ...
    ["Peak Time CI", "double"]];

NumVariables = size(TableVariables,1);

if isempty(RemovalPlotTable)
RemovalPlotTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
end
%%

NumChannelsRemovedFunc = @(y) cellfun(@(x) sum(~isnan(x)),y.ChannelRemoved);
NumLatentRemovedFunc = @(y) cellfun(@(x) sum(~isnan(x)),y.LatentRemoved);
NumRemovalsFunc = @(y) NumChannelsRemovedFunc(y) + NumLatentRemovedFunc(y);


%%
CheckCellFunc = @(y,z) cellfun(@(x) sum(strcmp(x,z)),y,"UniformOutput",true);
SingleCellSumFunc = @(y,z) sum(CheckCellFunc(y,z));

AllAreaCountFunc = @(x) [];
NumAreas = length(Probe_Areas);

for aidx = 1:NumAreas
AreaCountFunc = @(y) cellfun(@(x) SingleCellSumFunc(x,Probe_Areas{aidx}),y.AreaNames,"UniformOutput",true);
AllAreaCountFunc = @(z) [AllAreaCountFunc(z), AreaCountFunc(z)];
end

AllAreaPercentFunc = @(z) AllAreaCountFunc(z)./max(AllAreaCountFunc(z),[],1);
AllAreaCountFunc = @(z) sum(AllAreaCountFunc(z),2);

EqualAllAreaPercentFunc = @(z) AllAreaCountFunc(z)./max(AllAreaCountFunc(z),[],1);

AllAreaPercent_RelativeFunc = @(z) AllAreaPercentFunc(z) - EqualAllAreaPercentFunc(z);

% AllAreaPercent_Relative = AllAreaPercent_RelativeFunc(this_IA_Table);
% 
% plot(AllAreaPercent_Relative(:,1)); hold on; plot(AllAreaPercent_Relative(:,2)); plot(AllAreaPercent_Relative(:,3)); hold off;
%%
Time = cgg_getTime(cfg.Time_Start,cfg.SamplingFrequency,cfg.DataWidth,cfg.WindowStride,cfg.NumWindows,TimeOffset);
%%

Accuracy = [];
WindowAccuracy = [];
NumUnitsRemoved =[];
AreaPercent = [];
AreaRelativePercent = [];
PeakTime = [];
NumFolds = height(IA_Table_Fold);

for fidx = 1:NumFolds
    this_IA_Table = IA_Table_Fold{fidx,"IA_Table_Metric"};
    this_IA_Table = this_IA_Table{1};

this_NumUnitsRemoved = NumRemovalsFunc(this_IA_Table);
this_Accuracy = this_IA_Table.Peak;
this_WindowAccuracy = this_IA_Table.WindowAccuracy;
this_AreaPercent = AllAreaPercentFunc(this_IA_Table);
this_AreaRelativePercent = AllAreaPercent_RelativeFunc(this_IA_Table);
this_PeakTime = Time(this_IA_Table.PeakIDX);
this_PeakTime = diag(diag(this_PeakTime));

if ~any(isnan(SmoothWindow))
this_Accuracy = smoothdata(this_Accuracy,1,"gaussian",SmoothWindow);
this_PeakTime = smoothdata(this_PeakTime,1,"gaussian",SmoothWindow);
end

NumUnitsRemoved = cat(2,NumUnitsRemoved,this_NumUnitsRemoved);
Accuracy = cat(2,Accuracy,this_Accuracy);
WindowAccuracy = cat(3,WindowAccuracy,this_WindowAccuracy);
AreaPercent = cat(3,AreaPercent,this_AreaPercent);
AreaRelativePercent = cat(3,AreaRelativePercent,this_AreaRelativePercent);
PeakTime = cat(2,PeakTime,this_PeakTime);
end

%%

NumUnitsRemoved = mean(NumUnitsRemoved,2);

[Accuracy,~,Accuracy_STE,Accuracy_CI] = ...
    cgg_getMeanSTDSeries(Accuracy,'NumCollapseDimension',NumFolds);

[WindowAccuracy,~,~,~] = ...
    cgg_getMeanSTDSeries(WindowAccuracy,'NumCollapseDimension',NumFolds);

[AreaPercent,~,~,~] = ...
    cgg_getMeanSTDSeries(AreaPercent,'NumCollapseDimension',NumFolds);

[AreaRelativePercent,~,~,~] = ...
    cgg_getMeanSTDSeries(AreaRelativePercent,'NumCollapseDimension',NumFolds);

[PeakTime,~,PeakTime_STE,PeakTime_CI] = ...
    cgg_getMeanSTDSeries(PeakTime,'NumCollapseDimension',NumFolds);

% NumChannels = size(AreaRelativePercent,1);
% 
% [AreaRelativeBar,~,AreaRelativeBar_STE,AreaRelativeBar_CI] = ...
%     cgg_getMeanSTDSeries(AreaRelativePercent,'NumCollapseDimension',NumChannels);

NumRemoved = length(NumUnitsRemoved);

%%

this_RemovalPlotTable = table(repmat({Name},[NumRemoved,1]),...
    repmat({RemovalType},[NumRemoved,1]),NumUnitsRemoved,Accuracy,...
    Accuracy_STE,Accuracy_CI,WindowAccuracy,AreaPercent,...
    AreaRelativePercent,repmat({Probe_Areas'},[NumRemoved,1]),...
    PeakTime,PeakTime_STE,PeakTime_CI, ...
    'VariableNames',TableVariables(:,1));

RemovalPlotTable = [RemovalPlotTable;this_RemovalPlotTable];
end

