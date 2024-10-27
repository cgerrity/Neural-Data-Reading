function LearningRate = cgg_getLearningRate(Epoch,...
    InitialLearningRate,LearningRateDecay,LearningRateEpochDrop,...
    LearningRateEpochRamp)
%CGG_GETLEARNINGRATE Summary of this function goes here
%   Detailed explanation goes here


if Epoch <= LearningRateEpochRamp

% Obtain learning rate ramp from 0 to initial
    LearningRate = (Epoch - 1) .* (InitialLearningRate/LearningRateEpochRamp);
else

% Obtain learning rate with step decay
    LearningRate = InitialLearningRate .* (LearningRateDecay).^floor(...
            (Epoch - 1 - LearningRateEpochRamp) ./ LearningRateEpochDrop);
end

end

