function [Accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames)
%CGG_CALCCOMBINEDACCURACY Summary of this function goes here
%   Detailed explanation goes here

[FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames);
LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);

Accuracy=LabelMetrics.MacroTotalAccuracy;

end

