function PredictionErrorCategory = ...
    cgg_getPredictionErrorCategory(PredictionError,Dimensionality,RangeType)
%CGG_GETPREDICTIONERRORCATEGORY Summary of this function goes here
%   Detailed explanation goes here

PredictionErrorSign = PredictionError > 0;

switch RangeType
    case 'EqualCount'
        switch Dimensionality
            case 1
                PredictionErrorRanges_Positive = [-Inf,0.000865,0.015607,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.059915,-0.067543,-Inf];
            case 2
                PredictionErrorRanges_Positive = [-Inf,0.258750,0.302514,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.063991,-0.191213,-Inf];
            case 3
                PredictionErrorRanges_Positive = [-Inf,0.514534,0.565379,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.087289,-0.191945,-Inf];
            otherwise
                PredictionErrorRanges_Positive = [-Inf,0.260774,0.514022,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.072830,-0.187548,-Inf];
        end
    case 'EqualValue'
        switch Dimensionality
            case 1
                PredictionErrorRanges_Positive = [-Inf,0.085751,0.171471,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.036183,-0.072367,-Inf];
            case 2
                PredictionErrorRanges_Positive = [-Inf,0.303858,0.409120,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.096950,-0.192038,-Inf];
            case 3
                PredictionErrorRanges_Positive = [-Inf,0.493022,0.632298,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.132188,-0.264377,-Inf];
            otherwise
                PredictionErrorRanges_Positive = [-Inf,0.257212,0.514393,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.132188,-0.264377,-Inf];
        end
    otherwise
        switch Dimensionality
            case 1
                PredictionErrorRanges_Positive = [-Inf,0.085751,0.171471,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.036183,-0.072367,-Inf];
            case 2
                PredictionErrorRanges_Positive = [-Inf,0.303858,0.409120,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.096950,-0.192038,-Inf];
            case 3
                PredictionErrorRanges_Positive = [-Inf,0.493022,0.632298,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.132188,-0.264377,-Inf];
            otherwise
                PredictionErrorRanges_Positive = [-Inf,0.257212,0.514393,Inf];
                PredictionErrorRanges_Negative = [Inf,-0.132188,-0.264377,-Inf];
        end
end

if PredictionErrorSign
PredictionErrorRanges = PredictionErrorRanges_Positive;
else
PredictionErrorRanges = -PredictionErrorRanges_Negative;
PredictionError = abs(PredictionError);
end

[PredictionErrorCategory,~] = discretize(PredictionError,PredictionErrorRanges);
PredictionErrorCategory(isnan(PredictionError)) = 0;
end

