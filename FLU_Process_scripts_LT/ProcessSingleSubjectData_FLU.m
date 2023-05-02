function [trialData, blockData] = ProcessSingleSubjectData_FLU(varargin)
% subjectData = ProcessMonkeyGamesSingleSubjectData(dataFolder)
% subjectData = ProcessMonkeyGamesSingleSubjectData(dataFolder,gazestring)

%get current folder, set script to automatically return to this folder in
%event of early closing.
scriptPath = pwd;
finishup = onCleanup(@() CleanupFun(scriptPath));
addpath(genpath(scriptPath));

%% variables to force recaculation
forceAppendData = 0;
forceGazeClassification = 0;
forceGazeFrameAlignment = 0;
forceSaveFrameDataForReplayer = 0;
ignoreGaze = 0;
forceLP = 0;

%% set subject data paths and read in data
exptType = CheckVararginPairs('exptType', 'FLU', varargin{:});

dataFolder = CheckVararginPairs('dataFolder', '', varargin{:});
if isempty(dataFolder)
    dataFolder = uigetdir('Data', 'Choose the data folder');
end
gazeArgs = CheckVararginPairs('gazeArgs', '', varargin{:});

if isempty(gazeArgs) 
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
fprintf(['\n\nProcessing data files for subject ' subjectID '.\n']);

runtimeDataPath = [dataFolder filesep 'RuntimeData'];
processedDataPath = [dataFolder filesep 'ProcessedData'];
subjectDataStructPath = [processedDataPath filesep subjectID '__SubjectDataStruct.mat'];
subjectDataStructSmallPath = [processedDataPath filesep subjectID '__SubjectDataStructSmall.mat'];


saveData = 0;

if exist(subjectDataStructPath, 'file')
    fprintf('\tRaw data already loaded into .mat file, loading into workspace.\n');
    load(subjectDataStructPath);
else
    saveData = 1;
    subjectData = [];
end

    

fprintf('\tReading trial data files.\n');

if isfield(subjectData, 'TrialData') && ~forceAppendData
    trialData = subjectData.TrialData;
    abortedTrialData = subjectData.AbortedTrialData;
else
    saveData = 1;
    trialData = ReadDataFiles([runtimeDataPath filesep 'TrialData'], '*TrialData.txt');
    abortedTrials = trialData.AbortCode > 0 | trialData.TrialTime < 0;
    abortedTrialData = trialData(abortedTrials,:);
    trialData(abortedTrials,:) = [];
    trialData = AddSubjectAndSession(trialData, subjectNum, sessionNum);
end

if isequal(trialData(height(trialData), :), trialData(height(trialData)-1,:))
    trialData(height(trialData),:) = [];
end


if isfield(subjectData, 'BlockData') && ~forceAppendData
    blockData = subjectData.BlockData;
else
    saveData = 1;
    blockData = ReadDataFiles([runtimeDataPath filesep 'BlockData'], '*BlockData.txt');
    blockData = AddSubjectAndSession(blockData, subjectNum, sessionNum);
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
end

if ~ismember('ID_ED', blockData.Properties.VariableNames) || forceAppendData
    blockData = AddBlockType(blockData, exptType, runtimeDataPath);
end

if isfield(subjectData, 'FrameData') && ~forceAppendData
    frameData = subjectData.FrameData;
else
    saveData = 1;
    frameData = ReadDataFiles([runtimeDataPath filesep 'FrameData'], '*Trial*.txt', 'importOptions', {'delimiter', '\t'});
    frameData = AddSubjectAndSession(frameData, subjectNum, sessionNum);
end

if isfield(subjectData, 'ProcessedEyeData') && ~forceAppendData
%     rawGazeData = subjectData.RawGazeData;
elseif ~ignoreGaze
    saveData = 1;
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
        rawGazeData = ParseGazeData(gazeDataPath, '*Trial*.txt', scriptPath);%, badTrial);
    else
        rawGazeData = ReadDataFiles(gazeDataPath, '*Trial*.txt');
    end
