function ProcessSubjectData_FLU(varargin)
%{
Basic processing of a complete set of data from a FLU subject:
- imports the raw data files for each session, adds LP and block condition
information, saves to disk
- calculates condition-specific forward and backward learning curves for
the subject

Arguments should be in name-value pairs as follows (the order of the pairs
is not important). If an argument pair not given, the default value is used

'exptType', string representing the experiment name, default is 'FLU'
'subjectFolder', string path to the subject's folder, no default
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


subjectFolder = CheckVararginPairs('subjectFolder', '', varargin{:});
if isempty(subjectFolder)
    subjectFolder = uigetdir('Data', 'Choose the data folder');
end
gazeArgs = CheckVararginPairs('gazeArgs', '', varargin{:});

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

ignoreFolders = {'', '.', '..', '._', 'DS_Store', '.DS_Store'};
subjectID = CheckVararginPairs('SubjectID', 'Subject1', varargin{:});
subjectNum = CheckVararginPairs('Subject#', 1, varargin{:});
exptType = CheckVararginPairs('ExptType', 'FLU', varargin{:});


sessionFolders = dir(subjectFolder);
firstSession = 1;
for iSess = 1:length(sessionFolders)
    [sessionPath, sessionID] = fileparts ([subjectFolder filesep sessionFolders(iSess).name]);
    disp(sessionID);
    if sum(strcmp(ignoreFolders, sessionID)) == 0 && ~isempty(sessionID)
        [trialData, blockData] = ProcessSessionData_FLU('dataFolder', [sessionPath filesep sessionID], ...
            'subjectID', subjectID, 'subject#', subjectNum, 'gazeArgs', gazeArgs, 'sessionID', sessionID, 'session#', iSess, 'exptType', exptType);
        if firstSession
            subjTrialData = trialData;
            subjBlockData = blockData;
            firstSession = 0;
        else
            subjTrialData = TableConcatVarControl(subjTrialData, trialData);
            subjBlockData = TableConcatVarControl(subjBlockData, blockData);
        end
    end
end

[forwardCurveData, backwardCurveData] = FLU_GetConditionCurves(subjTrialData,subjBlockData, 'FLU');

save([subjectFolder filesep subjectID '_AllSessionData.mat'], 'subjTrialData', 'subjBlockData', 'forwardCurveData', 'backwardCurveData');



function CleanupFun(path)
cd(path);
warning('on', 'all');