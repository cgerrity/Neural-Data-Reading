clc; clear; close all;
%%
PathNameExt = '/Users/cgerrity/Downloads/FeatureValues_RLWMModelValues_01 (2).mat';
load(PathNameExt);
%%

this_Block = 5;
this_Session = 2;
this_Monkey = 1;
WantLog = false;

switch this_Monkey
    case 1
        this_Data = MATData1;
    case 2
        this_Data = MATData2;
    otherwise
        this_Data = MATData1;
end

BlockIDs = this_Data.blocknumindx;
SessionNames = this_Data.datasetname;

UniqueSessionNames = unique(SessionNames);
this_SessionName = UniqueSessionNames{this_Session};
SelectedSessionIndices = strcmp(SessionNames,this_SessionName);
UniqueBlockIds = unique(BlockIDs(SelectedSessionIndices));
SelectedBlockIndices = BlockIDs == UniqueBlockIds(this_Block);

RowIndices = find(SelectedBlockIndices & SelectedSessionIndices);
%%

% RowIndices = 280:314; % 1-D 
% RowIndices = 250:279; % 1-D 
% RowIndices = 1:30; % 2-D 
% RowIndices = 31:65; % 3-D 
% RowIndices = 66:99; % 2-D 
% RowIndices = 100:133; % 2-D 
% RowIndices = 168:198; % 3-D 
% RowIndices = 199:249; % 3-D 



%%
this_ChosenValue = this_Data.Value_ObjectChosen_RL(RowIndices,:);
this_NotChosenValue = this_Data.Value_ObjectsNotChosen_RL(RowIndices,:);
this_IDs = this_Data.featureID(RowIndices,:);
this_R = this_Data.R(:,RowIndices);
this_PEChosen = this_Data.PE_ObjectChosen(RowIndices,:);
this_PENotChosen = this_Data.PE_ObjectsNotChosen(RowIndices,:);

%%
RowIndices_TEST = 1:2000;
BlockIDs = this_Data.blocknumindx(RowIndices_TEST,:);
SessionNames = this_Data.datasetname(RowIndices_TEST,:);
FeatureIDs = this_Data.featureID(RowIndices_TEST,:);
ValueChosen = this_Data.Value_ObjectChosen_RL(RowIndices_TEST,:);
ValueNotChosen = this_Data.Value_ObjectsNotChosen_RL(RowIndices_TEST,:);
PEChosen = this_Data.PE_ObjectChosen(RowIndices_TEST,:);
PENotChosen = this_Data.PE_ObjectsNotChosen(RowIndices_TEST,:);

[TargetData, DistractorData] = cgg_getCorrectedVariables(BlockIDs, SessionNames, FeatureIDs, ValueChosen, ValueNotChosen, PEChosen, PENotChosen);
%%

AllIDs = unique(this_IDs);
AllIDs(AllIDs == 0) = [];
NumFeatures = length(AllIDs);
Dimensionality = round(NumFeatures/3);

ActiveChosen = 1:Dimensionality;
ActiveNotChosen = 1:round(2*Dimensionality);
first_vals = Dimensionality + ActiveChosen;
second_vals = first_vals + Dimensionality;
stacked = [first_vals; second_vals];
ActiveNotChosenFull = stacked(:)';

% ActiveNotChosen = 1:round(2*NumFeatures/3);
% ActiveNotChosenFull = ActiveNotChosen + length(ActiveChosen);

%%
EmptyIDs = all(this_IDs == 0,1);
EmptyChosenValues = true(1,3);
EmptyChosenValues(ActiveChosen) = false;
EmptyNotChosenValues = true(1,6);
EmptyNotChosenValues(ActiveNotChosen) = false;

% EmptyChosenValues = all(this_ChosenValue == 0,1);
% EmptyNotChosenValues = max(find(~all(this_NotChosenValue == 0,1)))+1:6;
TargetID = all(diff(this_IDs,2) == 0,1);
TargetID = this_IDs(1,TargetID);
TargetID(TargetID == 0) = [];
TargetIDX = AllIDs == TargetID;
%%
this_ChosenValue(:,EmptyChosenValues) = [];
this_NotChosenValue(:,EmptyNotChosenValues) = [];
this_PEChosen(:,EmptyChosenValues) = [];
this_PENotChosen(:,EmptyNotChosenValues) = [];
this_LogChosenValue = log(this_ChosenValue);
this_LogNotChosenValue = log(this_NotChosenValue);
% this_AllValues = cat(2,this_ChosenValue,this_NotChosenValue);

%%

