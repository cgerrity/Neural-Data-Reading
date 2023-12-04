function [p_Mean,p_Error] = cgg_plotLinePlotWithShadedError(XValues,YValues,PlotColor)
%CGG_PLOTLINEPLOTWITHSHADEDERROR Summary of this function goes here
%   Detailed explanation goes here


cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

Error_FaceAlpha = cfg_Plotting.Error_FaceAlpha;
Error_EdgeAlpha = cfg_Plotting.Error_EdgeAlpha;

[Dimensions(1),Dimensions(2)] = size(YValues);

NumSamples = length(XValues);

Dim = find(~(Dimensions==NumSamples));

YValues_Mean = diag(diag(mean(YValues,Dim)));
YValues_STD = diag(diag(std(YValues,[],Dim)));
YValues_STE = diag(diag(YValues_STD/sqrt(Dimensions(Dim))));

XValues=diag(diag(XValues));


Patch_IDX=~(isnan(YValues_Mean)|isnan(YValues_STE)|isnan(XValues));

this_XValues=XValues(Patch_IDX);
this_YValues_Mean=YValues_Mean(Patch_IDX);
this_YValues_STE=YValues_STE(Patch_IDX);

Patch_X=[this_XValues;flipud(this_XValues)];
Patch_Y=[this_YValues_Mean-this_YValues_STE;flipud(this_YValues_Mean+this_YValues_STE)];
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

