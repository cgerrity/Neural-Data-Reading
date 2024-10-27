function cgg_saveIterationInformation(Iteration,Epoch,Run,...
    MaximumValidationAccuracy,MinimumValidationLoss,...
    IterationSaveFrequency,SaveDir,Timer,OptimizerVariables,IsOptimal)
%CGG_SAVEITERATIONINFORMATION Summary of this function goes here
%   Detailed explanation goes here

if ~(mod(Iteration,IterationSaveFrequency)==1 || IsOptimal)
    return
end

IterationVariablesName = {'Iteration','Epoch','Run','MaximumValidationAccuracy','MinimumValidationLoss','Time'};
OptimizerVariablesName = {'OptimizerVariables'};

OptimalIterationPathNameExt = [SaveDir filesep 'OptimalIteration.mat'];
CurrentIterationPathNameExt = [SaveDir filesep 'CurrentIteration.mat'];

OptimizerVariablesPathNameExt = [SaveDir filesep 'OptimizerVariables.mat'];

IterationVariables = {Iteration,Epoch,Run,MaximumValidationAccuracy,MinimumValidationLoss,toc(Timer)};
cgg_saveVariableUsingMatfile(IterationVariables,IterationVariablesName,CurrentIterationPathNameExt);
if IsOptimal
cgg_saveVariableUsingMatfile(IterationVariables,IterationVariablesName,OptimalIterationPathNameExt);
end

% OptimizerVariables = {OptimizerVariables};
% cgg_saveVariableUsingMatfile(OptimizerVariables,OptimizerVariablesName,OptimizerVariablesPathNameExt);

end

