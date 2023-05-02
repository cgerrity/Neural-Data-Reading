function [OutData] = cgg_getSingleTrialDataFromTimeSegments(Start_IDX,End_IDX,fullfilename,trial_number)
%CGG_GETDATAFROMTIMESEGMENTS Summary of this function goes here
%   Detailed explanation goes here


this_trial_file_name=...
       sprintf(fullfilename,trial_number);

if exist(this_trial_file_name,'file')    
    m_trial = load(this_trial_file_name);
    this_fields = fieldnames(m_trial);
    m_trial=m_trial.(this_fields{1});
    OutData=m_trial.trial{1}(:,Start_IDX:End_IDX);
else
    OutData=[];
end

end

