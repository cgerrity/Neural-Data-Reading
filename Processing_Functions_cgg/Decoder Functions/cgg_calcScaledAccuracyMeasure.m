function ScaledAccuracy = cgg_calcScaledAccuracyMeasure(TrueValue,...
    Prediction,ClassNames,MatchType,IsQuaddle,varargin)
%CGG_CALCSCALEDACCURACYMEASURE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
RandomChance = CheckVararginPairs('RandomChance', '', varargin{:});
else
if ~(exist('RandomChance','var'))
RandomChance='';
end
end

if isfunction
MostCommon = CheckVararginPairs('MostCommon', '', varargin{:});
else
if ~(exist('MostCommon','var'))
MostCommon='';
end
end

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

if isempty(MostCommon) && isempty(RandomChance)
[MostCommon,RandomChance] = cgg_getBaselineAccuracyMeasures(TrueValue,...
    ClassNames,MatchType,IsQuaddle,'Weights',Weights);
end

ChanceLevel = max([MostCommon,RandomChance]);

Accuracy = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,...
    MatchType,'Weights',Weights);

ScaledAccuracy = (Accuracy-ChanceLevel)/(1-ChanceLevel);

end

