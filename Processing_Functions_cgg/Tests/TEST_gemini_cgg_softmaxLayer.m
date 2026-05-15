%% Test Script for cgg_softmaxLayer

clc; clear; close all;
rng('shuffle');
%%
% This script verifies the custom cgg_softmaxLayer by checking if the 
% output probabilities correctly sum to 1 over the specified dimensions.
% It also includes a visual test to demonstrate the spatial softmax,
% and verifies that gradients can be computed via automatic differentiation.

disp('Starting tests for cgg_softmaxLayer...');
% Tolerance relaxed slightly to 1e-3 to account for floating-point 
% accumulation errors when summing over many dimensions simultaneously.
tol = 1e-3; 

%% Test 1: Standard Channel Softmax ('C')
disp('Test 1: Channel dimension only...');
layer1 = cgg_softmaxLayer('C', 'Channel_Softmax');
% Create random input: 10 Channels, Batch size of 4
X1 = dlarray(randn(10, 4), 'CB'); 

Z1 = predict(layer1, X1);

% Verification: The sum along the channel dimension (dim 1) should be 1
SummationDimension1 = finddim(Z1,'C');
sumZ1 = sum(Z1, SummationDimension1); 
maxErr1 = max(abs(extractdata(sumZ1) - 1), [], 'all');
assert(maxErr1 < tol, sprintf('Test 1 Failed: Max error was %f', maxErr1));
disp('  -> Passed!');

%% Test 2: Spatial Softmax ('S')
disp('Test 2: Spatial dimensions only...');
layer2 = cgg_softmaxLayer('S', 'Spatial_Softmax');
% Create random input: 5x5 Spatial, 3 Channels, Batch size of 2
X2 = dlarray(randn(5, 5, 3, 2), 'SSCB'); 

Z2 = predict(layer2, X2);

% Verification: The sum along both spatial dimensions (dims 1 and 2) should be 1
SummationDimension2 = finddim(Z2,'S');
sumZ2 = sum(Z2, SummationDimension2);
maxErr2 = max(abs(extractdata(sumZ2) - 1), [], 'all');
assert(maxErr2 < tol, sprintf('Test 2 Failed: Max error was %f', maxErr2));
disp('  -> Passed!');

%% Test 3: Spatial, Channel, and Time Softmax ('SCT')
disp('Test 3: Spatial, Channel, and Time dimensions simultaneously...');
layer3 = cgg_softmaxLayer('SCT', 'SCT_Softmax');
% Create random input: 4x4 Spatial, 3 Channels, 5 Timesteps, Batch size of 2
X3 = dlarray(randn(4, 4, 3, 5, 2), 'SSCTB'); 

Z3 = predict(layer3, X3);

% Verification: The sum along S (1,2), C (3), and T (4) should be 1
SummationDimension3 = [finddim(Z3,'S'),finddim(Z3,'C'),finddim(Z3,'T')];
sumZ3 = sum(Z3, SummationDimension3);
maxErr3 = max(abs(extractdata(sumZ3) - 1), [], 'all');
assert(maxErr3 < tol, sprintf('Test 3 Failed: SCT softmax sum max error was %f', maxErr3));
disp('  -> Passed!');

%% Test 4: Missing Dimensions handling
disp('Test 4: Handling missing dimensions (Layer expects SCT, Data is CBT)...');
layer4 = cgg_softmaxLayer('SCT', 'Missing_Spatial');
% Create random input: 3 Channels, 5 Timesteps, Batch size of 2 (No Spatial dims)
X4 = dlarray(randn(3, 5, 2), 'CTB'); 

Z4 = predict(layer4, X4);

% Verification: Since data is 'CTB', it should operate on C (dim 1) and T (dim 2)
SummationDimension4 = [finddim(Z4,'C'),finddim(Z4,'T')];
sumZ4 = sum(Z4, SummationDimension4);
maxErr4 = max(abs(extractdata(sumZ4) - 1), [], 'all');
assert(maxErr4 < tol, sprintf('Test 4 Failed: Max error was %f', maxErr4));
disp('  -> Passed!');

%% Test 5: Visualizing the Spatial Softmax Layer
disp('Test 5: Visualizing spatial softmax distribution...');

% Create a 2D grid
[X_grid, Y_grid] = meshgrid(1:20, 1:20);

