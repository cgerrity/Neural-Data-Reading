function [MicroAccuracy] = cgg_calcMicroAccuracy(TrueValue,Prediction,ClassNames,varargin)
%CGG_CALCMICROACCURACY Summary of this function goes here
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

MicroAccuracy=LabelMetrics.MicroAccuracy;
end



