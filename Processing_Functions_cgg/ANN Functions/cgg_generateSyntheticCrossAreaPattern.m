function [OutPattern,Signal_Pattern] = cgg_generateSyntheticCrossAreaPattern(NumChannels,NumAreas,Time,PatternFrequency,PatternSTD,varargin)
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

NumSamples = length(Time);

OutPattern = NaN(NumChannels,NumSamples,NumAreas);
Signal_Pattern = NaN(NumChannels,NumSamples,NumAreas);

for aidx = 1:NumAreas

    if isnan(Pattern)
        this_Pattern = NaN;
    else
        this_Pattern = Pattern(:,:,aidx);
    end

[OutPattern(:,:,aidx),Signal_Pattern(:,:,aidx)] = cgg_generateSyntheticCrossChannelPattern(NumChannels,Time,PatternFrequency,PatternSTD,'Pattern',this_Pattern);

end

%%
end

