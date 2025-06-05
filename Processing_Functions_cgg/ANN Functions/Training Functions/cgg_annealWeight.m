function Weight = cgg_annealWeight(Epoch,InitialWeight,...
    WeightDelayEpoch,WeightEpochRamp)
%CGG_ANNEALWEIGHT Summary of this function goes here
%   Detailed explanation goes here

if isnan(WeightEpochRamp)
    Weight = InitialWeight;
elseif Epoch <= WeightDelayEpoch
    Weight = 0;
elseif Epoch <= WeightEpochRamp + WeightDelayEpoch
    % Obtain weight ramp from 0 to initial
    Weight = (Epoch - 1 - WeightDelayEpoch) .* (InitialWeight/WeightEpochRamp);
else
    Weight = InitialWeight;
end

end

