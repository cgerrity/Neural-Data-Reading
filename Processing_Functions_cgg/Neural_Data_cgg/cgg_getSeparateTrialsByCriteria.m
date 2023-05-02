function [All_Trials_Baseline,All_Trials_Data_Match,...
    All_Trials_Data_NotMatch,All_Trials_Baseline_Match,...
    All_Trials_Baseline_NotMatch,Trial_Counter_Match,...
    Trial_Counter_NotMatch] = cgg_getSeparateTrialsByCriteria(...
    Start_IDX,End_IDX,Start_IDX_Baseline,End_IDX_Baseline,...
    trial_file_name,trialData,TrialCondition,MatchValue,TrialCount,...
    TrialDuration_Minimum)
%CGG_GETSEPARATETRIALSBYCRITERIA Summary of this function goes here
%   Detailed explanation goes here



This_Trial_Counter=0;
Trial_Counter_Match=0;
Trial_Counter_NotMatch=0;

All_Trials_Data_Match=[];
All_Trials_Data_NotMatch=[];
All_Trials_Baseline_Match=[];
All_Trials_Baseline_NotMatch=[];
All_Trials_Baseline=[];

% TrialDuration_Minimum=10; % Seconds over which a trial is considered a bad trial

for tidx=1:TrialCount
    this_TrialCondition=TrialCondition{tidx};
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
%     this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
%     this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
    %
    disp(tidx)
    This_Trial_Counter=This_Trial_Counter+1;
    
    this_trial_file_name=sprintf(trial_file_name,tidx);
   
   
    m_this_trial = load(this_trial_file_name);
    this_fields = fieldnames(m_this_trial);
    this_data_struct=m_this_trial.(this_fields{1});
    
    %
    this_Start_IDX=Start_IDX(tidx);
    this_End_IDX=End_IDX(tidx);
    this_Start_IDX_Baseline=Start_IDX_Baseline(tidx);
    this_End_IDX_Baseline=End_IDX_Baseline(tidx);
    
    this_Data=this_data_struct.trial{1}(:,this_Start_IDX:this_End_IDX);
    this_Data_Baseline=this_data_struct.trial{1}(:,this_Start_IDX_Baseline:this_End_IDX_Baseline);
    
    All_Trials_Baseline(:,:,This_Trial_Counter)=this_Data_Baseline;

        if isequal(this_TrialCondition,MatchValue)
            Trial_Counter_Match=Trial_Counter_Match+1;
            All_Trials_Data_Match(:,:,Trial_Counter_Match)=this_Data;
            All_Trials_Baseline_Match(:,:,Trial_Counter_Match)=this_Data_Baseline;
        else
            Trial_Counter_NotMatch=Trial_Counter_NotMatch+1;
            All_Trials_Data_NotMatch(:,:,Trial_Counter_NotMatch)=this_Data;
            All_Trials_Baseline_NotMatch(:,:,Trial_Counter_NotMatch)=this_Data_Baseline;
        end
    
    end
end



end

