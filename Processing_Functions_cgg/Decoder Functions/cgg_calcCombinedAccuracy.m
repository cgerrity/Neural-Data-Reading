function [Accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames,varargin)
%CGG_CALCCOMBINEDACCURACY Summary of this function goes here
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

Accuracy=LabelMetrics.MacroTotalAccuracy;

end