end


%     pythonUDPRecvPath = [runtimeDataPath filesep 'PythonUDPRecvData'];
%     pythonUDPRecvData = ParsePythonUDPRecv_FLU(pythonUDPRecvPath, '*Trial*.txt', scriptPath, badTrial);
%     
%     pythonUDPSentPath = [runtimeDataPath filesep 'PythonUDPSentData'];
%     pythonUDPSentData = ParsePythonUDPSent_FLU(pythonUDPSentPath, '*Trial*.txt', scriptPath, badTrial);
%     
%     unityUDPRecvPath = [runtimeDataPath filesep 'UnityUDPRecvData'];
%     [unityUDPRecvData unityGazeData] = ParseUnityUDPRecv_FLU(unityUDPRecvPath, '*Trial*.txt', scriptPath, badTrial);
%     
%     unityUDPSentPath = [runtimeDataPath filesep 'UnityUDPSentData'];
%     unityUDPSentData = AppendDataFiles(unityUDPSentPath, '*Trial*.txt', scriptPath);
    
%     %trim data from incomplete final trial
%     lastCompleteTrial = max(trialData.TrialInExperiment);
%     frameData(frameData.TrialInExperiment > lastCompleteTrial,:) = [];
    
%     subjectData.Runtime.RulesetData = rulesetData;
%     subjectData.Runtime.BehaviouralSummary = behaviouralSummary;
%     subjectData.Runtime.RawGazeData = rawGazeData;
%     subjectData.Runtime.AbortedTrialFrameData = abortedTrialFrameData;
%     subjectData.Runtime.AbortedTrialRawGazeData = abortedTrialRawGazeData;


%% extract gaze classifications and add to trialData and frameData files 
disp('-----------------------------------------------------------------')
disp('#####   getting gaze classification')

if (~isfield(subjectData, 'ProcessedEyeData') || forceGazeClassification) && ~ignoreGaze
    fprintf('\tProcessing gaze data.\n');
    [eyeEvents, gazeData, cfg_gaze] = ana_extractEyeEvents_new(rawGazeData, dataFolder, gazeArgs);
    gazeData = AddSubjectAndSession(gazeData, subjectNum, sessionNum);
    subjectData.ProcessedEyeData.EyeEvents = eyeEvents;
    subjectData.ProcessedEyeData.GazeData = gazeData;
    subjectData.ProcessedEyeData.cfg_gaze = cfg_gaze;
    saveData = 1;
elseif ~ignoreGaze
    fprintf('\tProcessed gaze data already loaded into .mat file, loading into workspace.\n');
    eyeEvents = subjectData.ProcessedEyeData.EyeEvents;
    gazeData = subjectData.ProcessedEyeData.GazeData;
end

%% align eyetracker gaze classifications with frames
disp('-----------------------------------------------------------------')
disp('#####   getting frame aligned gaze data')

if (~isfield(subjectData, 'FrameData') || ~ismember('EventDataRow', subjectData.FrameData.Properties.VariableNames) || forceGazeFrameAlignment || forceAppendData) && ~ignoreGaze
    %match gaze classification to frame data if we haven't already saved it
    saveData = 1;
    [frameData, subjectData.UnmatchedFrameRows] = AlignFrameAndGazeData(frameData, gazeData, eyeEvents);
%     trialData = AddFixationCountsToTrialData(trialData, frameData);
end


if ~ismember('LP', blockData.Properties.VariableNames) || forceLP
    saveData = 1;
    [blockData, trialData] = AddLpInfo(blockData,trialData);
end


