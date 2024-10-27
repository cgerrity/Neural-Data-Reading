function P_Value = cgg_procTwoProportionZTest(Proportion1, NumSamples1, Proportion2, NumSamples2)
%CGG_PROCTWOPROPORTIONZTEST Summary of this function goes here
%   Detailed explanation goes here
    % Calculate the sample proportions
    Count1 = NumSamples1 * Proportion1;
    Count2 = NumSamples2 * Proportion2;
    
    % Calculate the pooled proportion
    ProportionPooled = (Count1 + Count2) / (NumSamples1 + NumSamples2);
    
    % Calculate the z-statistic
    z = (Proportion1 - Proportion2) / sqrt(ProportionPooled * (1 - ProportionPooled) * (1/NumSamples1 + 1/NumSamples2));
    
    % Calculate the two-tailed p-value from the z-statistic
    P_Value = 2 * (1 - normcdf(abs(z)));  % Two-tailed test

end

