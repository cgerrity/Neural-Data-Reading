function [p_record,p_fixation,p_choice,p_audio,p_move,p_complete] = cgg_plotDecisionEpochIndicators(LineColors,varargin)
%CGG_PLOTDECISIONEPOCHINDICATORS Summary of this function goes here
%   Detailed explanation goes here

%%

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
DecisionIndicatorLabelOrientation = CheckVararginPairs('DecisionIndicatorLabelOrientation', 'horizontal', varargin{:});
else
if ~(exist('DecisionIndicatorLabelOrientation','var'))
DecisionIndicatorLabelOrientation='horizontal';
end
end

if isfunction
wantFeedbackIndicators = CheckVararginPairs('wantFeedbackIndicators', false, varargin{:});
else
if ~(exist('wantFeedbackIndicators','var'))
wantFeedbackIndicators=false;
end
end

if isfunction
wantIndicatorNames = CheckVararginPairs('wantIndicatorNames', true, varargin{:});
else
if ~(exist('wantIndicatorNames','var'))
wantIndicatorNames=true;
end
end

if isfunction
TimeOffset = CheckVararginPairs('TimeOffset', 0, varargin{:});
else
if ~(exist('TimeOffset','var'))
TimeOffset=0;
end
end

if isfunction
Line_Width = CheckVararginPairs('Line_Width', cfg_Plotting.xline_width, varargin{:});
else
if ~(exist('Line_Width','var'))
Line_Width=cfg_Plotting.xline_width;
end
end

if isfunction
Indicator_Size = CheckVararginPairs('Indicator_Size', cfg_Plotting.Indicator_Size, varargin{:});
else
if ~(exist('Indicator_Size','var'))
Indicator_Size=cfg_Plotting.Indicator_Size;
end
end
%%
if ~wantFeedbackIndicators
p_audio = [];
p_move = [];
p_complete = [];
end

%%

xline_record = cfg_Plotting.xline_record + TimeOffset;
xline_fixation = cfg_Plotting.xline_fixation + TimeOffset;
xline_choice = cfg_Plotting.xline_choice + TimeOffset;

xline_halo = cfg_Plotting.xline_halo + TimeOffset;
xline_audio = cfg_Plotting.xline_audio + TimeOffset;
% xline_move = cfg_Plotting.xline_move + TimeOffset;
xline_complete = cfg_Plotting.xline_complete + TimeOffset;

xline_width = Line_Width;

%%

Label_Record = cfg_Plotting.Label_Record;
Label_Fixation = cfg_Plotting.Label_Fixation;
Label_Choice = cfg_Plotting.Label_Choice;
Label_Halo = cfg_Plotting.Label_Halo;
Label_Audio = cfg_Plotting.Label_Audio;
% Label_Move = cfg_Plotting.Label_Move;
Label_Complete = cfg_Plotting.Label_Complete;

%%

LineSpec_Record = cfg_Plotting.LineSpec_Record;
LineSpec_Fixation = cfg_Plotting.LineSpec_Fixation;
LineSpec_Choice = cfg_Plotting.LineSpec_Choice;
LineSpec_Halo = cfg_Plotting.LineSpec_Halo;
LineSpec_Audio = cfg_Plotting.LineSpec_Audio;
% LineSpec_Move = cfg_Plotting.LineSpec_Move;
LineSpec_Complete = cfg_Plotting.LineSpec_Complete;

%%

DisplayName_Record = cfg_Plotting.DisplayName_Record;
DisplayName_Fixation = cfg_Plotting.DisplayName_Fixation;
DisplayName_Choice = cfg_Plotting.DisplayName_Choice;
DisplayName_Halo = cfg_Plotting.DisplayName_Halo;
DisplayName_Audio = cfg_Plotting.DisplayName_Audio;
% DisplayName_Move = cfg_Plotting.DisplayName_Move;
DisplayName_Complete = cfg_Plotting.DisplayName_Complete;

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

