function gradients = aggregateGradients(gradients,factor)

gradients = cgg_extractData(gradients);
gradients = spmdPlus(factor*gradients);

end