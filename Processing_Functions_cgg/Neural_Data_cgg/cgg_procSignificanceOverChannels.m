function [Significance] = cgg_procSignificanceOverChannels(InP_Value,Significance_Value,Minimum_Length)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Minimum_Length_tmp=Minimum_Length;
Minimum_Length_tmp=max(Minimum_Length_tmp,1);

Significance_tmp=InP_Value<Significance_Value;
Structuring_Element = true(1,Minimum_Length_tmp);
Significance = imopen(Significance_tmp,Structuring_Element);

end