if wantFeedbackIndicators
if verLessThan('matlab','9.5')
InYLim = [-1e10,1e10];
p_halo = plot([xline_halo,xline_halo],InYLim,'Color',LineColors{1});
p_audio = plot([xline_audio,xline_audio],InYLim,'Color',LineColors{1});
% p_move = plot([xline_move,xline_move],InYLim,'Color',LineColors{2});
p_complete = plot([xline_complete,xline_complete],InYLim,'Color',LineColors{3});
else
p_halo = xline(xline_halo,LineSpec_Halo,Label_Halo,'Color',LineColors{1});
p_audio = xline(xline_audio,LineSpec_Audio,Label_Audio,'Color',LineColors{1});
% p_move = xline(xline_move,LineSpec_Move,Label_Move,'Color',LineColors{2});
p_complete = xline(xline_complete,LineSpec_Complete,Label_Complete,'Color',LineColors{3});
end
end
%% Line Width Assignment

p_record.LineWidth = xline_width;
p_fixation.LineWidth = xline_width;
p_choice.LineWidth = xline_width;
if wantFeedbackIndicators
p_halo.LineWidth = xline_width;
p_audio.LineWidth = xline_width;
% p_move.LineWidth = xline_width;
p_complete.LineWidth = xline_width;
end

%% Display Name Assignment

p_record.DisplayName = DisplayName_Record;
p_fixation.DisplayName = DisplayName_Fixation;
p_choice.DisplayName = DisplayName_Choice;
if wantFeedbackIndicators
p_halo.DisplayName = DisplayName_Halo;
p_audio.DisplayName = DisplayName_Audio;
% p_move.DisplayName = DisplayName_Move;
p_complete.DisplayName = DisplayName_Complete;
end

%% Label Orientation Assignment

p_record.LabelOrientation = DecisionIndicatorLabelOrientation;
p_fixation.LabelOrientation = DecisionIndicatorLabelOrientation;
p_choice.LabelOrientation = DecisionIndicatorLabelOrientation;
if wantFeedbackIndicators
p_halo.LabelOrientation = DecisionIndicatorLabelOrientation;
p_audio.LabelOrientation = DecisionIndicatorLabelOrientation;
% p_move.LabelOrientation = DecisionIndicatorLabelOrientation;
p_complete.LabelOrientation = DecisionIndicatorLabelOrientation;
end

%% Label Horizontal Alignment Assignment

p_record.LabelHorizontalAlignment = 'center';
p_fixation.LabelHorizontalAlignment = 'center';
p_choice.LabelHorizontalAlignment = 'center';
if wantFeedbackIndicators
p_halo.LabelHorizontalAlignment = 'center';
p_audio.LabelHorizontalAlignment = 'center';
% p_move.LabelHorizontalAlignment = 'center';
p_complete.LabelHorizontalAlignment = 'center';
end

%% Font Size Assignment

p_record.FontSize = Indicator_Size;
p_fixation.FontSize = Indicator_Size;
p_choice.FontSize = Indicator_Size;
if wantFeedbackIndicators
p_halo.FontSize = Indicator_Size;
p_audio.FontSize = Indicator_Size;
% p_move.FontSize = Indicator_Size;
p_complete.FontSize = Indicator_Size;
end

%% Remove Label

if ~wantIndicatorNames
p_record.Label = '';
p_fixation.Label = '';
p_choice.Label = '';
if wantFeedbackIndicators
p_halo.Label = '';
p_audio.Label = '';
% p_move.Label = '';
p_complete.Label = '';
end
end

%% Alpha

if ~wantIndicatorNames
p_record.Alpha = 1;
p_fixation.Alpha = 1;
p_choice.Alpha = 1;
if wantFeedbackIndicators
p_halo.Alpha = 1;
p_audio.Alpha = 1;
% p_move.Alpha = 1;
p_complete.Alpha = 1;
end
end

%% Move all to back

if ~wantIndicatorNames
    if isMATLABReleaseOlderThan("R2024a")
    cgg_setGraphicsLayer(p_record,'Back');
    cgg_setGraphicsLayer(p_fixation,'Back');
    cgg_setGraphicsLayer(p_choice,'Back');
    if wantFeedbackIndicators
    cgg_setGraphicsLayer(p_halo,'Back');
    cgg_setGraphicsLayer(p_audio,'Back');
    % cgg_setGraphicsLayer(p_move,'Back');
    cgg_setGraphicsLayer(p_complete,'Back');
    end
    else
    p_record.Layer = 'bottom';
    p_fixation.Layer = 'bottom';
    p_choice.Layer = 'bottom';
    if wantFeedbackIndicators
    p_halo.Layer = 'bottom';
    p_audio.Layer = 'bottom';
    % p_move.Layer = 'bottom';
    p_complete.Layer = 'bottom';
    end
    end
end

end

