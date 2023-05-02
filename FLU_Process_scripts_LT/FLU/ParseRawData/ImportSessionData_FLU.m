function ImportSessionData_FLU(varargin)
%{
Processes a complete set of raw data from a FLU session for later analysis,
saves each data type as table variables in a single .mat file

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
addpath(genpath(scriptPath));

%% Variables to force importing of different data and other fancy stuff
forceAppendAllData = 0;
forceTrialData = 0;
forceBlockData = 0;
forceFrameData = 0;
forceGazeData = 0;
forceUdpData = 0;
forceSerialData = 0;


deleteAbortedTrials = 0;
nanAbortedTrials = 1;

%% Read in varargin pairs
% exptType = CheckVararginPairs('exptType', 'FLU', varargin{:});

dataFolder = CheckVararginPairs('dataFolder', '', varargin{:});
if isempty(dataFolder)
    dataFolder = uigetdir('Data', 'Choose the data folder');
end
% gazeArgs = CheckVararginPairs('gazeArgs', '', varargin{:});

% if isempty(gazeArgs) && ~ignoreGaze
%    b = questdlg('Select the monitor/eye tracker', ...
%     'select monitor/ eye tracker', ...
%     'acer, TX120','TX300','cancel');
%    switch lower(b)
%        case 'acer, tx120'
%            gazeArgs = 'acer120';
%        case 'tx300'
%            gazeArgs = 'tx300';
%        case 'spectrum'
%            gazeArgs = 'spectrum';
%        case 'elo_large'
%            gazeArgs = 'elo_large';
%        case 'cancel'
%            return
%    end
% end

subjectID = CheckVararginPairs('SubjectID', 'Subject1', varargin{:});
subjectNum = CheckVararginPairs('Subject#', 1, varargin{:});

sessionID = CheckVararginPairs('SessionID', 'Sesssion1', varargin{:});
sessionNum = CheckVararginPairs('Session#', 1, varargin{:});


%% Prepare file paths
disp('-----------------------------------------------------------------')
fprintf(['\n\nProcessing data files for subject ' subjectID ', session ' sessionID '.\n']);

runtimeDataPath = [dataFolder filesep 'RuntimeData'];
processedDataFolderPath = [dataFolder filesep 'ProcessedData'];

if ~exist(processedDataFolderPath, 'dir')
    mkdir(processedDataFolderPath);
end

processedDataFilePath = [processedDataFolderPath filesep subjectID '_' sessionID '_AllData.mat'];
% subjectDataStructSmallPath = [processedDataFilePath filesep subjectID '__SubjectDataStructSmall.mat'];


% saveData = 0;

if exist(processedDataFilePath, 'file')
    fprintf('\tSubject data file exists, determining which variables are in it.\n');
    subjVarInfo = who('-file', processedDataFilePath);
else
    subjVarInfo = {};
%     saveData = 1;
end

runtimeFolders = dir(runtimeDataPath);
runtimeFolders = {runtimeFolders.name};

%% Process trial data
if any(strcmp(subjVarInfo, 'trialData')) && ~forceAppendAllData && ~forceTrialData %isfield(subjectData, 'TrialData') && ~forceAppendAllData
    fprintf('\tLoading trial data from file.');
    load(processedDataFilePath, 'trialData');
elseif any(strcmp(runtimeFolders, 'TrialData'))
    trialData = ReadDataFiles([runtimeDataPath filesep 'TrialData'], '*TrialData.txt', 'ImportOptions', {'delimiter', '\t'});
%     if deleteAbortedTrials
%         trialData(abortedTrials,:) = [];
%     elseif nanAbortedTrials
%         for i = abortedTrials'
%             trialData.ContextName{i} = '';
%             trialData.SelectedObjectID{i} = '';
%             trialData.isRewarded{i} = '';
%             trialData.isHighestProbReward{i} = '';
%             for j = 12:width(trialData) % this needs to be referring to specific columns
%                 trialData{i,j} = NaN;
%             end
%         end
%     end
    
    %adds subject and session columns to trial if needed
    trialData = AddSubjectAndSession(trialData, subjectNum, sessionNum);
    
    %remove garbage last trial if exists
    if isequal(trialData(height(trialData), :), trialData(height(trialData)-1,:))
        trialData(height(trialData),:) = [];
    end
end


if any(strcmp(subjVarInfo, 'abortedTrialData'))
    abortedTrialData = load(processedDataFilePath, 'abortedTrialData');
else
    %process aborted trials
    abortedTrials = find(trialData.AbortCode > 0 | trialData.TrialTime < 0);
    abortedTrialData = trialData(abortedTrials,:);
end

if any(strcmp(subjVarInfo, 'trialDefs'))
    trialDefs = load(processedDataFilePath, 'trialDefs');
else
    trialDefs = ReadJsonFiles([runtimeDataPath filesep 'TrialData'], '*trialdef_on_trial_*');
end


%% Process block data
if any(strcmp(subjVarInfo, 'blockData')) && ~forceAppendAllData && ~forceBlockData %isfield(subjectData, 'BlockData') && ~forceAppendAllData
    load(processedDataFilePath, 'blockData');
elseif any(strcmp(runtimeFolders, 'BlockData'))
    blockData = ReadDataFiles([runtimeDataPath filesep 'BlockData'], '*BlockData.txt', 'ImportOptions', {'delimiter', '\t'});
    if iscell(blockData.LastTrial)
        blockData.LastTrial = str2double(blockData.LastTrial);
    end
    blockData = AddSubjectAndSession(blockData, subjectNum, sessionNum);
end

%% Check for some annoying issues with block/trial data

% force block numbers not to be 0-indexed
if min(trialData.Block) == 0
    trialData.Block = trialData.Block + 1;
end

if min(blockData.Block) == 0
    blockData.Block = blockData.Block + 1;
end

% was last block row saved twice
if height(blockData) > 1
    if isequal(blockData(height(blockData), :), blockData(height(blockData)-1,:))
        badBlock = blockData.Block(height(blockData));
    else
        badBlock = [];
    end
else
    badBlock = [];
end

%is block data from incomplete block
badBlock = [badBlock; blockData.Block(isnan(blockData.FirstTrial) | isnan(blockData.LastTrial))];

blockData(ismember(blockData.Block, badBlock),:) = [];
trialData(ismember(trialData.Block, badBlock),:) = [];

%% Save Block and Trial Data

%save trial data
fprintf('\tSaving trial data to file.\n');
if exist(processedDataFilePath, 'file')
    save(processedDataFilePath, 'trialData', 'abortedTrialData', 'trialDefs', '-append');
else
    save(processedDataFilePath, 'trialData', 'abortedTrialData', 'trialDefs');
end


%save block data
fprintf('\tSaving block data to file.\n');
save(processedDataFilePath, 'blockData', '-append');

%% Process Frame Data
if any(strcmp(subjVarInfo, 'frameData')) && ~forceAppendAllData && ~forceFrameData
    load(processedDataFilePath, 'frameData');
    %some old data files import frame data incorrectly as a single column
    if width(frameData) == 1
        forceFrameData = 1;
    end
end
if (~any(strcmp(subjVarInfo, 'frameData')) || forceAppendAllData || forceFrameData) && any(strcmp(runtimeFolders, 'FrameData'))
    frameData = ReadDataFiles([runtimeDataPath filesep 'FrameData'], '*Trial*.txt', 'importOptions', {'delimiter', '\t'});
    frameData = AddSubjectAndSession(frameData, subjectNum, sessionNum);
    fprintf('\tSaving frame data to file.\n');
    save(processedDataFilePath, 'frameData', '-append');
end

%% Process Gaze Data

if any(strcmp(subjVarInfo, 'rawGazeData')) && ~forceAppendAllData && ~forceGazeData
    load(processedDataFilePath, 'rawGazeData');
elseif any(strcmp(runtimeFolders, 'GazeData'))
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
        rawGazeData = ReadDataFiles(gazeDataPath, '*Trial*.txt', 'ImportOptions', {'delimiter', '\t'});
    end
    fprintf('\tSaving gaze data to file.\n');
    save(processedDataFilePath, 'rawGazeData', '-append');
end

% Process UDP data
if any(strcmp(subjVarInfo, 'udpData')) && ~forceAppendAllData && ~forceUdpData
    load(processedDataFilePath, 'udpData');
else
    if any(strcmp(runtimeFolders, 'UnityUDPRecvData'))
        udpData.UnityUdpRecvData = ReadDataFiles([runtimeDataPath filesep 'UnityUDPRecvData'], '*UDPRecv*.txt', 'ImportOptions', {'delimiter', '\t'});
    else
        udpData.UnityUdpRecvData = 'No Unity UDP Recv Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'UnityUDPSentData'))
        udpData.UnityUdpSentData = ReadDataFiles([runtimeDataPath filesep 'UnityUDPSentData'], '*UDPSent*.txt', 'ImportOptions', {'delimiter', '\t'});
    else
        udpData.UnityUdpSentData = 'No Unity UDP Sent Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'PythonUDPRecvData'))
        udpData.PythonRecvData = ReadDataFiles([runtimeDataPath filesep 'PythonUDPRecvData'], '*UDPRecv*.txt', 'ImportOptions', {'delimiter', '\t'});
    else
        udpData.PythonRecvData = 'No Python UDP Recv Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'PythonUDPRecvData'))
        udpData.PythonSentData = ReadDataFiles([runtimeDataPath filesep 'PythonUDPSentData'], '*UDPSent*.txt', 'ImportOptions', {'delimiter', '\t'});
    else
        udpData.PythonSentData = 'No Python UDP Sent Data In Raw Data Files';
    end
    fprintf('\tSaving udp data to file.\n');
    save(processedDataFilePath, 'udpData', '-append');
end

%% Process Serial data


if any(strcmp(subjVarInfo, 'serialData')) && ~forceAppendAllData && ~forceSerialData
    load(processedDataFilePath, 'serialData');
else
    if any(strcmp(runtimeFolders, 'SerialRecv'))
        serialData.SerialRecvDataRaw = ReadDataFiles([runtimeDataPath filesep 'SerialRecv'], '*SerialRecv*.txt', 'ImportOptions', {'delimiter', '\t'});
        serialData.SerialRecvDataEvents = ExtractSerialRecvDataEventCodes(serialRecvData);
    else
        serialData.SerialRecvData = 'No Serial Recv Data In Raw Data Files';
    end
    if any(strcmp(runtimeFolders, 'SerialSent'))
        serialData.SerialSentDataRaw = ReadDataFiles([runtimeDataPath filesep 'SerialSent'], '*SerialSent*.txt', 'ImportOptions', {'delimiter', '\t'});
        serialData.SerialSentDataEvents = ExtractSerialSentDataEventCodes(serialSentData);
    else
        serialData.SerialSentData = 'No Serial Sent Data In Raw Data Files';
    end
    fprintf('\tSaving serial data to file.\n');
    save(processedDataFilePath, 'serialData', '-append');
end



function data = AddSubjectAndSession(data, subjectNum, sessionNum)

if ~ismember('SessionNum', data.Properties.VariableNames)
    data = [table(repmat(sessionNum, height(data), 1), 'VariableNames', {'SessionNum'}) data];
end
if ~ismember('SubjectNum', data.Properties.VariableNames)
    data = [table(repmat(subjectNum, height(data), 1), 'VariableNames', {'SubjectNum'}) data];
end

    
% function SaveData(subjectData, processedDataFilePath)
% 
% if ~exist(processedDataFilePath, 'dir')
%     mkdir(processedDataFilePath);
% end
% fprintf('\tSaving raw data to file.\n');
% save(processedDataFilePath, 'subjectData');


function CleanupFun(path)
cd(path);
warning('on', 'all');

