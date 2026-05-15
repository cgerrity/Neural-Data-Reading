%% Setup Test Environment for cgg_getPredictionFromClassifierProbabilities
clear; clc;
rng(42); % For reproducibility

% --- Toggles ---
WantPlot = true; % Visualize the multi-dimensional loss routing

% Simulate Dimensions: 2 Feature Branches (e.g., Shape and Color)
NumDims = 2;
NumBatches = 5;
NumTimeSteps = 10;

% Use numeric class names for robust onehotencode mapping
ClassNames = {[1, 2], [1, 2, 3]};

% Simulate Y (Network probabilities in 'CBT' format)
% Dimension 1: 2 classes
Y_1_raw = rand(2, NumBatches, NumTimeSteps); 
Y_1_raw = Y_1_raw ./ sum(Y_1_raw, 1);
% Dimension 2: 3 classes
Y_2_raw = rand(3, NumBatches, NumTimeSteps); 
Y_2_raw = Y_2_raw ./ sum(Y_2_raw, 1);

Y = {dlarray(Y_1_raw, 'CBT'), dlarray(Y_2_raw, 'CBT')};

% Simulate T (Targets matching ClassNames)
% FIX: Targets do not have a time component. They are a single classification
% per trial (NumDims x NumBatches).
T_target = zeros(NumDims, NumBatches);
T_target(1,:) = randi([1, 2], [1, NumBatches]);
T_target(2,:) = randi([1, 3], [1, NumBatches]);

disp('--- Starting Unit Tests for cgg_getPredictionFromClassifierProbabilities ---');

%% Test 1: Base Processing (No Confidence, Empty LossInfo)
[Win_Pred1, Win_True1, Loss_Class1, Agg_Pred1, Agg_True1, Loss_Conf1, ~, ~] = ...
    cgg_getPredictionFromClassifierProbabilities(T_target, Y, ClassNames, ...
    'IsQuaddle', false);

assert(length(Loss_Class1) == NumDims, 'Test 1 Failed: Classification loss should return an array matching NumDimensions.');
assert(all(isnan(cgg_extractData(Loss_Conf1)) | cgg_extractData(Loss_Conf1) == 0), 'Test 1 Failed: Confidence loss should default to 0/NaN.');
assert(~any(isnan(Agg_Pred1), 'all'), 'Test 1 Failed: Aggregation predictions returned NaNs.');
disp('Test 1 Passed: Core multidimensional prediction and base Cross-Entropy calculation successful.');

%% Test 2: Selective Classification Integration
% Inject low confidence to force the function to mask predictions
TrialConf = dlarray(0.01 * ones(1, NumBatches, NumTimeSteps), 'CBT');
TaskConf = {dlarray(0.01 * ones(1, NumBatches, NumTimeSteps), 'CBT'), ...
            dlarray(0.01 * ones(1, NumBatches, NumTimeSteps), 'CBT')};

% FIX: Add BatchFraction so the EMA math doesn't overwrite entirely with the current batch
[~, ~, Loss_Class2, ~, ~, Loss_Conf2, ~, ~] = ...
    cgg_getPredictionFromClassifierProbabilities(T_target, Y, ClassNames, ...
    'IsQuaddle', false, 'TrialConfidence', TrialConf, 'TaskConfidence', TaskConf, 'BatchFraction', 0.1);

% If interpolation works, the total classification loss should drop significantly
assert(sum(cgg_extractData(Loss_Class2)) < sum(cgg_extractData(Loss_Class1)), ...
    'Test 2 Failed: Selective classification masking failed to reduce primary loss.');
assert(sum(cgg_extractData(Loss_Conf2)) > 0, ...
    'Test 2 Failed: Regularization confidence loss was not calculated.');
disp('Test 2 Passed: Selective classification correctly integrated across multiple dimensions.');

%% Test 3: LossInformation EMA Unpacking
% Simulate a strong historical dataset running average
LossInfo.DatasetTotalConfidence = 0.9;
LossInfo.DatasetTrialConfidence = 0.9;
LossInfo.DatasetTaskConfidence  = 0.9;

% Rerun Test 2 (low batch confidence) but provide the strong EMA history
% FIX: Add BatchFraction so the parsed history is actually utilized
[~, ~, ~, ~, ~, Loss_Conf3, ~, ~] = ...
    cgg_getPredictionFromClassifierProbabilities(T_target, Y, ClassNames, ...
    'IsQuaddle', false, 'TrialConfidence', TrialConf, 'TaskConfidence', TaskConf, ...
    'LossInformation', LossInfo, 'BatchFraction', 0.1);

% Because the EMA history is strong, the penalty for dropping to 0.01 should
% be distinctly mathematically different than Test 2 (which defaults to EMA=1.0)
assert(sum(cgg_extractData(Loss_Conf3)) ~= sum(cgg_extractData(Loss_Conf2)), ...
    'Test 3 Failed: LossInformation EMA history was not parsed and applied.');
disp('Test 3 Passed: Historical EMA correctly unpacked from LossInformation struct and routed to regularizer.');

disp('--- All Unit Tests Passed! ---');

%% Visualization: Multidimensional Loss Routing
if WantPlot
    figure('Name', 'Multidimensional Classification & Prediction Validation', 'Position', [150, 150, 900, 450]);
    
    % Prepare data for bar chart
    LC_1 = cgg_extractData(Loss_Class1);
    LC_2 = cgg_extractData(Loss_Class2);
    
    LConf_2 = cgg_extractData(Loss_Conf2);
    LConf_3 = cgg_extractData(Loss_Conf3);
    
    DimNames = {'Feature Dim 1 (2 Classes)', 'Feature Dim 2 (3 Classes)'};
    
    subplot(1,2,1);
    b1 = bar([LC_1; LC_2]', 'grouped');
    set(gca, 'XTickLabel', DimNames);
    ylabel('Cross Entropy Loss');
    title('Interpolation Masking per Dimension');
    legend('Base Loss (No Confidence)', 'Masked Loss (\omega \approx 0)', 'Location', 'best');
    grid on;
    
    subplot(1,2,2);
    b2 = bar([LConf_2; LConf_3]', 'grouped');
    set(gca, 'XTickLabel', DimNames);
    ylabel('Confidence Penalty');
    title('EMA History Parsing from LossInformation');
    legend('Default EMA Initialization', 'Strong EMA parsed from Struct', 'Location', 'best');
    grid on;
    
    % Add explanatory text
    annotation('textbox', [0.15 0.01 0.75 0.08], 'String', ...
        'This proves the orchestrator successfully unpacks the multi-dimensional outputs and routes the EMA variables to the core regularizers.', ...
        'HorizontalAlignment', 'center', 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'FontSize', 10);
end