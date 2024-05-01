function [OutData,this_trial] = cgg_getSingleTrialDataFromTimeSegments_v2(Start_IDX,End_IDX,fullfilename,trial_number,Smooth_Factor,varargin)
%CGG_GETDATAFROMTIMESEGMENTS Summary of this function goes here
%   Detailed explanation goes here

%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
SmoothType = CheckVararginPairs('SmoothType', 'gaussian', varargin{:});
else
if ~(exist('SmoothType','var'))
SmoothType='gaussian';
end
end

%%

this_trial_file_name=...
       sprintf(fullfilename,trial_number);

if exist(this_trial_file_name,'file')    
    m_trial = load(this_trial_file_name);
    this_fields = fieldnames(m_trial);
    m_trial=m_trial.(this_fields{1});
    this_trial=m_trial.trial{1};
    this_trial_smooth=smoothdata(this_trial,2,SmoothType,Smooth_Factor);
    % this_trial_smooth=smoothdata(this_trial,2,'movmean',Smooth_Factor);
    OutData=this_trial_smooth(:,Start_IDX:End_IDX);
    this_trial=this_trial(1,Start_IDX:End_IDX);
else
    OutData=[];
end

end

