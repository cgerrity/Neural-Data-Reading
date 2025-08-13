function [Distribution] = cgg_getBaselineAccuracyDistribution(TrueValue,ClassNames,MatchType,IsQuaddle,varargin)
%CGG_GETBASELINEACCURACYDISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NumIterRand = CheckVararginPairs('NumIterRand', 10000, varargin{:});
else
if ~(exist('NumIterRand','var'))
NumIterRand=10000;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

%%

IsScaled = contains(MatchType,'Scaled');
MatchType_Calc = MatchType;
if IsScaled
        MatchType_Calc = extractAfter(MatchType,'Scaled-');
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled_');
        end
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled');
        end
end

%% Get Baseline Measures For Scaled

[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(...
    TrueValue,ClassNames,MatchType_Calc,IsQuaddle,'Weights',Weights);

%% Get Distribution

Distribution=NaN(2,NumIterRand);
parfor idx=1:NumIterRand
Prediction = TrueValue(randperm(size(TrueValue, 1)), :);
Distribution(1,idx) = cgg_calcAllPerformanceMetrics(...
    TrueValue,Prediction,ClassNames,'MatchType',MatchType,...
    'MostCommon',MostCommon,'RandomChance',RandomChance,...
    'Stratified',Stratified,varargin{:});
end
%% Random Chance

NumDimensions=length(ClassNames);
[Dim1,~]=size(TrueValue);
if Dim1==NumDimensions
    TrueValue=TrueValue';
end

[NumTrials,~]=size(TrueValue);

parfor idx=1:NumIterRand
Prediction=NaN(size(TrueValue));
for tidx=1:NumTrials
Prediction(tidx,:) = cgg_getRandomPrediction(ClassNames,IsQuaddle);
end
Distribution(2,idx) = cgg_calcAllPerformanceMetrics(...
    TrueValue,Prediction,ClassNames,'MatchType',MatchType,...
    'MostCommon',MostCommon,'RandomChance',RandomChance,...
    'Stratified',Stratified,varargin{:});
end


end

