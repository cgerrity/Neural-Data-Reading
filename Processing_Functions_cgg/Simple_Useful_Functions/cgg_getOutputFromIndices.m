function Y = cgg_getOutputFromIndices(func,X,Indices,NumOutputs)
%CGG_GETOUTPUTFROMINDICES Summary of this function goes here
%   Detailed explanation goes here
Outputs = cell(NumOutputs,1);

[Outputs{:}] = func(X);
Y = Outputs{Indices};
end

