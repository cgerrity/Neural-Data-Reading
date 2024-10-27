function [Series_Mean,Series_STD,Series_STE,Series_CI] = ...
    cgg_getMeanSTDSeries(InputSeries,varargin)
%CGG_GETMEANSTDSERIES Summary of this function goes here
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
DataTransform = CheckVararginPairs('DataTransform', '', varargin{:});
else
if ~(exist('DataTransform','var'))
DataTransform='';
end
end

if isfunction
NumSamples = CheckVararginPairs('NumSamples', '', varargin{:});
else
if ~(exist('NumSamples','var'))
NumSamples='';
end
end

if isfunction
NumCollapseDimension = CheckVararginPairs('NumCollapseDimension', [], varargin{:});
else
if ~(exist('NumCollapseDimension','var'))
NumCollapseDimension=[];
end
end

%%

this_Series = InputSeries;

if ~isempty(DataTransform)
    this_Series = DataTransform{1}(this_Series);
end

%%

Dimensions = size(InputSeries);

CollapseDim = [];
if ~isempty(NumCollapseDimension)
    CollapseDim = find((Dimensions==NumCollapseDimension),1);
end
if ~isempty(NumSamples) && isempty(CollapseDim)
    CollapseDim = find(~(Dimensions==NumSamples),1);
end
if isempty(CollapseDim)
    CollapseDim = 1;
end

%%

CountPerSample=sum(~isnan(this_Series),CollapseDim);
% CountPerSample(CountPerSample==0)=[];
CountPerSample(CountPerSample==0)=NaN;
% CountPerSample=diag(diag(CountPerSample));

% Series_Mean = diag(diag(mean(this_Series,CollapseDim,"omitnan")));
% Series_STD = diag(diag(std(this_Series,[],CollapseDim,"omitnan")));
% Series_STE = diag(diag(Series_STD./sqrt(CountPerSample)));

Series_Mean = mean(this_Series,CollapseDim,"omitnan");
Series_STD = std(this_Series,[],CollapseDim,"omitnan");
Series_STE = Series_STD./sqrt(CountPerSample);

ts = tinv(1-SignificanceValue/2,CountPerSample-1);
Series_CI = ts.*Series_STE;

%%

if ~isempty(DataTransform)
    Series_Mean = DataTransform{2}(Series_Mean);
    Series_STD = DataTransform{2}(Series_STD);
    Series_STE = DataTransform{2}(Series_STE);
    Series_CI = DataTransform{2}(Series_CI);
end

%%

% Series_Mean = Series_Mean';
% Series_STD = Series_STD';
% Series_STE = Series_STE';
% Series_CI = Series_CI';

end

