function [p_record,p_fixation,p_choice] = cgg_plotDecisionEpochIndicators(LineColors)
%CGG_PLOTDECISIONEPOCHINDICATORS Summary of this function goes here
%   Detailed explanation goes here


cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

%%

xline_record = cfg_Plotting.xline_record;
xline_fixation = cfg_Plotting.xline_fixation;
xline_choice = cfg_Plotting.xline_choice;
xline_width = cfg_Plotting.xline_width;

Label_Size = cfg_Plotting.Label_Size;

%%

Label_Record = cfg_Plotting.Label_Record;
Label_Fixation = cfg_Plotting.Label_Fixation;
Label_Choice = cfg_Plotting.Label_Choice;

%%

LineSpec_Record = cfg_Plotting.LineSpec_Record;
LineSpec_Fixation = cfg_Plotting.LineSpec_Fixation;
LineSpec_Choice = cfg_Plotting.LineSpec_Choice;

%%

DisplayName_Record = cfg_Plotting.DisplayName_Record;
DisplayName_Fixation = cfg_Plotting.DisplayName_Fixation;
DisplayName_Choice = cfg_Plotting.DisplayName_Choice;

%%

if verLessThan('matlab','9.5')
InYLim = [-1e10,1e10];
p_record = plot([xline_record,xline_record],InYLim,'Color',LineColors{1});
p_fixation = plot([xline_fixation,xline_fixation],InYLim,'Color',LineColors{2});
p_choice = plot([xline_choice,xline_choice],InYLim,'Color',LineColors{3});
else
p_record = xline(xline_record,LineSpec_Record,Label_Record,'Color',LineColors{1});
p_fixation = xline(xline_fixation,LineSpec_Fixation,Label_Fixation,'Color',LineColors{2});
p_choice = xline(xline_choice,LineSpec_Choice,Label_Choice,'Color',LineColors{3});
end

%% Line Width Assignment

p_record.LineWidth = xline_width;
p_fixation.LineWidth = xline_width;
p_choice.LineWidth = xline_width;

%% Display Name Assignment

p_record.DisplayName = DisplayName_Record;
p_fixation.DisplayName = DisplayName_Fixation;
p_choice.DisplayName = DisplayName_Choice;

%% Label Orientation Assignment

p_record.LabelOrientation = 'horizontal';
p_fixation.LabelOrientation = 'horizontal';
p_choice.LabelOrientation = 'horizontal';

%% Label Horizontal Alignment Assignment

p_record.LabelHorizontalAlignment = 'center';
p_fixation.LabelHorizontalAlignment = 'center';
p_choice.LabelHorizontalAlignment = 'center';

%% Font Size Assignment

p_record.FontSize = Label_Size;
p_fixation.FontSize = Label_Size;
p_choice.FontSize = Label_Size;

end

