function MonkeyGamesTimeAlignment(subjectData)

%% Constants and housekeeping
frameRate = 60;
expectedFrameDuration = 1000/frameRate;
leftSequenceString = '01';
rightSequenceEarlyString = '10';
rightSequenceLateString = ['000' '001' '010' '011' '100' '101' '110' '111']; 
timingTestBookendCodes = [50,51];

expectedFrameDetailsL = FindExpectedFrameDetails(leftSequenceString);
expectedFrameDetailsREarly = FindExpectedFrameDetails(rightSequenceEarlyString);
expectedFrameDetailsRLate = FindExpectedFrameDetails(rightSequenceLateString);

%na_joyAndPhoto = subjectData.SerialData.JoyAndPhotoDetails;
na_EventCodeDetails = subjectData.SerialData.EventCodeDetails;
frameData = subjectData.FrameData;

%% Get flip timing

%re-threshold photodiode data & get flip timing
%[leftThresholds, na_PanelFlipsL] = ThresholdPhotoDiodeData(na_joyAndPhoto{:,{'ArduinoTimestamp', 'PhotoL'}}, 3000, expectedFrameDuration);
%[rightThresholds, na_PanelFlipsR] = ThresholdPhotoDiodeData(na_joyAndPhoto{:,{'ArduinoTimestamp', 'PhotoR'}}, 3000, expectedFrameDuration);
%na_joyAndPhoto.ThresholdL = leftThresholds(:,1);
%na_joyAndPhoto.PhotoLStatus = leftThresholds(:,2);
%na_joyAndPhoto.ThresholdR = rightThresholds(:,1);
%na_joyAndPhoto.PhotoRStatus = rightThresholds(:,2);

%naPanelFlips = AlignLAndRPhotodiodeData(na_PanelFlipsL, na_PanelFlipsR);

%get flip timing from unity data
unity_PanelFlipsL = ParseFlashPanels(frameData{:,{'FrameStart', 'FlashPanelL'}}, expectedFrameDuration);
unity_PanelFlipsR = ParseFlashPanels(frameData{:,{'FrameStart', 'FlashPanelR'}}, expectedFrameDuration);

unityPanelFlips = AlignLAndRPhotodiodeData(unity_PanelFlipsL, unity_PanelFlipsR);

%% Align flip data

%naRow1 = find(naPanelFlips(:,5) == 0 & naPanelFlips(:,6) == 1, 1, 'first'); %start of timing test
%naPanelFlips = naPanelFlips(naRow1:end,:);
%naRow2 = find(naPanelFlips(:,5) == 0 & naPanelFlips(:,6) == 0, 1, 'first'); %start of trials

unityRow1 = find(unityPanelFlips(:,5) == 0 & unityPanelFlips(:,6) == 1, 1, 'first');
unityPanelFlips = unityPanelFlips(unityRow1:end,:);
unityRow2 = find(unityPanelFlips(:,5) == 0 & unityPanelFlips(:,6) == 0, 1, 'first');



aligned = 0;


%unity frame data
frameDataTtStartRow = find(frameData.EventCode==timingTestBookendCodes(1),1,'first');
frameDataTtEndRow = find(frameData.EventCode==timingTestBookendCodes(2),1,'last');

%neurarduino
eventTtStartRow = find(na_EventCodeDetails.EventCode == timingTestBookendCodes(1),1,'first');
eventTtEndRow = find(na_EventCodeDetails.EventCode == timingTestBookendCodes(2),1,'last');
arduinoTtStartTime = na_EventCodeDetails.ArduinoTimestamp(eventTtStartRow); %keep a few extra frames around just in case
arduinoTtEndTime = na_EventCodeDetails.ArduinoTimestamp(eventTtEndRow);
[~,arduinoTtStartRow] = min(abs(na_joyAndPhoto.ArduinoTimestamp - arduinoTtStartTime));
[~,arduinoTtEndRow] = min(abs(na_joyAndPhoto.ArduinoTimestamp - arduinoTtEndTime));



%try to match panel flip data, first working backwards from TtEnd


% matches = [];
% unityLRow = find(unity_PanelFlipsL(:,1) <= frameDataTtEndRow & unity_PanelFlipsL(:,2) >= frameDataTtEndRow);
% unityRRow = find(unity_PanelFlipsR(:,1) <= frameDataTtEndRow & unity_PanelFlipsR(:,2) >= frameDataTtEndRow);
% naLRow = find(na_PanelFlipsL(:,1) <= arduinoTtEndRow & na_PanelFlipsL(:,2) >= arduinoTtEndRow);
% naRRow = find(na_PanelFlipsR(:,1) <= arduinoTtEndRow & na_PanelFlipsR(:,2) >= arduinoTtEndRow);
% TtflipMatchesL = FindFlipMatchesReverse(unity_PanelFlipsL(1:unityLRow,[5 7]), na_PanelFlipsL(1:naLRow, [5 7]), expectedFrameDetailsL);
% TtflipMatchesR = FindFlipMatchesReverse(unity_PanelFlipsR(1:unityRRow,[5 7]), na_PanelFlipsR(1:naRRow, [5 7]), expectedFrameDetailsL);

