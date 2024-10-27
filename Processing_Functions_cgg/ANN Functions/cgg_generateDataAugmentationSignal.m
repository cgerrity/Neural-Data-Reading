function DataAugmentationSignal = cgg_generateDataAugmentationSignal(...
    NumChannels,NumSamples,NumProbes,STDChannelOffset,STDWhiteNoise,...
    STDRandomWalk)
%CGG_GENERATEDATAAUGMENTATIONSIGNAL Summary of this function goes here
%   Detailed explanation goes here

% Wilson et al. 2023

WantLowPass = true;

ChannelOffset = 0;
WhiteNoise = 0;
RandomWalk = 0;

if ~isnan(STDChannelOffset)
ChannelOffset = randn(NumChannels,1,NumProbes)*STDChannelOffset;
ChannelOffset = repmat(ChannelOffset,[1,NumSamples,1]);
end

if ~isnan(STDWhiteNoise)
WhiteNoise = randn(NumChannels,NumSamples,NumProbes)*STDWhiteNoise;
end

if ~isnan(STDRandomWalk)
RandomWalk = randn(NumChannels,NumSamples,NumProbes)*STDRandomWalk;
RandomWalk = cumsum(RandomWalk,2);
end

DataAugmentationSignal = ChannelOffset + WhiteNoise + RandomWalk;

if numel(DataAugmentationSignal) > 1 && WantLowPass
SmoothWindow = 50;
% tic
DataAugmentationSignal = smoothdata(DataAugmentationSignal,2,"gaussian",SmoothWindow);
% disp({'Smoothed',toc});
% 
% SamplingRate = 1000;
% LowPassFrequency = 10;
% Steepness = 0.99;
% tic
% parfor aidx = 1:NumProbes
% DataAugmentationSignal(:,:,aidx) = (lowpass(DataAugmentationSignal(:,:,aidx)',LowPassFrequency,SamplingRate,'Steepness',Steepness))';
% end
% disp({'Parallel Area',toc});
% DataAugmentationFilter = designfilt("lowpassfir", ...
%     PassbandFrequency=10,StopbandFrequency=20, ...
%     PassbandRipple=1,StopbandAttenuation=60, ...
%     DesignMethod="equiripple",SampleRate=1000);
% 
% DataAugmentationSignal = permute(DataAugmentationSignal,[2 1 3]);
% 
% DataAugmentationSignal = filtfilt(DataAugmentationFilter,DataAugmentationSignal);
% 
% DataAugmentationSignal = permute(DataAugmentationSignal,[2 1 3]);
%%
% sel_Channel = 2; sel_Area = 1; plot(Time,DataAugmentationSignal(sel_Channel,:,sel_Area)); hold on; plot(Time,DataAugmentationSignal_TMP(sel_Channel,:,sel_Area),'LineWidth',2); hold off

end

end

