%% Setup Test Environment for cgg_getConfidenceLossInformation
clear; clc;
rng(42); % For reproducibility

% --- Toggles ---
WantPlot = true; % Set to true to visualize the dynamic Beta controller

disp('--- Starting Unit Tests for cgg_getConfidenceLossInformation ---');

%% Setup Mock Inputs
% Simulate 2 valid classification dimensions (K=2)
ValidIndices = [true, true];
K_Dimensions = sum(ValidIndices);
BatchFraction = 0.1;

% Base mock losses
L_Trial = dlarray([1.0,1.0]);
L_Task  = dlarray([2.0, 4.0]); 
L_Total = dlarray([0.5, 1.5]); 

%% Test 1: Initialization & Tri-Partite Aggregation
LossInfo_Empty = struct();
TrialConf_Mock = dlarray(0.8 * ones(1, 10));
TaskConf_Mock  = dlarray(0.8 * ones(1, 10));

[Loss_Penalty1, LossInfo_Out1] = cgg_getConfidenceLossInformation(...
    LossInfo_Empty, TrialConf_Mock, TaskConf_Mock, ...
    L_Trial, L_Task, L_Total, ValidIndices, BatchFraction);

Expected_Penalty = 5.0;
Actual_Penalty = cgg_extractData(Loss_Penalty1);

assert(isfield(LossInfo_Out1, 'DatasetTotalConfidence'), 'Test 1 Failed: Struct not initialized.');
assert(abs(Actual_Penalty - Expected_Penalty) < 1e-4, 'Test 1 Failed: Tri-partite loss aggregation incorrect.');
disp('Test 1 Passed: Empty struct properly initialized and tri-partite losses successfully aggregated.');

%% Test 2: Beta Controller Amplification (Confidence Drop)
LossInfo_Strong = struct();
LossInfo_Strong.DatasetTotalConfidence = 0.95;
LossInfo_Strong.DatasetTrialConfidence = 0.95;
LossInfo_Strong.DatasetTaskConfidence  = 0.95;
LossInfo_Strong.Confidence_Beta = 1.0;

% Network suddenly predicts low confidence
TrialConf_Low = dlarray(sqrt(0.3) * ones(1, 10));
TaskConf_Low  = dlarray(sqrt(0.3) * ones(1, 10));

[~, LossInfo_Out2] = cgg_getConfidenceLossInformation(...
    LossInfo_Strong, TrialConf_Low, TaskConf_Low, ...
    L_Trial, L_Task, L_Total, ValidIndices, BatchFraction);

assert(LossInfo_Out2.Confidence_Beta > 1.0, 'Test 2 Failed: Beta controller did not amplify during a confidence drop.');
disp('Test 2 Passed: Dynamic Beta Controller successfully amplifies penalty when data is rejected.');

disp('--- All Unit Tests Passed! ---');

