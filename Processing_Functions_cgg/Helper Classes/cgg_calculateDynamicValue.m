function CurrentValue = cgg_calculateDynamicValue(Value, EpochPoints, MagnitudePoints, Epoch)
% cgg_calculateDynamicValue Computes the current value based on an epoch schedule.
%
% Inputs:
%   Value          - Scalar base value for this component
%   EpochPoints     - Vector of any length specifying epochs [e1, e2, ..., en]
%   MagnitudePoints - Vector matching epochPoints size [m1, m2, ..., mn]
%   Epoch                - Scalar representing the current epoch
%
% Output:
%   CurrentValue        - Scalar calculated value
    
    if Epoch <= EpochPoints(1)
        % At or before the first scheduled epoch point
        CurrentValue = Value * MagnitudePoints(1);
    elseif Epoch > EpochPoints(end)
        % After the last scheduled epoch point
        CurrentValue = Value * MagnitudePoints(end);
    else
        % Find the segment where the epoch falls.
        % We look for the last point that is strictly less than the current epoch.
        idx = find(EpochPoints < Epoch, 1, 'last');
        
        % Determine min/max value for the current segment
        MinWeight = Value * MagnitudePoints(idx);
        MaxWeight = Value * MagnitudePoints(idx+1);
        
        % Set up parameters for the anneal function for this specific segment
        WeightDelayEpoch = EpochPoints(idx);
        WeightEpochRamp = EpochPoints(idx+1) - EpochPoints(idx);
        TargetDiff = MaxWeight - MinWeight;
        
        % Calculate ramp value using the provided function
        RampValue = cgg_annealWeight(Epoch, TargetDiff, WeightDelayEpoch, WeightEpochRamp);
        CurrentValue = MinWeight + RampValue;
    end
end
