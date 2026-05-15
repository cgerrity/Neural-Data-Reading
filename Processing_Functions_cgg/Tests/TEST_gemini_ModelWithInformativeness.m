% [Performance Analysis] : Integrated Multi-Level Confidence Analysis
close all
%% 0. Configuration
% 1 = Fixed Threshold Scan, 2 = Trial/Task-Wise Cumulative Scan, 3 = Both
calculationMode = 2; 

% CM_Table = [];
% for cidx = 1:10
%     this_File = sprintf('/Users/cgerrity/Downloads/CM_Tables/CM_Table_Fold_%02d.mat',cidx);
%     this_CM_Table = load(this_File);
%     this_CM_Table = this_CM_Table.CM_Table;
%     this_CM_Table.Fold = repmat(cidx,[height(this_CM_Table),1]);
%     CM_Table = [CM_Table;this_CM_Table];
% end

% [Performance Analysis] : Fold-Averaged Integrated Confidence Analysis
close all


if ~strcmp(CM_Table.Properties.VariableNames,'Fold')
    CM_Table.Fold = repmat(1,[height(CM_Table),1]);
end
%% 0. Configuration
% 1 = Fixed Threshold Scan, 2 = Trial/Task-Wise Cumulative Scan, 3 = Both
calculationMode = 2; 

if calculationMode == 3
    modesToRun = [1, 2];
else
    modesToRun = calculationMode;
end

% Ensure folds are properly identified
folds = unique(CM_Table.Fold);
numFolds = length(folds);

%% 1. Universal Data Preparation
PredsAll = CM_Table.Aggregation_Prediction;
TruthAll = CM_Table.TrueValue;
TrialConf = CM_Table.TrialConfidence;
TaskConf  = CM_Table.TaskConfidence;

% Ensure numeric matrices
if iscell(PredsAll), PredsAll = cell2mat(PredsAll); end
if iscell(TruthAll), TruthAll = cell2mat(TruthAll); end
if iscell(TaskConf), TaskConf = cell2mat(TaskConf); end

% Combine Trial and Task Confidence (Probabilistic Multiplication)
IntegratedConf = TrialConf .* TaskConf; 

numTasks = size(TruthAll, 2);
numRowsTotal = height(CM_Table);

% Calculate Chance Baseline and Unique Classes per task (Globally)
numUniquePerTask = zeros(1, numTasks);
chancePerTask = zeros(1, numTasks);
for t = 1:numTasks
    numUniquePerTask(t) = length(unique(TruthAll(:, t)));
    chancePerTask(t) = 1 / max(numUniquePerTask(t), 1);
end
globalChance = mean(chancePerTask);
colors = lines(numTasks);

