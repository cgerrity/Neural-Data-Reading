function [sel_cut_start_index,sel_cut_end_index] = cgg_getTimeSegments_v2(varargin)
%CGG_GETTIMESEGMENTS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%% Directories

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

if isfunction
Activity_Type = CheckVararginPairs('Activity_Type', '', varargin{:});
else
if ~(exist('Activity_Type','var'))
    Activity_Type=[];
end
end
if isempty(Activity_Type)
    prompt = {'Enter Activity Type (e.g. MUA)'};
    dlgtitle = 'Input for Activity Type';
    dims = [1 35];
    definput = {'MUA'};
    Activity_Type = inputdlg(prompt,dlgtitle,dims,definput);
    Activity_Type = Activity_Type{1};
end

%%

% Generate the folder name for the Time Information
outdatadir_TimeInformation=[cfg.outdatadir_SessionName, filesep, 'Time_Information'];

outdatadir_TimeInformation_Type=[outdatadir_TimeInformation filesep Activity_Type];

outdatafile_FrameInformation=...
   sprintf([cfg.outdatadir_FrameInformation filesep ...
   'Frame_Data_%s.mat'],cfg.SessionName);

outdatafile_EventInformation_Each=...
   sprintf([cfg.outdatadir_EventInformation filesep ...
   'Event_Codes_Each_%s.mat'],cfg.SessionName);

outdatafile_TrialInformation=...
   sprintf([cfg.outdatadir_TrialInformation filesep ...
   'Trial_Definition_%s.mat'],cfg.SessionName);

%%
    
%     m_gameframedata = matfile(outdatafile_FrameInformation);
    m_gameframedata = load(outdatafile_FrameInformation);
    this_frame_data=m_gameframedata.gameframedata;
    
    m_rectrialdefs = load(outdatafile_TrialInformation);
    rectrialdefs=m_rectrialdefs.rectrialdefs;

    
%%
if isfunction
Frame_Event_Selection = CheckVararginPairs('Frame_Event_Selection', 'SelectObject', varargin{:});
Frame_Event_Selection_Location = CheckVararginPairs('Frame_Event_Selection_Location', 'END', varargin{:});
Frame_Event_Window_Before = CheckVararginPairs('Frame_Event_Window_Before', 1, varargin{:});
Frame_Event_Window_After = CheckVararginPairs('Frame_Event_Window_After', 1.5, varargin{:});
else
Frame_Event_Selection={'SelectObject'};
Frame_Event_Selection_Location='END';
Frame_Event_Window_Before=1; % In Seconds
Frame_Event_Window_After=1.5; % In Seconds  
end

frame_Epochs={'SelectObject','ChoiceToFB','Feedback','Reward','ITI',...
    'Blink','Fixation','BaselineNoFix','Calibration'};

sel_frame_Epoch=strcmp(frame_Epochs,Frame_Event_Selection);

[NumTrials,~]=size(rectrialdefs);

sel_cut_start_index=NaN(NumTrials,1);
sel_cut_end_index=NaN(NumTrials,1);

%%

parfor tidx=1:NumTrials
   this_trial_index=rectrialdefs(tidx,8);
   this_trial_Type_file_name=...
       sprintf([outdatadir_TimeInformation_Type filesep Activity_Type '_Trial_%d_Time.mat'],this_trial_index);
   disp(this_trial_index)
%    m_MUA = matfile(this_trial_MUA_file_name);
    m_Time = load(this_trial_Type_file_name);
    this_trial_time=m_Time.this_trial_time;

%     time_offsets=this_trial_time.trialinfo(:,3);
    time_offsets=rectrialdefs(tidx,6);
    %rectrialdef index 6
%% FIXME
%!!!THIS SECTION PRODUCES A TIME POINT IN THE ABSOLUTE RECORDING TIME> CAN
%BE MOVED TO A NEW FUNCTION PRODUCING A SINGLE VALUE!!!
    this_trial_frame_data=this_frame_data(this_frame_data.TrialCounter==this_trial_index,:);
    
    Epoch_Start_idx=NaN(length(frame_Epochs),1);
    Epoch_End_idx=NaN(length(frame_Epochs),1);
    Epoch_Start_Time=NaN(length(frame_Epochs),1);
    Epoch_End_Time=NaN(length(frame_Epochs),1);
    for eidx=1:length(frame_Epochs)
        
        sel_cut_frame_index=strcmp(this_trial_frame_data.TrialEpoch,...
            frame_Epochs{eidx});
        
        Epoch_indices=find(sel_cut_frame_index==1);
        
        if ~(isempty(Epoch_indices))
        Epoch_Start_idx(eidx)=Epoch_indices(1);
        Epoch_End_idx(eidx)=Epoch_indices(end);
        Epoch_Start_Time(eidx)=this_trial_frame_data.recTime(Epoch_Start_idx(eidx));
        Epoch_End_Time(eidx)=this_trial_frame_data.recTime(Epoch_End_idx(eidx));
        else
        Epoch_Start_idx(eidx)=NaN;
        Epoch_End_idx(eidx)=NaN;
        Epoch_Start_Time(eidx)=NaN;
        Epoch_End_Time(eidx)=NaN;
        end
    end
    
    if strcmp(Frame_Event_Selection_Location,'START')
        sel_cut_time=Epoch_Start_Time(sel_frame_Epoch);
    else
        sel_cut_time=Epoch_End_Time(sel_frame_Epoch);
    end
    
    %%
    
    this_time_series_absolute=this_trial_time+time_offsets;
   
    sel_cut_start_time=sel_cut_time-Frame_Event_Window_Before;
    sel_cut_end_time=sel_cut_time+Frame_Event_Window_After;
    
    [~,sel_cut_start_index(tidx)]=min(abs(this_time_series_absolute-sel_cut_start_time));
    [~,sel_cut_end_index(tidx)]=min(abs(this_time_series_absolute-sel_cut_end_time));
    
    
    
end
    
end

