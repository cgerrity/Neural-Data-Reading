function [y,tOut] = cgg_siganaRectify(x,tIn)
% Remove the DC value of a signal by subtracting its mean
   y = abs(x);
   tOut = tIn;
end