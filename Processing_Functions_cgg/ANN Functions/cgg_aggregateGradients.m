function gradients = cgg_aggregateGradients(gradients,factor,priorgradient)

gradients = extractdata(gradients);
gradients = factor*gradients;
if ~isnan(priorgradient)
gradients = gradients + priorgradient;
end

end