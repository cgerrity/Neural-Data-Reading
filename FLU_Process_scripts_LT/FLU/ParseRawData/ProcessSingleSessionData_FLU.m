function [trialData, blockData] = ProcessSingleSessionData_FLU(varargin)
%{
Processes a complete set of raw data from a FLU session for later analysis

Arguments should be in name-value pairs as follows (the order of the pairs
is not important). If an argument pair not given, the default value is used

'exptType', string representing the experiment name, default is 'FLU'
'dataFolder', string path to the session data folder, no default
'gazeArgs', string giving the name of the eyetracker being used, no default
(possible values include 'Spectrum' and' 'TX300', but this will have to be
updated to account for different monitor setups)
'subjectID', subject ID string, default is 'Subject1'
'subject#', subject ID number, default is 1
'sessionID', session ID string, default is 'Session1'
'session#', session ID number, default is 1

%}


%get current folder, set script to automatically return to this folder in
%event of early closing.
scriptPath = pwd;
finishup = onCleanup(@() CleanupFun(scriptPath));
% addpath(genpath(scriptPath));

%% variables to force recaculation
forceProcessAllData = 0;
forceGazeClassification = 0;
forceGazeFrameAlignment = 0;
forceSaveFrameDataForReplayer = 0;
ignoreGaze = 0;
ignoreGazeClassification = 0;
ignoreBlockCondition = 1;
ignoreReplayer = 1;
forceLP = 0;


deleteAbortedTrials = 0;
nanAbortedTrials = 1;
%% set subject data paths and read in data
exptType = CheckVararginPairs('exptType', 'FLU', varargin{:});

dataFolder = CheckVararginPairs('dataFolder', '', varargin{:});
if isempty(dataFolder)
    dataFolder = uigetdir('Data', 'Choose the data folder');
end
gazeArgs = CheckVararginPairs('gazeArgs', '', varargin{:});

if isempty(gazeArgs) && ~ignoreGaze
   b = questdlg('Select the monitor/eye tracker', ...
    'select monitor/ eye tracker', ...
    'acer, TX120','TX300','cancel');
   switch lower(b)
       case 'acer, tx120'
           gazeArgs = 'acer120';
       case 'tx300'
           gazeArgs = 'tx300';
       case 'spectrum'
           gazeArgs = 'spectrum';
       case 'elo_large'
           gazeArgs = 'elo_large';
       case 'cancel'
           return
   end
end

subjectID = CheckVararginPairs('SubjectID', 'Subject1', varargin{:});
subjectNum = CheckVararginPairs('Subject#', 1, varargin{:});

sessionID = CheckVararginPairs('SessionID', 'Sesssion1', varargin{:});
sessionNum = CheckVararginPairs('Session#', 1, varargin{:});



disp('-----------------------------------------------------------------')
fprintf(['\n\nProcessing data files for subject ' subjectID ', session ' sessionID '.\n']);


global processedDataPath singleDataFileName singleDataFileVarNames multiDataFileVarNames; 

runtimeDataPath = [dataFolder filesep 'RuntimeData'];
processedDataPath = [dataFolder filesep 'ProcessedData'];
singleDataFileName = [subjectID '__ProcessedData.mat'];
processedDataFilePath = [processedDataPath filesep singleDataFileName];
% processedDataSmallPath = [processedDataPath filesep subjectID '__ProcessedDataSmall.mat'];




if ~exist(processedDataPath, 'dir')
    mkdir(processedDataPath);
end

if exist(processedDataFilePath, 'file')
    fprintf('\tComplete subject data file exists, determining which variables are in it.\n');
    singleDataFileVarNames = who('-file', processedDataFilePath);
%     fprintf('\tRaw data already loaded into .mat file, loading into workspace.\n');
%     load(processedDataFilePath);
else
    singleDataFileName = '';
    singleDataFileVarNames = '';
end
multiDataFileVarNames = dir([processedDataPath filesep '*.mat']);
multiDataFileVarNames = {multiDataFileVarNames.name};

runtimeFolders = dir(runtimeDataPath);
runtimeFolders = {runtimeFolders.name};

