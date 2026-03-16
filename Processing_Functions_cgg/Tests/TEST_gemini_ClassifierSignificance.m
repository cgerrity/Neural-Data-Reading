% =========================================================================
% Permutation Test Null Distribution Comparison
% Metric: Balanced Accuracy
% Dataset: Imbalanced Multi-class (3 classes)
% =========================================================================

clc; clear; close all;

% 1. Setup Dataset Parameters
N = 500;                 % Total number of samples (Try changing to 100, 5000, etc.)
num_permutations = 100000; % Number of iterations for the null distributions
classes = [1, 2, 3];     % 3-class problem
model_skill = 0.38;      % Proportion of forced correct predictions (0.0 to 1.0)
K_folds = 10;             % Number of cross-validation folds
pred_type = 'wrong_bias';   % Options: 'wrong_bias', 'majority', 'proportional', 'uniform'
target_p_value = 0.05;   % Target significance level for Figure 3
num_model_reps = 1000;     % Number of model repetitions to stabilize p-value curves (Figure 5)
skill_sweep_max = 0.4;

% 2. Create Imbalanced True Labels (Y_true)
% Severe imbalance: 80% Class 1, 15% Class 2, 5% Class 3
n_c1 = round(0.80 * N);
n_c2 = round(0.15 * N);
n_c3 = N - n_c1 - n_c2; % Ensure total is exactly N
Y_true = [ones(n_c1, 1); 2*ones(n_c2, 1); 3*ones(n_c3, 1)];

% 3. Create Model Predictions (Y_pred_base) based on pred_type
switch pred_type
    case 'wrong_bias'
        % Predicts Class 1 (60%), Class 2 (40%), NEVER Class 3
        n_p1 = round(0.60 * N);
        Y_pred_base = [ones(n_p1, 1); 2*ones(N - n_p1, 1)];
    case 'majority'
        % Predicts ONLY the majority class (Class 1)
        Y_pred_base = ones(N, 1);
    case 'proportional'
        % Predicts with the exact same imbalance as the true labels
        Y_pred_base = [ones(n_c1, 1); 2*ones(n_c2, 1); 3*ones(n_c3, 1)];
    case 'uniform'
        % Predicts all classes equally
        n_u = floor(N / 3);
        Y_pred_base = [ones(n_u, 1); 2*ones(n_u, 1); 3*ones(N - 2*n_u, 1)];
    otherwise
        error('Unknown pred_type. Choose from: wrong_bias, majority, proportional, uniform');
end

Y_pred = Y_pred_base(randperm(N)); % Shuffle to ensure it's random chance initially

% Give the model a tiny bit of true predictive power so it beats chance
% We'll force a proportion of its predictions to perfectly match the true labels based on model_skill
num_matches = round(model_skill * N);
match_idx = randperm(N, num_matches);
Y_pred(match_idx) = Y_true(match_idx);

% Assign each sample to a random fold (1 to K)
fold_ids = mod(randperm(N) - 1, K_folds) + 1;

% 4. Calculate the TRUE Balanced Accuracy of our model across K folds
true_fold_accs = zeros(K_folds, 1);
for k = 1:K_folds
    idx = (fold_ids == k);
    true_fold_accs(k) = calc_balanced_accuracy(Y_true(idx), Y_pred(idx), classes);
end
true_bal_acc = mean(true_fold_accs);
fprintf('True Balanced Accuracy (K-Fold Average): %.4f\n', true_bal_acc);

% 5. Initialize arrays to hold the null distributions
null_dist_method1 = zeros(num_permutations, 1);
null_dist_method2 = zeros(num_permutations, 1);

fprintf('Running %d permutations in parallel...\n', num_permutations);

parfor i = 1:num_permutations
    % Shuffle Y_true globally to break the relationship with features
    Y_true_shuffled = Y_true(randperm(N));
    Y_pred_random = Y_true(randperm(N)); % For Method 2
    
    fold_accs_m1 = zeros(K_folds, 1);
    fold_accs_m2 = zeros(K_folds, 1);
    
    for k = 1:K_folds
        idx = (fold_ids == k);
        
        % ---------------------------------------------------------------------
        % METHOD 1 (Correct): Evaluate actual Y_pred against shuffled Y_true
        % ---------------------------------------------------------------------
        fold_accs_m1(k) = calc_balanced_accuracy(Y_true_shuffled(idx), Y_pred(idx), classes);
        
        % ---------------------------------------------------------------------
        % METHOD 2 (Flawed): Evaluate shuffled Y_true against another shuffled Y_true
        % ---------------------------------------------------------------------
        fold_accs_m2(k) = calc_balanced_accuracy(Y_true_shuffled(idx), Y_pred_random(idx), classes);
    end
    
    % The null metric must be the mean of the fold metrics
    null_dist_method1(i) = mean(fold_accs_m1);
    null_dist_method2(i) = mean(fold_accs_m2);
