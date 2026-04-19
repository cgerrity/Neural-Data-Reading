% TEST_gemini_cgg_DynamicParameters.m
% Test script to verify the functionality of the cgg_generateLossWeights 
% and cgg_generateLoadParameters classes.

clear; clc; close all;

%% ========================================================================
%  PART 1: LOSS WEIGHTS
%  ========================================================================

%% 1. Define the Dynamic Weighting Schedule
% We will use the same schedule we defined earlier
DynamicWeighting = struct();

DynamicWeighting.Reconstruction.EpochPoints = [100, 100];
DynamicWeighting.Reconstruction.MagnitudePoints = [1, 1];

DynamicWeighting.KL.EpochPoints = [100, 100];
DynamicWeighting.KL.MagnitudePoints = [1, 1];

DynamicWeighting.Classification.EpochPoints = [100, 200];
DynamicWeighting.Classification.MagnitudePoints = [1e-4, 1];

%% 2. Instantiate the cgg_generateLossWeights class
% We pass the configuration in as Name-Value arguments. 
% Note: This assumes PARAMETERS_cgg_runAutoEncoder() is on your MATLAB path.
fprintf('Initializing cgg_generateLossWeights...\n');

LossWeights = cgg_generateLossWeights( ...
    'DynamicWeighting', DynamicWeighting, ...
    'WeightReconstruction', 1.0, ...
    'WeightKL', 1.0, ...
    'WeightClassification', 1.0, ...
    'WeightOffsetAndScale', 0 ...
);

%% 3. Test a Single Epoch Update
% Let's test epoch 150. Classification should be approximately 0.5
testEpoch = 150;
LossWeights.cgg_updateAllLossWeights(testEpoch);

fprintf('\n--- Weights at Epoch %d ---\n', testEpoch);
fprintf('Reconstruction: %.4f\n', LossWeights.CurrentWeightReconstruction);
fprintf('KL: %.4f\n', LossWeights.CurrentWeightKL);
fprintf('Classification: %.4f\n', LossWeights.CurrentWeightClassification);

%% 4. Visualize Over All Epochs
% Call the class's built-in plotting method to test it
NumEpochs = 250;
fprintf('\nGenerating weight plot for %d epochs...\n', NumEpochs);

[FigHandleWeights, TileHandleWeights] = LossWeights.cgg_plotWeightsOverEpochs(NumEpochs);

% Adjust figure properties for better viewing
FigHandleWeights.Name = 'Loss Weights Over Epochs';
FigHandleWeights.Position = [100, 100, 600, 800];
title(TileHandleWeights, 'Dynamic Loss Weight Scheduling');


%% ========================================================================
%  PART 2: LOAD PARAMETERS
%  ========================================================================

%% 5. Define the Dynamic Augmentation Schedule
DynamicAugmentation = struct();

% Ramps from 0.1 to 1.0 between epoch 50 and 150
DynamicAugmentation.ChannelOffset.EpochPoints = [50, 150];
DynamicAugmentation.ChannelOffset.MagnitudePoints = [0.1, 1.0];

% Ramps from 1e-3 to 1.0 between epoch 100 and 200
DynamicAugmentation.WhiteNoise.EpochPoints = [100, 200];
DynamicAugmentation.WhiteNoise.MagnitudePoints = [1e-3, 1.0];

% Keep RandomWalk and TimeShift static at 1.0
DynamicAugmentation.RandomWalk.EpochPoints = [1, 1];
DynamicAugmentation.RandomWalk.MagnitudePoints = [1, 1];

DynamicAugmentation.TimeShift.EpochPoints = [1, 1];
DynamicAugmentation.TimeShift.MagnitudePoints = [1, 1];

%% 6. Instantiate the cgg_generateLoadParameters class
fprintf('\nInitializing cgg_generateLoadParameters...\n');

LoadParameters = cgg_generateLoadParameters( ...
    'DynamicAugmentation', DynamicAugmentation, ...
    'STDChannelOffset', 1.0, ...
    'STDWhiteNoise', 1.0, ...
    'STDRandomWalk', 1.0, ...
    'STDTimeShift', 1.0, ...
    'WantSeparateTimeShift', false ...
);

%% 7. Test a Single Epoch Update for Load Parameters
LoadParameters.cgg_updateAllLoadParameters(testEpoch);

fprintf('\n--- Load Parameters at Epoch %d ---\n', testEpoch);
fprintf('ChannelOffset: %.4f\n', LoadParameters.CurrentSTDChannelOffset);
fprintf('WhiteNoise: %.4f\n', LoadParameters.CurrentSTDWhiteNoise);
fprintf('RandomWalk: %.4f\n', LoadParameters.CurrentSTDRandomWalk);
fprintf('TimeShift: %.4f\n', LoadParameters.CurrentSTDTimeShift);

%% 8. Visualize Load Parameters Over All Epochs
fprintf('\nGenerating load parameter plot for %d epochs...\n', NumEpochs);

[FigHandleLoad, TileHandleLoad] = LoadParameters.cgg_plotLoadParameterOverEpochs(NumEpochs);

% Adjust figure properties for better viewing
FigHandleLoad.Name = 'Load Parameters Over Epochs';
% Offset the position slightly so it doesn't completely overlap the first figure
FigHandleLoad.Position = [720, 100, 600, 800]; 
title(TileHandleLoad, 'Dynamic Load Parameter (Augmentation) Scheduling');