this_AllValues = zeros(size(this_IDs));
this_AllValues(:,ActiveChosen) = this_ChosenValue;
this_AllValues(:,ActiveNotChosenFull) = this_NotChosenValue;

this_AllPEs = zeros(size(this_IDs));
this_AllPEs(:,ActiveChosen) = this_PEChosen;
this_AllPEs(:,ActiveNotChosenFull) = this_PENotChosen;

%%

this_Indices = cell(NumFeatures,1);
% this_IndicesChosen = cell(NumFeatures,1);
% this_IndicesNotChosen = cell(NumFeatures,1);
% this_Indices = NaN(size(this_IDs));

for fidx = 1:NumFeatures
    this_IDMatch = this_IDs == AllIDs(fidx);
    this_Indices{fidx} = this_IDs == AllIDs(fidx);
    % this_IndicesChosen{fidx} = this_IDMatch(:,ActiveChosen);
    % this_IndicesNotChosen{fidx} = this_IDMatch(:,ActiveNotChosenFull);
end

%%

% this_Index_15 = this_IDs == 15;
% this_Index_13 = this_IDs == 13;
% this_Index_11 = this_IDs == 11;
%%
% this_Index_11(:,[1,4:9]) = [];
% this_Index_13(:,[1,4:9]) = [];
%%

NumRows = length(RowIndices);

this_Values = cell(NumFeatures,1);
this_PEs = cell(NumFeatures,1);

for fidx = 1:NumFeatures
    this_Value = NaN(NumRows,1);
    this_PE = NaN(NumRows,1);
for idx = 1:NumRows
    this_Value(idx) = this_AllValues(idx,this_Indices{fidx}(idx,:));
    this_PE(idx) = this_AllPEs(idx,this_Indices{fidx}(idx,:));
end
if WantLog
this_Value = log(this_Value);
this_PE = log(this_PE);
end
this_Values{fidx} = this_Value;
this_PEs{fidx} = this_PE;
end

TargetValues = this_Values{TargetIDX};
TargetPE = this_PEs{TargetIDX};
DistractorValues = this_Values(~TargetIDX);
DistractorPE = this_PEs(~TargetIDX);
%%


% this_Value_15 = NaN(NumRows,1);
% this_Value_13 = NaN(NumRows,1);
% this_Value_11 = NaN(NumRows,1);
% for idx = 1:NumRows
% this_Value_15(idx) = this_ChosenValue(idx,1);
% this_Value_13(idx) = this_NotChosenValue(idx,this_Index_13(idx,:));
% this_Value_11(idx) = this_NotChosenValue(idx,this_Index_11(idx,:));
% end

%%
figure;
plot(1:NumRows,this_Values{1}, "DisplayName",num2str(AllIDs(1)),"LineWidth",2,"LineStyle",":");
hold on;
plot(1:NumRows,this_Values{2}, "DisplayName",num2str(AllIDs(2)),"LineWidth",2,"LineStyle",":");
for fidx = 3:NumFeatures
plot(1:NumRows,this_Values{fidx}, "DisplayName",num2str(AllIDs(fidx)),"LineWidth",2);
end
hold off;
legend;
title('Value');
xlabel('Trial in Block');
ylabel('Value');

figure;
plot(1:NumRows,this_PEs{1}, "DisplayName",num2str(AllIDs(1)),"LineWidth",2,"LineStyle",":");
hold on;
plot(1:NumRows,this_PEs{2}, "DisplayName",num2str(AllIDs(2)),"LineWidth",2,"LineStyle",":");
for fidx = 3:NumFeatures
plot(1:NumRows,this_PEs{fidx}, "DisplayName",num2str(AllIDs(fidx)),"LineWidth",2);
end
hold off;
legend;
title('Prediction Error');
xlabel('Trial in Block');
ylabel('Prediction Error');

%%
close all;
sel_Correct = false;
sel_Dim = 3;
wantAllVariables = false;
wantVariableSubset = false;
sel_VariableSubset = "Prediction Error Target";
wantAllDims = true;
wantAllOutcomes = true;
wantNotLearned = false;
wantUnLearned = false;

sel_Var1 = "VT_cat";
sel_Var2 = "L";

CorrectIDX = Identifiers_Table.("Correct Trial") == sel_Correct;
DimensionIDX = Identifiers_Table.("Dimensionality") == sel_Dim;
NotLearnedIDX = ~(Identifiers_Table.("Learned") == -1);
UnLearnedIDX = ~(Identifiers_Table.("Target Value Category") == 0);