%process trial data
% if any(strcmp(singleDataFileVarNames, 'trialData'))  && ~forceProcessAllData %isfield(subjectData, 'TrialData') && ~forceAppendData

%     fprintf('\tLoading trial data from file.\n');
trialData = LoadDataCheckCompleteFile('trialData', forceProcessAllData);
abortedTrialData = LoadDataCheckCompleteFile('abortedTrialData', forceProcessAllData);
%     load(processedDataFilePath, 'trialData');
%     load(processedDataFilePath, 'abortedTrialData');
if isempty(trialData)
    trialData = ReadDataFiles([runtimeDataPath filesep 'TrialData'], '*TrialData.txt', 'ImportOptions', {'delimiter', '\t', 'TreatAsEmpty',{'null'}});
    
    abortedTrials = find(trialData.AbortCode > 0 | trialData.TrialTime < 0);
    abortedTrialData = trialData(abortedTrials,:);
    if deleteAbortedTrials
        trialData(abortedTrials,:) = [];
    elseif nanAbortedTrials
        vars = trialData.Properties.VariableNames;
        abortCol = find(strcmp(vars, 'AbortCode'));
        for i = abortedTrials'
            for iCol = abortCol + 1 : width(trialData)
                if iscell(trialData.(vars{iCol}))
                    trialData.(vars{iCol}){i} = '';
                elseif isnumeric(trialData.(vars{iCol}))
                    trialData.(vars{iCol})(i) = NaN;
                end
            end
        end
    end
    trialData = AddSubjectAndSession(trialData, subjectNum, sessionNum);
    if height(trialData) > 1
        if isequal(trialData(height(trialData), :), trialData(height(trialData)-1,:))
            trialData(height(trialData),:) = [];
        end
    end
    SaveDataCheckCompleteFile('trialData', trialData);
    SaveDataCheckCompleteFile('abortedTrialData', abortedTrialData);
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'trialData', 'abortedTrialData', '-append');
%     else
%         save(processedDataFilePath, 'trialData', 'abortedTrialData');
%     end
%     subjectData.TrialData = trialData;
%     SaveData(subjectData, processedDataFilePath, processedDataFilePath);
end

trialDefs = LoadDataCheckCompleteFile('trialDefs', forceProcessAllData);
% if any(strcmp(singleDataFileVarNames, 'trialDefs')) && ~forceProcessAllData
%     fprintf('\tLoading trialDefs from file.\n');
%     trialDefs = LoadDataCheckCompleteFile(processedDataPath, singleDataFileName, 'trialDefs');
%     load(processedDataFilePath, 'trialDefs');
if isempty(trialDefs)
    trialDefs = ReadJsonFiles([runtimeDataPath filesep 'TrialData'], '*trialdef*.json');
    if ~isempty(trialDefs)
        SaveDataCheckCompleteFile('trialDefs', trialDefs);
    end
    
    
%     trialDefFiles = dir([runtimeDataPath filesep 'TrialData' filesep '*trialdef*.json']);
%     trialDefFiles = {trialDefFiles.name};
%     trialDefs = cell(height(trialData),1);
%     if ~isempty(trialDefFiles)
%         for iTrial = 1:height(trialData)
%             trialDefName = [runtimeDataPath filesep 'TrialData' filesep trialDefFiles{contains(trialDefFiles,['trialdef_on_trial_' num2str(trialData.TrialCounter(iTrial)) '.json'])}];
%             trialDefs{iTrial} = jsondecode(fileread(trialDefName));
%             %             trialDefs{iTrial} = jsondecode(fileread([runtimeDataPath filesep 'TrialData' filesep '*trialdef_on_trial_' num2str(trialData.TrialCounter(iTrial)) '.json']));
%         end
%         SaveDataCheckCompleteFile('trialDefs', trialDefs);
% %         fprintf('\tSaving trialDefs to file.\n');
% %         if exist(processedDataFilePath, 'file')
% %             save(processedDataFilePath, 'trialDefs', '-append');
% %         else
% %             save(processedDataFilePath, 'trialDefs');
% %         end
%     end
end

% if any(strcmp(singleDataFileVarNames, 'blockData')) && ~forceProcessAllData %isfield(subjectData, 'BlockData') && ~forceAppendData
%     fprintf('\tLoading block data from file.\n');
%     load(processedDataFilePath, 'blockData');
    
