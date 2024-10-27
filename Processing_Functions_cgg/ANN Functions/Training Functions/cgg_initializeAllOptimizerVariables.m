function OptimizerVariables = cgg_initializeAllOptimizerVariables(...
    Optimizer,OptimizerVariables)
%CGG_INITIALIZEALLOPTIMIZERVARIABLES Summary of this function goes here
%   Detailed explanation goes here

if isstruct(OptimizerVariables)
OptimizerVariables = struct();
end

if ~isfield(OptimizerVariables,'Encoder')
OptimizerVariables.Encoder = cgg_initializeOptimizerVariables(Optimizer);
end
if ~isfield(OptimizerVariables,'Decoder')
OptimizerVariables.Decoder = cgg_initializeOptimizerVariables(Optimizer);
end
if ~isfield(OptimizerVariables,'Classifier')
OptimizerVariables.Classifier = cgg_initializeOptimizerVariables(Optimizer);
end


end

