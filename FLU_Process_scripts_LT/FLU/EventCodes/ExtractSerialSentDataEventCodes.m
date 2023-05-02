function serialSentDataEvents = ExtractSerialSentDataEventCodes(serialSentData)
codeRows = find(contains(serialSentData.Message, 'NEU '));

Frame = serialSentData.FrameSent(codeRows);

SystemTimestamp = serialSentData.SystemTimestamp(codeRows);
FrameStartUnity = serialSentData.FrameStart(codeRows);

Code = nan(length(codeRows),1);
SplitCode = nan(length(codeRows),1);

for iC = 1:length(codeRows)
    Code(iC) = str2double(serialSentData.Message{codeRows(iC)}(5:end));
    try
        SplitCode(iC) = SingleByteCodeFromTwoBytes(Code(iC), 'decimal');
    catch
        SplitCode(iC) = NaN;
    end
end

serialSentDataEvents = table(Frame, FrameStartUnity, SystemTimestamp, Code, SplitCode);