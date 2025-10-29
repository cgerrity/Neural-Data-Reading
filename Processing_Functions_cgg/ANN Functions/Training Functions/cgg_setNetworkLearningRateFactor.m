function InputNet = cgg_setNetworkLearningRateFactor(InputNet,Factor)
%CGG_SETNETWORKLEARNINGRATEFACTOR Summary of this function goes here
%   Detailed explanation goes here


LayerNames = InputNet.Learnables.Layer;
ParameterNames = InputNet.Learnables.Parameter;

if length(Factor) < length(LayerNames)
    Factor = repmat(Factor,length(LayerNames),1);
end

for lidx = 1:length(LayerNames)
InputNet = setLearnRateFactor(InputNet,LayerNames(lidx),ParameterNames(lidx),Factor(lidx));
end
end