%% Visualization: Simulated Closed-Loop Non-Linear Control
if WantPlot
    figure('Name', 'Dynamic Confidence Budgeting Validation', 'Position', [150, 150, 950, 650]);
    
    NumEpochs = 500;
    BrutalEpochEnd = 100;
    BetaHistory = zeros(1, NumEpochs);
    DataConfHistory = zeros(1, NumEpochs);
    RunAvgHistory = zeros(1, NumEpochs);
    
    SimLossInfo = struct(); 
    SimLossInfo.Confidence_Beta = 1.0;
    SimLossInfo.DatasetTotalConfidence = NaN;
    
    % Simulated neural network's internal confidence state
    NetworkBaseConfidence = 0.5; 
    
    for i = 1:NumEpochs
        
        % 1. SIMULATED NEURAL NETWORK UPDATE STEP (Gradient Descent Proxy)
        if i <= 30
            % Phase 1: Easy task. Network is happy staying confident.
            DownwardPressure = 0.01;
        elseif i <= BrutalEpochEnd
            % Phase 2: BRUTAL task. Classification loss pushes extremely hard 
            % to drop confidence down to zero to mask the bad predictions.
            DownwardPressure = 0.1;
        else
            % Phase 3: Task becomes easy again. Classification pressure lifts.
            DownwardPressure = 0.01;
        end
        
        % Network reacts to the regularizer: A higher Beta produces a stronger 
        % gradient pushing the network to keep its confidence high.
        UpwardPull = 0.05 * SimLossInfo.Confidence_Beta;
        
        % Apply simulated gradient update to the network's strategy
        NetworkBaseConfidence = NetworkBaseConfidence + UpwardPull - DownwardPressure;
        NetworkBaseConfidence = max(min(NetworkBaseConfidence, 0.99), 0.01); 
        
        % Generate the batch predictions based on current network strategy
        T_Conf = dlarray(sqrt(NetworkBaseConfidence) + 0.01 * randn(1, 10));
        K_Conf = dlarray(sqrt(NetworkBaseConfidence) + 0.01 * randn(1, 10));
        
        T_Conf(T_Conf > 1) = 1; T_Conf(T_Conf < 0) = 0;
        K_Conf(K_Conf > 1) = 1; K_Conf(K_Conf < 0) = 0;
        
        BatchConf = T_Conf .* K_Conf;
        DataConfHistory(i) = mean(cgg_extractData(BatchConf), 'all');
        
        % 2. ARCHITECTURE CONTROLLER STEP (The function we are testing)
        [~, SimLossInfo] = cgg_getConfidenceLossInformation(...
            SimLossInfo, T_Conf, K_Conf, ...
            L_Trial, L_Task, L_Total, ValidIndices, 0.1);
        
        BetaHistory(i) = SimLossInfo.Confidence_Beta;
        RunAvgHistory(i) = SimLossInfo.DatasetTotalConfidence;
    end
    
    % Panel 1: Data Confidence vs Running Average
    subplot(2,1,1);
    plot(1:NumEpochs, DataConfHistory, '-o', 'LineWidth', 1.5, 'MarkerSize', 5, 'DisplayName', 'Network Batch Conf (\bar{\omega}_b)');
    hold on;
    plot(1:NumEpochs, RunAvgHistory, '--r', 'LineWidth', 2, 'DisplayName', 'EMA Tracking (\Omega_t)');
    
    xline(30.5, 'k:', 'LineWidth', 2, 'DisplayName', 'Phase 2: Task gets Hard');
    xline(BrutalEpochEnd + 0.5, 'g:', 'LineWidth', 2, 'DisplayName', 'Phase 3: Task gets Easy');
    
    ylabel('Confidence Magnitude');
    title('Closed-Loop Autonomous Equilibrium: Confidence Recovery');
    legend('Location', 'southwest');
    grid on;
    ylim([0, 1.1]);
    
    % Panel 2: Beta Multiplier Response
    subplot(2,1,2);
    plot(1:NumEpochs, BetaHistory, '-s', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'MarkerSize', 5, 'DisplayName', 'Dynamic Controller (\beta_t)');
    hold on;
    xline(30.5, 'k:', 'LineWidth', 2, 'HandleVisibility', 'off');
    xline(BrutalEpochEnd + 0.5, 'g:', 'LineWidth', 2, 'HandleVisibility', 'off');
    yline(1.0, 'k--', 'LineWidth', 1, 'DisplayName', 'Baseline Penalty (\beta = 1.0)');
    
    xlabel('Training Steps (Batches)');
    ylabel('Beta Controller (\beta_t)');
    title('Beta anchors during stress, gracefully relaxes when safe');
    legend('Location', 'northwest');
    grid on;
    
    % Add explanatory text
    dim = [0.54 0.24 0.35 0.19];
    str = {'Equilibrium Controller Mechanics:', ...
           '1. Phase 2 (Hard): Confidence drops, Beta integrates UP.', ...
           '2. Push vs Pull hits Equilibrium: Beta holds steady at ~4.0.', ...
           '3. Crucially, Beta REFUSES to drop because doing so would', ...
           '   cause confidence to collapse under the hard task.', ...
           '4. Phase 3 (Easy): Confidence rises to 0.99 naturally.', ...
           '5. The Relaxation Pull takes over, and Beta smoothly coasts to 1.0.'};
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on', 'BackgroundColor', 'w');
end
