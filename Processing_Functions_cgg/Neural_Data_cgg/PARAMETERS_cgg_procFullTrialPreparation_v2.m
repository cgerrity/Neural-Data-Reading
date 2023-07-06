function cfg = PARAMETERS_cgg_procFullTrialPreparation_v2


% This script includes the Parameters for cgg_procFullTrialPreparation_v2.
% The parameters are explained and default values are included.

%%
TrialDuration_Minimum=10;
Count_Sel_Trial=30;

probe_area='ACC_001';
Activity_Type='MUA';
Smooth_Factor=250;

Frame_Event_Selection_Data = 'SelectObject';
Frame_Event_Selection_Location_Data = 'END';
Window_Before_Data = 1.5;
Window_After_Data = 1.5;

Frame_Event_Selection_Baseline = 'Blink';
Frame_Event_Selection_Location_Baseline = 'START';
Window_Before_Baseline = 0;
Window_After_Baseline = 0.5;

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end


end

%
% This is the end of the file.