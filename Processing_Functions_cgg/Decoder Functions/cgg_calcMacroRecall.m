function [MacroRecall] = cgg_calcMacroRecall(TrueValue,Prediction,ClassNames)
%CGG_CALCMACROF1 Summary of this function goes here
%   Detailed explanation goes here

[FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames);
LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);

MacroRecall=LabelMetrics.MacroRecall;
end