blockData = LoadDataCheckCompleteFile('blockData', forceProcessAllData);
if isempty(blockData)
    blockData = ReadDataFiles([runtimeDataPath filesep 'BlockData'], '*BlockData.txt', 'ImportOptions', {'delimiter', '\t', 'TreatAsEmpty',{'null'}});
    if iscell(blockData.LastTrial)
        blockData.LastTrial = str2double(blockData.LastTrial);
    end
    blockData = AddSubjectAndSession(blockData, subjectNum, sessionNum);

    SaveDataCheckCompleteFile('blockData', blockData);
%     fprintf('\tSaving block data to file.\n');
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'blockData', '-append');
%     else
%         save(processedDataFilePath, 'blockData');
%     end
end

if min(trialData.Block) == 0 && min(blockData.Block) == 1
    trialData.Block = trialData.Block + 1;
end

if height(blockData) > 1
    if isequal(blockData(height(blockData), :), blockData(height(blockData)-1,:))
        badBlock = blockData.Block(height(blockData));
    else
        badBlock = [];
    end
else
    badBlock = [];
end


badBlock = [badBlock; blockData.Block(isnan(blockData.FirstTrial) | isnan(blockData.LastTrial))];
blockData(ismember(blockData.Block, badBlock),:) = [];
trialData(ismember(trialData.Block, badBlock),:) = [];

if strcmp(exptType, 'FLU_GL') && (~ismember('MeanPositiveTokens', blockData.Properties.VariableNames))
    blockjson = jsondecode(fileread([runtimeDataPath filesep 'SessionSettings' filesep 'BlockDefs.json']));
    blockData = AddTokenInfo(blockData, blockjson);
    
    SaveDataCheckCompleteFile('blockData', blockData);
%     fprintf('\tSaving block data to file.\n');
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'blockData', '-append');
%     else
%         save(processedDataFilePath, 'blockData');
%     end
end

if (~ismember('ID_ED', blockData.Properties.VariableNames) || forceProcessAllData) && ~ ignoreBlockCondition
    blockData = AddBlockType(blockData, exptType, runtimeDataPath);
    SaveDataCheckCompleteFile('blockData', blockData);
    
%     fprintf('\tSaving block data to file.\n');
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'blockData', '-append');
%     else
%         save(processedDataFilePath, 'blockData');
%     end
end

% if any(strcmp(singleDataFileVarNames, 'frameData')) && ~forceProcessAllData
%     fprintf('\tLoading frame data from file.\n');
%     load(processedDataFilePath, 'frameData');
frameData = LoadDataCheckCompleteFile('frameData', forceProcessAllData);
%     if width(frameData) == 1
%         frameData = ReadDataFiles([runtimeDataPath filesep 'FrameData'], '*Trial*.txt', 'importOptions', {'delimiter', '\t', 'TreatAsEmpty',{'null'}});
%         frameData = AddSubjectAndSession(frameData, subjectNum, sessionNum);
% %         fprintf('\tSaving frame data to file.\n');
% %         if exist(processedDataFilePath, 'file')
% %             save(processedDataFilePath, 'frameData', '-append');
% %         else
% %             save(processedDataFilePath, 'frameData');
% %         end
%     end
if isempty(frameData) || width(frameData) == 1
    frameData = ReadDataFiles([runtimeDataPath filesep 'FrameData'], '*Trial*.txt', 'importOptions', {'delimiter', '\t', 'TreatAsEmpty',{'null'}});
    frameData = AddSubjectAndSession(frameData, subjectNum, sessionNum);
    SaveDataCheckCompleteFile('frameData', frameData);
%     fprintf('\tSaving frame data to file.\n');
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'frameData', '-append');
%     else
%         save(processedDataFilePath, 'frameData');
%     end
end