if saveData
    subjectData.TrialData = trialData;
    subjectData.AbortedTrialData = abortedTrialData;
    subjectData.BlockData = blockData;
    subjectData.FrameData = frameData;
    if ~exist(processedDataPath, 'dir')
        mkdir(processedDataPath);
    end
    fprintf('\tSaving raw data to file.\n');
    save(subjectDataStructPath, 'subjectData');
    
    subjectDataSmall.TrialData = trialData;
    subjectDataSmall.BlockData = blockData;
    save(subjectDataStructSmallPath, 'subjectDataSmall');
end

%% save stuff for replayer
replayerPath = [processedDataPath filesep 'FrameDataGazeDetails'];

if ~exist(replayerPath, 'dir') || forceSaveFrameDataForReplayer
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
    fprintf('\tReplayer frameData files already created.\n');
end

%this takes too bloody long
% display('...Parsing Neurarduino data (this may take a while)')
% subjectData.SerialData = ParseNeurarduinoData(rawData);


function [dataTable, abortedTrialDataTable] = AppendDataFiles(folder, filestring, scriptPath, varargin)
cd(folder)
fileInfo = dir(filestring);
[fileNames,~] = sort_nat({fileInfo.name}');

if ~isempty(varargin)
%     badTrials = ~cellfun('isempty',strfind(fileNames, ['Trial_' num2str(varargin{1})]));
% %     fileNames(badTrials) = [];
%     for iFile = 1:length(fileNames)
    badTrials = varargin{1};
else
    badTrials = [];
end

%weird bad data files get saved with . at start
moreBad = startsWith(fileNames, '.');
fileNames(moreBad) = [];

cd(scriptPath)
dataTable = readtable([folder filesep fileNames{1}], 'delimiter', '\t');
abortedTrialDataTable = readtable([folder filesep fileNames{1}], 'delimiter', '\t');

[~,folderName,~] = fileparts(folder);
warned = 0;
reverseStr = '';
for i = 2:length(fileNames)
    %print percentage of file reading
    percentDone = 100 * i / size(fileNames,1);
    msg = sprintf(['\tReading files from ' folderName ' folder, %3.1f percent finished.'], percentDone); %Don't forget this semicolon
    fprintf([reverseStr, msg]);
    if ~strcmp(fileNames{i}(1:end-4), fileNames{i-1}(1:end-7)) %sometimes duplicate files are created, ignore them
        
        newTable = readtable([folder filesep fileNames{i}], 'delimiter', '\t', 'treatasempty', '');
        [msgstr, msgid] = lastwarn;
        if ~isempty(msgstr) && ~warned
            fprintf('\n');
            warning(msgstr);
            fprintf('\n');
            fprintf([reverseStr, msg]);
            warned = 1;
            warning('off', msgid);
            warning('');
            lastwarn('');
        end
        
        try
            bad = 0;
            for iTrial = 1:length(badTrials)
                if strfind(fileNames{i}, ['Trial_' num2str(badTrials(iTrial))])
                    bad = 1;
                    break;
                end
            end
            if ~bad
                dataTable = [dataTable; newTable]; %#ok<AGROW>
            else
                abortedTrialDataTable = [abortedTrialDataTable; newTable]; %#ok<AGROW>
            end
        catch
            disp(fileNames{i})
        end
        CheckBlankLines([folder filesep fileNames{i}], newTable)
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    else
        grrr = 1;
    end
end

if warned
    warning('on', 'all');
end

fprintf('\n');


function CheckBlankLines(path, dataTable)
%deal with blank lines in data tables - rewrite table without lines if
%found.
fid = fopen(path);

newline = sprintf('\r\n');
containsBlanks = 0;
for i = 1:10
    line = fgets(fid);
    if strcmp(newline,line) || length(line) == 1
        containsBlanks = 1;
    end
end
fclose(fid);

if containsBlanks
    writetable(dataTable, path, 'delimiter', '\t');
end

% 
% 
% function [cs,index] = sort_nat(c,mode)
% %sort_nat: Natural order sort of cell array of strings.
% % usage:  [S,INDEX] = sort_nat(C)
% %
% % where,
% %    C is a cell array (vector) of strings to be sorted.
% %    S is C, sorted in natural order.
% %    INDEX is the sort order such that S = C(INDEX);
% %
% % Natural order sorting sorts strings containing digits in a way such that
% % the numerical value of the digits is taken into account.  It is
% % especially useful for sorting file names containing index numbers with
% % different numbers of digits.  Often, people will use leading zeros to get
% % the right sort order, but with this function you don't have to do that.
% % For example, if C = {'file1.txt','file2.txt','file10.txt'}, a normal sort
% % will give you
% %
% %       {'file1.txt'  'file10.txt'  'file2.txt'}
% %
% % whereas, sort_nat will give you
% %
% %       {'file1.txt'  'file2.txt'  'file10.txt'}
% %
% % See also: sort
% 
% % Version: 1.4, 22 January 2011
% % Author:  Douglas M. Schwarz
% % Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% % Real_email = regexprep(Email,{'=','*'},{'@','.'})
% 
% 
% % Set default value for mode if necessary.
% if nargin < 2
% 	mode = 'ascend';
% end
% 
% % Make sure mode is either 'ascend' or 'descend'.
% modes = strcmpi(mode,{'ascend','descend'});
% is_descend = modes(2);
% if ~any(modes)
% 	error('sort_nat:sortDirection',...
% 		'sorting direction must be ''ascend'' or ''descend''.')
% end
% 
% % Replace runs of digits with '0'.
% c2 = regexprep(c,'\d+','0');
% 
% % Compute char version of c2 and locations of zeros.
% s1 = char(c2);
% z = s1 == '0';
% 
% % Extract the runs of digits and their start and end indices.
% [digruns,first,last] = regexp(c,'\d+','match','start','end');
% 
% % Create matrix of numerical values of runs of digits and a matrix of the
% % number of digits in each run.
% num_str = length(c);
% max_len = size(s1,2);
% num_val = NaN(num_str,max_len);
% num_dig = NaN(num_str,max_len);
% for i = 1:num_str
% 	num_val(i,z(i,:)) = sscanf(sprintf('%s ',digruns{i}{:}),'%f');
% 	num_dig(i,z(i,:)) = last{i} - first{i} + 1;
% end
% 
% % Find columns that have at least one non-NaN.  Make sure activecols is a
% % 1-by-n vector even if n = 0.
% activecols = reshape(find(~all(isnan(num_val))),1,[]);
% n = length(activecols);
% 
% % Compute which columns in the composite matrix get the numbers.
% numcols = activecols + (1:2:2*n);
% 
% % Compute which columns in the composite matrix get the number of digits.
% ndigcols = numcols + 1;
% 
% % Compute which columns in the composite matrix get chars.
% charcols = true(1,max_len + 2*n);
% charcols(numcols) = false;
% charcols(ndigcols) = false;
% 
% % Create and fill composite matrix, comp.
% comp = zeros(num_str,max_len + 2*n);
% comp(:,charcols) = double(s1);
% comp(:,numcols) = num_val(:,activecols);
% comp(:,ndigcols) = num_dig(:,activecols);
% 
% % Sort rows of composite matrix and use index to sort c in ascending or
% % descending order, depending on mode.
% [unused,index] = sortrows(comp);
% if is_descend
% 	index = index(end:-1:1);
% end
% index = reshape(index,size(c));
% cs = c(index);


function data = AddSubjectAndSession(data, subjectNum, sessionNum)

if ~ismember('SessionNum', data.Properties.VariableNames)
    data = [table(repmat(sessionNum, height(data), 1), 'VariableNames', {'SessionNum'}) data];
end
if ~ismember('SubjectNum', data.Properties.VariableNames)
    data = [table(repmat(subjectNum, height(data), 1), 'VariableNames', {'SubjectNum'}) data];
end

    


function CleanupFun(path)
cd(path);
warning('on', 'all');

