function Identifiers_Table = cgg_getAttentionWeights(Identifiers_Table)
%CGG_GETATTENTIONWEIGHTS Summary of this function goes here
%   Detailed explanation goes here

%% Attentional Filtering Components
TargetDimension = Identifiers_Table{:,"Target Feature"};
CorrectTrial = Identifiers_Table{:,"Correct Trial"};
FeatureMatrix = Identifiers_Table{:,"TrueValue"};
TargetDimensionIDX = sub2ind(size(FeatureMatrix), (1:size(FeatureMatrix,1))', TargetDimension);

ActiveDimensionsTable = varfun(@(x1){unique(x1)},Identifiers_Table,"InputVariables","Target Feature","GroupingVariables","Session Name");
TMP_Table = innerjoin(Identifiers_Table, ActiveDimensionsTable, 'Keys', 'Session Name');
ActiveDimensionTMP = TMP_Table.("Fun_Target Feature");
Identifiers_Table.("Active Dimensions") = ActiveDimensionTMP;

% InactiveMatrix = cellfun(@(x) ~ismember(1:NumDimension, x), Identifiers_Table.("Active Dimensions"), 'UniformOutput', false);
% InactiveMatrix = double(cell2mat(InactiveMatrix));

DistractorMatrix = FeatureMatrix ~=0;
DistractorMatrix(TargetDimensionIDX) = 0;
% NeutralMatrix = FeatureMatrix == 0 - InactiveMatrix;

TargetDimWeights = zeros(size(FeatureMatrix));
TargetDimWeights(TargetDimensionIDX) = 1;

TargetFeatureWeights = TargetDimWeights;
% TargetDimNonRewardedWeights = TargetDimWeights;
TargetFeatureWeights(CorrectTrial == 0,:) = 0;
% TargetDimNonRewardedWeights(CorrectTrial == 1,:) = 0;

DistractorWeights = DistractorMatrix./sum(DistractorMatrix,2);
DistractorWeights(isnan(DistractorWeights)) = 0;
% DistractorErrorWeights = DistractorWeights;
DistractorErrorWeights = DistractorWeights | TargetDimWeights;
DistractorCorrectWeights = DistractorWeights;
DistractorCorrectWeights(CorrectTrial == 0,:) = 0;
DistractorErrorWeights(CorrectTrial == 1,:) = 0;

% NeutralWeights = NeutralMatrix./sum(NeutralMatrix,2);
% NeutralWeights(isnan(NeutralWeights)) = 0;
DistractorErrorWeights = DistractorErrorWeights./sum(DistractorErrorWeights,2);
DistractorErrorWeights(isnan(DistractorErrorWeights)) = 0;
DistractorCorrectWeights = DistractorCorrectWeights./sum(DistractorCorrectWeights,2);
DistractorCorrectWeights(isnan(DistractorCorrectWeights)) = 0;

% InactiveWeights = double(InactiveMatrix);

% AttentionalFiltering = struct();
% AttentionalFiltering.Overall = ones(size(TargetDimWeights));
% AttentionalFiltering.TargetFeature = TargetFeatureWeights;
% AttentionalFiltering.TargetDimensionNonRewarded = TargetDimNonRewardedWeights;
% AttentionalFiltering.TargetDimension = TargetDimWeights;
% AttentionalFiltering.DistractorCorrect = DistractorCorrectWeights;
% AttentionalFiltering.DistractorError = DistractorErrorWeights;
% AttentionalFiltering.Distractor = DistractorWeights;
% AttentionalFiltering.Neutral = NeutralWeights;
% AttentionalFiltering.Inactive = InactiveWeights;

% Identifiers_Table.Overall = ones(size(TargetDimWeights));
Identifiers_Table.TargetFeature = TargetFeatureWeights;
% Identifiers_Table.TargetDimensionNonRewarded = TargetDimNonRewardedWeights;
% Identifiers_Table.TargetDimension = TargetDimWeights;
Identifiers_Table.DistractorCorrect = DistractorCorrectWeights;
Identifiers_Table.DistractorError = DistractorErrorWeights;
% Identifiers_Table.Distractor = DistractorWeights;
% Identifiers_Table.Neutral = NeutralWeights;
% Identifiers_Table.Inactive = InactiveWeights;
end

