function [allTrialData, allBlockData, forwardCurveData, backwardCurveData] = ProcessAllSubjectData_FLU(varargin)
% allSubjectData = ProcessMonkeyGamesAllSubjectData(allSubjectData,dataFolder,gazeArgs)

%get current folder, set script to automatically return to this folder in
%event of early closing.
scriptPath = pwd;
finishup = onCleanup(@() ReturnToFolder(scriptPath));
addpath(genpath(scriptPath));



% allSubjectData = CheckVararginPairs('allSubjectData', [], varargin{:});

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

minTrials = CheckVararginPairs('minTrials', 30, varargin{:});
trialsAroundLP = CheckVararginPairs('trialsAroundLP', 10, varargin{:});
exptType = CheckVararginPairs('exptType', 'FLU', varargin{:});

subjFolders = dir(dataFolder);
ignoreFolders = {'', '.', '..', '._', 'DS_Store', '.DS_Store'};


firstSubject = 1;
for iSubj = 1:length(subjFolders)
    
    [subjectPath, subjectID] = fileparts ([dataFolder filesep subjFolders(iSubj).name]);
    if sum(strcmp(ignoreFolders, subjectID)) == 0 && ~isempty(subjectID)
%         if ~isfield(allSubjectData, subjectID)
%             allSubjectData.(subjectID) = [];
%         end
        sessionFolders = dir([subjectPath filesep subjectID]);
        firstSession = 1;
        for iSess = 1:length(sessionFolders)
            [sessionPath, sessionID] = fileparts ([dataFolder filesep subjFolders(iSubj).name filesep sessionFolders(iSess).name]);
            if sum(strcmp(ignoreFolders, sessionID)) == 0 && ~isempty(sessionID)
                [trialData, blockData] = ProcessSingleSessionData_FLU('dataFolder', [sessionPath filesep sessionID], ...
                    'subjectID', subjectID, 'subject#', iSubj, 'gazeArgs', gazeArgs, 'sessionID', sessionID, 'session#', iSess, 'exptType', exptType);
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
        
        
        
        if firstSubject
            allTrialData = subjTrialData;
            allBlockData = subjBlockData;
            [forwardCurveData, backwardCurveData] = FLU_GetConditionMeans(subjTrialData, subjBlockData, exptType, 'minTrials', minTrials, 'trialsAroundLP', trialsAroundLP);
            firstSubject = 0;
        else
            allTrialData = TableConcatVarControl(allTrialData, subjTrialData);
            allBlockData = TableConcatVarControl(allBlockData, subjBlockData);
            [forwardCurveData, backwardCurveData] = FLU_GetConditionMeans(subjTrialData, subjBlockData, exptType,...
                'minTrials', minTrials, 'trialsAroundLP', trialsAroundLP, 'backwardCurves', backwardCurveData, 'forwardCurves', forwardCurveData);
        end
    end
end


dvs = fields(forwardCurveData);
conditions = fields(forwardCurveData.(dvs{1}));

for iDV = 1:length(dvs)
    dv = dvs{iDV};
    for iCond = 1:length(conditions)
        cond = conditions{iCond};
        forwardCurveData.(dv).(cond).Mean = nanmean(forwardCurveData.(dv).(cond).SubjectData, 1);
        backwardCurveData.(dv).(cond).Mean = nanmean(backwardCurveData.(dv).(cond).SubjectData, 1);
        forwardCurveData.(dv).(cond).SEM = SEM(forwardCurveData.(dv).(cond).SubjectData, 1, 1);
        backwardCurveData.(dv).(cond).SEM = SEM(backwardCurveData.(dv).(cond).SubjectData, 1, 1);
    end
end



