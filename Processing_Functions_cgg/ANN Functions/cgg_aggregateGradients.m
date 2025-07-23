function gradients = cgg_aggregateGradients(gradients,priorgradient,factor)

% gradients = cgg_extractData(gradients);
gradients = factor.*gradients;
if ~(all(isnan(priorgradient),'all') || isempty(priorgradient))
gradients = gradients + priorgradient;
end

end