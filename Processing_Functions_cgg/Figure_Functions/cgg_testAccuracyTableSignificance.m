function IsSignificant = cgg_testAccuracyTableSignificance(AccuracyTable,varargin)
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
this_Window_Accuracy = AccuracyTable.('Window Accuracy'){1};
[~,NumWindows] = size(this_Window_Accuracy);

[Series_Mean,~,~,Series_CI] = ...
    cgg_getMeanSTDSeries(this_Window_Accuracy,...
    'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);

this_TestSignal = Series_Mean - Series_CI;

if exist("Time","var") && ~isempty(TimeRange)
TimeRangeIndices = Time > min(TimeRange) & Time < max(TimeRange);
this_TestSignal(~TimeRangeIndices) = [];
end
IsSignificant = any(this_TestSignal > ChanceLevel);

end

