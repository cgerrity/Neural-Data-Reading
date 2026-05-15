function Time = cgg_getTime(Time_Start,SamplingRate,DataWidth,WindowStride,NumWindows,TimeOffset,varargin)
%CGG_GETTIME Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Time_End = CheckVararginPairs('Time_End', NaN, varargin{:});
else
if ~(exist('Time_End','var'))
Time_End=NaN;
end
end

if isfunction
Total_Points = CheckVararginPairs('Total_Points', NaN, varargin{:});
else
if ~(exist('Total_Points','var'))
Total_Points=NaN;
end
end

if ~isnan(Total_Points)
    Time_End = (Total_Points-1)/SamplingRate + Time_Start;
end

% if ~isnan(Time_End) && ~isnan(NumWindows)
if ~isnan(Time_End)
Total_Points = (Time_End-Time_Start)*SamplingRate+1;
NumWindows = floor((Total_Points - DataWidth) / WindowStride) + 1;
end

DataWidth = DataWidth/SamplingRate;
WindowStride = WindowStride/SamplingRate;

Time_Start_Adjusted = Time_Start+DataWidth/2+TimeOffset;

Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
end

