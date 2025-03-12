function [P_Value,Z_Value] = cgg_procDifferenceOfDifferencesProportionTest(Proportion_Positive_1,Proportion_Negative_1,Proportion_Positive_2,Proportion_Negative_2,NumSamples_1,NumSamples_2)
%CGG_PROCFOURPROPORTIONZTEST Summary of this function goes here
%   Detailed explanation goes here
Proportion_Difference_1 = Proportion_Positive_1 - Proportion_Negative_1;
Proportion_Difference_2 = Proportion_Positive_2 - Proportion_Negative_2;

STE_Overall = sqrt((Proportion_Positive_1 * (1 - Proportion_Positive_1) + ...
    Proportion_Negative_1 * (1 - Proportion_Negative_1)) / NumSamples_1 + ...
    (Proportion_Positive_2 * (1 - Proportion_Positive_2) + ...
    Proportion_Negative_2 * (1 - Proportion_Negative_2)) / NumSamples_2);

Z_Value = (Proportion_Difference_1 - Proportion_Difference_2) / STE_Overall;

P_Value = 2 * (1 - normcdf(abs(Z_Value)));  % Two-tailed test
end