fred = 2;

function expectedFrameDetails = FindExpectedFrameDetails(sequenceString)
finished = 0;
expectedFrameDetails = [];
pos = 1;
black = strfind(sequenceString,'0');
white = strfind(sequenceString,'1');

while ~finished
    status = str2double(sequenceString(pos));
    nextpos = strfind(sequenceString(pos+1:end), num2str(abs(1-status)));
    if ~isempty(nextpos)
        nextpos = nextpos(1) + pos;
        expectedFrameDetails = [expectedFrameDetails; status, nextpos-pos];
        pos = nextpos;
    else
        expectedFrameDetails = [expectedFrameDetails; status, length(sequenceString) - pos + 1];
        finished = 1;
    end
end

function [thresholds, panelFlips] = ThresholdPhotoDiodeData(photoData, timeWindow, expectedFrameDuration)
%photoData columns: Time RawValue
%groupedData columns: StartRow EndRow StartTime Endtime State Duration EstimatedFrameCount Deviation
thresholds = nan(size(photoData,1),2);


%calculate sliding window thresholds, determine current colour (0 or 1 for white or black) according to each threshold 
firstUsableTimePoint = find(photoData(:,1) - photoData(1,1) > timeWindow/2,1);
lastUsableTimePoint = find(photoData(end,1) - photoData(:,1) > timeWindow/2,1,'last');

for i = firstUsableTimePoint:lastUsableTimePoint
    time = photoData(i,1);
    thresholds(i,1) = nanmean(photoData(find(time - photoData(:,1) > timeWindow/2,1,'last') : find(photoData(:,1) - time > timeWindow/2,1),2));
    thresholds(i,2) = photoData(i,2) > thresholds(i,1);
end
thresholds(1:firstUsableTimePoint-1,1) = thresholds(firstUsableTimePoint,1);
thresholds(1:firstUsableTimePoint-1,2) = photoData(1:firstUsableTimePoint-1,2) > thresholds(firstUsableTimePoint,1);
thresholds(lastUsableTimePoint+1:end,2) = thresholds(lastUsableTimePoint,1);
thresholds(lastUsableTimePoint+1:end,2) = photoData(lastUsableTimePoint+1:end,1) > thresholds(lastUsableTimePoint,1);


%calculate times at which threshold was crossed
%  linearly interpolate between points, find time value where interpolation
%  crosses threshold.
panelFlips = [];
finished = false;
row = 1;
while ~finished
    currentStatus = thresholds(row,2); %0 = black, 1 = white
    if row < size(photoData,1)
        nextChangeRow = row + find(thresholds(row+1:end,2) ~= currentStatus, 1); %get the row of the next flip from black to white or vice versa
        if ~isempty(nextChangeRow)
            %if we have a 0 in frame N and a 1 in frame N + 1, we know that
            %somewhere between the start and end of N we have a changeover,
            %so here we try to find the best estimate of the exact time of 
            %threshold crossing using interpolation
            if row == 1
                startTime = photoData(row,1);
            else
                startTime = interp1([photoData(row-1,2) photoData(row,2)], [photoData(row-1,1) photoData(row,1)], thresholds(row,1));
                if isnan(startTime)
                    startTime = interp1([photoData(row-2,2) photoData(row,2)], [photoData(row-2,1) photoData(row,1)], thresholds(row,1));
                end
            end
            try
                endTime = interp1([photoData(nextChangeRow-1,2) photoData(nextChangeRow,2)], [photoData(nextChangeRow-1,1) photoData(nextChangeRow,1)], thresholds(nextChangeRow,1));
                if isnan(endTime)
                    endTime = interp1([photoData(nextChangeRow-2,2) photoData(nextChangeRow,2)], [photoData(nextChangeRow-2,1) photoData(nextChangeRow,1)], thresholds(nextChangeRow,1));
                end
            catch
                display(num2str(row) + ' ' + num2str(nextChangeRow));
            end
            frameDetails = GetFrameDetails(startTime, endTime, expectedFrameDuration);
            
            panelFlips = [panelFlips; row, nextChangeRow - 1, startTime, endTime, currentStatus, frameDetails]; %#ok<AGROW>
            row = nextChangeRow;
        else
            finished = 1; %there is no further flip
        end
    else
        finished = 1; %we are at the last row
    end