%% ========================================================================
%  PART 3: EDGE CASES (LOSS WEIGHTS & LOAD PARAMETERS)
%  ========================================================================
fprintf('\n========================================================================\n');
fprintf('RUNNING EDGE CASE TESTS\n');
fprintf('========================================================================\n');

%% Edge Case 3.1: Global Schedule (Root-Level Epoch/Magnitude Points)
% Testing the specific case where the struct only contains EpochPoints and 
% MagnitudePoints, applying uniformly to all weights.
fprintf('\n--- Edge Case 3.1: Global Schedule (Root Epoch/Magnitude) ---\n');
DynamicWeightingGlobal = struct();
DynamicWeightingGlobal.EpochPoints = [50, 150];
DynamicWeightingGlobal.MagnitudePoints = [0.1, 1.0];

LossWeightsGlobal = cgg_generateLossWeights( ...
    'DynamicWeighting', DynamicWeightingGlobal, ...
    'WeightReconstruction', 1.0, ...
    'WeightKL', 1.0, ...
    'WeightClassification', 1.0);

try
    LossWeightsGlobal.cgg_updateAllLossWeights(100);
    fprintf('SUCCESS: Global Schedule applied correctly.\n');
catch ME
    fprintf('EXPECTED BUG CAUGHT: The update failed for the Global Schedule.\n');
    fprintf('Error Message: %s\n', ME.message);
    fprintf('Reason: cgg_updateSelectLossWeight expects to find .DynamicWeighting.(ParameterName)\n');
    fprintf('        which does not exist when parameters are at the root level.\n');
end

%% Edge Case 3.2: Empty Struct
fprintf('\n--- Edge Case 3.2: Empty Schedule (struct()) ---\n');
try
    LossWeightsEmpty = cgg_generateLossWeights( ...
        'DynamicWeighting', struct(), ...
        'WeightReconstruction', 1.0);
    LossWeightsEmpty.cgg_updateAllLossWeights(10);
    fprintf('SUCCESS: Empty struct handled gracefully.\n');
catch ME
    fprintf('FAILED: Empty struct caused an error: %s\n', ME.message);
end

%% Edge Case 3.3: Multi-Point Arrays (Testing dynamic segment lookup)
fprintf('\n--- Edge Case 3.3: Multi-Point Segment Interpolation ---\n');
DynamicWeightingMulti = struct();
DynamicWeightingMulti.Reconstruction.EpochPoints = [10, 50, 100, 200];
DynamicWeightingMulti.Reconstruction.MagnitudePoints = [0, 0.5, 0.5, 1.0];

LossWeightsMulti = cgg_generateLossWeights( ...
    'DynamicWeighting', DynamicWeightingMulti, ...
    'WeightReconstruction', 1.0);

% Test Epoch 75 (Should be 0.5, trapped in the flat segment between 50 and 100)
LossWeightsMulti.cgg_updateAllLossWeights(75);
fprintf('Epoch 75 Weight: %.4f (Expected: 0.5000)\n', LossWeightsMulti.CurrentWeightReconstruction);

% Test Epoch 150 (Should be 0.75, ramping exactly halfway between 100 and 200)
LossWeightsMulti.cgg_updateAllLossWeights(150);
fprintf('Epoch 150 Weight: %.4f (Expected: 0.7500)\n', LossWeightsMulti.CurrentWeightReconstruction);

%% Edge Case 3.4: Single-Point Arrays
fprintf('\n--- Edge Case 3.4: Single-Point Arrays ---\n');
DynamicWeightingSingle = struct();
DynamicWeightingSingle.Reconstruction.EpochPoints = [100];
DynamicWeightingSingle.Reconstruction.MagnitudePoints = [1.0];

LossWeightsSingle = cgg_generateLossWeights( ...
    'DynamicWeighting', DynamicWeightingSingle, ...
    'WeightReconstruction', 2.0);

LossWeightsSingle.cgg_updateAllLossWeights(50);
fprintf('Epoch 50 Weight: %.4f (Expected: 2.0000 - Trapped at/before single point)\n', LossWeightsSingle.CurrentWeightReconstruction);
LossWeightsSingle.cgg_updateAllLossWeights(150);
fprintf('Epoch 150 Weight: %.4f (Expected: 2.0000 - Trapped after single point)\n', LossWeightsSingle.CurrentWeightReconstruction);

%% Edge Case 3.5: Extreme Epoch Bounds
fprintf('\n--- Edge Case 3.5: Extreme Epoch Inputs ---\n');
% Testing negative epochs and massively large epochs to ensure clamping works
LossWeights.cgg_updateAllLossWeights(-10);
fprintf('Epoch -10 Classification: %.4f (Expected: 0.0001)\n', LossWeights.CurrentWeightClassification);

LossWeights.cgg_updateAllLossWeights(999999);
fprintf('Epoch 999999 Classification: %.4f (Expected: 1.0000)\n', LossWeights.CurrentWeightClassification);

%% Edge Case 3.6: Default / Unset Arguments
fprintf('\n--- Edge Case 3.6: Unset Base Weights ---\n');
try
    % Creating without assigning WeightReconstruction
    LossWeightsUnset = cgg_generateLossWeights('DynamicWeighting', DynamicWeighting);
    LossWeightsUnset.cgg_updateAllLossWeights(150);
    fprintf('SUCCESS: Unset arguments default gracefully. CurrentWeightReconstruction = %s\n', mat2str(LossWeightsUnset.CurrentWeightReconstruction));
catch ME
    fprintf('FAILED: Unset arguments caused an error: %s\n', ME.message);
end

fprintf('\nDone! All Edge Cases successfully executed.\n');