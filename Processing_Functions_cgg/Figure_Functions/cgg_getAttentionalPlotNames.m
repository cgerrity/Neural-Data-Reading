function [AttentionalInput] = cgg_getAttentionalPlotNames(AttentionalInput)
%CGG_GETATTENTIONALPLOTNAMES Summary of this function goes here
%   Detailed explanation goes here

if istable(AttentionalInput)
    RowNames = AttentionalInput.Properties.RowNames;
elseif iscell(AttentionalInput)
    RowNames = AttentionalInput;
elseif ischar(AttentionalInput)
    RowNames = string(AttentionalInput);
elseif isstring(AttentionalInput)
    RowNames = AttentionalInput;
end

%% Target Feature
this_IDX = strcmp(RowNames,'TargetFeature');
if any(this_IDX)
RowNames{this_IDX} = 'Target Feature';
end

%% Target Dimension
this_IDX = strcmp(RowNames,'TargetDimension');
if any(this_IDX)
RowNames{this_IDX} = 'Target Dimension';
end

%% Target Dimension (Unrewarded)
this_IDX = strcmp(RowNames,'TargetDimensionNonRewarded');
if any(this_IDX)
RowNames{this_IDX} = 'Target Dimension (Unrewarded)';
end

%% Distractor Dimension
this_IDX = strcmp(RowNames,'Distractor');
if any(this_IDX)
RowNames{this_IDX} = 'Distractor Dimension';
end

%% Distractor Dimension (Correct)
this_IDX = strcmp(RowNames,'DistractorCorrect');
if any(this_IDX)
% RowNames{this_IDX} = 'Distractor Dimension (Correct)';
RowNames{this_IDX} = 'Distractor (Correct)';
end

%% Distractor Dimension (Error)
this_IDX = strcmp(RowNames,'DistractorError');
if any(this_IDX)
% RowNames{this_IDX} = 'Distractor Dimension (Error)';
RowNames{this_IDX} = 'Distractor (Error)';
end

if istable(AttentionalInput)
    AttentionalInput.Properties.RowNames = RowNames;
elseif iscell(AttentionalInput)
    AttentionalInput = RowNames;
elseif ischar(AttentionalInput)
    AttentionalInput = char(RowNames);
elseif isstring(AttentionalInput)
    AttentionalInput = RowNames;
end

end