end


function groupedData = AlignLAndRPhotodiodeData(dataL, dataR)

groupedData = [];
finished = 0;
rowL = 1;
rowR = 1;
framesAccountedForL = 0;
framesAccountedForR = 0;

while ~finished
    if framesAccountedForL == 0
        [segStatusL, segFramesL, segStartTimeL, segFrameDurL, sourceRowL] = SegmentDetails(dataL(rowL,:));
    else
        sourceRowL = NaN;
    end
    if framesAccountedForR == 0
        [segStatusR, segFramesR, segStartTimeR, segFrameDurR, sourceRowR] = SegmentDetails(dataR(rowR,:));
    else
        sourceRowR = NaN;
    end
    framesAccountedForL = framesAccountedForL + 1;
    framesAccountedForR = framesAccountedForR + 1;
    frameStartL = segStartTimeL + framesAccountedForL * segFrameDurL;
    frameStartR = segStartTimeR + framesAccountedForR * segFrameDurR;
    meanDur = mean([segFrameDurL, segFrameDurR]);
    meanStart = mean([frameStartL, frameStartR]);
    stuckFrames = framesAccountedForL - 1;
    
    if framesAccountedForL == segFramesL && framesAccountedForR < segFramesR
        frameStart1Sided = frameStartL;
    elseif framesAccountedForR == segFramesR && framesAccountedForL < segFramesL
        frameStart1Sided = frameStartR;
    else   
        frameStart1Sided = meanStart;
    end
    if rowL > 1 || framesAccountedForL > 1
        groupedData(end,3) = meanStart - groupedData(end,1); 
        groupedData(end,4) = frameStart1Sided - groupedData(end,2); 
        %overwrite the previous frame's duration with the duration from
        %its meaned start time to the meaned start time of the current
        %frame - yes this is computationally inefficient, leave me alone.
    end
    groupedData = [groupedData; meanStart, frameStart1Sided, meanDur, meanDur, segStatusL, segStatusR, stuckFrames, sourceRowL, sourceRowR]; %#ok<AGROW>
    
    if framesAccountedForL == segFramesL
        framesAccountedForL = 0;
        rowL = rowL + 1;
    end
    if framesAccountedForR == segFramesR
        framesAccountedForR = 0;
        rowR = rowR + 1;
    end
    if rowL > size(dataL,1) && rowR > size(dataR,1)
        finished = 1;
    elseif rowL > size(dataL,1) || rowR > size(dataR,1)
        display('AAAAAAAAAH!!!!!!!');
    end
end
    

function [status, numFrames, startTime, frameDur, row] = SegmentDetails(segment)
status = segment(5);
numFrames = segment(7);
startTime = segment(3);
frameDur = (segment(4) - startTime) / numFrames;
row = segment(1);

function groupedData = ParseFlashPanels(rawData, expectedFrameDuration)
%rawData columns: Time State (0 or 1)
%groupedData columns: StartRow EndRow StartTime Endtime State Duration EstimatedFrameCount Deviation

%onsetToOnsetDurations = [];
groupedData = [];
finished = 0;
row = 1;

%For each onset or offset, find the next change (from onset to offset or
%vice versa), then record the frame number, current status (0 for black, 1
%for white), onset time, and duration from onset to next flip (black to
%white or vice versa).
while ~finished
    currentStatus = rawData(row,2); %find out if this row is an onset or offset
    if row < size(rawData,1)
        nextChangeRow = row + find(rawData(row+1:end,2) ~= currentStatus, 1); %get the row of the next flip from black to white or vice versa
        if ~isempty(nextChangeRow)
            frameDetails = GetFrameDetails(rawData(row,1), rawData(nextChangeRow,1), expectedFrameDuration);
            groupedData = [groupedData; row, nextChangeRow - 1, rawData(row,1), rawData(nextChangeRow,1), ...
                currentStatus, frameDetails]; %#ok<AGROW>
            row = nextChangeRow;
        else
            finished = 1; %there is no further flip
        end
    else
        finished = 1; %we are at the last row
    end
end

function frameDetails = GetFrameDetails(startTime, endTime, expectedFrameDuration)
duration = endTime - startTime;
estimatedFrameCount = round(duration / expectedFrameDuration);
deviation = estimatedFrameCount * expectedFrameDuration - duration;
frameDetails = [duration estimatedFrameCount deviation];



function [bvaCodesAndTimes, unityCodesAndTimes] = AlignRealTrialCodes(bvaCodesAndTimes, unityCodesAndTimes, frameData)


