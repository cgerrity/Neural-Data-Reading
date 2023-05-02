function serialRecvDataEvents = ExtractSerialRecvDataEventCodes(serialRecvData)
% serialData = subjectData.SerialData.SerialRecvData;
% codeString = 'Lynx:';
codeString = 'Code:';


codeRows = find(contains(serialRecvData.Message, codeString(1)));

Frame = serialRecvData.FrameReceived(codeRows);
FrameStartUnity = serialRecvData.FrameStart(codeRows);
SystemTimestamp = serialRecvData.SystemTimestamp(codeRows);
ArduinoTimestamp = nan(length(codeRows),1);
Code = nan(length(codeRows),1);
SplitCode = nan(length(codeRows),1);


for iC = 1:length(codeRows)
    row = codeRows(iC);
    codeStr = serialRecvData.Message{row};
    if length(codeStr) ~= 19
        lengthIssue = 1;
        if row < height(serialRecvData)
            tempRow = (row+1);
            while isempty(serialRecvData.Message{tempRow})
                tempRow = tempRow + 1;
            end
            temp = [codeStr serialRecvData.Message{tempRow}];
            if length(temp) == 18
                temp = [temp(1:14) ' ' temp(15:end)];
            end
            if strcmp(temp(1:5), codeString)
                if ~strcmp(temp(6), ' ')
                    temp = [temp(1:5) ' ' temp(6:end)];
                end
                temp(strfind(temp, '  ')) = [];
            end
            if length(temp) == 19 && isequal(strfind(temp, ' '), [6 15])
                codeStr = temp;
                lengthIssue = 0;
            end
        end
        if lengthIssue
            disp(['Unexpected length of serial received message at line ' num2str(row) ', Frame ' num2str(Frame(iC)) '.']);
            continue
        end
    end
    ArduinoTimestamp(iC) = hex2dec(codeStr(7:14));
    Code(iC) = hex2dec(codeStr(16:19));
    try
        SplitCode(iC) = SingleByteCodeFromTwoBytes(Code(iC), 'decimal');
    catch
        SplitCode(iC) = NaN;
    end
        
end

serialRecvDataEvents = table(Frame, FrameStartUnity, SystemTimestamp, ArduinoTimestamp, Code, SplitCode);