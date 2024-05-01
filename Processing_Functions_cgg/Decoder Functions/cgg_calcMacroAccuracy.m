function [Accuracy] = cgg_calcMacroAccuracy(TrueValue,Prediction,ClassNames)
%CGG_CALCMACROACCURACY Summary of this function goes here
%   Detailed explanation goes here

[FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames);
LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);

Accuracy=LabelMetrics.MacroAccuracy;

end

