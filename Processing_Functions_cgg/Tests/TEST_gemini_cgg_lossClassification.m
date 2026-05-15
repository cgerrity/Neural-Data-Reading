%% Setup Test Environment for cgg_lossClassification
clear; clc;
rng(42); % For reproducibility

% --- Toggles ---
WantPlot = true; % Set to true to visualize the loss masking effect

NumClasses = 5;
NumBatches = 10;

% Simulate Network Outputs (Y) and One-Hot Targets (T) for CrossEntropy
% Y is random probabilities (softmaxed for realism)
Y_raw = rand(NumClasses, NumBatches);
Y_raw = Y_raw ./ sum(Y_raw, 1); 
Y = dlarray(Y_raw, 'CB');

T_raw = zeros(NumClasses, NumBatches);
T_raw(1, :) = 1; % Assume Class 1 is always the correct target
T = dlarray(T_raw, 'CB');

disp('--- Starting Unit Tests for cgg_lossClassification ---');

%% Test 1: Base Classification (No Confidence)
[Loss_Base, L_Conf1, L_Trial1, L_Task1] = cgg_lossClassification(T, Y);

assert(cgg_extractData(L_Conf1) == 0, 'Test 1 Failed: Loss_Confidence should default to 0.');
assert(cgg_extractData(Loss_Base) > 0, 'Test 1 Failed: Base loss should be > 0.');
disp('Test 1 Passed: Base CrossEntropy operates normally without confidence inputs.');

%% Test 2: Low Confidence Masking (Y interpolates to T, Loss drops)
TrialConf_Low = dlarray(0.01 * ones(1, NumBatches), 'CB');
TaskConf_Low  = dlarray(0.01 * ones(1, NumBatches), 'CB');

[Loss_LowConf, L_Conf2, ~, ~] = cgg_lossClassification(T, Y, ...
    'TrialConfidence', TrialConf_Low, 'TaskConfidence', TaskConf_Low);

% Since low confidence masks the prediction with the ground truth, the error should be near 0
assert(cgg_extractData(Loss_LowConf) < cgg_extractData(Loss_Base), 'Test 2 Failed: Low confidence should reduce classification loss.');
disp('Test 2 Passed: Low Confidence successfully masks predictions (Classification Loss drops).');

%% Test 3: High Confidence Preserving (Y is preserved, Loss stays high)
% Use 0.9999 to prevent log-scale amplification in Cross-Entropy from tiny interpolation shifts
TrialConf_High = dlarray(0.9999 * ones(1, NumBatches), 'CB');
TaskConf_High  = dlarray(0.9999 * ones(1, NumBatches), 'CB');

[Loss_HighConf, L_Conf3, ~, ~] = cgg_lossClassification(T, Y, ...
    'TrialConfidence', TrialConf_High, 'TaskConfidence', TaskConf_High);

diffLoss = abs(cgg_extractData(Loss_HighConf) - cgg_extractData(Loss_Base));
assert(diffLoss < 0.1, 'Test 3 Failed: High confidence should preserve the original classification loss.');
disp('Test 3 Passed: High Confidence successfully preserves predictions.');

%% Test 4: Weighted CrossEntropy
ClassWeights = dlarray(rand(NumClasses, 1), 'C');
[Loss_Weighted, ~, ~, ~] = cgg_lossClassification(T, Y, 'Weights', ClassWeights);

assert(cgg_extractData(Loss_Weighted) ~= cgg_extractData(Loss_Base), 'Test 4 Failed: Weights did not alter the loss.');
disp('Test 4 Passed: Weighted CrossEntropy applies weights successfully.');

%% Test 5: DatasetConfidence Historical EMA Effect
% We will pass the exact same mid-level batch confidence, but change the
% historical DatasetConfidence to see how the EMA alters the final penalty.
TrialConf_Mid = dlarray(0.5 * ones(1, NumBatches), 'CB');
TaskConf_Mid  = dlarray(0.5 * ones(1, NumBatches), 'CB');
% Total batch confidence mean will be 0.25

