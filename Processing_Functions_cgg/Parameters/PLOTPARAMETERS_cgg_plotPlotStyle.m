function cfg = PLOTPARAMETERS_cgg_plotPlotStyle(varargin)
%PLOTPARAMETERS_CGG_PLOTPLOTSTYLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantPaperFormat = CheckVararginPairs('WantPaperFormat', false, varargin{:});
else
if ~(exist('WantPaperFormat','var'))
WantPaperFormat=false;
end
end

if isfunction
WantDecisionCentered = CheckVararginPairs('WantDecisionCentered', false, varargin{:});
else
if ~(exist('WantDecisionCentered','var'))
WantDecisionCentered=false;
end
end

X_Name_Size=18;
Y_Name_Size=18;

Main_Title_Size=18;
Main_SubTitle_Size=14;
Main_SubSubTitle_Size=8;

Title_Size=24;

Label_Size=14;
Legend_Size = 6;

Indicator_Size = 8;

Text_Size = 12;

Tick_Size_Channels=16;
Tick_Size_Time=0.5;
Tick_Size_Z = 0.025;

ErrorCapSize=50;

X_Name_Size_Pie=12;

%%

Line_Width = 4;
Line_Width_ProgressMonitor = 2;

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
Error_EdgeAlpha = 0.25;

%% Decision Epoch

xline_record=0;
xline_fixation=-0.7;
xline_choice=-0.4;
xline_halo=0.2;
xline_audio=0.55;
xline_move=0.75;
xline_complete=1.45;

xline_width=4;

Label_Record = {'Decision', 'Recorded'};
Label_Fixation = {'Fixation', 'Start'};
Label_Choice = {'Likely', 'Committed'};
Label_Halo = {'Halo', 'Onset'};
Label_Audio = {'Audio', 'Feedback'};
Label_Move = {'Tokens', 'Move'};
Label_Complete = {'Token Bar', 'Completion'};

LineSpec_Record = '-';
LineSpec_Fixation = '-';
LineSpec_Choice = '-';
LineSpec_Halo = '-';
LineSpec_Audio = '-';
LineSpec_Move = '-';
LineSpec_Complete = '-';

DisplayName_Record = 'Decision Recorded';
DisplayName_Fixation = 'Fixation Start';
DisplayName_Choice = 'Likely Committed';
DisplayName_Halo = 'Halo Onset';
DisplayName_Audio = 'Audio Feedback';
DisplayName_Move = 'Tokens Move';
DisplayName_Complete = 'Token Bar Completion';

%% SubPlot Sizing

SubPlot_Fraction=0.2;
SubPlot_Total=50;
SubPlot_Separation_Fraction=0.05;

%% Range Sizes

RangeFactorUpper = 0.3;
RangeFactorLower = 0.3;

RangeFactorHeatUpper = 0.3;
RangeFactorHeatLower = 0.3;

RangeAccuracyUpper = 0.5;
RangeAccuracyLower = 0.4;

%% Regular Preferences 

Time_Offset = 0;

Limit_Correlation = [NaN,NaN];

Limit_ChannelProportion = [NaN,NaN];
Limit_ChannelProportion_Large = [NaN,NaN];
Limit_Time = [NaN,NaN];
Limit_ChannelProportion_Small = [NaN,NaN];

Limit_LatentProportion = [0,0.12];
Limit_LatentCorrelation = [0.25,0.4];

Tick_Size_ChannelProportion = NaN;
Tick_Size_ChannelProportion_Large = NaN;
% Tick_Size_Time = NaN;

Tick_Size_LatentProportion = 0.02;
Tick_Size_LatentCorrelation = 0.05;

TickDir = '';
TickDir_ChannelProportion = '';
TickDir_Time = '';

WantTitle = true;

wantDecisionIndicators = true;
wantSubPlot = true;
wantFeedbackIndicators = false;
DecisionIndicatorLabelOrientation = 'aligned';
wantIndicatorNames = true;
wantPaperSized = false;

%% Paper Preferences 

if WantPaperFormat

Error_FaceAlpha = 0.2;
Error_EdgeAlpha = 0;

Title_Size = 12;
Y_Name_Size=12;
Line_Width = 0.5;
Time_Offset = 0.7;
Legend_Size = 4;
Label_Size=14;

Limit_ChannelProportion = [0,0.3];
Limit_Time = [-0.3,1.4];
Limit_ChannelProportion_Small = [0,0.4];
Limit_ChannelProportion_Medium = [0,0.4];
Limit_ChannelProportion_Large = [0,0.5];
Limit_ChannelProportion_Model = [0,0.4];
Limit_Correlation = [0.05,0.15];
Limit_Correlation_Large = [0,0.4];
Limit_ChannelProportion_Difference = [0,0.1];
Limit_BetaValues = [-0.15,0.3];

Tick_Size_ChannelProportion = 0.1;
Tick_Size_ChannelProportion_Medium = 0.1;
Tick_Size_ChannelProportion_Large = 0.25;
Tick_Size_ChannelProportion_Model = 0.1;
Tick_Size_Time = 0.3;
Tick_Size_Correlation = 0.05;
Tick_Size_ChannelProportion_Difference = 0.05;
Tick_Size_BetaValues = 0.15;

TickDir = 'out';

TickDir_ChannelProportion = 'out';
TickDir_Time = 'out';
TickDir_Correlation = 'out';

WantTitle = false;

wantDecisionIndicators = true;
wantSubPlot = true;
wantFeedbackIndicators = true;
DecisionIndicatorLabelOrientation = 'aligned';
wantIndicatorNames = false;
wantPaperSized = true;

Indicator_Size = 4;

end

%% Decision Centered Format

if WantDecisionCentered
Time_Offset = 0;
Limit_Time = [-1.5,1.5];
Tick_Size_Time = 0.5;
wantFeedbackIndicators = false;
wantIndicatorNames = true;
end
%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end
end

