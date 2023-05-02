function trialData = AddFixationCountsToTrialData(trialData, frameData)

targetNames = {'rel1', 'rel2', 'irrel3', 'irrel4', 'other'};
nanData = nan(height(trialData),1);
fix = table(nanData,nanData,nanData,nanData,nanData,nanData,nanData,nanData,'VariableNames', ...
    {'TotalFixations', 'ObjectFixations', 'RelevantFixations', 'TargetFixations', 'DistractorFixations', 'IrrelevantFixations', 'OtherFixations', 'TargetBias'});

fprintf('\n');
reverseStr = '';
for iTrial = 1:height(trialData)
    %print percentage of processing
    percentDone = 100 * iTrial / height(trialData);
    msg = sprintf('\tAdding fixation counts to trial data, %3.1f percent finished.', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    trialInfo = trialData(iTrial,:);
    
    if ismember('TrialCounter', frameData.Properties.VariableNames)
        matchedFrameData = frameData(frameData.TrialCounter == trialInfo.TrialCounter,:);
    else
        %need to purge data from aborted trials
        tempFrameData = frameData(frameData.TrialInExperiment == trialInfo.TrialInExperiment,:);
        if ~isempty(tempFrameData)
            if ~isnumeric(frameData.TrialEpoch)
                lastItiFrame = find(ismember(tempFrameData.TrialEpoch, 'ITI'), 1, 'last');
                prevTrialEndFrame = find(~ismember(tempFrameData.TrialEpoch(1:lastItiFrame), {'ITI', 'Blink', 'Fixation', 'Baseline'}), 1, 'last');
            else
                if max(tempFrameData.TrialEpoch) < 8 || trialData.AbortCode(iTrial) > 0
                    fix.TotalFixations(iTrial) = NaN;
                    fix.ObjectFixations(iTrial) = NaN;
                    fix.RelevantFixations(iTrial) = NaN;
                    fix.TargetFixations(iTrial) = NaN;
                    fix.DistractorFixations(iTrial) = NaN;
                    fix.IrrelevantFixations(iTrial) = NaN;
                    fix.OtherFixations(iTrial) = NaN;
                    fix.TargetBias(iTrial) = NaN;
                    continue;
                end
                
                lastItiFrame = find(ismember(tempFrameData.TrialEpoch, 0), 1, 'last');
                prevTrialEndFrame = find(~ismember(tempFrameData.TrialEpoch(1:lastItiFrame), [-1, 0, 1, 2, 3]), 1, 'last');
            end
            if ~isempty(prevTrialEndFrame)
                matchedFrameData = tempFrameData(prevTrialEndFrame + 1 : end, :);
            else
                matchedFrameData = tempFrameData;
            end
        else
            fix.TotalFixations(iTrial) = NaN;
            fix.ObjectFixations(iTrial) = NaN;
            fix.RelevantFixations(iTrial) = NaN;
            fix.TargetFixations(iTrial) = NaN;
            fix.DistractorFixations(iTrial) = NaN;
            fix.IrrelevantFixations(iTrial) = NaN;
            fix.OtherFixations(iTrial) = NaN;
            fix.TargetBias(iTrial) = NaN;
            continue;
        end
    end
    %     liftTime = trialInfo.TimeofQuaddleSelected - trialInfo.TimeTouchFromLiftOfHoldKey;
    if ~isnumeric(frameData.TrialEpoch)
        if sum(contains(matchedFrameData.Properties.VariableNames, 'IsSpaceOnHold')) > 0
            liftTime = matchedFrameData.FrameStartUnity(find(strcmp(matchedFrameData.IsSpaceOnHold, 'False') & strcmp(matchedFrameData.TrialEpoch, 'SelectObject'),1));
        elseif sum(contains(trialData.Properties.VariableNames, 'TimeLiftOfHoldKeyFromStimOnset')) > 0
            liftTime = trialData.TimeLiftOfHoldKeyFromStimOnset(iTrial) + matchedFrameData.FrameStartUnity(find(strcmp(matchedFrameData.TrialEpoch, 'Baseline'),1));
        else
            fix.TotalFixations(iTrial) = NaN;
            fix.ObjectFixations(iTrial) = NaN;
            fix.RelevantFixations(iTrial) = NaN;
            fix.TargetFixations(iTrial) = NaN;
            fix.DistractorFixations(iTrial) = NaN;
            fix.IrrelevantFixations(iTrial) = NaN;
            fix.OtherFixations(iTrial) = NaN;
            fix.TargetBias(iTrial) = NaN;
            continue;
        end
        gazeFrameData = matchedFrameData(intersect(find(ismember(matchedFrameData.TrialEpoch, {'FreeGaze', 'SelectObject'})), find(matchedFrameData.FrameStartUnity < liftTime)),:);
    else
        if sum(contains(matchedFrameData.Properties.VariableNames, 'IsSpaceOnHold')) > 0
            liftTime = matchedFrameData.FrameStartUnity(find(strcmp(matchedFrameData.IsSpaceOnHold, 'False') & matchedFrameData.TrialEpoch == 5,1));
        elseif sum(contains(trialData.Properties.VariableNames, 'TimeLiftOfHoldKeyFromStimOnset')) > 0
            liftTime = trialData.TimeLiftOfHoldKeyFromStimOnset(iTrial) + matchedFrameData.FrameStartUnity(find(matchedFrameData.TrialEpoch == 3,1));
        else
            fix.TotalFixations(iTrial) = NaN;
            fix.ObjectFixations(iTrial) = NaN;
            fix.RelevantFixations(iTrial) = NaN;
            fix.TargetFixations(iTrial) = NaN;
            fix.DistractorFixations(iTrial) = NaN;
            fix.IrrelevantFixations(iTrial) = NaN;
            fix.OtherFixations(iTrial) = NaN;
            fix.TargetBias(iTrial) = NaN;
            continue;
        end
        gazeFrameData = matchedFrameData(intersect(find(ismember(matchedFrameData.TrialEpoch, [4,5])), find(matchedFrameData.FrameStartUnity < liftTime)),:);
    end
    gazeFrameData(gazeFrameData.GazeClassification ~= 3, :) = [];
    fixEvents = unique(gazeFrameData.EventDataRow);
    fixations = zeros(1,length(targetNames));
    for iFix = 1:length(fixEvents) %parse all fixations during FreeGaze and SelectObject states
        hitCounts = zeros(1, length(targetNames));
        fixHitData = gazeFrameData.ShotgunTargets(gazeFrameData.EventDataRow == fixEvents(iFix));
        for iHit = 1:length(fixHitData) %parse all frames during each fixation
            if ~isempty(fixHitData{iHit})
                hitDetails = jsondecode(fixHitData{iHit});
                hits = fields(hitDetails);
                maxProp = 0;
                for iField = 1:length(hits)
                    if hitDetails.(hits{iField}) > maxProp
                        topHit = hits{iField};
                    end
                end
                
                if sum(ismember(targetNames, topHit)) > 0
                    hitCounts(ismember(targetNames, topHit)) = hitCounts(ismember(targetNames, topHit)) + 1;
                else
                    hitCounts(5) = hitCounts(5) + 1;
                end
            else
                hitCounts(5) = hitCounts(5) + 1;
            end
        end
        fixations(hitCounts == max(hitCounts)) = fixations(hitCounts == max(hitCounts)) + 1;
    end
    fix.TotalFixations(iTrial) = sum(fixations);
    fix.ObjectFixations(iTrial) = sum(fixations(1:4));
    fix.RelevantFixations(iTrial) = sum(fixations(1:2));
    fix.TargetFixations(iTrial) = fixations(1);
    fix.DistractorFixations(iTrial) = fixations(2);
    fix.IrrelevantFixations(iTrial) = sum(fixations(3:4));
    fix.OtherFixations(iTrial) = fixations(5);
    fix.TargetBias(iTrial) = (fixations(1) - fixations(2)) / (fixations(1) + fixations(2));
end

trialData = [trialData fix];