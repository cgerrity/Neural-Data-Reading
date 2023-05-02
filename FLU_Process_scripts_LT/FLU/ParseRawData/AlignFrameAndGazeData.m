function [frameData, unmatchedFrameRows] = AlignFrameAndGazeData(frameData, gazeData, eyeEvents)

newFrameData = nan(height(frameData),9);
reverseStr = '';
gazeRow = 1;
searchEnd = length(gazeData.EyetrackerTimestamp);
unmatchedFrameRows = [];
for i = 1:height(frameData)
%print percentage of processing
    percentDone = 100 * i / size(frameData,1);
    msg = sprintf('\tMatching frame gaze data, %3.1f percent finished.', percentDone); %Don't forget this semicolon
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    timestamp = frameData.EyetrackerTimeStamp(i);
    [timeDiff, gazeRow] = min(abs(gazeData.EyetrackerTimestamp - timestamp));
    if timeDiff > 10 %there should in theory always be an exact match between framedata and gazedata timestamps, but
        %due to some rounding error (???) it is sometimes off by <0.1
        %ms. No idea how that happens...
        gazeRow = [];
    end
    %         if gazeRow == 1
    %             gazeRow = find(gazeData.EyetrackerTimestamp(gazeRow:end) == timestamp,1) + gazeRow - 1;
    %         else %attempt to speed up search - generally gaze rows to match frame rows should be 4-6 rows apart, so don't need to look through whole thing
    %             gazeRow = find(gazeData.EyetrackerTimestamp(gazeRow:min(gazeRow+100,end)) == timestamp,1) + gazeRow - 1;
    %         end
    if ~isempty(gazeRow)
        switch gazeData.Classification(gazeRow)
            case 1
                eventRow = find(eyeEvents.SaccadeInfo.StartTime <= timestamp/10^6 & eyeEvents.SaccadeInfo.EndTime >= timestamp/10^6);
            case 3
                eventRow = find(eyeEvents.FixationInfo.StartTime <= timestamp/10^6 & eyeEvents.FixationInfo.EndTime >= timestamp/10^6);
            case 4
                eventRow = find(eyeEvents.SmoothPursuitInfo.StartTime <= timestamp/10^6 & eyeEvents.SmoothPursuitInfo.EndTime >= timestamp/10^6);
            otherwise
                eventRow = NaN;
        end

        if isempty(eventRow)
            eventRow = NaN;
        end

        newFrameData(i,:) = [gazeData.XMean(gazeRow), gazeData.YMean(gazeRow),...
            gazeData.XSmooth(gazeRow), gazeData.YSmooth(gazeRow),...
            gazeData.XFix(gazeRow), gazeData.YFix(gazeRow),...
            gazeData.Classification(gazeRow), gazeRow, eventRow];
    else
        unmatchedFrameRows = [unmatchedFrameRows;i]; %#ok<AGROW>
    end

end

if ~isempty(unmatchedFrameRows)
fprintf('\n\t***************************\n***************************\n***************************\nUNMATCHED FRAME ROWS\n***************************\n***************************\n***************************\n');
% subjectData.UnmatchedFrameRows = unmatchedFrameRows;
end
fprintf('\n');
frameData = horzcat(frameData, array2table(newFrameData, 'VariableNames', ...
{'GazeXMean', 'GazeYMean', 'GazeXSmooth', 'GazeYSmooth', 'GazeFixX', 'GazeFixY', 'GazeClassification', 'GazeDataRow', 'EventDataRow'}));