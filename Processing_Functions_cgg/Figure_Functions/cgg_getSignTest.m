function ConfidenceRange = cgg_getSignTest(Samples,varargin)
%CGG_GETSIGNTEST Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NumIter = CheckVararginPairs('NumIter', 1000, varargin{:});
else
if ~(exist('NumIter','var'))
NumIter=1000;
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end



Sign_Bootstrap = zeros(NumIter, 1);

parfor i = 1:NumIter
    this_Sign = sign(randn(size(Samples)));
    Bootstrap = Samples .* this_Sign;
    Sign_Bootstrap(i) = mean(Bootstrap,"all","omitmissing");
end

SignificancePercentile = [SignificanceValue/2,1-SignificanceValue/2]*100;

ConfidenceRange = prctile(Sign_Bootstrap, SignificancePercentile);



end

