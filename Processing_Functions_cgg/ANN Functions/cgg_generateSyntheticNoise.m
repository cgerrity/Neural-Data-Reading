function PerTrial_Noise = cgg_generateSyntheticNoise(NumAreas,NumChannels,NoiseLevel,Time,Noise_Amplitude,Noise_Spread,Noise_Center,Noise_Maximum,NoiseLevelArea,LowPassFrequency)
%CGG_GENERATESYNTHETICNOISE Summary of this function goes here
%   Detailed explanation goes here

NumSamples = length(Time);

PerTrial_Noise = NaN(NumChannels,NumSamples,NumAreas);

for aidx = 1:NumAreas
    this_NoiseLevelArea = NoiseLevelArea(aidx);
PerTrial_Noise(:,:,aidx) = cgg_generateSyntheticNoisePerArea(NumChannels,NoiseLevel,Time,Noise_Amplitude,Noise_Spread,Noise_Center,Noise_Maximum,this_NoiseLevelArea,LowPassFrequency);
end

end