if wantAllDims
    DimensionIDX = true(size(DimensionIDX));
end
if wantAllOutcomes
    CorrectIDX = true(size(CorrectIDX));
end
if wantNotLearned
    NotLearnedIDX = true(size(NotLearnedIDX));
end
if wantUnLearned
    UnLearnedIDX = true(size(UnLearnedIDX));
end

SelectionIDX = CorrectIDX & DimensionIDX & NotLearnedIDX & UnLearnedIDX;

if wantVariableSubset
T = Identifiers_Table(SelectionIDX,["Prediction Error Target","Target Prediction Error Category"]);
T.Properties.VariableNames(1) = "PET";
T.Properties.VariableNames(2) = "PET_cat";
elseif wantAllVariables
T = Identifiers_Table(SelectionIDX,["Learned","Absolute Prediction Error","Prediction Error","Prediction Error Category","Prediction Error Target","Value RL Target","Value RL Difference","Target Prediction Error Category","Target Value Category","Value Difference Category"]);
T.Properties.VariableNames(1) = "L";
T.Properties.VariableNames(2) = "PE_Abs";
T.Properties.VariableNames(3) = "PE";
T.Properties.VariableNames(4) = "PE_cat";
T.Properties.VariableNames(5) = "PET";
T.Properties.VariableNames(6) = "VT";
T.Properties.VariableNames(7) = "VTD";
T.Properties.VariableNames(8) = "PET_cat";
T.Properties.VariableNames(9) = "VT_cat";
T.Properties.VariableNames(10) = "VTD_cat";
else
T = Identifiers_Table(SelectionIDX,["Learned","Prediction Error Target","Value RL Target","Value RL Difference","Target Prediction Error Category","Target Value Category","Value Difference Category"]);
T.Properties.VariableNames(1) = "L";
T.Properties.VariableNames(2) = "PET";
T.Properties.VariableNames(3) = "VT";
T.Properties.VariableNames(4) = "VTD";
T.Properties.VariableNames(5) = "PET_cat";
T.Properties.VariableNames(6) = "VT_cat";
T.Properties.VariableNames(7) = "VTD_cat";
end
Z = Identifiers_Table(SelectionIDX,["Dimensionality","Correct Trial"]);

figure;
corrplot(T, 'Type', 'Spearman', 'TestR', 'on');
figure;
corrplot(T, 'Type', 'Kendall', 'TestR', 'on');

R_partial = partialcorr(T{:,:},Z{:,:}, 'Type', 'Spearman', 'Rows', 'pairwise');

figure;
h = heatmap(R_partial, 'Colormap', parula, 'ColorLimits', [-1 1]);
h.XDisplayLabels = T.Properties.VariableNames;
h.YDisplayLabels = T.Properties.VariableNames;
title('Spearman Partial Correlation (Controlled for Others)');

% 1. Regress Var1 and Var2 against the control variable (Group)
mdl1 = fitlm(Z, T.(sel_Var1));
mdl2 = fitlm(Z, T.(sel_Var2));

% 2. Plot the residuals against each other
figure;
scatter(mdl1.Residuals.Raw, mdl2.Residuals.Raw, 'filled', 'MarkerFaceAlpha', 0.5);
grid on;
xlabel(sprintf('Residuals of %s (controlled for Group)',sel_Var1));
ylabel(sprintf('Residuals of %s (controlled for Group)',sel_Var2));
title('Partial Correlation Visualization');

T.Dimensionality = Z.Dimensionality;
T.Outcome = Z.("Correct Trial");
lme = fitlme(T, sprintf('%s ~ 1 + %s + (1 + %s | Dimensionality) + (1 + %s | Outcome)',sel_Var1,sel_Var2,sel_Var2,sel_Var2));
% lme = fitlme(T, sprintf('%s ~ 1 + %s + (1 + %s | Dimensionality)',sel_Var1,sel_Var2,sel_Var2));

% 1. Extract the Global Fixed Effect for your predictor
% Instead of fixedEffects(sel_Var2), we find the row in the Coefficients table
idxFixed = strcmp(lme.CoefficientNames, sel_Var2);
fixedEffect_Slope = lme.Coefficients.Estimate(idxFixed);

% 2. Get random effects and their identification table
[random_effects, ~, stats] = randomEffects(lme);

% 3. Filter for the slope term and the specific grouping variable
% Note: In 'stats', the 'Name' column contains the variable name (e.g., sel_Var2)
% and 'Group' contains the name of the grouping variable (e.g., 'Dimensionality')
isSlopeForDim = strcmp(stats.Name, sel_Var2) & strcmp(stats.Group, 'Dimensionality');
relevant_stats = stats(isSlopeForDim, :);

