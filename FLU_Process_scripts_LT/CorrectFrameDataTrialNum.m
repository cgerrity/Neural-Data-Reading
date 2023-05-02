function frameData = CorrectFrameDataTrialNum(frameData)

if min(frameData.TrialInExperiment) == 2
    frameData.TrialInExperiment = frameData.TrialInExperiment -1;
end

if min(frameData.TrialInBlock) == 2
    frameData.TrialInBlock = frameData.TrialInBlock - 1;
end