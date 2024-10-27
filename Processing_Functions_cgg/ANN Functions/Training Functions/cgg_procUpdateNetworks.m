function [UpdateNet,OptimizerVariables] = cgg_procUpdateNetworks(...
    InputNet,Gradients,LearningRate,Optimizer,OptimizerVariables)
%CGG_PROCUPDATENETWORKS Summary of this function goes here
%   Detailed explanation goes here


switch Optimizer
    case 'SGD'
    % Update the network parameters using the SGDM optimizer.
    Velocity  = OptimizerVariables.Velocity;
    Momentum  = OptimizerVariables.Momentum;
    [UpdateNet,Velocity] = sgdmupdate(InputNet,Gradients,Velocity,LearningRate,Momentum);
    OptimizerVariables.Velocity = Velocity;
    case 'ADAM'
    % Update the network parameters using the ADAM optimizer.
    AverageGrad  = OptimizerVariables.AverageGrad;
    AverageSqGrad  = OptimizerVariables.AverageSqGrad;
    Iteration = OptimizerVariables.Iteration;
    [UpdateNet,AverageGrad,AverageSqGrad] = adamupdate(InputNet,Gradients,AverageGrad,AverageSqGrad,Iteration,LearningRate);
    OptimizerVariables.AverageGrad = AverageGrad;
    OptimizerVariables.AverageSqGrad = AverageSqGrad;
    OptimizerVariables.Iteration = Iteration + 1;
    otherwise
end


end

