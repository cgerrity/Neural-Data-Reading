function [AttentionalTable] = cgg_getAttentionalPlotNames(AttentionalTable)
%CGG_GETATTENTIONALPLOTNAMES Summary of this function goes here
%   Detailed explanation goes here

RowNames = AttentionalTable.Properties.RowNames;

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

AttentionalTable.Properties.RowNames = RowNames;

end

