function [F1] = cgg_calcMacroF1(TrueValue,Prediction,ClassNames,varargin)
%CGG_CALCMACROF1 Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

[FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames,'Weights',Weights);
LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);

F1=LabelMetrics.MacroF1;
end