if ~ignoreGaze && any(strcmp(runtimeFolders, 'GazeData'))
    rawGazeData = LoadDataCheckCompleteFile('rawGazeData', forceProcessAllData);
    % if any(strcmp(singleDataFileVarNames, 'rawGazeData')) && ~forceProcessAllData
    %     fprintf('\tLoading raw gaze data from file.\n');
    %     load(processedDataFilePath, 'rawGazeData');
    % elseif any(strcmp(runtimeFolders, 'GazeData')) && ~ignoreGaze
    if isempty(rawGazeData)
        gazeDataPath = [runtimeDataPath filesep 'GazeData'];
        %check gaze data type
        fileInfo = dir([gazeDataPath filesep '*Trial*.txt']);
        [fileNames,~] = sort_nat({fileInfo.name}');
        %some issues with hidden files
        startsWithPeriod = @(x) startsWith(x, '.');
        fileNames(cellfun(startsWithPeriod, fileNames)) = [];
        fid = fopen([gazeDataPath filesep fileNames{1}], 'r');
        line1 = '';
        while isempty(line1)
            line1 = fgetl(fid);
        end
        fclose(fid);
        if strcmp(line1(1), '{')
            rawGazeData = ParseGazeDataOld(gazeDataPath, '*Trial*.txt', scriptPath);%, badTrial);
            fprintf('\n');
        else
            rawGazeData = ReadDataFiles(gazeDataPath, '*Trial*.txt', 'importOptions', {'delimiter', '\t', 'TreatAsEmpty',{'null'}});
        end
        SaveDataCheckCompleteFile('rawGazeData', rawGazeData);
%         fprintf('\tSaving raw gaze data to file.\n');
%         if exist(processedDataFilePath, 'file')
%             save(processedDataFilePath, 'rawGazeData', '-append');
%         else
%             save(processedDataFilePath, 'rawGazeData');
%         end
    end
end

udpData = LoadDataCheckCompleteFile('udpData', forceProcessAllData);
% if any(strcmp(singleDataFileVarNames, 'udpData')) && ~forceProcessAllData
%     fprintf('\tLoading udp data from file.\n');
%     load(processedDataFilePath, 'udpData');
if isempty(udpData)
    if any(strcmp(runtimeFolders, 'UnityUDPRecvData'))
        udpData.UnityUdpRecvData = ReadDataFiles([runtimeDataPath filesep 'UnityUDPRecvData'], '*UDPRecv*.txt', 'importOptions', {'delimiter', '\t'});
    else
        udpData.UnityUdpRecvData = 'No Unity UDP Recv Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'UnityUDPSentData'))
        udpData.UnityUdpSentData = ReadDataFiles([runtimeDataPath filesep 'UnityUDPSentData'], '*UDPSent*.txt', 'importOptions', {'delimiter', '\t'});
    else
        udpData.UnityUdpSentData = 'No Unity UDP Sent Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'PythonUDPRecvData'))
        udpData.PythonUdpRecvData = ReadDataFiles([runtimeDataPath filesep 'PythonUDPRecvData'], '*UDPRecv*.txt', 'importOptions', {'delimiter', '\t'});
    else
        udpData.PythonUdpRecvData = 'No Python UDP Recv Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'PythonUDPSentData'))
        udpData.PythonUdpSentData = ReadDataFiles([runtimeDataPath filesep 'PythonUDPSentData'], '*UDPSent*.txt', 'importOptions', {'delimiter', '\t'});
    else
        udpData.PythonUdpSentData = 'No Python UDP Sent Data In Raw Data Files';
    end
%     fprintf('\tSaving UDP data to file.\n');
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'udpData', '-append');
%     else
%         save(processedDataFilePath, 'udpData');
%     end

    SaveDataCheckCompleteFile('udpData', udpData);
end


serialData = LoadDataCheckCompleteFile('serialData', forceProcessAllData);
% if any(strcmp(singleDataFileVarNames, 'serialData')) && ~forceProcessAllData
%     fprintf('\tLoading serial data from file.\n');
%     load(processedDataFilePath, 'serialData');
% else
if isempty(serialData)
    if any(strcmp(runtimeFolders, 'SerialRecv'))
        serialData.SerialRecvData = ReadDataFiles([runtimeDataPath filesep 'SerialRecv'], '*SerialRecv*.txt', 'importOptions', {'delimiter', '\t'});
    else
        serialData.SerialRecvData = 'No Serial Recv Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'SerialSent'))
        serialData.SerialSentData = ReadDataFiles([runtimeDataPath filesep 'SerialSent'], '*SerialSent*.txt', 'importOptions', {'delimiter', '\t'});
    else
        serialData.SerialSentData = 'No Serial Sent Data In Raw Data Files';
    end
    
    SaveDataCheckCompleteFile('serialData', serialData);
