function gradients = aggregateGradients(gradients,factor)

gradients = extractdata(gradients);
gradients = spmdPlus(factor*gradients);

end