end

% 6. Calculate P-Values for both methods
p_val_1 = sum(null_dist_method1 >= true_bal_acc) / num_permutations;
p_val_2 = sum(null_dist_method2 >= true_bal_acc) / num_permutations;

fprintf('P-value (Method 1 - Correct): %.4f\n', p_val_1);
fprintf('P-value (Method 2 - Flawed) : %.4f\n', p_val_2);

% 7. Visualization
figure('Position', [100, 100, 900, 500]);
hold on;

% Plot Method 2 (Flawed) in Red
h2 = histogram(null_dist_method2, 'FaceColor', [0.85 0.32 0.09], ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none', 'Normalization', 'pdf', ...
    'NumBins', 150);

% Plot Method 1 (Correct) in Blue
h1 = histogram(null_dist_method1, 'FaceColor', [0 0.447 0.741], ...
    'FaceAlpha', 0.6, 'EdgeColor', 'none', 'Normalization', 'pdf', ...
    'NumBins', 150);

% Plot True Balanced Accuracy Line
xline(true_bal_acc, 'k--', 'LineWidth', 2.5, ...
    'Label', sprintf('True Acc: %.3f', true_bal_acc), ...
    'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'top');

% Formatting
title('Null Distributions: Method 1 vs Method 2 (Balanced Accuracy)', 'FontSize', 14);
xlabel('Balanced Accuracy Score', 'FontSize', 12);
ylabel('Probability Density', 'FontSize', 12);
legend([h1, h2], ...
    {'Method 1 (Correct): Actual Predictions vs Shuffled True Labels', ...
     'Method 2 (Flawed): Random Guesser vs Shuffled True Labels'}, ...
    'Location', 'northwest', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 11);
hold off;

% =========================================================================
% PART 2: Effect of Model Skill on the Null Distribution Shape
% =========================================================================
fprintf('\nGenerating Figure 2: Effect of Model Skill...\n');

skill_levels = [0.0, 0.5, 1.0];
skill_colors = [0.4660 0.6740 0.1880;  % Green (Skill 0.0 - Bad/Biased Model)
                0.9290 0.6940 0.1250;  % Yellow/Orange (Skill 0.5 - Mediocre Model)
                0.4940 0.1840 0.5560]; % Purple (Skill 1.0 - Perfect Model)

figure('Position', [150, 150, 900, 500]);
hold on;

% Plot Method 2 (Flawed) first as a solid outline.
% We reuse null_dist_method2 from Part 1 because Method 2 only relies on Y_true 
% and is completely unaffected by model skill!
h_flawed = histogram(null_dist_method2, 'DisplayStyle', 'stairs', ...
    'EdgeColor', [0.85 0.32 0.09], 'LineWidth', 2.5, 'Normalization', 'pdf', ...
    'NumBins', 100, 'DisplayName', 'Method 2 (Flawed) - Static Baseline');

hist_handles = gobjects(length(skill_levels) + 1, 1);
hist_handles(1) = h_flawed;

% Initialize cell array to store the distributions for Part 3
all_null_dists = cell(length(skill_levels), 1);

for s_idx = 1:length(skill_levels)
    current_skill = skill_levels(s_idx);
    
    % 1. Create temporary predictions based on this skill level and chosen pred_type
    temp_Y_pred = Y_pred_base(randperm(N)); 
    
    num_matches = round(current_skill * N);
    match_idx = randperm(N, num_matches);
    temp_Y_pred(match_idx) = Y_true(match_idx);
    
    % 2. Run permutations for Method 1 in parallel
    null_dist_skill = zeros(num_permutations, 1);
    parfor i = 1:num_permutations
        Y_true_shuf = Y_true(randperm(N));
        fold_accs = zeros(K_folds, 1);
        for k = 1:K_folds
            idx = (fold_ids == k);
            fold_accs(k) = calc_balanced_accuracy(Y_true_shuf(idx), temp_Y_pred(idx), classes);
        end
        null_dist_skill(i) = mean(fold_accs);
    end
    
    % Save the distribution for Part 3
    all_null_dists{s_idx} = null_dist_skill;
    
    % 3. Plot the distribution
    hist_handles(s_idx + 1) = histogram(null_dist_skill, 'FaceColor', skill_colors(s_idx, :), ...
        'FaceAlpha', 0.5, 'EdgeColor', 'none', 'Normalization', 'pdf', ...
        'NumBins', 100, 'DisplayName', sprintf('Method 1 (Correct): Skill = %.1f', current_skill));
end

title('Null Distributions: Correct vs Flawed Across Model Skills', 'FontSize', 14);
xlabel('Balanced Accuracy Score', 'FontSize', 12);
ylabel('Probability Density', 'FontSize', 12);
legend(hist_handles, 'Location', 'northeast', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 11);
hold off;

% =========================================================================
% PART 3: Critical Thresholds (Sweep Across Skill Levels)
% =========================================================================
fprintf('\nGenerating Figure 3: Sweeping Skill Levels for Critical Thresholds...\n');

figure('Position', [200, 200, 800, 500]);
hold on;

% Find the threshold index (e.g. top 5% of scores)
target_idx = max(1, round(target_p_value * num_permutations));

% 1. Calculate Flawed Threshold (Static)
sorted_flawed = sort(null_dist_method2, 'descend');
threshold_flawed = sorted_flawed(target_idx);

% 2. Sweep over many skill levels to generate the curve
skill_sweep = linspace(0, skill_sweep_max, 21); % 21 points from 0.0 to 1.0
thresholds_sweep = zeros(length(skill_sweep), 1);
all_sweeps_sorted = zeros(num_permutations, length(skill_sweep)); % Added to store data for Part 4

% Added to store data for Part 5
p_vals_m1_sweep = zeros(length(skill_sweep), 1);
p_vals_m2_sweep = zeros(length(skill_sweep), 1);
p_vals_ttest_sweep = zeros(length(skill_sweep), 1);

for s_idx = 1:length(skill_sweep)
    current_skill = skill_sweep(s_idx);
    
    % --- 1. GENERATE REPRESENTATIVE PREDICTIONS FOR PERMUTATIONS ---
    % We only need to generate the expensive null distribution once per skill level
    temp_Y_pred_rep1 = Y_pred_base(randperm(N)); 
    num_matches = round(current_skill * N);
    match_idx = randperm(N, num_matches);
    temp_Y_pred_rep1(match_idx) = Y_true(match_idx);
    
    % --- 2. RUN PERMUTATIONS (Once per skill level) ---
    null_dist_sweep = zeros(num_permutations, 1);
    parfor i = 1:num_permutations
        Y_true_shuf = Y_true(randperm(N));
        fold_accs = zeros(K_folds, 1);
        for k = 1:K_folds
            idx = (fold_ids == k);
            fold_accs(k) = calc_balanced_accuracy(Y_true_shuf(idx), temp_Y_pred_rep1(idx), classes);
        end
        null_dist_sweep(i) = mean(fold_accs);
    end
    
    % Calculate threshold for Figures 3 & 4
    sorted_sweep = sort(null_dist_sweep, 'descend');
    thresholds_sweep(s_idx) = sorted_sweep(target_idx);
    all_sweeps_sorted(:, s_idx) = sorted_sweep; 
    
    % --- 3. REPETITIONS TO STABILIZE P-VALUES (For Figure 5) ---
    rep_p_m1 = zeros(num_model_reps, 1);
    rep_p_m2 = zeros(num_model_reps, 1);
    rep_p_ttest = zeros(num_model_reps, 1);
    
    for rep = 1:num_model_reps
        % Create temporary predictions based on this skill level
        temp_Y_pred = Y_pred_base(randperm(N)); 
        match_idx = randperm(N, num_matches);
        temp_Y_pred(match_idx) = Y_true(match_idx);
        
        % Calculate true performance of temp_Y_pred on unshuffled Y_true
        true_sweep_fold_accs = zeros(K_folds, 1);
        for k = 1:K_folds
            idx = (fold_ids == k);
            true_sweep_fold_accs(k) = calc_balanced_accuracy(Y_true(idx), temp_Y_pred(idx), classes);
        end
        true_sweep_mean = mean(true_sweep_fold_accs);
        
        % Calculate p-values for this repetition
        rep_p_m1(rep) = sum(null_dist_sweep >= true_sweep_mean) / num_permutations;
        rep_p_m2(rep) = sum(null_dist_method2 >= true_sweep_mean) / num_permutations;
        
        % Manual right-tailed T-test (Null: chance = 1 / number of classes)
        chance_level = 1 / length(classes);
        df = K_folds - 1;
        if std(true_sweep_fold_accs) > 0
            t_stat = (true_sweep_mean - chance_level) / (std(true_sweep_fold_accs) / sqrt(K_folds));
            try
                p_ttest = 1 - tcdf(t_stat, df);
            catch
                % Fallback normal approximation if Statistics Toolbox is missing
                p_ttest = 0.5 * erfc(t_stat / sqrt(2)); 
            end
        else
            if true_sweep_mean > chance_level
                p_ttest = 1e-6;
            else
                p_ttest = 1.0;
            end
        end
        rep_p_ttest(rep) = p_ttest;
    end
    
    % Store the median p-values to cleanly smooth the log-scale plots
    % (Median prevents rare extreme outliers from destroying the log-scale mean)
    p_vals_m1_sweep(s_idx) = mean(rep_p_m1);
    p_vals_m2_sweep(s_idx) = mean(rep_p_m2);
    p_vals_ttest_sweep(s_idx) = mean(rep_p_ttest);
end

% 3. Plot the Line for Method 1 (Correct)
plot(skill_sweep, thresholds_sweep, '-o', 'Color', [0 0.447 0.741], ...
    'LineWidth', 2, 'MarkerSize', 5, 'MarkerFaceColor', [0 0.447 0.741], ...
    'DisplayName', 'Method 1 (Correct) Thresholds');

% 4. Plot the Flawed Method as a distinct point at Skill = 1.0
% Since at Skill = 1.0, Y_pred perfectly matches Y_true, Method 1 mathematically
% converges to Method 2. We plot it as a star at the end of the line!
plot(1.0, threshold_flawed, 'p', 'Color', [0.85 0.32 0.09], ...
    'MarkerSize', 16, 'MarkerFaceColor', [0.85 0.32 0.09], ...
    'DisplayName', 'Method 2 (Flawed) Baseline');

% Add a faint horizontal dashed line to show where the flawed baseline sits globally
yline(threshold_flawed, '--', 'Color', [0.85 0.32 0.09 0.5], 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Formatting
title_str = sprintf('Critical Balanced Accuracy to Achieve p \\leq %.2f\nPrediction Type: %s', target_p_value, strrep(pred_type, '_', ' '));
title(title_str, 'FontSize', 14);
xlabel('Model Predictive Skill (0.0 to 1.0)', 'FontSize', 12);
ylabel('Required Balanced Accuracy Score', 'FontSize', 12);
legend('Location', 'northwest', 'FontSize', 11);
grid on;

% Adjust y-axis to provide some padding
min_thresh = min([thresholds_sweep; threshold_flawed]);
max_thresh = max([thresholds_sweep; threshold_flawed]);
ylim([max(0, min_thresh - 0.05), max_thresh + 0.05]); 

hold off;

% =========================================================================
% PART 4: Critical Thresholds Across Multiple P-Values
% =========================================================================
fprintf('\nGenerating Figure 4: Sweeping Skill Levels for Multiple P-Values...\n');

figure('Position', [250, 250, 800, 500]);
hold on;

% Define the p-values to visualize
p_value_range = [0.01, 0.05, 0.10];
colors_p = [0.4940 0.1840 0.5560;  % Purple for p=0.01 (Stricter threshold)
            0 0.447 0.741;         % Blue for p=0.05 (Standard threshold)
            0.4660 0.6740 0.1880]; % Green for p=0.10 (Lenient threshold)

plot_handles_p = [];
min_thresh_p = 1.0;
max_thresh_p = 0.0;

for p_idx = 1:length(p_value_range)
    current_p_val = p_value_range(p_idx);
    t_idx = max(1, round(current_p_val * num_permutations));
    
    % Get the thresholds for this specific p-value using the saved permutations
    thresh_sweep_p = all_sweeps_sorted(t_idx, :);
    thresh_flawed_p = sorted_flawed(t_idx);
    
    % Track min/max for y-axis formatting later
    min_thresh_p = min([min_thresh_p, min(thresh_sweep_p), thresh_flawed_p]);
    max_thresh_p = max([max_thresh_p, max(thresh_sweep_p), thresh_flawed_p]);
    
    % Plot the Line for Method 1 (Correct)
    h_m1 = plot(skill_sweep, thresh_sweep_p, '-o', 'Color', colors_p(p_idx, :), ...
        'LineWidth', 2, 'MarkerSize', 4, 'MarkerFaceColor', colors_p(p_idx, :), ...
        'DisplayName', sprintf('Method 1 (p \\leq %.2f)', current_p_val));
    
    % Plot the Flawed Method as a distinct star at Skill = 1.0
    h_m2 = plot(1.0, thresh_flawed_p, 'p', 'Color', colors_p(p_idx, :), ...
        'MarkerSize', 12, 'MarkerFaceColor', colors_p(p_idx, :), ...
        'DisplayName', sprintf('Method 2 baseline (p \\leq %.2f)', current_p_val));
        
    % Add a faint horizontal dashed line for the flawed baseline
    yline(thresh_flawed_p, '--', 'Color', [colors_p(p_idx, :), 0.3], 'LineWidth', 1.5, 'HandleVisibility', 'off');
    
    plot_handles_p = [plot_handles_p, h_m1, h_m2];
end

% Formatting
title_str = sprintf('Required Balanced Accuracy Across P-Values\nPrediction Type: %s', strrep(pred_type, '_', ' '));
title(title_str, 'FontSize', 14);
xlabel('Model Predictive Skill (0.0 to 1.0)', 'FontSize', 12);
ylabel('Required Balanced Accuracy Score', 'FontSize', 12);
legend(plot_handles_p, 'Location', 'northwest', 'FontSize', 10, 'NumColumns', 2);
grid on;

% Adjust y-axis to provide some padding
ylim([max(0, min_thresh_p - 0.05), max_thresh_p + 0.05]); 

hold off;

% =========================================================================
% PART 5: P-Value Comparison (Permutation vs T-Test on Folds)
% =========================================================================
fprintf('\nGenerating Figure 5: P-Value Comparison (Permutation vs T-Test)...\n');

figure('Position', [300, 300, 800, 500]);
hold on;

% To allow plotting on a log scale cleanly, we floor the p-values at 1/num_permutations
min_p_val = 1 / num_permutations;
plot_p_m1 = max(p_vals_m1_sweep, min_p_val);
plot_p_m2 = max(p_vals_m2_sweep, min_p_val);
plot_p_ttest = max(p_vals_ttest_sweep, min_p_val);

plot(skill_sweep, plot_p_m1, '-o', 'Color', [0 0.447 0.741], 'LineWidth', 2, ...
    'DisplayName', 'Method 1 (Correct Permutation)');
plot(skill_sweep, plot_p_m2, '-s', 'Color', [0.85 0.32 0.09], 'LineWidth', 2, ...
    'DisplayName', 'Method 2 (Flawed Permutation)');
plot(skill_sweep, plot_p_ttest, '-^', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 2, ...
    'DisplayName', sprintf('1-Sample T-Test (K=%d Folds)', K_folds));

yline(target_p_value, 'k--', 'LineWidth', 1.5, ...
    'Label', sprintf('p = %.2f (Significance Threshold)', target_p_value), ...
    'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');

set(gca, 'YScale', 'log');
ylim([min_p_val * 0.5, 1.5]);
yticks([1e-4, 1e-3, 1e-2, 0.05, 1e-1, 1]);
yticklabels({'0.0001', '0.001', '0.01', '0.05', '0.1', '1.0'});

title_str = sprintf('Obtained P-Value by Test Method\nPrediction Type: %s', strrep(pred_type, '_', ' '));
title(title_str, 'FontSize', 14);
xlabel('Model Predictive Skill (0.0 to 1.0)', 'FontSize', 12);
ylabel('Obtained P-Value (Log Scale)', 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 11);
grid on;

hold off;

% =========================================================================
% PART 6: Confusion Matrix of the Simulated Model
% =========================================================================
fprintf('\nGenerating Figure 6: Confusion Matrix...\n');

figure('Position', [350, 350, 600, 500]);
cm = confusionchart(Y_true, Y_pred);

% Formatting the confusion chart
cm.Title = sprintf('Confusion Matrix\n(Prediction Type: %s, Skill: %.2f)', strrep(pred_type, '_', ' '), model_skill);
% RowSummary displays the True Positive Rate (Recall) for each class
% The average of these percentages is exactly your Balanced Accuracy!
cm.RowSummary = 'row-normalized'; 
cm.ColumnSummary = 'column-normalized'; % Displays Precision

% =========================================================================
% HELPER FUNCTION: Calculate Balanced Accuracy
% =========================================================================
function bal_acc = calc_balanced_accuracy(y_t, y_p, classes)
    % Balanced accuracy is the arithmetic mean of sensitivity (recall) 
    % for each class.
    accs = zeros(length(classes), 1);
    for c_idx = 1:length(classes)
        c = classes(c_idx);
        idx = (y_t == c); % Find all true instances of class 'c'
        
        if sum(idx) > 0
            % How many of the true instances did we correctly predict?
            accs(c_idx) = sum(y_p(idx) == c) / sum(idx);
        else
            accs(c_idx) = 0; % Edge case if a class is entirely missing
        end
    end
    bal_acc = mean(accs);
end