%     fprintf('\tSaving serial data to file.\n');
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'serialData', '-append');
%     else
%         save(processedDataFilePath, 'serialData');
%     end
end

%% extract gaze classifications and add to trialData and frameData files 
disp('-----------------------------------------------------------------')
disp('#####   getting gaze classification')

%just for today
% if ~ignoreGazeClassification && any(strcmp(runtimeFolders, 'GazeData'))
%     processedGazeData = LoadDataCheckCompleteFile('processedGazeData', forceProcessAllData | forceGazeClassification);
%     
%     if ~isempty(processedGazeData)
%         eyeEvents = processedGazeData.EyeEvents;
%         gazeData = processedGazeData.GazeData;
%     else
%         
%         
%         % if (~any(strcmp(singleDataFileVarNames, 'processedGazeData')) || forceGazeClassification) && ~ignoreGazeClassification
%         fprintf('\tProcessing gaze data.\n');
%         [eyeEvents, gazeData, cfg_gaze] = ana_extractEyeEvents_new(rawGazeData, dataFolder, gazeArgs);
%         gazeData = AddSubjectAndSession(gazeData, subjectNum, sessionNum);
%         processedGazeData.EyeEvents = eyeEvents;
%         processedGazeData.GazeData = gazeData;
%         processedGazeData.cfg_gaze = cfg_gaze;
%         
%         SaveDataCheckCompleteFile('processedGazeData', processedGazeData);
%         %     fprintf('\tSaving processed gaze data to file.\n');
%         %     if exist(processedDataFilePath, 'file')
%         %         save(processedDataFilePath, 'processedGazeData', '-append');
%         %     else
%         %         save(processedDataFilePath, 'processedGazeData');
%         %     end
%         % elseif ~ignoreGazeClassification
%         %     fprintf('\tProcessed gaze data already loaded into .mat file, loading into workspace.\n');
%         %     eyeEvents = processedGazeData.EyeEvents;
%         %     gazeData = processedGazeData.GazeData;
%         %     load(processedDataFilePath, 'processedGazeData');
%     end
% end
% 
% % if ignoreGazeClassification
% %     gazeData = rawGazeData;
% % end
% 
% %% align eyetracker gaze classifications with frames
% disp('-----------------------------------------------------------------')
% disp('#####   getting frame aligned gaze data')
% 
% 
% if ~ignoreGazeClassification && ~ignoreGaze && any(strcmp(runtimeFolders, 'GazeData')) && (~ismember('EventDataRow', frameData.Properties.VariableNames) || forceGazeFrameAlignment || forceProcessAllData)
% % if (~any(strcmp(singleDataFileVarNames, 'frameData')) || ~ismember('EventDataRow', frameData.Properties.VariableNames) || forceGazeFrameAlignment || forceProcessAllData) && ~ignoreGaze && ~ignoreGazeClassification
%     %match gaze classification to frame data if we haven't already saved it
%     [frameData, unmatchedFrameRows] = AlignFrameAndGazeData(frameData, gazeData, eyeEvents);
% %     trialData = AddFixationCountsToTrialData(trialData, frameData);
%     fprintf('\tSaving gaze-aligned frame data to file.\n');
%     
%     SaveDataCheckCompleteFile('frameData', frameData);
%     SaveDataCheckCompleteFile('unmatchedFrameRows', unmatchedFrameRows);
% %     if exist(processedDataFilePath, 'file')
% %         save(processedDataFilePath, 'frameData', 'unmatchedFrameRows', '-append');
% %     else
% %         save(processedDataFilePath, 'frameData', 'unmatchedFrameRows');
% %     end
% end
% 



if ~ismember('LP', blockData.Properties.VariableNames) || forceLP
    [blockData, trialData] = AddLpInfo(blockData,trialData);
    fprintf('\tSaving block and trial data with LPs to file.\n');
    SaveDataCheckCompleteFile('blockData', blockData);
    SaveDataCheckCompleteFile('trialData', trialData);