bvaRealTrialsMatched = bvaCodesAndTimes.RealTrials;
unityRealTrialsMatched = unityCodesAndTimes.RealTrials;
unityRealTrialsUnmatched = [];
bvaRealTrialsUnmatched = [];
 
framesAligned = 0;
 
startCheck = 1;
 
while ~framesAligned
    
    bvaLength = size(bvaRealTrialsMatched,1);
    unityLength = size(unityRealTrialsMatched,1);
    minLength = min(bvaLength, unityLength);
    expectedCodes = unityRealTrialsMatched(:,2);
    nextProblem = find(bvaRealTrialsMatched(startCheck:minLength,2) - expectedCodes(startCheck:minLength) ~= 0, 1) + startCheck - 1;
    if isempty(nextProblem) && bvaLength == unityLength
        framesAligned = 1;
    else
        display(['Problem in real trials at line: ' num2str(nextProblem) ', Code: ' num2str(bvaRealTrialsMatched(nextProblem,2))])
        unityFrame = unityRealTrialsMatched(nextProblem,1);
        unityCode = unityRealTrialsMatched(nextProblem,2);
        trialInBlock = frameData.TrialInBlock(frameData.FrameCount == unityFrame);
        trialInExperiment = frameData.TrialInExperiment(frameData.FrameCount == unityFrame);
       
        if bvaRealTrialsMatched(nextProblem,2) == 15 && bvaRealTrialsMatched(nextProblem-1,2) == 7 && ...
                unityRealTrialsMatched(nextProblem,2) == 10 && unityRealTrialsMatched(nextProblem -1,2) == 7
            %for some reason on late trials (response code = 7) the
            %feedback onset (which should be 10) is recorded as 15 by BVA -
            %something wrong in my code and need to fix it but for now,
            %ignore
            
            %note none of this makes any real difference to the analysis as
            %I won't be looking at late trials.
            bvaRealTrialsUnmatched = [bvaRealTrialsUnmatched; bvaRealTrialsMatched(nextProblem,:)]; %#ok<AGROW>
            if bvaRealTrialsMatched(nextProblem,4) <= 3 && bvaRealTrialsMatched(nextProblem + 1, 2) == 10
                %sometimes the 15 appears for 1 ms followed by the 10.
                %Still not sure why
                bvaRealTrialsMatched(nextProblem,:) = [];
            else
                bvaRealTrialsMatched(nextProblem,2) = 10;
            end
        end
    end
end


function flipMatches = FindFlipMatchesReverse(flipsA, flipsB, expectedFrameDetails)
%flipsA/B: two columns, one giving photodiode status (0/1) and one giving
%number of frames where it was that status
%flipMatches = N
%1: status A matched expected status (0 or 1, 1 is good)
%2: status B matched expected status
%3: frameCount A minus expected frameCount (0 is good)
%4: frameCount B minus expected frameCount

rowA = size(flipsA,1);
rowB = size(flipsB,1);

patternLength = length(expectedFrameDetails);

flipMatches = [];

while rowA - patternLength > 0 && rowB - patternLength > 0
    for i = 0:patternLength-1
        matchA = flipsA(rowA-i,1) == expectedFrameDetails(end-i,1);
        matchB = flipsB(rowB-i,1) == expectedFrameDetails(end-i,1);
        deviationA = flipsA(rowA-i,2) - expectedFrameDetails(end-i,2);
        deviationB = flipsB(rowB-i,2) - expectedFrameDetails(end-i,2);
        flipMatches = [matchA matchB deviationA deviationB; flipMatches]; %#ok<AGROW>
    end
    rowA = rowA - patternLength;
    rowB = rowB - patternLength;
end


function start = findPattern2(array, pattern)
% taken from http://blogs.mathworks.com/loren/2008/09/08/finding-patterns-in-arrays/
%findPattern2 Locate a pattern in an array.
%
%   indices = findPattern2(array, pattern) finds the starting indices of
%   pattern within array.
%
%   Example:
%   a = [0 1 4 9 16 4 9];
%   patt = [4 9];
%   indices = findPattern2(a,patt)
%   indices =
%        3     6

% Let's assume for now that both the pattern and the array are non-empty
% VECTORS, but there's no checking for this. 
% For this algorithm, I loop over the pattern elements.
len = length(pattern);
% First, find candidate locations; i.e., match the first element in the
% pattern.
start = find(array==pattern(1));
% Next remove start values that are too close to the end to possibly match
% the pattern.
endVals = start+len-1;
start(endVals>length(array)) = [];
% Next, loop over elements of pattern, usually much shorter than length of
% array, to check which possible locations are valid still.
for pattval = 2:len
    % check viable locations in array
    locs = pattern(pattval) == array(start+pattval-1);
    % delete false ones from indices
    start(~locs) = [];
end




