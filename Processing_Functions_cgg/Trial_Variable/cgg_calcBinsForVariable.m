function [BinnedVariable,BinEdges] = cgg_calcBinsForVariable(VariableValues,NumBins,RangeType)
%CGG_CALCBINSFORVARIABLE Summary of this function goes here
%   Detailed explanation goes here

switch RangeType
    case 'EqualCount'
        BinPercentiles = (0:NumBins)/NumBins*100;
        BinEdges = prctile(VariableValues,BinPercentiles);
    case 'EqualValue'
        BinWidth = range(VariableValues)/NumBins;
        BinEdges = (0:NumBins)*BinWidth + min(VariableValues);
    otherwise
        BinWidth = range(VariableValues)/NumBins;
        BinEdges = (0:NumBins)*BinWidth + min(VariableValues);
end

BinEdges(1) = -Inf;
BinEdges(end) = Inf;

[BinnedVariable,~] = discretize(VariableValues,BinEdges);
BinnedVariable(isnan(VariableValues)) = 0;

end

