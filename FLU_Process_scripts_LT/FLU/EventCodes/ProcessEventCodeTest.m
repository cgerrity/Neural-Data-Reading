function results = ProcessEventCodeTest(path)

results.SerialData.SerialSentData = readtable([path filesep 'SerialSent' filesep 'SerialSent.txt'], 'delimiter', '\t');
results.SerialData.SerialRecvData = readtable([path filesep 'SerialRecv' filesep 'SerialRecv.txt'], 'delimiter', '\t');

% results.SerialData.SerialSentData.Properties.VariableNames = {'FrameSent', 'FrameStart', 'SystemTimestamp', 'Message'};
% results.SerialData.SerialRecvData.Properties.VariableNames = {'FrameRecv', 'FrameStart', 'SystemTimestamp', 'Message'};

results.SerialSentDataEvents = ExtractSerialSentDataEventCodes(results);
results.SerialRecvDataEvents = ExtractSerialRecvDataEventCodes(results);

[results.SerialSentDataUnmatched, results.SerialRecvDataUnmatched, results.SerialSentRecvMatched] = CompareSerialSentAndSerialRecvDataEvents(results.SerialSentDataEvents, results.SerialRecvDataEvents);

maxUnmatchedFrame = max([max(results.SerialSentDataUnmatched(:,1)), max(results.SerialRecvDataUnmatched(:,1))]);
maxMs = num2str(results.SerialData.SerialSentData.MsWait(find(results.SerialData.SerialSentData.FrameSent == maxUnmatchedFrame, 1, 'last')));

disp(['All codes matched in sent and received serial data for buffers > ' maxMs ' ms.']);