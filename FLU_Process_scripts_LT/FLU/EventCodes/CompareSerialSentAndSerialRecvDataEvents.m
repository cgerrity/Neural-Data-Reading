function [serialSentDataUnmatched, serialRecvDataUnmatched, serialSentRecvMatched] = CompareSerialSentAndSerialRecvDataEvents(serialSentDataEvents, serialRecvDataEvents)

% frames = union(unique(frameDataEvents.Frame), unique(serialSentDataEvents.Frame));
tolerance = 100000;

origRecv = serialRecvDataEvents;
serialSentDataUnmatched = [];
serialSentRecvMatched = [];

for row = 1:height(serialSentDataEvents)
    sentRow = serialSentDataEvents(row,:);
    code = sentRow.Code;
    frame = sentRow.Frame;
    timestamp = sentRow.SystemTimestamp;
    match = find(serialRecvDataEvents.Code == code & abs(serialRecvDataEvents.SystemTimestamp - timestamp) <= tolerance, 1);
    if ~isempty(match)
        serialSentRecvMatched = [serialSentRecvMatched; frame timestamp serialRecvDataEvents.SystemTimestamp(match) code];
        serialRecvDataEvents(match,:) = [];
    else
        serialSentDataUnmatched = [serialSentDataUnmatched; frame, code];
    end
end

serialRecvDataUnmatched = [serialRecvDataEvents.Frame serialRecvDataEvents.Code];