%% 2. Execution Loop
for currentMode = modesToRun
    
    if currentMode == 1
        % =================================================================
        % MODE 1: FIXED THRESHOLD SCAN
        % =================================================================
        thresholds = 1:-0.01:0;
        numThresh = length(thresholds);
        
        % --- Preallocate Fold Matrices ---
        t_acc_folds = NaN(numFolds, numThresh);
        t_info_folds = NaN(numFolds, numThresh);
        t_part_folds = zeros(numFolds, numThresh);
        
        tsk_acc_folds = NaN(numFolds, numThresh, numTasks);
        tsk_part_folds = zeros(numFolds, numThresh, numTasks);
        
        int_acc_folds = NaN(numFolds, numThresh, numTasks);
        int_part_folds = zeros(numFolds, numThresh, numTasks);

        for f = 1:numFolds
            f_idx = (CM_Table.Fold == folds(f));
            f_TrialConf = TrialConf(f_idx);
            f_TaskConf = TaskConf(f_idx, :);
            f_IntConf = IntegratedConf(f_idx, :);
            f_Preds = PredsAll(f_idx, :);
            f_Truth = TruthAll(f_idx, :);
            numRows_f = sum(f_idx);
            
            for i = 1:numThresh
                curr_thresh = thresholds(i);
                
                % 1. Trial Processing
                idx_trial = f_TrialConf >= curr_thresh;
                t_part_folds(f, i) = (sum(idx_trial) / numRows_f) * 100;
                if sum(idx_trial) > 0
                    t_info_folds(f, i) = mean(f_TrialConf(idx_trial));
                    P = f_Preds(idx_trial, :); T = f_Truth(idx_trial, :);
                    temp_task_acc = zeros(1, numTasks);
                    for t = 1:numTasks
                        if numUniquePerTask(t) <= 1, temp_task_acc(t) = 0;
                        else, temp_task_acc(t) = (mean(P(:, t) == T(:, t)) - chancePerTask(t)) / (1 - chancePerTask(t)); end
                    end
                    t_acc_folds(f, i) = mean(temp_task_acc);
                end
                
                % 2. Task & 3. Integrated Processing
                for t = 1:numTasks
                    idx_task = f_TaskConf(:, t) >= curr_thresh;
                    tsk_part_folds(f, i, t) = (sum(idx_task) / numRows_f) * 100;
                    if sum(idx_task) > 0
                        if numUniquePerTask(t) <= 1, tsk_acc_folds(f, i, t) = 0;
                        else, tsk_acc_folds(f, i, t) = (mean(f_Preds(idx_task, t) == f_Truth(idx_task, t)) - chancePerTask(t)) / (1 - chancePerTask(t)); end
                    end
                    
                    idx_int = f_IntConf(:, t) >= curr_thresh;
                    int_part_folds(f, i, t) = (sum(idx_int) / numRows_f) * 100;
                    if sum(idx_int) > 0
                        if numUniquePerTask(t) <= 1, int_acc_folds(f, i, t) = 0;
                        else, int_acc_folds(f, i, t) = (mean(f_Preds(idx_int, t) == f_Truth(idx_int, t)) - chancePerTask(t)) / (1 - chancePerTask(t)); end
                    end
                end
            end
        end
        
        % Aggregate Across Folds
        trial_scaled_acc = squeeze(mean(t_acc_folds, 1, 'omitnan'))';
        trial_scaled_acc_std = squeeze(std(t_acc_folds, 0, 1, 'omitnan'))';
        trial_set_info = squeeze(mean(t_info_folds, 1, 'omitnan'))';
        trial_part_rate = squeeze(mean(t_part_folds, 1, 'omitnan'))';
        
        task_scaled_acc = squeeze(mean(tsk_acc_folds, 1, 'omitnan'));
        task_scaled_acc_std = squeeze(std(tsk_acc_folds, 0, 1, 'omitnan'));
        task_part_rate = squeeze(mean(tsk_part_folds, 1, 'omitnan'));
        
        int_scaled_acc = squeeze(mean(int_acc_folds, 1, 'omitnan'));
        int_scaled_acc_std = squeeze(std(int_acc_folds, 0, 1, 'omitnan'));
        int_part_rate = squeeze(mean(int_part_folds, 1, 'omitnan'));
        
        task_avg_scaled_acc = mean(task_scaled_acc, 2, 'omitnan');
        task_avg_scaled_acc_std = std(mean(tsk_acc_folds, 3, 'omitnan'), 0, 1, 'omitnan')';
        task_avg_part_rate = mean(task_part_rate, 2);
        
        int_avg_scaled_acc = mean(int_scaled_acc, 2, 'omitnan');
        int_avg_scaled_acc_std = std(mean(int_acc_folds, 3, 'omitnan'), 0, 1, 'omitnan')';
        int_avg_part_rate = mean(int_part_rate, 2);
        
        x_val_trial = thresholds';
        x_val_task = repmat(thresholds', 1, numTasks);
        x_val_int = repmat(thresholds', 1, numTasks);
        mode_str = 'Fixed Scan';
        
    else
        % =================================================================
        % MODE 2: SORTED / CUMULATIVE SCAN (Interpolated for Averaging)
        % =================================================================
        pct_grid = linspace(0.1, 100, 1000)'; % Common data volume axis
        
        t_acc_folds = NaN(numFolds, 1000);
        t_info_folds = NaN(numFolds, 1000);
        t_conf_folds = NaN(numFolds, 1000);
        
        tsk_acc_folds = NaN(numFolds, 1000, numTasks);
        tsk_conf_folds = NaN(numFolds, 1000, numTasks);
        
        int_acc_folds = NaN(numFolds, 1000, numTasks);
        int_conf_folds = NaN(numFolds, 1000, numTasks);
        
        for f = 1:numFolds
            f_idx = (CM_Table.Fold == folds(f));
            f_TrialConf = TrialConf(f_idx); f_TaskConf = TaskConf(f_idx, :); f_IntConf = IntegratedConf(f_idx, :);
            f_Preds = PredsAll(f_idx, :); f_Truth = TruthAll(f_idx, :);
            numRows_f = sum(f_idx);
            pr_f = ((1:numRows_f)' / numRows_f) * 100;
            
            % 1. Trial Processing
            [s_conf, s_idx] = sort(f_TrialConf, 'descend');
            s_Preds = f_Preds(s_idx, :); s_Truth = f_Truth(s_idx, :);
            acc_f = NaN(numRows_f, 1); info_f = NaN(numRows_f, 1);
            
            for i = 1:numRows_f
                info_f(i) = mean(s_conf(1:i));
                P = s_Preds(1:i, :); T = s_Truth(1:i, :);
                temp_task_acc = zeros(1, numTasks);
                for t = 1:numTasks
                    if numUniquePerTask(t) <= 1, temp_task_acc(t) = 0;
                    else, temp_task_acc(t) = (mean(P(:, t) == T(:, t)) - chancePerTask(t)) / (1 - chancePerTask(t)); end
                end
                acc_f(i) = mean(temp_task_acc);
            end
            t_acc_folds(f, :) = interp1(pr_f, acc_f, pct_grid, 'linear', 'extrap');
            t_info_folds(f, :) = interp1(pr_f, info_f, pct_grid, 'linear', 'extrap');
            t_conf_folds(f, :) = interp1(pr_f, s_conf, pct_grid, 'linear', 'extrap');
            
            % 2. Task & 3. Integrated Processing
            for t = 1:numTasks
                % Task Sorting
                [s_t_conf, s_idx_T] = sort(f_TaskConf(:, t), 'descend');
                t_preds = f_Preds(s_idx_T, t); t_truth = f_Truth(s_idx_T, t);
                acc_t_f = NaN(numRows_f, 1);
                
                % Integrated Sorting
                [s_i_conf, s_idx_I] = sort(f_IntConf(:, t), 'descend');
                i_preds = f_Preds(s_idx_I, t); i_truth = f_Truth(s_idx_I, t);
                acc_i_f = NaN(numRows_f, 1);
                
                for i = 1:numRows_f
                    if numUniquePerTask(t) <= 1
                        acc_t_f(i) = 0; acc_i_f(i) = 0;
                    else
                        acc_t_f(i) = (sum(t_preds(1:i) == t_truth(1:i))/i - chancePerTask(t)) / (1 - chancePerTask(t));
                        acc_i_f(i) = (sum(i_preds(1:i) == i_truth(1:i))/i - chancePerTask(t)) / (1 - chancePerTask(t));
                    end
                end
                tsk_acc_folds(f, :, t) = interp1(pr_f, acc_t_f, pct_grid, 'linear', 'extrap');
                tsk_conf_folds(f, :, t) = interp1(pr_f, s_t_conf, pct_grid, 'linear', 'extrap');
                
                int_acc_folds(f, :, t) = interp1(pr_f, acc_i_f, pct_grid, 'linear', 'extrap');
                int_conf_folds(f, :, t) = interp1(pr_f, s_i_conf, pct_grid, 'linear', 'extrap');
            end
        end
        
        % Aggregate Across Folds
        trial_scaled_acc = mean(t_acc_folds, 1, 'omitnan')';
        trial_scaled_acc_std = std(t_acc_folds, 0, 1, 'omitnan')';
        trial_set_info = mean(t_info_folds, 1, 'omitnan')';
        x_val_trial = mean(t_conf_folds, 1, 'omitnan')';
        trial_part_rate = pct_grid;
        
        task_scaled_acc = squeeze(mean(tsk_acc_folds, 1, 'omitnan'));
        task_scaled_acc_std = squeeze(std(tsk_acc_folds, 0, 1, 'omitnan'));
        x_val_task = squeeze(mean(tsk_conf_folds, 1, 'omitnan'));
        task_part_rate = repmat(pct_grid, 1, numTasks);
        
        int_scaled_acc = squeeze(mean(int_acc_folds, 1, 'omitnan'));
        int_scaled_acc_std = squeeze(std(int_acc_folds, 0, 1, 'omitnan'));
        x_val_int = squeeze(mean(int_conf_folds, 1, 'omitnan'));
        int_part_rate = repmat(pct_grid, 1, numTasks);
        
        task_avg_scaled_acc = mean(task_scaled_acc, 2, 'omitnan');
        task_avg_scaled_acc_std = std(mean(tsk_acc_folds, 3, 'omitnan'), 0, 1, 'omitnan')';
        task_avg_part_rate = pct_grid;
        
        int_avg_scaled_acc = mean(int_scaled_acc, 2, 'omitnan');
        int_avg_scaled_acc_std = std(mean(int_acc_folds, 3, 'omitnan'), 0, 1, 'omitnan')';
        int_avg_part_rate = pct_grid;
        
        mode_str = 'Trial/Task-Wise Sorted Scan (Fold Avg)';
    end

    %% ====================================================================
    %% HISTOGRAM AGGREGATION
    %% ====================================================================
    binEdges = linspace(0, 1, 30);
    binCenters = binEdges(1:end-1) + diff(binEdges)/2;
    
    hc_trial_folds = zeros(numFolds, length(binCenters));
    hc_task_folds = zeros(numFolds, length(binCenters), numTasks);
    hc_int_folds = zeros(numFolds, length(binCenters), numTasks);
    
    for f = 1:numFolds
        f_idx = CM_Table.Fold == folds(f);
        hc_trial_folds(f, :) = histcounts(TrialConf(f_idx), binEdges);
        for t = 1:numTasks
            hc_task_folds(f, :, t) = histcounts(TaskConf(f_idx, t), binEdges);
            hc_int_folds(f, :, t) = histcounts(IntegratedConf(f_idx, t), binEdges);
        end
    end
    
    hc_trial_mean = mean(hc_trial_folds, 1); hc_trial_std = std(hc_trial_folds, 0, 1);
    hc_task_mean = squeeze(mean(hc_task_folds, 1)); hc_task_std = squeeze(std(hc_task_folds, 0, 1));
    hc_int_mean = squeeze(mean(hc_int_folds, 1)); hc_int_std = squeeze(std(hc_int_folds, 0, 1));

    %% ====================================================================
    %% PLOTTING
    %% ====================================================================
    
    % --- FIGURE A: TRIAL CONFIDENCE ---
    maxA_trial = max(trial_scaled_acc, [], 'omitnan');
    if isempty(maxA_trial) || isnan(maxA_trial), maxA_trial = 1; end
    yLimA_trial = max(1.1, maxA_trial * 1.15);
    yLimH_trial = max(hc_trial_mean + hc_trial_std) * 1.15;

    figA = figure('Color', 'w', 'Position', [50, 50, 600, 950], 'Name', ['Trial-Level Evaluation (' mode_str ')']);
    
    ax1_A = subplot(3, 1, 1); hold on; grid on;
    yyaxis left; 
    plot_shade(x_val_trial, trial_scaled_acc, trial_scaled_acc_std, 'b');
    plot(x_val_trial, trial_scaled_acc, 'b-', 'LineWidth', 2);
    ylabel('Scaled Accuracy'); ylim([0 yLimA_trial]);
    yyaxis right; plot(x_val_trial, trial_set_info, 'g-', 'LineWidth', 1.5);
    plot(x_val_trial, trial_part_rate(:,1) / 100, 'r--', 'LineWidth', 1.5);
    ylabel('Ref Scale (0-1)'); ylim([0 1.05]);
    set(gca, 'XDir', 'reverse', 'XLim', [0 1]);
    title('Overall Performance vs. Trial Confidence');
    legend({'Scaled Accuracy (±SD)', 'Set Informativeness', 'Data Coverage'}, 'Location', 'southwest');

    ax2_A = subplot(3, 1, 2); hold on; grid on;
    bar(binCenters, hc_trial_mean, 1, 'FaceColor', [0.466 0.674 0.188], 'EdgeColor', 'w');
    errorbar(binCenters, hc_trial_mean, hc_trial_std, 'k', 'LineStyle', 'none');
    set(gca, 'XDir', 'reverse', 'XLim', [0 1]);
    ylabel('Avg Trial Count per Fold'); ylim([0 yLimH_trial]);
    title('Distribution of Trial Informativeness');

    subplot(3, 1, 3); hold on; grid on;
    [sPart_trial, sIdx_trial] = sort(trial_part_rate(:,1));
    plot_shade(sPart_trial, trial_scaled_acc(sIdx_trial), trial_scaled_acc_std(sIdx_trial), 'k');
    plot(sPart_trial, trial_scaled_acc(sIdx_trial), 'k-', 'LineWidth', 2);
    xlabel('Percentage of Data Used (%)'); ylabel('Scaled Accuracy');
    xlim([0 100]); ylim([0 yLimA_trial]);
    title('Trade-off: Overall Accuracy vs. Data Volume');
    linkaxes([ax1_A, ax2_A], 'x');
    sgtitle(['A: Trial-Level Analysis | ' mode_str], 'FontSize', 12, 'FontWeight', 'bold');

    % --- FIGURE B: TASK CONFIDENCE ---
    maxA_task = max(task_avg_scaled_acc, [], 'omitnan');
    if isempty(maxA_task) || isnan(maxA_task), maxA_task = 1; end
    yLimA_task = max(1.1, maxA_task * 1.15);

    figB = figure('Color', 'w', 'Position', [660, 50, 600, 950], 'Name', ['Task-Level Evaluation (' mode_str ')']);
              
    ax1_B = subplot(3, 1, 1); hold on; grid on;
    yyaxis left;
    for t = 1:numTasks
        plot_shade(x_val_task(:, t), task_scaled_acc(:, t), task_scaled_acc_std(:, t), colors(t,:));
        plot(x_val_task(:, t), task_scaled_acc(:, t), '-', 'Color', [colors(t,:) 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off');
    end
    x_val_task_avg = mean(x_val_task, 2, 'omitnan');
    plot_shade(x_val_task_avg, task_avg_scaled_acc, task_avg_scaled_acc_std, 'k');
    p_avg = plot(x_val_task_avg, task_avg_scaled_acc, 'k-', 'LineWidth', 3, 'DisplayName', 'Avg Task Accuracy (±SD)');
    ylabel('Scaled Accuracy'); ylim([0 yLimA_task]);
    yyaxis right;
    p_cov = plot(x_val_task_avg, task_avg_part_rate / 100, 'r--', 'LineWidth', 2, 'DisplayName', 'Avg Data Coverage');
    ylabel('Data Remaining (0-1)'); ylim([0 1.05]);
    ax = gca; ax.YColor = [0.85 0.33 0.1];
    set(gca, 'XDir', 'reverse', 'XLim', [0 1]);
    title('Task-Level Performance vs. Task Confidence');
    legend([p_avg, p_cov], 'Location', 'southwest');

    ax2_B = subplot(3, 1, 2); hold on; grid on;
    maxCountTask = max(max(hc_task_mean + hc_task_std));
    for t = 1:numTasks
        plot_shade(binCenters', hc_task_mean(:, t), hc_task_std(:, t), colors(t,:));
        plot(binCenters, hc_task_mean(:, t), '-o', 'Color', colors(t,:), 'LineWidth', 1.5, 'MarkerSize', 3, 'MarkerFaceColor', colors(t,:), 'DisplayName', ['Task ' num2str(t)]);
    end
    set(gca, 'XDir', 'reverse', 'XLim', [0 1]);
    ylabel('Avg Frequency per Fold'); ylim([0 max(1, maxCountTask * 1.15)]);
    title('Density of Confidence Scores per Task');
    legend('Location', 'northwest');

    subplot(3, 1, 3); hold on; grid on;
    for t = 1:numTasks
        [sPart, sIdx] = sort(task_part_rate(:, t));
        plot_shade(sPart, task_scaled_acc(sIdx, t), task_scaled_acc_std(sIdx, t), colors(t,:));
        plot(sPart, task_scaled_acc(sIdx, t), '-', 'Color', [colors(t,:) 0.4], 'LineWidth', 1.5);
    end
    [sAvgPart, sAvgIdx] = sort(task_avg_part_rate);
    plot_shade(sAvgPart, task_avg_scaled_acc(sAvgIdx), task_avg_scaled_acc_std(sAvgIdx), 'k');
    plot(sAvgPart, task_avg_scaled_acc(sAvgIdx), 'k-', 'LineWidth', 3);
    xlabel('Percentage of Task Data Used (%)'); ylabel('Scaled Accuracy');
    xlim([0 100]); ylim([0 yLimA_task]);
    title('Trade-off: Accuracy vs. Data Volume');
    linkaxes([ax1_B, ax2_B], 'x');
    sgtitle(['B: Task-Level Analysis | ' mode_str], 'FontSize', 12, 'FontWeight', 'bold');

    % --- FIGURE C: INTEGRATED CONFIDENCE ---
    maxA_int = max(int_avg_scaled_acc, [], 'omitnan');
    if isempty(maxA_int) || isnan(maxA_int), maxA_int = 1; end
    yLimA_int = max(1.1, maxA_int * 1.15);

    figC = figure('Color', 'w', 'Position', [1270, 50, 600, 950], 'Name', ['Integrated Evaluation (' mode_str ')']);
              
    ax1_C = subplot(3, 1, 1); hold on; grid on;
    yyaxis left;
    for t = 1:numTasks
        plot_shade(x_val_int(:, t), int_scaled_acc(:, t), int_scaled_acc_std(:, t), colors(t,:));
        plot(x_val_int(:, t), int_scaled_acc(:, t), '-', 'Color', [colors(t,:) 0.4], 'LineWidth', 1.5, 'HandleVisibility', 'off');
    end
    x_val_int_avg = mean(x_val_int, 2, 'omitnan');
    plot_shade(x_val_int_avg, int_avg_scaled_acc, int_avg_scaled_acc_std, 'k');
    p_avg_int = plot(x_val_int_avg, int_avg_scaled_acc, 'k-', 'LineWidth', 3, 'DisplayName', 'Avg Integrated Accuracy');
    ylabel('Scaled Accuracy'); ylim([0 yLimA_int]);
    yyaxis right;
    p_cov_int = plot(x_val_int_avg, int_avg_part_rate / 100, 'r--', 'LineWidth', 2, 'DisplayName', 'Avg Data Coverage');
    ylabel('Data Remaining (0-1)'); ylim([0 1.05]);
    ax = gca; ax.YColor = [0.85 0.33 0.1];
    set(gca, 'XDir', 'reverse', 'XLim', [0 1]);
    title('Performance vs. Integrated Confidence (Trial \times Task)');
    legend([p_avg_int, p_cov_int], 'Location', 'southwest');

    ax2_C = subplot(3, 1, 2); hold on; grid on;
    maxCountInt = max(max(hc_int_mean + hc_int_std));
    for t = 1:numTasks
        plot_shade(binCenters', hc_int_mean(:, t), hc_int_std(:, t), colors(t,:));
        plot(binCenters, hc_int_mean(:, t), '-o', 'Color', colors(t,:), 'LineWidth', 1.5, 'MarkerSize', 3, 'MarkerFaceColor', colors(t,:), 'DisplayName', ['Task ' num2str(t)]);
    end
    set(gca, 'XDir', 'reverse', 'XLim', [0 1]);
    ylabel('Avg Frequency per Fold'); ylim([0 max(1, maxCountInt * 1.15)]);
    title('Density of Integrated Confidence Scores');
    legend('Location', 'northwest');

    subplot(3, 1, 3); hold on; grid on;
    for t = 1:numTasks
        [sPartInt, sIdxInt] = sort(int_part_rate(:, t));
        plot_shade(sPartInt, int_scaled_acc(sIdxInt, t), int_scaled_acc_std(sIdxInt, t), colors(t,:));
        plot(sPartInt, int_scaled_acc(sIdxInt, t), '-', 'Color', [colors(t,:) 0.4], 'LineWidth', 1.5);
    end
    [sAvgPartInt, sAvgIdxInt] = sort(int_avg_part_rate);
    plot_shade(sAvgPartInt, int_avg_scaled_acc(sAvgIdxInt), int_avg_scaled_acc_std(sAvgIdxInt), 'k');
    plot(sAvgPartInt, int_avg_scaled_acc(sAvgIdxInt), 'k-', 'LineWidth', 3);
    xlabel('Percentage of Task Data Used (%)'); ylabel('Scaled Accuracy');
    xlim([0 100]); ylim([0 yLimA_int]);
    title('Trade-off: Accuracy vs. Data Volume');
    linkaxes([ax1_C, ax2_C], 'x');
    sgtitle(['C: Integrated Analysis | ' mode_str], 'FontSize', 12, 'FontWeight', 'bold');

end

%% Helper Function for Standard Deviation Shading
function plot_shade(x, y, e, c)
    % plot_shade overlays a transparent polygon representing the standard deviation.
    valid = ~isnan(x) & ~isnan(y) & ~isnan(e);
    if sum(valid) < 2, return; end
    xv = x(valid); yv = y(valid); ev = e(valid);
    xv = xv(:); yv = yv(:); ev = ev(:); % Ensure column vectors
    fill([xv; flipud(xv)], [yv + ev; flipud(yv - ev)], c, ...
        'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end