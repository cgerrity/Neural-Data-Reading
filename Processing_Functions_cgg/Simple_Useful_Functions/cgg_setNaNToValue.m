function Y = cgg_setNaNToValue(X,Value)
%CGG_SETNANTOVALUE Summary of this function goes here
%   Detailed explanation goes here
Y = X;
Y(isnan(Y)) = Value;
end

