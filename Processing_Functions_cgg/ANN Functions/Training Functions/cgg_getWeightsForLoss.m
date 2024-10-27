function [Weights,ClassNames] = cgg_getWeightsForLoss(...
    InDataStore,WeightedLoss)
%CGG_GETWEIGHTSFORLOSS Summary of this function goes here
%   Detailed explanation goes here

[ClassNames,~,ClassPercent,~] = cgg_getClassesFromDataStore(InDataStore);

switch WeightedLoss
    case 'Inverse'
        Weights = cellfun(@(x) dlarray(diag(diag(1./(x/100))),'C'),...
            ClassPercent,'UniformOutput',false);
    otherwise
        Weights = cell(0);
end

end

