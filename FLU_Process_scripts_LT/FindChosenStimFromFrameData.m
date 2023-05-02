function chosenStim = FindChosenStimFromFrameData(trialCount, frameData)

frameDataSelectRow = frameData(find(frameData.TrialCounter == trialCount & strcmp(frameData.TrialEpoch, 'SelectObject'), 1, 'last'),:);
hits = fields(jsondecode(frameDataSelectRow.ShotgunCursorHits{1}));
chosenStim = hits{contains(hits,'rel')};


