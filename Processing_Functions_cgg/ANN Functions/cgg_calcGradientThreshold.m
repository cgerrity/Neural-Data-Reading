function GradientsNew = cgg_calcGradientThreshold(Gradients,GradientThreshold)
%CGG_CALCGRADIENTTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here

epsilon=0.0000001;

GradientsNew = Gradients;

GradientsValue = GradientsNew.Value;

globalL2Norm = 0;
for i = 1:numel(GradientsValue)
    globalL2Norm = globalL2Norm + sum(GradientsValue{i}(:).^2);
end
globalL2Norm = sqrt(globalL2Norm);

if globalL2Norm > GradientThreshold
    normScale = GradientThreshold / (globalL2Norm+epsilon);
    for i = 1:numel(GradientsValue)
        GradientsValue{i} = GradientsValue{i} * normScale;
    end
end

GradientsNew.Value = GradientsValue;

end

