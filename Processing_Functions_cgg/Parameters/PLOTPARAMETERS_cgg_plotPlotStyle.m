function cfg = PLOTPARAMETERS_cgg_plotPlotStyle
%PLOTPARAMETERS_CGG_PLOTPLOTSTYLE Summary of this function goes here
%   Detailed explanation goes here

X_Name_Size=18;
Y_Name_Size=18;

Main_Title_Size=18;
Main_SubTitle_Size=14;
Main_SubSubTitle_Size=8;

Title_Size=24;

Label_Size=14;
Legend_Size = 14;

Tick_Size_Channels=8;
Tick_Size_Time=0.5;

%%

Line_Width = 4;

%% MATLAB Standard Colors

MATLABPlotColors{1}="#0072BD";
MATLABPlotColors{2}="#D95319";
MATLABPlotColors{3}="#EDB120";
MATLABPlotColors{4}="#7E2F8E";
MATLABPlotColors{5}="#77AC30";
MATLABPlotColors{6}="#4DBEEE";
MATLABPlotColors{7}="#A2142F";


%% Area Colors

Color_ACC = '#ED1C24';
Color_CD = '#00A651';
Color_PFC = '#2E3192';

%% Error Plots

Error_FaceAlpha = 0.05;
Error_EdgeAlpha = 0.75;

%% Decision Epoch

xline_record=0;
xline_fixation=-0.7;
xline_choice=-0.4;
xline_width=4;

Label_Record = 'Decision Recorded';
Label_Fixation = 'Fixation Start';
Label_Choice = 'Likely Committed';

LineSpec_Record = '-';
LineSpec_Fixation = '-';
LineSpec_Choice = '-';

DisplayName_Record = 'Decision Recorded';
DisplayName_Fixation = 'Fixation Start';
DisplayName_Choice = 'Likely Committed';

%% SubPlot Sizing

SubPlot_Fraction=0.2;
SubPlot_Total=50;
SubPlot_Separation_Fraction=0.05;

%% Range Sizes

RangeFactorUpper = 0.3;
RangeFactorLower = 0.3;


%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end
end

