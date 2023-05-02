function trialData = AddLiftTimeToTrialData(trialData,frameData)

TimeLiftOfHoldKeyFromStimOnset = nan(height(trialData),1);

for i = 1:height(trialData)
   frameTrialData = frameData(frameData.TrialInExperiment == trialData.TrialInExperiment(i),:);
   appearFrame = find(frameTrialData.TrialEpoch == 3,1);
   liftFrame = find(strcmp(frameTrialData.IsSpaceOnHold, 'False') & frameTrialData.TrialEpoch == 5, 1);
   if ~isempty(appearFrame) && ~isempty(liftFrame)
       TimeLiftOfHoldKeyFromStimOnset(i) = frameTrialData.FrameStartUnity(liftFrame) - frameTrialData.FrameStartUnity(appearFrame);
   end
end

if ~contains(trialData.Properties.VariableNames, 'TimeLiftOfHoldKeyFromStimOnset')
    trialData = addvars(trialData, TimeLiftOfHoldKeyFromStimOnset, 'Before', 'TimeTouchFromLiftOfHoldKey');
else
    trialData.TimeLiftOfHoldKeyFromStimOnset = TimeLiftOfHoldKeyFromStimOnset;
end
    