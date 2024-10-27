function OptimizerVariables = cgg_initializeOptimizerVariables(Optimizer)
%CGG_INITIALIZEOPTIMIZERVARIABLES Summary of this function goes here
%   Detailed explanation goes here

OptimizerVariables = struct();

switch Optimizer
    case 'SGD'
        OptimizerVariables.Velocity = [];
        OptimizerVariables.Momentum = 0.9;
    case 'ADAM'
        OptimizerVariables.AverageGrad = [];
        OptimizerVariables.AverageSqGrad = [];
        OptimizerVariables.Iteration = 1;
    otherwise
end




end

