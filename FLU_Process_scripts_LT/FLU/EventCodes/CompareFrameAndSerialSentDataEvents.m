function [frameDataUnmatched, serialSentDataUnmatched] = CompareFrameAndSerialSentDataEvents(frameDataEvents, serialSentDataEvents)

frames = union(unique(frameDataEvents.Frame), unique(serialSentDataEvents.Frame));

frameDataUnmatched = [];
serialSentDataUnmatched = [];

for iF = 1:length(frames)
    frame = frames(iF);
    frameCodes = table2array(frameDataEvents(frameDataEvents.Frame==frame, {'Code'}));
    serialCodes = table2array(serialSentDataEvents(serialSentDataEvents.Frame == frame, {'Code'}));
    if ~isequal(frameCodes, serialCodes)
        fUnmatchedCodes = [];
        for iC = 1:length(frameCodes)
            fC = frameCodes(iC);
            match = find(serialCodes == fC,1);
            if isempty(match)
                fUnmatchedCodes = [fUnmatchedCodes; fC];
            else
                serialCodes(match) = [];
            end
        end
        sUnmatchedCodes = serialCodes;
        frameDataUnmatched = [frameDataUnmatched; repmat(frame,length(fUnmatchedCodes),1) fUnmatchedCodes];
        serialSentDataUnmatched = [serialSentDataUnmatched; repmat(frame,length(sUnmatchedCodes),1) sUnmatchedCodes];
    end
end