% Create two "peaks" (e.g., simulated raw attention logits)
peak1 = exp(-((X_grid-5).^2 + (Y_grid-5).^2)/5);
peak2 = 0.8 * exp(-((X_grid-14).^2 + (Y_grid-14).^2)/10);
V = peak1 + peak2; 

% Multiply by a scalar so the softmax exponentiation is more visible
V = V * 10; 

% Reshape explicitly to 4D to perfectly match SSCB format (20, 20, 1, 1)
V_4D = reshape(V, [20, 20, 1, 1]);
X_vis = dlarray(V_4D, 'SSCB');

% Apply Spatial Softmax
layer_vis = cgg_softmaxLayer('S', 'Visual_Softmax');
Z_vis = predict(layer_vis, X_vis);

% Extract and squeeze data down to 2D matrices for plotting
V_plot = squeeze(extractdata(X_vis));
Z_plot = squeeze(extractdata(Z_vis));

% Create the visualization figure
figure('Name', 'Spatial Softmax Visualization', 'Position', [150, 150, 1000, 450]);

% Plot 1: Raw Logits
subplot(1, 2, 1);
surf(X_grid, Y_grid, V_plot, 'EdgeColor', 'none');
title('Raw Input Logits (X)');
xlabel('Spatial X'); ylabel('Spatial Y'); zlabel('Magnitude');
colormap parula; colorbar; view(-30, 45);

% Plot 2: Softmax Probabilities
subplot(1, 2, 2);
surf(X_grid, Y_grid, Z_plot, 'EdgeColor', 'none');
title('Softmax Output Probabilities (Z)');
xlabel('Spatial X'); ylabel('Spatial Y'); zlabel('Probability');
colormap parula; colorbar; view(-30, 45);

sgtitle('Effect of cgg\_softmaxLayer over Spatial Dimensions');
disp('  -> Figure generated!');

%% Test 6: Visualizing CT (Channel and Time) Softmax
disp('Test 6: Visualizing Channel and Time (CT) softmax distribution...');

% Create synthetic data: 4 Classes (C), 1 Batch (B), 25 Timesteps (T)
C_dim = 4; B_dim = 1; T_dim = 25;
V_CT = zeros(C_dim, B_dim, T_dim);

% Time vector reshaped to match the Time dimension (dim 3)
t = reshape(1:T_dim, 1, 1, T_dim);

% Add varying Gaussian "humps" to demonstrate duration vs magnitude
% Class 1: A tall but very narrow/short-lived peak.
V_CT(1, 1, :) = 5.0 * exp(-((t-6).^2) / 1.5);  
% Class 2: A shorter but much wider peak that lasts for more time points.
V_CT(2, 1, :) = 4.0 * exp(-((t-16).^2) / 20.0); 
% Class 3: A medium peak for comparison.
V_CT(3, 1, :) = 3.5 * exp(-((t-22).^2) / 4.0); 
% Class 4: A smaller background bump.
V_CT(4, 1, :) = 2.5 * exp(-((t-10).^2) / 5.0); 

% Generate random background noise, and smooth it over the time dimension.
% The noise magnitude is slightly reduced so the wider peak isn't hidden.
raw_noise = randn(C_dim, B_dim, T_dim) * 0.3;
smoothed_noise = smoothdata(raw_noise, 3, 'gaussian', 3);

V_CT = V_CT + smoothed_noise;

% Format as CBT
X_CT = dlarray(V_CT, 'CBT');

% Apply Softmax over Channel and Time
layer_CT = cgg_softmaxLayer('CT', 'CT_Softmax_Vis');
Z_CT = predict(layer_CT, X_CT);

% Verification: Sum over C (dim 1) and T (dim 3) should be 1
% Using vector indexing for the sum as implemented earlier
SummationDimension_CT = [finddim(Z_CT,'C'),finddim(Z_CT,'T')];
sumZ_CT = sum(Z_CT, SummationDimension_CT);
maxErrCT = max(abs(extractdata(sumZ_CT) - 1), [], 'all');
assert(maxErrCT < tol, sprintf('Test 6 Failed: CT softmax sum max error was %f', maxErrCT));

% Extract and squeeze for plotting (Yields a 2D C x T matrix)
X_CT_plot = squeeze(extractdata(X_CT));
Z_CT_plot = squeeze(extractdata(Z_CT));

