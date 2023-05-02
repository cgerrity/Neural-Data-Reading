function frameData = AddReplayerGazeToFluFrameData(processedDataFolderPath, subjectID, frameData)

processedGazeTable = ReadDataFiles([processedDataFolderPath filesep 'FrameDataGazeHits'], '*_Trial_*.txt', 'importOptions', {'delimiter', '\t'});

processedDataFilePath = [processedDataFolderPath filesep subjectID '_AllData.mat'];
frameData = [frameData processedGazeTable(:,end-11:end)];