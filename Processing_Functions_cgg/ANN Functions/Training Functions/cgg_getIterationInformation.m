function [Iteration,Epoch,Run,MaximumValidationAccuracy,...
    MinimumValidationLoss,OptimizerVariables] = ...
    cgg_getIterationInformation(SaveDir)
%CGG_GETITERATIONINFORMATION Summary of this function goes here
%   Detailed explanation goes here

IterationPathNameExt = [SaveDir filesep 'CurrentIteration.mat'];
OptimizerVariablesPathNameExt = [SaveDir filesep 'OptimizerVariables.mat'];

if isfile(IterationPathNameExt)
m_IterationInformation = matfile(IterationPathNameExt,"Writable",false);
Iteration=m_IterationInformation.Iteration;
Epoch=m_IterationInformation.Epoch;
Run=m_IterationInformation.Run;
MaximumValidationAccuracy=m_IterationInformation.MaximumValidationAccuracy;
MinimumValidationLoss=m_IterationInformation.MinimumValidationLoss;
else
Iteration=0;
Epoch=1;
Run=0;
MaximumValidationAccuracy=-Inf;
MinimumValidationLoss=Inf;
end
Run = Run+1;

if isfile(OptimizerVariablesPathNameExt)
m_OptimizerVariables = matfile(OptimizerVariablesPathNameExt,"Writable",false);
OptimizerVariables=m_OptimizerVariables.OptimizerVariables;
else
OptimizerVariables = [];
end

end

