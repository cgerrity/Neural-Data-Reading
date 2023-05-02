function [trialData, blockData] = ProcessSessionData_FLU(varargin)
%{
Basic processing of a complete set of data from a FLU session:
- imports the raw data files, saving them to disc
- adds LP and block condition information

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

ImportSessionData_FLU('DataFolder', dataFolder, 'SubjectID', subjectID, 'Subject#', subjectNum, 'SessionID', sessionID, 'Session#', sessionNum);

processedDataFilePath = [dataFolder filesep 'ProcessedData' filesep subjectID '_' sessionID '_AllData.mat'];
load(processedDataFilePath, 'frameData');
load(processedDataFilePath, 'trialData');
load(processedDataFilePath, 'blockData');
[blockData, trialData] = AddLpInfo(blockData, trialData);
frameData = AddReplayerGazeToFluFrameData([dataFolder filesep 'ProcessedData'], subjectID, frameData);
trialData = AddFixationCountsToTrialData(trialData, frameData);
blockData = AddBlockType(blockData, 'FLU', [dataFolder filesep 'RuntimeData']);
trialData = AddBlockFactorsToTrialData(trialData, blockData);

save(processedDataFilePath, 'frameData', 'trialData', 'blockData', '-append');



function CleanupFun(path)
cd(path);
warning('on', 'all');