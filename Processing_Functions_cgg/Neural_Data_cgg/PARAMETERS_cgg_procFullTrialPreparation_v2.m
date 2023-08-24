function cfg = PARAMETERS_cgg_procFullTrialPreparation_v2


% This script includes the Parameters for cgg_procFullTrialPreparation_v2.
% The parameters are explained and default values are included.

%%
TrialDuration_Minimum=10;
Count_Sel_Trial=30;

probe_area='ACC_001';
Activity_Type='MUA';
Smooth_Factor=250;
want_all_Probes=true;

Increment_Time=25; %Value in ms

Frame_Event_Selection_Data = 'SelectObject';
Frame_Event_Selection_Location_Data = 'END';
Window_Before_Data = 1.5;
Window_After_Data = 1.5;

Frame_Event_Selection_Baseline = 'Blink';
Frame_Event_Selection_Location_Baseline = 'START';
Window_Before_Baseline = 0;
Window_After_Baseline = 0.5;

Epoch = 'Decision';

%% Regression Parameters

GainValue=3;
LossValue=-3;

Regression_SP=25;
Significance_Value=0.05;
Minimum_Length=50;

%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end


end

%
% This is the end of the file.