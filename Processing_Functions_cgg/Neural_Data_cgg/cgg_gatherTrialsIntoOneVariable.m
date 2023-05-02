function [AllDataFT] = cgg_gatherTrialsIntoOneVariable(trial_file_name,outdatafile_TrialInformation,StartTrial,EndTrial)
%CGG_GATHERTRIALSINTOONEVARIABLE Summary of this function goes here
%   Detailed explanation goes here


    m_rectrialdefs = load(outdatafile_TrialInformation);
    rectrialdefs=m_rectrialdefs.rectrialdefs;
    TrialIDX=StartTrial:EndTrial;
    TrialCount=length(TrialIDX);
    All_Data=cell(TrialCount,1);

parfor tidx=StartTrial:EndTrial
   this_trial_index=rectrialdefs(tidx,8);
   this_trial_file_name=...
       sprintf(trial_file_name,this_trial_index);    
    m_file = load(this_trial_file_name);
    this_fields = fieldnames(m_file)
    this_data_struct=m_file.(this_fields{1});
    
    All_Data{tidx}=this_data_struct;
end

cfg=[];
AllDataFT = ft_appenddata(cfg, All_Data);



end

