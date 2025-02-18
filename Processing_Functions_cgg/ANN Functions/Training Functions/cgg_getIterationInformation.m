function [Iteration,Epoch,Run,MaximumValidationAccuracy,...
    MinimumValidationLoss,OptimizerVariables] = ...
    cgg_getIterationInformation(SaveDir,NumEpochs)
%CGG_GETITERATIONINFORMATION Summary of this function goes here
%   Detailed explanation goes here

IterationPathNameExt = [SaveDir filesep 'CurrentIteration.mat'];
OptimizerVariablesPathNameExt = [SaveDir filesep 'OptimizerVariables.mat'];
EncoderSavePathNameExt = [SaveDir filesep 'Encoder-Current.mat'];

HasIterationParameters = isfile(IterationPathNameExt);
HasNetwork = isfile(EncoderSavePathNameExt);

% if isfile(IterationPathNameExt) && isfile(EncoderSavePathNameExt)
if HasIterationParameters
m_IterationInformation = matfile(IterationPathNameExt,"Writable",false);
Epoch=m_IterationInformation.Epoch;
Iteration=m_IterationInformation.Iteration;
Run=m_IterationInformation.Run;
MaximumValidationAccuracy=m_IterationInformation.MaximumValidationAccuracy;
MinimumValidationLoss=m_IterationInformation.MinimumValidationLoss;
IsFinished = Epoch > NumEpochs;
WantReset = ~IsFinished & ~HasNetwork;
    if WantReset
    Epoch=1;
    Iteration=0;
    Run=0;
    MaximumValidationAccuracy=-Inf;
    MinimumValidationLoss=Inf;
    end
else
Epoch=1;
Iteration=0;
Run=0;
MaximumValidationAccuracy=-Inf;
MinimumValidationLoss=Inf;
end
%%
Run = Run+1;

if isfile(OptimizerVariablesPathNameExt)
m_OptimizerVariables = matfile(OptimizerVariablesPathNameExt,"Writable",false);
OptimizerVariables=m_OptimizerVariables.OptimizerVariables;
else
OptimizerVariables = [];
end

end