% Sub-Test 5A: Strong Historical Confidence (EMA anchor = 0.9)
Hist_Strong = dlarray(0.9);
[~, Loss_Conf_StrongHistory, ~, ~] = cgg_lossClassification(T, Y, ...
    'TrialConfidence', TrialConf_Mid, 'TaskConfidence', TaskConf_Mid, ...
    'DatasetConfidence', Hist_Strong, ...
    'DatasetTrialConfidence', Hist_Strong, ...
    'DatasetTaskConfidence', Hist_Strong, ...
    'BatchFraction', 0.1, 'ConfidenceLossType', 'L1');

% Sub-Test 5B: Weak Historical Confidence (EMA anchor = 0.3)
Hist_Weak = dlarray(0.3);
[~, Loss_Conf_WeakHistory, ~, ~] = cgg_lossClassification(T, Y, ...
    'TrialConfidence', TrialConf_Mid, 'TaskConfidence', TaskConf_Mid, ...
    'DatasetConfidence', Hist_Weak, ...
    'DatasetTrialConfidence', Hist_Weak, ...
    'DatasetTaskConfidence', Hist_Weak, ...
    'BatchFraction', 0.1, 'ConfidenceLossType', 'L1');

% Because both batches have a mean of 0.25, the weak history (0.3) drags 
% the overall EMA much further away from the 1.0 target than the strong 
% history (0.9), resulting in a harsher penalty.
assert(cgg_extractData(Loss_Conf_WeakHistory) > cgg_extractData(Loss_Conf_StrongHistory), ...
    'Test 5 Failed: A weaker confidence history should result in a higher regularizer penalty.');
disp('Test 5 Passed: Historical DatasetConfidence correctly modulates the penalty via EMA tracking.');

disp('--- All Unit Tests Passed! ---');

%% Visualization: Dual Effect of Confidence
if WantPlot
    figure('Name', 'Classification & Confidence Loss Behaviors', 'Position', [100, 100, 1000, 500]);
    
    % --- Panel 1: Selective Classification (Masking Effect) ---
    subplot(1,2,1);
    base_val = cgg_extractData(Loss_Base);
    high_val = cgg_extractData(Loss_HighConf);
    low_val  = cgg_extractData(Loss_LowConf);
    
    LossValues = [base_val, high_val, low_val];
    Categories = {'Base (No Conf)', 'High Conf', 'Low Conf (Masked)'};
    
    b1 = bar(LossValues, 'FaceColor', 'flat');
    b1.CData(1,:) = [0.6 0.6 0.6]; % Gray
    b1.CData(2,:) = [0.8 0.3 0.3]; % Red
    b1.CData(3,:) = [0.3 0.7 0.4]; % Green
    
    set(gca, 'XTickLabel', Categories);
    ylabel('Cross Entropy Loss (\mathcal{L}_{cls})');
    title('Interpolation Effect on Classification Loss');
    grid on;
    
    for i = 1:length(LossValues)
        text(i, LossValues(i) + 0.05, sprintf('%.3f', LossValues(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
    end
    
    % --- Panel 2: EMA Dataset Tracking Effect ---
    subplot(1,2,2);
    strong_hist_val = cgg_extractData(Loss_Conf_StrongHistory);
    weak_hist_val   = cgg_extractData(Loss_Conf_WeakHistory);
    
    ConfLossValues = [strong_hist_val, weak_hist_val];
    ConfCategories = {'Strong History (\Omega_{t-1}=0.9)', 'Weak History (\Omega_{t-1}=0.3)'};
    
    b2 = bar(ConfLossValues, 'FaceColor', 'flat');
    b2.CData(1,:) = [0.2 0.5 0.8]; % Blue
    b2.CData(2,:) = [0.8 0.5 0.2]; % Orange
    
    set(gca, 'XTickLabel', ConfCategories);
    ylabel('Dataset Confidence Penalty (\mathcal{L}_{conf})');
    title('EMA History Effect (Identical Batch Input)');
    grid on;
    
    for i = 1:length(ConfLossValues)
        text(i, ConfLossValues(i) + (max(ConfLossValues)*0.05), sprintf('%.3f', ConfLossValues(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
    end
    
    % Add explanatory text box spanning the bottom
    annotation('textbox', [0.15 0.01 0.75 0.1], 'String', ...
        'Left: Low confidence successfully cheats classification by interpolating to ground truth. Right: The regularizer fights back. An identical low-confidence batch receives a harsher penalty if the historical dataset trend is already poor.', ...
        'HorizontalAlignment', 'center', 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'FontSize', 10);
end