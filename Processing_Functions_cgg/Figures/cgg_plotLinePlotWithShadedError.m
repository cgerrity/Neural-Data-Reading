function [p_Mean,p_Error] = cgg_plotLinePlotWithShadedError(XValues,YValues,PlotColor)
%CGG_PLOTLINEPLOTWITHSHADEDERROR Summary of this function goes here
%   Detailed explanation goes here


wantCI=true;

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

Error_FaceAlpha = cfg_Plotting.Error_FaceAlpha;
Error_EdgeAlpha = cfg_Plotting.Error_EdgeAlpha;

[Dimensions(1),Dimensions(2)] = size(YValues);

NumSamples = length(XValues);

Dim = find(~(Dimensions==NumSamples));

CountPerSample=sum(~isnan(YValues),Dim);
% CountPerSample(CountPerSample==0)=[];
CountPerSample(CountPerSample==0)=NaN;
CountPerSample=diag(diag(CountPerSample));

YValues_Mean = diag(diag(mean(YValues,Dim,"omitnan")));
YValues_STD = diag(diag(std(YValues,[],Dim,"omitnan")));
YValues_STE = diag(diag(YValues_STD./sqrt(CountPerSample)));

ts = tinv(0.975,CountPerSample-1);
YValues_CI = ts.*YValues_STE;

XValues=diag(diag(XValues));

this_ErrorMetric=YValues_STE;
if wantCI
    this_ErrorMetric=YValues_CI;
end

Patch_IDX=~(isnan(YValues_Mean)|isnan(this_ErrorMetric)|isnan(XValues));



% this_XValues=XValues;
% this_YValues_Mean=YValues_Mean;
% this_YValues_Error=this_ErrorMetric;

this_XValues=XValues(Patch_IDX);
this_YValues_Mean=YValues_Mean(Patch_IDX);
this_YValues_Error=this_ErrorMetric(Patch_IDX);

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

