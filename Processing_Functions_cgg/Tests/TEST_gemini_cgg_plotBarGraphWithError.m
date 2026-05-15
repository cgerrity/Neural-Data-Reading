% TEST_gemini_cgg_plotBarGraphWithError
%
% This script tests the functionality of cgg_plotBarGraphWithError.m
% It runs through various configurations (Standard, Legacy Scatter, NeurIPS 
% Scatter, Horizontal, Grouped, No Error Bars) and provides visual explanations.

clc; close all; clear;

%% Generate Mock Data
disp('Generating mock data for testing...');
rng(42); % Set random seed for reproducible jitter/data

% Data for non-grouped tests
val1 = randn(40, 1) * 1.5 + 10; % Mean ~10
val2 = randn(45, 1) * 2.0 + 15; % Mean ~15
val3 = randn(35, 1) * 1.0 + 8;  % Mean ~8
Values_Raw = {val1, val2, val3};
ValueNames_Raw = {'Control', 'Treatment A', 'Treatment B'};

% Data for grouped tests (Function expects means when IsGrouped = true)
% 3 Groups, 2 Bars per group
Values_Grouped = {[10, 12], [15, 11], [8, 14]}; 
Error_Grouped = {[1.5, 1.0], [2.0, 1.2], [1.0, 1.8]}; % Custom Error Metrics
ValueNames_Grouped = {'Condition 1', 'Condition 2', 'Condition 3'};
GroupNames_Grouped = {'Metric Alpha', 'Metric Beta'};

%% Test 1: Standard Bar Graph
disp('Running Test 1: Standard Bar Graph...');
fig1 = figure('Name', 'Test 1: Standard Bar Graph', 'Position', [100, 100, 600, 500]);
[bP1, bE1, InFig1] = cgg_plotBarGraphWithError(Values_Raw, ValueNames_Raw, ...
    'InFigure', fig1, ...
    'PlotTitle', 'Test 1: Standard Bar Graph', ...
    'Y_Name', 'Response Metric', ...
    'wantSTD', true);

subtitle({'EXPECTED:', ...
    '- Three solid bars', ...
    '- Error bars displaying Standard Deviation (wantSTD=true)', ...
    '- Standard MATLAB axes and grid behavior'}, 'FontAngle', 'italic');

%% Test 2: Legacy Scatter Style (WantScatter = true)
disp('Running Test 2: Legacy Scatter Style...');
fig2 = figure('Name', 'Test 2: Legacy Scatter Style', 'Position', [150, 150, 600, 500]);
[bP2, bE2, InFig2] = cgg_plotBarGraphWithError(Values_Raw, ValueNames_Raw, ...
    'InFigure', fig2, ...
    'PlotTitle', 'Test 2: Legacy Scatter (WantScatter=true)', ...
    'Y_Name', 'Response Metric', ...
    'WantScatter', true);

subtitle({'EXPECTED:', ...
    '- NO bars (transparent faces/edges)', ...
    '- A single marker point at each mean', ...
    '- Standard Error (STE) bars extending from the marker point'}, 'FontAngle', 'italic');

%% Test 3: NeurIPS Publication Scatter (WantNeurIPSScatter = true)
disp('Running Test 3: NeurIPS Scatter Style...');
fig3 = figure('Name', 'Test 3: NeurIPS Scatter Style', 'Position', [200, 200, 600, 500]);
[bP3, bE3, InFig3] = cgg_plotBarGraphWithError(Values_Raw, ValueNames_Raw, ...
    'InFigure', fig3, ...
    'PlotTitle', 'Test 3: NeurIPS Scatter (WantNeurIPSScatter=true)', ...
    'Y_Name', 'Response Metric', ...
    'WantNeurIPSScatter', true, ...
    'ColorOrder', [0.2 0.6 0.8; 0.8 0.3 0.2; 0.4 0.7 0.4]); % Custom colors

subtitle({'EXPECTED:', ...
    '- NO bars (transparent)', ...
    '- Raw data points jittered and semi-transparent (ScatterAlpha=0.6)', ...
    '- Thick solid line indicating the mean (MeanLineWidth=2)', ...
    '- Error bars without markers', ...
    '- Clean axes: no box, outward ticks, light gray horizontal grid lines'}, 'FontAngle', 'italic');

%% Test 4: NeurIPS Scatter - Horizontal
disp('Running Test 4: Horizontal NeurIPS Scatter...');
fig4 = figure('Name', 'Test 4: Horizontal NeurIPS Scatter', 'Position', [250, 250, 600, 500]);
[bP4, bE4, InFig4] = cgg_plotBarGraphWithError(Values_Raw, ValueNames_Raw, ...
    'InFigure', fig4, ...
    'PlotTitle', 'Test 4: Horizontal NeurIPS Scatter', ...
    'X_Name', 'Response Metric', ...
    'Y_Name', 'Categories', ...
    'WantNeurIPSScatter', true, ...
    'WantHorizontal', true);

subtitle({'EXPECTED:', ...
    '- Same beautiful style as Test 3, but rotated horizontally', ...
    '- Y-axis categorical, X-axis numerical', ...
    '- Vertical grid lines instead of horizontal'}, 'FontAngle', 'italic');

