function MainMonkeyGamesAnalysis


%get current folder, set script to automatically return to this folder in
%event of early closing.
scriptPath = pwd;
finishup = onCleanup(@() CleanupFun(scriptPath));


dataFolder = uigetdir('Data', 'Choose the subject folder');
[~,subjectID,~] = fileparts(dataFolder);

frameRate = 60;
expectedFrameDuration = 1000/frameRate;
leftSequenceString = '01';
rightSequenceString = ['000' '001' '010' '011' '100' '101' '110' '111']; 
leftSequence = str2num(leftSequenceString');
rightSequence = str2num(rightSequenceString');
bookendCodes = [50,51];
%sequence of white = 0 black = 1 that should be displayed on the right
%square after a set number of repetitions of the left sequence

%% TimingTest Analysis
arduinoTimingTestDataRaw = readtable([dataFolder filesep 'UnityData' filesep 'Neurarduino' subjectID '__NeurarduinoData_TimingTest_.csv'], 'Delimiter', '\t');
arduinoEventSentDataRaw = readtable([dataFolder filesep 'UnityData' filesep subjectID '_NeurarduinoEventData_TimingTest_.csv'], 'Delimiter', '\t');
unityTimingTestDataRaw = readtable([dataFolder filesep 'UnityData' filesep 'TimingTestData' filesep subjectID '_TimingTest.txt'], 'Delimiter', '\t');

% for some bloody reason half the timing test data from the arduino gets
% sent to the first trial's data file, so append.

arduinoTrial1DataRaw = readtable([dataFolder filesep 'PythonData' filesep 'Arduino' filesep 'arduino' subjectID '__Trial_1.csv'], 'Delimiter', '\t');
arduinoEventSentTrial1DataRaw = readtable([dataFolder filesep 'PythonData' filesep 'ArduinoEventSent' filesep 'arduino_event_sent' subjectID '__Trial_1.csv'], 'Delimiter', '\t');

arduinoTimingTestDataRaw = [arduinoTimingTestDataRaw;arduinoTrial1DataRaw];
arduinoEventSentDataRaw = [arduinoEventSentDataRaw;arduinoEventSentTrial1DataRaw];
arduinoTimingTestDataRaw.ArduinoTimestamp = arduinoTimingTestDataRaw.ArduinoTimestamp / 1;
arduinoEventSentDataRaw.ArduinoTimestamp = arduinoEventSentDataRaw.ArduinoTimestamp / 100; %why is this 100 and not 1? no fucking idea

%get rid of timing test "bookends"
firstRow = find(unityTimingTestDataRaw.EventCode == bookendCodes(1), 1, 'last') + 1;
lastRow = find(unityTimingTestDataRaw.EventCode == bookendCodes(2), 1, 'first') - 1;
unityTimingTestData = unityTimingTestDataRaw(firstRow:lastRow,:);
firstRow = find(arduinoEventSentDataRaw.EventCode == bookendCodes(1), 1, 'last') + 1;
lastRow = find(arduinoEventSentDataRaw.EventCode == bookendCodes(2), 1, 'first') - 1;
arduinoEventSentData = arduinoEventSentDataRaw(firstRow:lastRow,:);
[~,firstRow] = min(abs(arduinoTimingTestDataRaw.ArduinoTimestamp - arduinoEventSentData.ArduinoTimestamp(1))); %+/- 50 to allow for terrible jitter issues
[~,lastRow] = min(abs(arduinoTimingTestDataRaw.ArduinoTimestamp - arduinoEventSentData.ArduinoTimestamp(end)));
% arduinoTimingTestData = arduinoTimingTestDataRaw(firstRow-50:lastRow+50,:);

% unityDeltas = unityTimingTestData.FrameStart(2:end) - unityTimingTestData.FrameStart(1:end-1);
% arduinoEventDeltas = arduinoEventSentData.ArduinoTimestamp(2:end) - arduinoEventSentData.ArduinoTimestamp(1:end-1);
arduinoTimingTestData = arduinoTimingTestDataRaw;
%this should clipped at some point to match time stamps in
%arduinoEventSentData but those time stamps are dumb.


unityL = ParseFlashPanels(table2array(unityTimingTestData(:,{'FrameStart', 'FlashPanelL'})));
unityR = ParseFlashPanels(table2array(unityTimingTestData(:,{'FrameStart', 'FlashPanelR'})));

photoDiodeL = ParsePhotoDiodes(table2array(arduinoTimingTestData(:,{'ArduinoTimestamp', 'PhotoLValue'})), 3000);
photoDiodeR = ParsePhotoDiodes(table2array(arduinoTimingTestData(:,{'ArduinoTimestamp', 'PhotoRValue'})), 3000);



fred = 2;

function groupedData = ParseFlashPanels(rawData)
%rawData columns: Time State (0 or 1)
%groupedData columns: StartRow EndRow StartTime Endtime State

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
            groupedData = [groupedData; row, nextChangeRow - 1, rawData(row,1), rawData(nextChangeRow,1), currentStatus]; %#ok<AGROW>
            row = nextChangeRow;
        else
            finished = 1; %there is no further flip
        end
    else
        finished = 1; %we are at the last row
    end
end

function groupedData = ParsePhotoDiodes(rawData, timeWindow)
%rawData columns: Time RawValue
%groupedData columns: StartRow EndRow StartTime Endtime State
thresholds = nan(size(rawData,1),2);
normalizedTimes = rawData(:,1) - rawData(1,1);


%calculate sliding window threshold 
firstUsableTimePoint = find(normalizedTimes > timeWindow/2,1);
lastUsableTimePoint = find(normalizedTimes(end) - normalizedTimes > timeWindow/2,1,'last');

for i = firstUsableTimePoint:lastUsableTimePoint
    time = normalizedTimes(i);
    thresholds(i,1) = nanmean(rawData(find(time - normalizedTimes > timeWindow/2,1,'last') : find(normalizedTimes - time > timeWindow/2,1),2));
    thresholds(i,2) = rawData(i,2) > thresholds(i,1);
end
thresholds(1:firstUsableTimePoint-1,1) = thresholds(firstUsableTimePoint,1);
thresholds(1:firstUsableTimePoint-1,2) = rawData(1:firstUsableTimePoint-1,2) > thresholds(firstUsableTimePoint,1);
thresholds(lastUsableTimePoint+1:end,2) = thresholds(lastUsableTimePoint,1);
thresholds(lastUsableTimePoint+1:end,2) = rawData(lastUsableTimePoint+1:end,1) > thresholds(lastUsableTimePoint,1);

groupedData = [];
finished = 0;
row = 1;

%For each onset or offset, find the next change (from onset to offset or
%vice versa), then record the frame number, current status (0 for black, 1
%for white), onset time, and duration from onset to next flip (black to
%white or vice versa).
while ~finished
    currentStatus = thresholds(row,2); %photodiode is greater or lesser than photodiode
    if row < size(rawData,1)
        nextChangeRow = row + find(thresholds(row+1:end,2) ~= currentStatus, 1); %get the row of the next flip from black to white or vice versa
        if ~isempty(nextChangeRow)
            if row == 1
                startTime = rawData(row,1);
            else
                startTime = interp1([rawData(row-1,2) rawData(row,2)], [rawData(row-1,1) rawData(row,1)], thresholds(row,1));
            end
            try
                endTime = interp1([rawData(nextChangeRow-1,2) rawData(nextChangeRow,2)], [rawData(nextChangeRow-1,1) rawData(nextChangeRow,1)], thresholds(nextChangeRow,1));
            catch
                display(num2str(row) + ' ' + num2str(nextChangeRow));
            end
            groupedData = [groupedData; row, nextChangeRow - 1, startTime, endTime, currentStatus]; %#ok<AGROW>
            row = nextChangeRow;
        else
            finished = 1; %there is no further flip
        end
    else
        finished = 1; %we are at the last row
    end
end




function CleanupFun(path)
cd(path);