function cgg_saveIterationInformation(Iteration,Epoch,Run,...
    MaximumValidationAccuracy,AggregateValidationAccuracy,...
    MinimumValidationLoss,...
    IterationSaveFrequency,SaveDir,Timer,OptimizerVariables,IsOptimal)
%CGG_SAVEITERATIONINFORMATION Summary of this function goes here
%   Detailed explanation goes here

if ~(mod(Iteration,IterationSaveFrequency)==1 || IsOptimal || IterationSaveFrequency == 1)
    return
end

IterationVariablesName = {'Iteration','Epoch','Run','MaximumValidationAccuracy','AggregateValidationAccuracy','MinimumValidationLoss','Time'};
OptimizerVariablesName = {'OptimizerVariables'};

OptimalIterationPathNameExt = [SaveDir filesep 'OptimalIteration.mat'];
CurrentIterationPathNameExt = [SaveDir filesep 'CurrentIteration.mat'];

OptimizerVariablesPathNameExt = [SaveDir filesep 'OptimizerVariables.mat'];

IterationVariables = {Iteration,Epoch,Run,MaximumValidationAccuracy,AggregateValidationAccuracy,MinimumValidationLoss,toc(Timer)};
cgg_saveVariableUsingMatfile(IterationVariables,IterationVariablesName,CurrentIterationPathNameExt);
if IsOptimal
cgg_saveVariableUsingMatfile(IterationVariables,IterationVariablesName,OptimalIterationPathNameExt);
end

% OptimizerVariables = {OptimizerVariables};
% cgg_saveVariableUsingMatfile(OptimizerVariables,OptimizerVariablesName,OptimizerVariablesPathNameExt);

end

