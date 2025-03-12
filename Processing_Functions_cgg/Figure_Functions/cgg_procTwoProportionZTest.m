function [P_Value,Z_Value] = cgg_procTwoProportionZTest(Proportion1, NumSamples1, Proportion2, NumSamples2,varargin)
%CGG_PROCTWOPROPORTIONZTEST Summary of this function goes here
%   Detailed explanation goes here
    % Calculate the sample proportions

isfunction=exist('varargin','var');

if isfunction
IsDependent = CheckVararginPairs('IsDependent', false, varargin{:});
else
if ~(exist('IsDependent','var'))
IsDependent=false;
end
end
    Count1 = NumSamples1 * Proportion1;
    Count2 = NumSamples2 * Proportion2;
    
    % Calculate the pooled proportion
    if ~IsDependent
        ProportionPooled = (Count1 + Count2) / (NumSamples1 + NumSamples2);
        % Calculate Sample Size
        if NumSamples1 == 0 && NumSamples2 == 0
            SampleSize = 0;
        elseif NumSamples1 == 0
            SampleSize = (1/NumSamples2);
        elseif NumSamples2 == 0
            SampleSize = (1/NumSamples1);
        else
            SampleSize = (1/NumSamples1 + 1/NumSamples2);
        end
    else
        ProportionPooled = (Count1 + Count2) / (NumSamples1);
        SampleSize = 1/NumSamples1;
    end

    
    % Calculate the z-statistic
    Z_Value = (Proportion1 - Proportion2) / sqrt(ProportionPooled * (1 - ProportionPooled) * SampleSize);
    
    % Calculate the two-tailed p-value from the z-statistic
    P_Value = 2 * (1 - normcdf(abs(Z_Value)));  % Two-tailed test

end

