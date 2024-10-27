function PerformanceMetric = cgg_calcAllPerformanceMetrics(...
    TrueValue,Prediction,ClassNames,varargin)
%CGG_CALCALLPERFORMANCEMETRICS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'macroRecall', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='macroRecall';
end
end
%%

IsScaled = contains(MatchType,'Scaled');
if IsScaled
        MatchType_Calc = extractAfter(MatchType,'Scaled-');
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled_');
        end
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled');
        end
end

%%

if IsScaled
    PerformanceMetric = cgg_calcScaledAccuracyMeasure(TrueValue,...
        Prediction,ClassNames,MatchType_Calc,IsQuaddle,varargin{:});
else
    PerformanceMetric = cgg_calcAllAccuracyTypes(TrueValue,Prediction,...
        ClassNames,MatchType);
end

end

