
clc; clear; close all;
%%


InitialLearningRate = 1;
LearningRateDecay = 0.9;
LearningRateEpochDrop = 10;
Epoch = 1:100;
LearningRateEpochRamp = 15;

LearningRate = NaN(size(Epoch));

for eidx = 1:length(Epoch)
LearningRate(eidx) = cgg_getLearningRate(Epoch(eidx),InitialLearningRate,LearningRateDecay,LearningRateEpochDrop,LearningRateEpochRamp);
end



plot(Epoch,LearningRate);

ylim([0,InitialLearningRate*1.5])
