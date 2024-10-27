function PerChannel_Noise = cgg_generateSyntheticNoisePerChannel(NoiseLevel,Time,Noise_Amplitude,Noise_Spread,Noise_Center,Noise_Maximum,LowPassFrequency)
%CGG_GENERATESYNTHETICNOISE Summary of this function goes here
%   Detailed explanation goes here


NumSamples = length(Time);
SamplingRate = 1/mean(diff(Time));

Logistic_Function = @(x,a,b,c) a./(1+exp(-b*(x-c)));

Noise_Maximum = max([Noise_Maximum,Noise_Amplitude]);

Noise_Profile = Noise_Maximum-Logistic_Function(Time,Noise_Amplitude,Noise_Spread,Noise_Center);

PerChannel_Noise = randn(1,NumSamples)*NoiseLevel.*Noise_Profile;

PerChannel_Noise = lowpass(PerChannel_Noise,LowPassFrequency,SamplingRate,'Steepness',0.99);

end