%% Test 5: Grouped Bar Graph
disp('Running Test 5: Grouped Bar Graph...');
fig5 = figure('Name', 'Test 5: Grouped Bar Graph', 'Position', [300, 300, 600, 500]);
[bP5, bE5, InFig5] = cgg_plotBarGraphWithError(Values_Grouped, ValueNames_Grouped, ...
    'InFigure', fig5, ...
    'PlotTitle', 'Test 5: Grouped Bar Graph', ...
    'IsGrouped', true, ...
    'GroupNames', GroupNames_Grouped, ...
    'ErrorMetric', Error_Grouped, ...
    'WantLegend', true, ...
    'ColorOrder', [0.3 0.3 0.3; 0.7 0.7 0.7]);

subtitle({'EXPECTED:', ...
    '- 3 Categorical Groups on X-axis', ...
    '- 2 Bars per group (Dark gray and Light gray)', ...
    '- Custom error bars applied properly to each sub-bar', ...
    '- Legend displayed in the best location showing "Metric Alpha" and "Metric Beta"'}, 'FontAngle', 'italic');

%% Test 6: Confidence Intervals & YRange limitation
disp('Running Test 6: Confidence Intervals and YRange...');
fig6 = figure('Name', 'Test 6: Confidence Intervals & Limits', 'Position', [350, 350, 600, 500]);
[bP6, bE6, InFig6] = cgg_plotBarGraphWithError(Values_Raw, ValueNames_Raw, ...
    'InFigure', fig6, ...
    'PlotTitle', 'Test 6: Confidence Intervals & YRange', ...
    'wantCI', true, ...
    'SignificanceValue', 0.01, ... % 99% CI
    'YRange', [0, 25]);

subtitle({'EXPECTED:', ...
    '- Error bars represent 99% Confidence Interval (larger than standard STE)', ...
    '- Y-axis is strictly bound from 0 to 25'}, 'FontAngle', 'italic');

%% Test 7: NeurIPS Scatter with NO Error Bars (New Feature)
disp('Running Test 7: NeurIPS Scatter without Error Bars...');
fig7 = figure('Name', 'Test 7: NeurIPS Scatter (No Error Bars)', 'Position', [400, 400, 600, 500]);
[bP7, bE7, InFig7] = cgg_plotBarGraphWithError(Values_Raw, ValueNames_Raw, ...
    'InFigure', fig7, ...
    'PlotTitle', 'Test 7: NeurIPS Scatter (WantErrorBars=false)', ...
    'Y_Name', 'Response Metric', ...
    'WantNeurIPSScatter', true, ...
    'WantErrorBars', false, ...
    'ColorOrder', [0.5 0.2 0.6; 0.2 0.7 0.3; 0.9 0.5 0.1]);

subtitle({'EXPECTED:', ...
    '- Scatter points and thick mean lines are drawn', ...
    '- NO distracting error bars visible anywhere', ...
    '- Clean NeurIPS axes formatting is retained'}, 'FontAngle', 'italic');

disp('All tests executed successfully. Please review the generated figures.');

%%

calculate_task_balanced_acc(CM_Table)

function [avgBalancedAcc, scaledAcc] = calculate_task_balanced_acc(CM_Table)
    % Extract the multi-column variables
    % Assuming these are 107x4 arrays within the table
    trueMatrix = CM_Table.TrueValue;
    predMatrix = CM_Table.Aggregation_Prediction;
    
    numTasks = size(trueMatrix, 2); % Should be 4
    taskBalancedAcc = zeros(numTasks, 1);
    taskChanceLevels = zeros(numTasks, 1);
    
    for t = 1:numTasks
        ytarget = trueMatrix(:, t);
        ypred = predMatrix(:, t);
        
        % Get unique classes present in the ground truth for this task
        % This determines the chance level for Task T
        taskClasses = unique(ytarget);
        nClasses = numel(taskClasses);
        
        taskChanceLevels(t) = 1 / nClasses;
        
        % Calculate Balanced Accuracy for this specific task
        taskBalancedAcc(t) = compute_bal_acc(ytarget, ypred, taskClasses);
    end
    
    % 1. Average of task-wise balanced accuracies
    avgBalancedAcc = mean(taskBalancedAcc);
    
    % 2. Calculate the average chance level
    avgChance = mean(taskChanceLevels);
    
    % 3. Scale: 0 is chance, 1 is perfect
    scaledAcc = (avgBalancedAcc - avgChance) / (1 - avgChance);
    
    % Display output
    fprintf('--- Multi-Task Results ---\n');
    for t = 1:numTasks
        fprintf('Task %d: B-Acc = %.4f (Chance = %.4f)\n', t, taskBalancedAcc(t), taskChanceLevels(t));
    end
    fprintf('--------------------------\n');
    fprintf('Total Balanced Accuracy: %.4f\n', avgBalancedAcc);
    fprintf('Scaled Accuracy:         %.4f\n', scaledAcc);
end

function bacc = compute_bal_acc(ytarget, ypred, classes)
    numClasses = numel(classes);
    recall = zeros(numClasses, 1);
    
    for j = 1:numClasses
        c = classes(j);
        % Recall = TP / (TP + FN)
        tp = sum((ytarget == c) & (ypred == c));
        fn = sum((ytarget == c) & (ypred ~= c));
        
        if (tp + fn) == 0
            recall(j) = 0; 
        else
            recall(j) = tp / (tp + fn);
        end
    end
    bacc = mean(recall);
end