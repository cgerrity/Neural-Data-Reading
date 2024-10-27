function PerArea_Noise = cgg_generateSyntheticNoisePerArea(NumChannels,NoiseLevel,Time,Noise_Amplitude,Noise_Spread,Noise_Center,Noise_Maximum,NoiseLevelArea,LowPassFrequency)
%CGG_GENERATESYNTHETICNOISE Summary of this function goes here
%   Detailed explanation goes here

NumSamples = length(Time);

PerArea_Noise = NaN(NumChannels,NumSamples);

for cidx = 1:NumChannels

PerArea_Noise(cidx,:) = cgg_generateSyntheticNoisePerChannel(NoiseLevel,Time,Noise_Amplitude,Noise_Spread,Noise_Center,Noise_Maximum,LowPassFrequency).*NoiseLevelArea;
end

end

