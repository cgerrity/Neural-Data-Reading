function frameDataEvents = ExtractFrameDataEventCodes(subjectData)

checkSplitCodes = 1;
checkPreSplitCodes = 1;

frameData = subjectData.FrameData;
codeRows = find(~cellfun(@isempty, frameData.EventCodes));

Frame = [];
FrameStartUnity = [];
FrameStartSystem = [];
Code = [];
SplitCode = [];
PreSplitCode = [];

for iR = 1:length(codeRows)
    row = frameData(codeRows(iR),:);
    codesSent = str2double(split(row.EventCodes,','));
    nCodes = length(codesSent);
    splitCodes = str2double(split(row.SplitEventCodes,','));
%     preSplitCodes = str2double(split(row.PreSplitCodes,','));
    if checkSplitCodes
        if length(splitCodes) ~= nCodes
            error(['FrameData: different numbers of codes and splitCodes on frame ' num2str(row.Frame)]);
        end
        for iC = 1:nCodes
            if SingleByteCodeFromTwoBytes(codesSent(iC), 'decimal') ~= splitCodes(iC)
                error(['FrameData: code ' num2str(codesSent(ic)) ' sent on frame ' num2str(row.Frame) ' but does not split into expected ' num2str(codesSent(iC)) '.']);
            end
        end
        if checkPreSplitCodes
        end
    end
    Frame = [Frame; repmat(row.Frame, nCodes, 1)];
    FrameStartUnity = [FrameStartUnity; repmat(row.FrameStartUnity, nCodes, 1)];
    FrameStartSystem = [FrameStartSystem; repmat(row.FrameStartSystem, nCodes, 1)];
    Code = [Code; codesSent];
    SplitCode = [SplitCode; splitCodes];
    PreSplitCode = [PreSplitCode; splitCodes];
end

frameDataEvents = table(Frame, FrameStartUnity, FrameStartSystem, Code, SplitCode, PreSplitCode);