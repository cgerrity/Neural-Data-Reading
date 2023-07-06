function [Output] = cgg_procFullTrialPreparation_v2(varargin)
%cgg_procFullTrialPreparation_v2 Summary of this function goes here
%   Detailed explanation goes here

%% Parameters

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2;

TrialDuration_Minimum=cfg_param.TrialDuration_Minimum;
% Count_Sel_Trial=cfg_param.Count_Sel_Trial;

probe_area=cfg_param.probe_area;
Activity_Type=cfg_param.Activity_Type;
Smooth_Factor=cfg_param.Smooth_Factor;

Frame_Event_Selection_Data=cfg_param.Frame_Event_Selection_Data;
Frame_Event_Selection_Location_Data=cfg_param.Frame_Event_Selection_Location_Data;
Window_Before_Data=cfg_param.Window_Before_Data;
Window_After_Data=cfg_param.Window_After_Data;

Frame_Event_Selection_Baseline=cfg_param.Frame_Event_Selection_Baseline;
Frame_Event_Selection_Location_Baseline=cfg_param.Frame_Event_Selection_Location_Baseline;
Window_Before_Baseline=cfg_param.Window_Before_Baseline;
Window_After_Baseline=cfg_param.Window_After_Baseline;


%% Get input/output folders

isfunction=exist('varargin','var');

% Get the directories needed depending on whether this is called as a
% function or as a script for testing
if isfunction
[cfg] = cgg_generateNeuralDataFoldersTopLevel(varargin{:});
elseif (exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',...
    inputfolder,'outdatadir',outdatadir);
elseif (exist('inputfolder','var'))&&~(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',inputfolder);
elseif ~(exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('outdatadir',outdatadir);
else
[cfg] = cgg_generateNeuralDataFoldersTopLevel;
end

inputfolder=cfg.inputfolder;
outdatadir=cfg.outdatadir;

[cfg_directories] = cgg_generateNeuralDataFolders_v2(probe_area,'inputfolder',inputfolder,'outdatadir',outdatadir);

%% Get the time point indices for the trials
[Start_IDX_Data,End_IDX_Data] = cgg_getTimeSegments_v2(...
    'inputfolder',inputfolder,'outdatadir',outdatadir,...
    'Activity_Type',Activity_Type,...
    'Frame_Event_Selection',Frame_Event_Selection_Data,...
    'Frame_Event_Selection_Location',Frame_Event_Selection_Location_Data,...
    'Frame_Event_Window_Before',Window_Before_Data,...
    'Frame_Event_Window_After',Window_After_Data);

[Start_IDX_Base,End_IDX_Base] = cgg_getTimeSegments_v2(...
    'inputfolder',inputfolder,'outdatadir',outdatadir,...
    'Activity_Type',Activity_Type,...
    'Frame_Event_Selection',Frame_Event_Selection_Baseline,...
    'Frame_Event_Selection_Location',Frame_Event_Selection_Location_Baseline,...
    'Frame_Event_Window_Before',Window_Before_Baseline,...
    'Frame_Event_Window_After',Window_After_Baseline);

%% Get the full file name
fullfilename = cgg_generateActivityFullFileName('inputfolder',inputfolder,'outdatadir',outdatadir,...
    'Activity_Type',Activity_Type,'probe_area',probe_area);

%% Identify the Disconnected Channels

[Connected_Channels,Disconnected_Channels,is_any_previously_rereferenced] = cgg_loadChannelClusteringFromDirectories(cfg_directories);

%% Get the segmented data and smooth it

[Segmented_Data,TrialNumbers_Data,~] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX_Data,End_IDX_Data,fullfilename,Smooth_Factor,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[Segmented_Baseline,TrialNumbers_Baseline,~] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX_Base,End_IDX_Base,fullfilename,Smooth_Factor,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

%% Detrend the data according to the baseline period

[Detrend_Data,Detrend_Baseline] = cgg_procDetrendFromBaseline(Segmented_Data,Segmented_Baseline,TrialNumbers_Baseline);

%% Get the trial variables

[trialVariables] = cgg_getTrialVariables('inputfolder',inputfolder,'outdatadir',outdatadir);

%% Select the data that is not aborted or too long

TrialVariableTrialNumber=[trialVariables(:).TrialNumber];

[TrialCondition,MatchValue] = cgg_getTrialCriteriaBaseline(trialVariables,'TrialDuration_Minimum',TrialDuration_Minimum);

[MatchData,~,~,MatchTrialNumber_Data] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition,MatchValue,TrialVariableTrialNumber,Detrend_Data,TrialNumbers_Data);
[MatchBaseline,~,~,MatchTrialNumber_Baseline] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition,MatchValue,TrialVariableTrialNumber,Detrend_Baseline,TrialNumbers_Baseline);

FullBaseline=MatchBaseline;

%% Normalize the baseline and data according to the baseline period

[Mean_Norm_Data,Mean_Norm_Baseline,...
    STD_ERROR_Norm_Data,STD_ERROR_Norm_Baseline,...
    Norm_Data,Norm_Baseline] = ...
    cgg_procTrialNormalization_v2(MatchData,MatchBaseline,FullBaseline);

%%

Output=struct();

Output(1).Name='Description of Each Field';
Output(2).Name='Data';
Output(3).Name='Baseline';

Output(1).Mean={'Mean Value of the signal source across trials.';...
    ['The value for each time point and each channel is averaged '...
    'across each trial.']};
Output(2).Mean=Mean_Norm_Data;
Output(3).Mean=Mean_Norm_Baseline;

Output(1).STD_Error={['Standard Error of the mean of the signal source '...
    'across trials.'];...
    ['The value for each time point and each channel is averaged '...
    'across each trial. Then the standard error of this mean is taken.']};
Output(2).STD_Error=STD_ERROR_Norm_Data;
Output(3).STD_Error=STD_ERROR_Norm_Baseline;

Output(1).Trials={'All the trials for the data source';...
    ['Each channel is baseline z-scored by the mean and standard '...
    'deviation that come from the FullBaseline. This FullBaseline '...
    'excludes aborted trials and trials longer than specified. The '...
    'activity of all the trials for all time points of a channel are '...
    'used to calculate the mean and standard deviations for normalizing']};
Output(2).Trials=Norm_Data;
Output(3).Trials=Norm_Baseline;

Output(1).TrialNumber={'The trial numbers for each trial.';...
    ['The trial number is unique for each trial whether it is aborted '...
    'or not. This value indicates which of the trials is included in '...
    'this data since there are no numbers on the Trials field. The '...
    'first trial in the Trials field could have trial number 2. This '...
    'would be the second trial in the session but the first in the '...
    'Trials field']};
Output(2).TrialNumber=MatchTrialNumber_Data;
Output(3).TrialNumber=MatchTrialNumber_Baseline;

Output(1).Connected_Channels={'Channels that are connected.';...
    ['The Channels that are in the brain and recording brain activity '...
    'instead of random noise unrelated to the brain']};
Output(2).Connected_Channels=Connected_Channels;
Output(3).Connected_Channels=Connected_Channels;


end

