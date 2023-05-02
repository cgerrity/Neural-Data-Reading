function s = movestd(varargin)
% v = movestd(x,winlen)
% v = movestd(x,[nr,nf])
%
% calculates the moving standard deviation in input signal x over a window of length
% w. Can specify number of leading or lagging samples with [nr,nf]
%
% From: http://matlabtricks.com/post-20/

s = movevar(varargin{:}) .^ 0.5;