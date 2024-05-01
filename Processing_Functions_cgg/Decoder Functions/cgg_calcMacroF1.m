function [F1] = cgg_calcMacroF1(TrueValue,Prediction,ClassNames)
%CGG_CALCMACROF1 Summary of this function goes here
%   Detailed explanation goes here

[FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames);
LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);

F1=LabelMetrics.MacroF1;
end

