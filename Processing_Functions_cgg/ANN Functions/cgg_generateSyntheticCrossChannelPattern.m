function [OutPattern,Signal_Pattern] = cgg_generateSyntheticCrossChannelPattern(NumChannels,Time,PatternFrequency,PatternSTD,varargin)
%CGG_GENERATESYNTHETICCROSSCHANNELPATTERN Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Pattern = CheckVararginPairs('Pattern', NaN, varargin{:});
else
if ~(exist('Pattern','var'))
Pattern=NaN;
end
end

GaussianFilter = pdf('Normal',Time,0,PatternSTD);
GaussianFilter = GaussianFilter./sum(GaussianFilter);
GaussianFilter_Max = max(GaussianFilter);

NumSamples = length(Time);

OutPattern = NaN(NumChannels,NumSamples);
Signal_Pattern = NaN(NumChannels,NumSamples);

for cidx = 1:NumChannels

    if isnan(Pattern)
        this_Pattern = random('Poisson',PatternFrequency,1,NumSamples);
        this_Pattern = this_Pattern.*(((randi(2,1,NumSamples)-1)*2)-1);
    else
        this_Pattern = Pattern(cidx,:);
    end

    this_Signal_Pattern = conv(this_Pattern,GaussianFilter,'same');

    OutPattern(cidx,:) = this_Pattern;
    Signal_Pattern(cidx,:) = this_Signal_Pattern./GaussianFilter_Max;

end

%%
end

