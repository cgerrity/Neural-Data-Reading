%% Setup Test Environment for cgg_lossConfidence
clear; clc;
rng(42); % For reproducibility

% --- Toggles ---
WantPlot = true; % Set to true to visualize the interpolation results

NumClasses = 5;
NumBatches = 10;

% Simulate Network Outputs (Y) and One-Hot Targets (T)
% Y is random probabilities, T is a one-hot vector (Class 1 is correct)
Y_raw = rand(NumClasses, NumBatches);
Y = dlarray(Y_raw, 'CB');

T_raw = zeros(NumClasses, NumBatches);
T_raw(1, :) = 1; 
T = dlarray(T_raw, 'CB');

disp('--- Starting Unit Tests for cgg_lossConfidence ---');

%% Test 1 & 2: Interpolation (High & Low Confidence)
% We'll make the first 5 batches HIGH confidence, and the last 5 LOW confidence
TrialConf_raw = [0.999 * ones(1, 5), 0.001 * ones(1, 5)];
TaskConf_raw  = [0.999 * ones(1, 5), 0.001 * ones(1, 5)];
TrialConf = dlarray(TrialConf_raw, 'CB');
TaskConf  = dlarray(TaskConf_raw, 'CB');

[Y_out, Loss_Total, Loss_Trial, Loss_Task] = cgg_lossConfidence(...
    Y, T, TrialConf, TaskConf, 'BatchFraction', 0.1, 'WantDatasetConfidence', false);

% Extract for assertions
Y_out_data = extractdata(Y_out);

% Assertions for High Confidence (Batches 1:5) -> Y_out should be close to original Y
diffY_HighConf = mean(abs(Y_out_data(:, 1:5) - Y_raw(:, 1:5)), 'all');
assert(diffY_HighConf < 0.01, 'Test 1 Failed: High confidence should leave Y mostly unchanged.');
disp('Test 1 Passed: High Confidence Preserves Predictions.');

% Assertions for Low Confidence (Batches 6:10) -> Y_out should be close to ground truth T
diffT_LowConf = mean(abs(Y_out_data(:, 6:10) - T_raw(:, 6:10)), 'all');
assert(diffT_LowConf < 0.01, 'Test 2 Failed: Low confidence should interpolate Y completely towards T.');
disp('Test 2 Passed: Low Confidence Masks Data with Ground Truth.');

%% Test 3: Missing Branch Handling
[Y_out3, Loss_Total3, Loss_Trial3, Loss_Task3] = cgg_lossConfidence(...
    Y, T, TrialConf, [], 'BatchFraction', 0.1, 'WantDatasetConfidence', false);

assert(extractdata(Loss_Task3) == 0, 'Test 3 Failed: Missing TaskConfidence should return 0 loss.');
disp('Test 3 Passed: Missing Confidence Branches Handled Gracefully.');

%% Test 4: Mathematical Verification of EMA and Gradient Scaling
HistoricalConf = dlarray(0.5); % Set historical running average to 0.5
BatchFraction = 0.1;           % Gamma

% Use perfectly certain inputs so batch mean = 1.0
TrialConf_Perfect = dlarray(ones(1, NumBatches), 'CB');
TaskConf_Perfect  = dlarray(ones(1, NumBatches), 'CB');

[~, Loss_Total4, ~, ~] = cgg_lossConfidence(...
    Y, T, TrialConf_Perfect, TaskConf_Perfect, ...
    'BatchFraction', BatchFraction, ...
    'DatasetTotalConfidence', HistoricalConf, ...
    'WantDatasetConfidence', true, ...
    'LossType', 'L1','WantBatchCorrection',true);

% --- Manual Verification of the Math ---
% 1. Batch Mean (\bar{\omega}_b) = 1.0 * 1.0 = 1.0
% 2. EMA Update: \Omega_t = 0.5 * (1 - 0.1) + 1.0 * 0.1 = 0.45 + 0.1 = 0.55
% 3. L1 Loss vs target 1.0: |1.0 - 0.55| = 0.45
% 4. Gradient Correction Scaling: 0.45 / 0.1 = 4.5
ExpectedLoss = 4.5;
ActualLoss = extractdata(Loss_Total4);

assert(abs(ActualLoss - ExpectedLoss) < 1e-4, ...
    sprintf('Test 4 Failed: Expected Loss %f, but got %f', ExpectedLoss, ActualLoss));
disp('Test 4 Passed: EMA and 1/\gamma Gradient Scaling verified to 4 decimal places.');

disp('--- All Unit Tests Passed! ---');

%% Visualization
if WantPlot
    figure('Name', 'Confidence Interpolation Validation', 'Position', [100, 100, 1000, 600]);
    
    % We visualize the values for Class 1 (the target class) across all batches
    Y_c1 = Y_raw(1,:);
    T_c1 = T_raw(1,:);
    Y_out_c1 = Y_out_data(1,:);
    TotalConf_calculated = TrialConf_raw .* TaskConf_raw;
    
    subplot(2,1,1);
    plot(1:NumBatches, Y_c1, '-o', 'DisplayName', 'Original Prediction (Y)', 'LineWidth', 2, 'MarkerSize', 6); hold on;
    plot(1:NumBatches, T_c1, '--s', 'DisplayName', 'Ground Truth Target (T)', 'LineWidth', 2, 'MarkerSize', 8);
    plot(1:NumBatches, Y_out_c1, '-^', 'DisplayName', 'Interpolated Output (Y'')', 'LineWidth', 2, 'MarkerSize', 6);
    ylabel('Class 1 Probability');
    title('Interpolation Effect on Predictions (High Conf vs. Low Conf)');
    legend('Location', 'best');
    grid on;
    
    % Draw a dividing line between the high/low confidence tests
    xline(5.5, 'k:', 'LineWidth', 1.5, 'DisplayName', 'Confidence Shift');
    
    subplot(2,1,2);
    bar(1:NumBatches, TotalConf_calculated, 'FaceColor', [0.4 0.6 0.8]);
    xlabel('Batch Instance');
    ylabel('Total Confidence (\omega^{total})');
    title('Confidence Level per Instance (\omega^{trial} \times \omega^{task})');
    ylim([0 1.1]);
    grid on;
end