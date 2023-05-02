function [allBlockData, allTrialData] = CombineAllSubjectFluData(dataFolder)%, allForwardCurveData, allBackwardCurveData] = CombineAllSubjectFluData(dataFolder)


%get current folder, set script to automatically return to this folder in
%event of early closing.
scriptPath = pwd;
finishup = onCleanup(@() CleanupFun(scriptPath));
% addpath(genpath(scriptPath));


ignoreFolders = {'', '.', '..', '._', 'DS_Store', '.DS_Store'};

subjectFolders = dir(dataFolder);
subjCount = 0;
for iFolder = 1:length(subjectFolders)
    [subjectPath, subjectID] = fileparts ([dataFolder filesep subjectFolders(iFolder).name]);
    if sum(strcmp(ignoreFolders, subjectID)) == 0 && ~isempty(subjectID) && ~strcmp(subjectID(1), '.')
        subjCount = subjCount + 1;
        load([subjectPath filesep subjectID filesep subjectID '_AllSessionData.mat']);
        if subjCount == 1
            allBlockData = subjBlockData;
            allTrialData = subjTrialData;
%             allForwardCurveData = forwardCurveData;
%             allBackwardCurveData = backwardCurveData;
        else
            allBlockData = TableConcatVarControl(allBlockData, subjBlockData);
            allTrialData = TableConcatVarControl(allTrialData, subjTrialData);
%             allForwardCurveData = AppendSubjCurveData(allForwardCurveData, forwardCurveData);
%             allBackwardCurveData = AppendSubjCurveData(allBackwardCurveData, backwardCurveData);
        end
    end
end

allTrialData = CorrectAbortTrialNumbersFlu(allTrialData);
allTrialData.TimeTouchFromLiftOfHoldKey(allTrialData.TimeTouchFromLiftOfHoldKey == -9999) = NaN;
% allForwardCurveData = AddSummaryCurvesData(allForwardCurveData);
% allBackwardCurveData = AddSummaryCurvesData(allBackwardCurveData);
save([dataFolder filesep 'AllSubjectDataNoAbortCorrection.mat'], 'allBlockData', 'allTrialData');%, 'allForwardCurveData', 'allBackwardCurveData');


function allCurveData = AppendSubjCurveData(allCurveData, subjCurveData)
dvs = fields(allCurveData);
for iDV = 1:length(dvs)
    dv = dvs{iDV};
    conditions = fields(allCurveData.(dv));
    for iCond = 1:length(conditions)
        cond = conditions{iCond};
        if strcmpi(dv,'Acc')
            allCurveData.(dv).(cond).SubjectData = [allCurveData.(dv).(cond).SubjectData; subjCurveData.(dv).(cond).SubjectData];
        else
            allCurveData.(dv).(cond).AllAcc.SubjectData = [allCurveData.(dv).(cond).AllAcc.SubjectData; subjCurveData.(dv).(cond).AllAcc.SubjectData];
            allCurveData.(dv).(cond).Corr.SubjectData = [allCurveData.(dv).(cond).Corr.SubjectData; subjCurveData.(dv).(cond).Corr.SubjectData];
            allCurveData.(dv).(cond).Inc.SubjectData = [allCurveData.(dv).(cond).Inc.SubjectData; subjCurveData.(dv).(cond).Inc.SubjectData];
        end
    end
end

function allCurveData = AddSummaryCurvesData(allCurveData)
dvs = fields(allCurveData);
for iDV = 1:length(dvs)
    dv = dvs{iDV};
    conditions = fields(allCurveData.(dv));
    for iCond = 1:length(conditions)
        cond = conditions{iCond};
        if strcmpi(dv, 'Acc')
            allCurveData.(dv).(cond).Mean = nanmean(allCurveData.(dv).(cond).SubjectData);
            allCurveData.(dv).(cond).Median = nanmedian(allCurveData.(dv).(cond).SubjectData);
            allCurveData.(dv).(cond).SEM = SEM(allCurveData.(dv).(cond).SubjectData);
        else
            allCurveData.(dv).(cond).AllAcc.Mean = nanmean(allCurveData.(dv).(cond).AllAcc.SubjectData);
            allCurveData.(dv).(cond).AllAcc.Median = nanmedian(allCurveData.(dv).(cond).AllAcc.SubjectData);
            allCurveData.(dv).(cond).AllAcc.SEM = SEM(allCurveData.(dv).(cond).AllAcc.SubjectData);
            allCurveData.(dv).(cond).Corr.Mean = nanmean(allCurveData.(dv).(cond).Corr.SubjectData);
            allCurveData.(dv).(cond).Corr.Median = nanmedian(allCurveData.(dv).(cond).Corr.SubjectData);
            allCurveData.(dv).(cond).Corr.SEM = SEM(allCurveData.(dv).(cond).Corr.SubjectData);
            allCurveData.(dv).(cond).Inc.Mean = nanmean(allCurveData.(dv).(cond).Inc.SubjectData);
            allCurveData.(dv).(cond).Inc.Median = nanmedian(allCurveData.(dv).(cond).Inc.SubjectData);
            allCurveData.(dv).(cond).Inc.SEM = SEM(allCurveData.(dv).(cond).Inc.SubjectData);
        end
    end
end

function CleanupFun(path)
cd(path);
warning('on', 'all');