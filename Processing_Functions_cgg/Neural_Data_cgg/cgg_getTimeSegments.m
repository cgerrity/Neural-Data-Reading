function [sel_cut_start_index,sel_cut_end_index] = cgg_getTimeSegments(varargin)
%CGG_GETTIMESEGMENTS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%% Directories
if isfunction
[inputfolder,outdatadir,SessionName,ExperimentName,...
    outdatadir_EventInformation,outdatadir_FrameInformation,...
    outdatadir_TrialInformation] = ...
    cgg_generateAllNeuralDataFolders(varargin{:});    
end

if isfunction
probe_area = CheckVararginPairs('probe_area', '', varargin{:});
else
if ~(exist('probe_area','var'))
    probe_area=[];
end
end
if isempty(probe_area)
    prompt = {'Enter Probe Area Name (e.g. ACC_001)'};
    dlgtitle = 'Input for Probe Area';
    dims = [1 35];
    definput = {'ACC_001'};
    probe_area = inputdlg(prompt,dlgtitle,dims,definput);
    probe_area = probe_area{1};
end

%%

[outdatadir_WideBand,outdatadir_LFP,outdatadir_Spike,...
    outdatadir_MUA] = cgg_generateNeuralDataFolders(...
    outdatadir,SessionName,ExperimentName,probe_area);

outdatafile_GazeInformation=...
   sprintf([outdatadir_FrameInformation filesep ...
   'Gaze_Data_%s.mat'],SessionName);

outdatafile_FrameInformation=...
   sprintf([outdatadir_FrameInformation filesep ...
   'Frame_Data_%s.mat'],SessionName);

outdatafile_EventInformation_Each=...
   sprintf([outdatadir_EventInformation filesep ...
   'Event_Codes_Each_%s.mat'],SessionName);

outdatafile_EventInformation_Concatenated=...
   sprintf([outdatadir_EventInformation filesep ...
   'Event_Codes_Concatenated_%s.mat'],SessionName);

outdatafile_TrialInformation=...
   sprintf([outdatadir_TrialInformation filesep ...
   'Trial_Definition_%s.mat'],SessionName);

outdatafile_TrialInformation_Table=...
   sprintf([outdatadir_TrialInformation filesep ...
   'Trial_Definition_Table_%s.mat'],SessionName);

%%

%     m_event_each = matfile(outdatafile_EventInformation_Each);
    m_event_each = load(outdatafile_EventInformation_Each);
    trialcodes_each=m_event_each.trialcodes_each;
    
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
end

% Frame_Event_Selection={'SelectObject'};
% Frame_Event_Selection_Location='END';
% Frame_Event_Window_Before=1; % In Seconds
% Frame_Event_Window_After=1.5; % In Seconds

frame_Epochs={'SelectObject','ChoiceToFB','Feedback','Reward','ITI',...
    'Blink','Fixation','BaselineNoFix','Calibration'};

sel_frame_Epoch=strcmp(frame_Epochs,Frame_Event_Selection);

NumTrials=length(trialcodes_each);

sel_cut_start_index=NaN(NumTrials,1);
sel_cut_end_index=NaN(NumTrials,1);

%%

parfor tidx=1:NumTrials
   this_trial_index=rectrialdefs(tidx,8);
   this_trial_MUA_file_name=...
       sprintf([outdatadir_MUA filesep 'MUA_Trial_%d.mat'],this_trial_index);
   disp(this_trial_index)
%    m_MUA = matfile(this_trial_MUA_file_name);
    m_MUA = load(this_trial_MUA_file_name);
    this_data_struct=m_MUA.this_recdata_activity;

    time_offsets=this_data_struct.trialinfo(:,3);
    %rectrialdef index 6

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
    
    this_time_series=this_data_struct.time{:};
    this_time_series_absolute=this_time_series+time_offsets;
    
    
    if strcmp(Frame_Event_Selection_Location,'START')
        sel_cut_time=Epoch_Start_Time(sel_frame_Epoch);
    else
        sel_cut_time=Epoch_End_Time(sel_frame_Epoch);
    end
   
    sel_cut_start_time=sel_cut_time-Frame_Event_Window_Before;
    sel_cut_end_time=sel_cut_time+Frame_Event_Window_After;
    
    [~,sel_cut_start_index(tidx)]=min(abs(this_time_series_absolute-sel_cut_start_time));
    [~,sel_cut_end_index(tidx)]=min(abs(this_time_series_absolute-sel_cut_end_time));
    
    
    
end
    
end