% Calculate the total probability per class (summation over time)
class_probs = sum(Z_CT_plot, 2);

% Create visualization figure
figure('Name', 'Channel-Time Softmax Visualization', 'Position', [200, 200, 1400, 400]);

% Plot 1: Raw Logits (Line Plot)
subplot(1, 3, 1);
plot(X_CT_plot', 'LineWidth', 2);
title('Raw Input Logits (X)');
xlabel('Time (T)'); ylabel('Magnitude');
legend('Class 1', 'Class 2', 'Class 3', 'Class 4', 'Location', 'best');
grid on;

% Plot 2: Softmax Probabilities (Line Plot)
subplot(1, 3, 2);
plot(Z_CT_plot', 'LineWidth', 2);
title('Softmax Probabilities (Z)');
xlabel('Time (T)'); ylabel('Probability');
legend('Class 1', 'Class 2', 'Class 3', 'Class 4', 'Location', 'best');
grid on;

% Plot 3: Class Probabilities (Bar Chart)
subplot(1, 3, 3);
bar(class_probs, 'FaceColor', [0.2 0.6 0.8]);
title('Total Probability per Class');
xlabel('Class (C)'); ylabel('Probability (Sum over T)');
xticks(1:C_dim);
xticklabels({'Class 1', 'Class 2', 'Class 3', 'Class 4'});
grid on;

sgtitle('Effect of cgg\_softmaxLayer over Channel & Time Dimensions (Joint Probability = 1)');
disp('  -> Figure generated!');

%% Test 7: Integration with dlnetwork
disp('Test 7: Integration with dlnetwork and initialization...');

% Create a simple layer array using an imageInputLayer
layers = [
    imageInputLayer([5 5 3], 'Normalization', 'none', 'Name', 'input')
    cgg_softmaxLayer('S', 'Spatial_Softmax_Net')
];

% Create an uninitialized dlnetwork
net = dlnetwork(layers);

% Create formatted input data matching the imageInputLayer (5x5 spatial, 3 channels, batch of 2)
X_net = dlarray(randn(5, 5, 3, 2), 'SSCB');

% Initialize the dlnetwork using the sample input. This validates that the
% custom layer plays nicely with MATLAB's automated network initialization.
net = initialize(net, X_net);

% Perform the forward pass using the initialized network
Z_net = predict(net, X_net);

% Verification: The sum along both spatial dimensions ('S') should be 1
SummationDimension_net = finddim(Z_net, 'S');
sumZ_net = sum(Z_net, SummationDimension_net);
maxErr_net = max(abs(extractdata(sumZ_net) - 1), [], 'all');
assert(maxErr_net < tol, sprintf('Test 7 Failed: dlnetwork softmax sum max error was %f', maxErr_net));
disp('  -> Passed!');

%% Test 8: Gradient Calculation (Autodiff)
disp('Test 8: Gradient calculation via automatic differentiation...');
layer8 = cgg_softmaxLayer('CT', 'Gradient_Softmax');
% Create random input (needs to be a dlarray to be tracked by dlfeval)
X8 = dlarray(randn(4, 1, 5), 'CBT'); 

% Evaluate the mock loss function and compute gradients with dlfeval
[loss8, grad8] = dlfeval(@computeMockLoss, layer8, X8);
[loss8_noextract, grad8_noextract] = dlfeval(@computeMockLoss, layer8, X8);

% Verification: Check that the gradient exists, matches size, and isn't zero
assert(~isempty(grad8), 'Test 8 Failed: Gradient output is empty.');
assert(isequal(size(grad8), size(X8)), 'Test 8 Failed: Gradient size does not match input size.');
assert(any(extractdata(grad8) ~= 0, 'all'), 'Test 8 Failed: All gradients are zero (backprop failed).');
disp('  -> Passed!');

%% Completion
disp('----------------------------------------------------');
disp('All tests passed successfully! The layer is ready for use.');

%% Local Functions

function [loss, gradX] = computeMockLoss(layer, X)
    % Perform the forward pass
    Z = predict(layer, X);
    
    % Compute a dummy loss (sum of squared probabilities) to ensure gradients flow back
    loss = sum(Z.^2, 'all');
    
    % Compute the gradient of the loss with respect to the input X
    gradX = dlgradient(loss, X);
end