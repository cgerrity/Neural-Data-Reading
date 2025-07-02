function ScaledAccuracy = cgg_calcScaledAccuracyMeasure(TrueValue,...
    Prediction,ClassNames,MatchType,IsQuaddle,varargin)
%CGG_CALCSCALEDACCURACYMEASURE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
RandomChance = CheckVararginPairs('RandomChance', [], varargin{:});
else
if ~(exist('RandomChance','var'))
RandomChance=[];
end
end

if isfunction
MostCommon = CheckVararginPairs('MostCommon', [], varargin{:});
else
if ~(exist('MostCommon','var'))
MostCommon=[];
end
end

if isfunction
Stratified = CheckVararginPairs('Stratified', [], varargin{:});
else
if ~(exist('Stratified','var'))
Stratified=[];
end
end

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

if isempty(MostCommon) || isempty(RandomChance) || isempty(Stratified)
[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(...
    TrueValue,ClassNames,MatchType,IsQuaddle,'Weights',Weights);
end

% ChanceLevel = max([MostCommon,RandomChance]);
ChanceLevel = Stratified;

Accuracy = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,...
    MatchType,'Weights',Weights);

ScaledAccuracy = (Accuracy-ChanceLevel)/(1-ChanceLevel);

end

