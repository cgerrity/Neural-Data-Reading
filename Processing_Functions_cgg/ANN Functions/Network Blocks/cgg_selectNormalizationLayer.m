function NormalizationLayer = cgg_selectNormalizationLayer(WantNormalization,Name_Normalization)
%CGG_SELECTNORMALIZATIONLAYER Summary of this function goes here
%   Detailed explanation goes here
switch WantNormalization
    case 'Batch'
        NormalizationLayer = batchNormalizationLayer('Name',Name_Normalization);
    case 'Instance'
        NormalizationLayer = instanceNormalizationLayer('Name',Name_Normalization);
    case 'Group'
        NormalizationLayer = groupNormalizationLayer(2,'Name',Name_Normalization);
    case 'Layer'
        NormalizationLayer = layerNormalizationLayer('Name',Name_Normalization);
    case true
        NormalizationLayer = layerNormalizationLayer('Name',Name_Normalization);
    otherwise
        NormalizationLayer = [];
end

end