%     if exist(processedDataFilePath, 'file')
%         save(processedDataFilePath, 'blockData', 'trialData', '-append');
%     else
%         save(processedDataFilePath, 'blockData', 'trialData');
%     end
end

%     
% subjectDataSmall.TrialData = trialData;
% subjectDataSmall.BlockData = blockData;
% save(processedDataSmallPath, 'subjectDataSmall');

%% save stuff for replayer
replayerPath = [processedDataFilePath filesep 'FrameDataGazeDetails'];

if (~exist(replayerPath, 'dir') || forceSaveFrameDataForReplayer) && ~ignoreReplayer
    mkdir(replayerPath);
    
    reverseStr = '';
    for i = 1:max(frameData.TrialInExperiment)
        %print percentage of processing
        percentDone = 100 * i / max(frameData.TrialInExperiment);
        msg = sprintf('\tWriting replayer frameData files, %3.1f percent finished.', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        writetable(frameData(frameData.TrialInExperiment == i,:), ...
            [replayerPath filesep subjectID '__FrameDataGazeDetails_Trial_' num2str(i) '.txt'], 'Delimiter', '\t');
    end
    fprintf('\n');
else
    if ~ignoreReplayer
        fprintf('\tReplayer frameData files already created.\n');
    end
end

%this takes too bloody long
% display('...Parsing Neurarduino data (this may take a while)')
% subjectData.SerialData = ParseNeurarduinoData(rawData);



function data = AddSubjectAndSession(data, subjectNum, sessionNum)

if ~ismember('SessionNum', data.Properties.VariableNames)
    data = [table(repmat(sessionNum, height(data), 1), 'VariableNames', {'SessionNum'}) data];
end
if ~ismember('SubjectNum', data.Properties.VariableNames)
    data = [table(repmat(subjectNum, height(data), 1), 'VariableNames', {'SubjectNum'}) data];
end

function SaveDataCheckCompleteFile(varname, data)
    
global processedDataPath singleDataFileName; 

SaveData(processedDataPath, [upper(varname(1)) varname(2:end) '.mat'], varname, data);
if ~isempty(singleDataFileName)
    SaveData(processedDataPath, singleDataFileName, varname, data);
end

function data = LoadDataCheckCompleteFile(varname, forceProcessAllData)
    
global processedDataPath singleDataFileName singleDataFileVarNames multiDataFileVarNames; 

iFile = strcmp(multiDataFileVarNames, [upper(varname(1)) varname(2:end) '.mat']);
iVar = strcmp(singleDataFileVarNames, varname);

if ~isempty(iFile) && sum(iFile) > 0 && ~forceProcessAllData
    filename = multiDataFileVarNames{iFile};
% if ~isempty(filename) && ~forceProcessAllData
    data = LoadData(processedDataPath, filename, varname);
elseif ~isempty(iVar) && sum(iVar) > 0 && ~forceProcessAllData
    data = LoadData(processedDataPath, singleDataFileName, varname);
else
    data = [];
end


function SaveData(dataFolderPath, dataFilename, varname, data)

if ~exist(dataFolderPath, 'dir')
    mkdir(dataFolderPath);
end
fprintf(['\tSaving ' varname ' to file.\n']);
S.(varname) = data;

if ~exist([dataFolderPath filesep dataFilename], 'file')
    save([dataFolderPath filesep dataFilename], '-struct', 'S')
else
    save([dataFolderPath filesep dataFilename], '-append', '-struct', 'S');
end
% save([dataFolderPathdataFilename, 'subjectData');

function data = LoadData(dataFolderPath, dataFilename, varname)
if ~exist([dataFolderPath filesep dataFilename], 'file')
    error(['Tried to load the variable ' varname ' from ' [dataFolderPath filesep dataFilename] ' but this file does not exist.']);
else
    try
        fprintf(['\tLoading ' varname ' from file.\n']);
        S = load([dataFolderPath filesep dataFilename], varname);
        data = S.(varname);
    catch e
        error([e.identifier '/t' e.message]);
    end
end




function CleanupFun(path)
cd(path);
warning('on', 'all');

