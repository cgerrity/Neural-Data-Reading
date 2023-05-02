function varargout = movevar(x,winlen,includeCurrentPoint,omitNan)
% v = movevar(x,winlen)
% v = movevar(x,[nr,nf])
% v = movevar(x,[nr,nf],includeCurrentPoint)
% v = movevar(x,[nr,nf],includeCurrentPoint,omitNan)
% [v,n] = movevar(...)
%
% calculates the moving variance in input signal x over a window of length
% w. Can specify number of leading or lagging samples with [nr,nf]
%
% inspiration: http://matlabtricks.com/post-20/
% Ben Voloh, 2018

if nargin < 3
    includeCurrentPoint = 1;
end
if nargin < 4
    omitNan = 0;
end

%create the window
if numel(winlen)==1 
   win = ones(1,winlen);
else %defined lead and lag
    st = ones(1,winlen(1));
    fn = ones(1,winlen(2));
    
    if includeCurrentPoint
        c = 1;
    else
        c = 0;
    end
    
    %pad if windows arent symmetrical
    % - nb: convolution requirs flipping
    d = diff(winlen);
    if d < 0 %left flank is greater
        win = [zeros(1,abs(d)),fn,c,st];
    elseif d > 0 %right flank is greater
        win = [fn,c,st,zeros(1,abs(d))];
    end
end

%variables for var calculation
N = length(x);              % length of the signal
if omitNan
    n = nanconv(ones(size(x2)), win, 'nanout');
    s = nanconv(x2, win, 'nanout');
    q = x2 .^ 2;
    q = nanconv(q, win, 'nanout');
else
    n = conv(ones(size(x2)), win, 'same');
    s = conv(x2, win, 'same');
    q = x2 .^ 2;
    q = conv(q, win, 'same');
end

%adjust based on nans
if omitNan
    nc = conv(double(nans),win,'same');
    n = n - nc;
    
    sc = conv(nanVec,win,'same');
    s = s - sc;
    
    qc = conv(nanVec.^2,win,'same');
    q = q - qc;
end

% calculate output values
v = (q - s .^ 2 ./ n) ./ (n - 1);

%avoid inf
v(n==1) = 0;

%output
varargout{1} = v;
if nargout>1
    varargout{2} = n;
end