% 4. Calculate Adjusted Slopes for each group in 'Dimensionality'
% Formula: Global Slope + Group-Specific Offset
group_levels = relevant_stats.Level; 
group_offsets = random_effects(isSlopeForDim);
adjusted_slopes = fixedEffect_Slope + group_offsets;

% 5. Create final summary table
group_summary = table(group_levels, adjusted_slopes, ...
    'VariableNames', {'Dimensionality_Level', 'Group_Specific_Slope'});

disp(group_summary);

% 1. Setup figure and basic scatter plot
figure('Color', 'w', 'Name', 'Mixed-Effects Slope Analysis');
% We color the points by Dimensionality since that is our primary group of interest
h = gscatter(T.(sel_Var2), T.(sel_Var1), T.Dimensionality);
hold on;

% 2. Generate Prediction Lines
% We create a range of X values (from min to max of your predictor)
x_range = linspace(min(T.(sel_Var2)), max(T.(sel_Var2)), 100)';
unique_dims = unique(T.Dimensionality);

% For each group in Dimensionality, we plot the model's predicted line
for i = 1:length(unique_dims)
    % Create a temporary table for prediction
    % Note: We must also provide a value for 'Outcome' since it's in the model.
    % We'll use the most frequent category or '1' to keep the line consistent.
    target_dim = repmat(unique_dims(i), 100, 1);
    const_Outcome = repmat(T.Outcome(1), 100, 1); % Holding 'Outcome' constant

    tbl_pred = table(target_dim, const_Outcome, x_range, ...
        'VariableNames', {'Dimensionality', 'Outcome', char(sel_Var2)});

    % Calculate predictions (y_hat)
    y_pred = predict(lme, tbl_pred);

    % Match line color to the scatter points
    plot(x_range, y_pred, 'LineWidth', 2.5, 'Color', h(i).Color);
end

% 3. Formatting
grid on;
xlabel(sprintf('Predictor: %s', sel_Var2), 'Interpreter', 'none');
ylabel(sprintf('Response: %s', sel_Var1), 'Interpreter', 'none');
title({['Mixed-Effects Slopes by Dimensionality'], ...
       ['Controlled for: ' char(sel_Var2) ' | Grouped by: Dimensionality & Outcome']}, ...
       'Interpreter', 'none');

% Add a legend entry for the lines if desired
legend(h, 'Location', 'bestoutside');
hold off;

% 1. Setup figure and basic scatter plot
figure('Color', 'w', 'Name', 'Mixed-Effects Slope Analysis');
% We color the points by Outcome since that is our primary group of interest
h = gscatter(T.(sel_Var2), T.(sel_Var1), T.Outcome);
hold on;

% 2. Generate Prediction Lines
% We create a range of X values (from min to max of your predictor)
x_range = linspace(min(T.(sel_Var2)), max(T.(sel_Var2)), 100)';
unique_outcome = unique(T.Outcome);

% For each group in Outcome, we plot the model's predicted line
for i = 1:length(unique_outcome)
    % Create a temporary table for prediction
    % Note: We must also provide a value for 'Correct' since it's in the model.
    % We'll use the most frequent category or '1' to keep the line consistent.
    target_dim = repmat(unique_outcome(i), 100, 1);
    const_dimensionality = repmat(T.Dimensionality(1), 100, 1); % Holding 'Dimensionality' constant

    tbl_pred = table(target_dim, const_dimensionality, x_range, ...
        'VariableNames', {'Outcome', 'Dimensionality', char(sel_Var2)});

    % Calculate predictions (y_hat)
    y_pred = predict(lme, tbl_pred);

    % Match line color to the scatter points
    plot(x_range, y_pred, 'LineWidth', 2.5, 'Color', h(i).Color);
end

% 3. Formatting
grid on;
xlabel(sprintf('Predictor: %s', sel_Var2), 'Interpreter', 'none');
ylabel(sprintf('Response: %s', sel_Var1), 'Interpreter', 'none');
title({['Mixed-Effects Slopes by Outcome'], ...
       ['Controlled for: ' char(sel_Var2) ' | Grouped by: Outcome & Dimensionality']}, ...
       'Interpreter', 'none');

% Add a legend entry for the lines if desired
legend(h, 'Location', 'bestoutside');
hold off;



% BubbleTable = groupcounts(T,["L","VT-cat"]);
% bubblechart(BubbleTable,'L','VT-cat','GroupCount');