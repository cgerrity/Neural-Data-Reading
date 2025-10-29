function Factor = cgg_getNetworkLearningRateFactor(InputNet)
%CGG_GETNETWORKLEARNINGRATEFACTOR Summary of this function goes here
%   Detailed explanation goes here

LayerNames = InputNet.Learnables.Layer;
ParameterNames = InputNet.Learnables.Parameter;

Factor = NaN(1,length(LayerNames));

for lidx = 1:length(LayerNames)
Factor(lidx) = getLearnRateFactor(InputNet,LayerNames(lidx),ParameterNames(lidx));
end

Factor(isnan(Factor)) = [];
Factor = mean(Factor,"all");

end

