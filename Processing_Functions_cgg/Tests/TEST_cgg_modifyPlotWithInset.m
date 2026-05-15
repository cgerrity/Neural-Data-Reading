% test_cgg_modifyPlotWithInset.m
% Test script to verify the functionality of cgg_modifyPlotWithInset.m

% Clean up workspace and close existing figures
close all;
clear;
clc;

disp('Running tests for cgg_modifyPlotWithInset...');

%% Test 1: Basic Line Plot with a Histogram Inset (Top-Right)
figure('Name', 'Test 1: Line Plot + Histogram', 'Position', [100, 100, 600, 400]);
ax1 = axes();
x1 = linspace(0, 4*pi, 100);
y1 = sin(x1) + randn(1, 100)*0.1; % Sine wave with noise
plot(ax1, x1, y1, 'b-', 'LineWidth', 1.5);
title(ax1, 'Main: Noisy Sine Wave');
xlabel(ax1, 'Time');
ylabel(ax1, 'Amplitude');

% Create Inset
histData = randn(500, 1);
insetPos1 = [0.65, 0.65, 0.25, 0.25]; % Top-Right
axInset1 = cgg_modifyPlotWithInset(ax1, @histogram, {histData, 15}, insetPos1);
title(axInset1, 'Noise Dist');

%% Test 2: 3D Surface Plot with a Scatter Inset (Top-Left)
figure('Name', 'Test 2: Surface + Scatter', 'Position', [150, 150, 600, 400]);
ax2 = axes();
surf(ax2, peaks);
title(ax2, 'Main: 3D Peaks Surface');

% Create Inset
% Demonstrating passing multiple arguments (X, Y, Size, Color, 'filled')
scatX = rand(50, 1);
scatY = rand(50, 1);
scatSize = rand(50, 1) * 100;
scatColor = rand(50, 1);
insetPos2 = [0.05, 0.65, 0.3, 0.25]; % Top-Left
axInset2 = cgg_modifyPlotWithInset(ax2, @scatter, {scatX, scatY, scatSize, scatColor, 'filled'}, insetPos2);
title(axInset2, 'Scatter Inset');
colormap(axInset2, 'hot'); % Apply colormap only to the inset

%% Test 3: Bar Chart with a Pie Chart Inset (Custom Position)
figure('Name', 'Test 3: Bar + Pie', 'Position', [200, 200, 600, 400]);
ax3 = axes();
categories = categorical({'A', 'B', 'C', 'D', 'E'});
barData = [15 22 18 35 12];
bar3 = bar(ax3, categories, barData, 'FaceColor', [0.2 0.6 0.5]);
title(ax3, 'Main: Bar Chart');
ylabel(ax3, 'Counts');

% Create Inset
pieData = [35, 25, 40];
insetPos3 = [0.15, 0.45, 0.35, 0.35]; % Middle-Left
axInset3 = cgg_modifyPlotWithInset(ax3, @pie, {pieData}, insetPos3);
title(axInset3, 'Proportions');
% Remove the background box for the pie chart for a cleaner look
axInset3.Color = 'none';
box(axInset3, 'off');

%% Test 4: Multiple Insets in a Single Plot
figure('Name', 'Test 4: Multiple Insets', 'Position', [250, 250, 600, 400]);
ax4 = axes();
plot(ax4, rand(20, 3), 'LineWidth', 2);
title(ax4, 'Main: Multiple Random Lines');
legend(ax4, 'Series 1', 'Series 2', 'Series 3', 'Location', 'southwest');

% Inset 1: Top-Left (Small Plot)
insetPos4a = [0.05, 0.70, 0.2, 0.2];
cgg_modifyPlotWithInset(ax4, @plot, {rand(10, 1), 'r-o', 'MarkerFaceColor', 'r'}, insetPos4a);

% Inset 2: Bottom-Right (Small Bar)
insetPos4b = [0.75, 0.15, 0.2, 0.2];
cgg_modifyPlotWithInset(ax4, @bar, {rand(1, 4)}, insetPos4b);

disp('All tests completed. Check the generated figures.');