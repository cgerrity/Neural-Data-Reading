function [p_Mean,p_Error] = cgg_plotLinePlotWithShadedError(XValues,YValues,PlotColor,varargin)
%CGG_PLOTLINEPLOTWITHSHADEDERROR Summary of this function goes here
%   Detailed explanation goes here

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

isfunction=exist('varargin','var');

if isfunction
wantCI = CheckVararginPairs('wantCI', true, varargin{:});
else
if ~(exist('wantCI','var'))
wantCI=true;
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
YValues_STD = CheckVararginPairs('YValues_STD', '', varargin{:});
else
if ~(exist('YValues_STD','var'))
YValues_STD='';
end
end

if isfunction
CountPerSample = CheckVararginPairs('CountPerSample', '', varargin{:});
else
if ~(exist('CountPerSample','var'))
CountPerSample='';
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
ErrorMetric = CheckVararginPairs('ErrorMetric', '', varargin{:});
else
if ~(exist('ErrorMetric','var'))
ErrorMetric='';
end
end

if isfunction
Error_FaceAlpha = CheckVararginPairs('Error_FaceAlpha', cfg_Plotting.Error_FaceAlpha, varargin{:});
else
if ~(exist('Error_FaceAlpha','var'))
Error_FaceAlpha=cfg_Plotting.Error_FaceAlpha;
end
end

if isfunction
Error_EdgeAlpha = CheckVararginPairs('Error_EdgeAlpha', cfg_Plotting.Error_EdgeAlpha, varargin{:});
else
if ~(exist('Error_EdgeAlpha','var'))
Error_EdgeAlpha=cfg_Plotting.Error_EdgeAlpha;
end
end

%%

if ~isempty(DataTransform)
    this_YValues = DataTransform{1}(YValues);
else
    this_YValues = YValues;
end

[Dimensions(1),Dimensions(2)] = size(this_YValues);

NumSamples = length(XValues);

Dim = find(~(Dimensions==NumSamples));

%%

if isempty(CountPerSample)
CountPerSample=sum(~isnan(this_YValues),Dim);
% CountPerSample(CountPerSample==0)=[];
CountPerSample(CountPerSample==0)=NaN;
CountPerSample=diag(diag(CountPerSample));
end

YValues_Mean = diag(diag(mean(this_YValues,Dim,"omitnan")));
if isempty(YValues_STD)
YValues_STD = diag(diag(std(this_YValues,[],Dim,"omitnan")));
end
YValues_STE = diag(diag(YValues_STD./sqrt(CountPerSample)));

ts = tinv(1-SignificanceValue/2,CountPerSample-1);
YValues_CI = ts.*YValues_STE;

XValues=diag(diag(XValues));

this_ErrorMetric=YValues_STE;
if wantCI
    this_ErrorMetric=YValues_CI;
end

if ~isempty(ErrorMetric)
this_ErrorMetric = ErrorMetric;
end

if size(this_ErrorMetric,1) < size(this_ErrorMetric,2)
this_ErrorMetric = this_ErrorMetric';
end

%%

Patch_IDX=~(isnan(YValues_Mean)|isnan(this_ErrorMetric)|isnan(XValues));



% this_XValues=XValues;
% this_YValues_Mean=YValues_Mean;
% this_YValues_Error=this_ErrorMetric;

this_XValues=XValues(Patch_IDX);
this_YValues_Mean=YValues_Mean(Patch_IDX);
this_YValues_Error=this_ErrorMetric(Patch_IDX);

if ~isempty(DataTransform)
    this_YValues_Mean = DataTransform{2}(this_YValues_Mean);
    this_YValues_Error = DataTransform{2}(this_YValues_Error);
end

Patch_X=[this_XValues;flipud(this_XValues)];
Patch_Y=[this_YValues_Mean-this_YValues_Error;flipud(this_YValues_Mean+this_YValues_Error)];
% Area_Y=[this_YValues_Mean-this_YValues_Error;this_YValues_Mean+this_YValues_Error];
%%
if isempty(Patch_Y)||isempty(Patch_X)
    Patch_X=NaN;
    Patch_Y=NaN;
end
%%
hold on

p_Mean=plot(XValues,YValues_Mean);
p_Mean.Color=PlotColor;

p_Error=patch(Patch_X,Patch_Y,'r');
p_Error.FaceColor=PlotColor;
p_Error.EdgeColor=PlotColor;
p_Error.FaceAlpha=Error_FaceAlpha;
p_Error.EdgeAlpha=Error_EdgeAlpha;

end

