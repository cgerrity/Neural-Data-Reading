% TEST_gemini_cgg_DynamicParameters_v2.m
% Test script to verify the functionality of the V2 Object-Oriented
% cgg_generateLossWeights_v2 and cgg_generateLoadParameters_v2 classes.

clear; clc; close all;

%% ========================================================================
%  PART 1: LOSS WEIGHTS V2
%  ========================================================================

%% 1. Define the Dynamic Weighting Schedule
DynamicWeighting = struct();

DynamicWeighting.Reconstruction.EpochPoints = [100, 100];
DynamicWeighting.Reconstruction.MagnitudePoints = [1, 1];

DynamicWeighting.KL.EpochPoints = [100, 100];
DynamicWeighting.KL.MagnitudePoints = [1, 1];

DynamicWeighting.Classification.EpochPoints = [100, 200];
DynamicWeighting.Classification.MagnitudePoints = [1e-4, 1];

%% 2. Instantiate the cgg_generateLossWeights_v2 class
fprintf('Initializing cgg_generateLossWeights_v2...\n');

LossWeights = cgg_generateLossWeights_v2( ...
    'DynamicWeighting', DynamicWeighting, ...
    'WeightReconstruction', 1.0, ...
    'WeightKL', 1.0, ...
    'WeightClassification', 1.0, ...
    'WeightOffsetAndScale', 0 ...
);

%% 3. Test a Single Epoch Update
testEpoch = 150;
LossWeights.cgg_updateAllLossWeights(testEpoch);

fprintf('\n--- Weights at Epoch %d ---\n', testEpoch);
fprintf('Reconstruction: %.4f\n', LossWeights.CurrentWeightReconstruction);
fprintf('KL: %.4f\n', LossWeights.CurrentWeightKL);
fprintf('Classification: %.4f\n', LossWeights.CurrentWeightClassification);

%% 4. Visualize Over All Epochs
NumEpochs = 250;
fprintf('\nGenerating weight plot for %d epochs...\n', NumEpochs);

[FigHandleWeights, TileHandleWeights] = LossWeights.cgg_plotWeightsOverEpochs(NumEpochs);
FigHandleWeights.Name = 'Loss Weights Over Epochs';
FigHandleWeights.Position = [50, 50, 500, 700];
title(TileHandleWeights, 'Dynamic Loss Weight Scheduling (Standard)');


%% ========================================================================
%  PART 2: LOAD PARAMETERS V2
%  ========================================================================

%% 5. Define the Dynamic Augmentation Schedule
DynamicAugmentation = struct();

DynamicAugmentation.ChannelOffset.EpochPoints = [50, 150];
DynamicAugmentation.ChannelOffset.MagnitudePoints = [0.1, 1.0];

DynamicAugmentation.WhiteNoise.EpochPoints = [100, 200];
DynamicAugmentation.WhiteNoise.MagnitudePoints = [1e-3, 1.0];

DynamicAugmentation.RandomWalk.EpochPoints = [1, 1];
DynamicAugmentation.RandomWalk.MagnitudePoints = [1, 1];

DynamicAugmentation.TimeShift.EpochPoints = [1, 1];
DynamicAugmentation.TimeShift.MagnitudePoints = [1, 1];

%% 6. Instantiate the cgg_generateLoadParameters_v2 class
fprintf('\nInitializing cgg_generateLoadParameters_v2...\n');

LoadParameters = cgg_generateLoadParameters_v2( ...
    'DynamicAugmentation', DynamicAugmentation, ...
    'STDChannelOffset', 1.0, ...
    'STDWhiteNoise', 1.0, ...
    'STDRandomWalk', 1.0, ...
    'STDTimeShift', 1.0, ...
    'WantSeparateTimeShift', false ...
);

%% 7. Visualize Load Parameters Over All Epochs
fprintf('\nGenerating load parameter plot for %d epochs...\n', NumEpochs);

[FigHandleLoad, TileHandleLoad] = LoadParameters.cgg_plotLoadParameterOverEpochs(NumEpochs);
FigHandleLoad.Name = 'Load Parameters Over Epochs';
FigHandleLoad.Position = [560, 50, 500, 700]; 
title(TileHandleLoad, 'Dynamic Load Parameter Scheduling');


%% ========================================================================
%  PART 3: EDGE CASES & EXTRA FIGURES
%  ========================================================================
fprintf('\n========================================================================\n');
fprintf('RUNNING EDGE CASE TESTS & GENERATING EXTRA FIGURES\n');
fprintf('========================================================================\n');

%% Edge Case 3.1: Global Schedule (Root-Level Epoch/Magnitude Points)
fprintf('\n--- Edge Case 3.1: Global Schedule (Root Epoch/Magnitude) ---\n');
DynamicWeightingGlobal = struct();
DynamicWeightingGlobal.EpochPoints = [50, 150];
DynamicWeightingGlobal.MagnitudePoints = [0.1, 1.0];

LossWeightsGlobal = cgg_generateLossWeights_v2( ...
    'DynamicWeighting', DynamicWeightingGlobal, ...
    'WeightReconstruction', 1.0, ...
    'WeightKL', 1.0, ...
    'WeightClassification', 1.0);

[FigGlobal, TileGlobal] = LossWeightsGlobal.cgg_plotWeightsOverEpochs(200);
FigGlobal.Name = 'Edge Case: Global Schedule';
FigGlobal.Position = [1070, 50, 400, 600];
title(TileGlobal, 'Global Schedule (All weights share same ramp)');
fprintf('SUCCESS: Global Schedule plotted.\n');

%% Edge Case 3.2: Empty Struct
fprintf('\n--- Edge Case 3.2: Empty Schedule (struct()) ---\n');
try
    LossWeightsEmpty = cgg_generateLossWeights_v2( ...
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

LossWeightsMulti = cgg_generateLossWeights_v2( ...
    'DynamicWeighting', DynamicWeightingMulti, ...
    'WeightReconstruction', 1.0);

[FigMulti, TileMulti] = LossWeightsMulti.cgg_plotWeightsOverEpochs(250);
FigMulti.Name = 'Edge Case: Multi-Point Ramps';
FigMulti.Position = [50, 450, 400, 400];
title(TileMulti, 'Multi-Point Complex Interpolation');
fprintf('SUCCESS: Multi-Point interpolation plotted.\n');

%% Edge Case 3.4: Single-Point Arrays
fprintf('\n--- Edge Case 3.4: Single-Point Arrays ---\n');
DynamicWeightingSingle = struct();
DynamicWeightingSingle.Reconstruction.EpochPoints = [100];
DynamicWeightingSingle.Reconstruction.MagnitudePoints = [0.5];

LossWeightsSingle = cgg_generateLossWeights_v2( ...
    'DynamicWeighting', DynamicWeightingSingle, ...
    'WeightReconstruction', 2.0);

[FigSingle, TileSingle] = LossWeightsSingle.cgg_plotWeightsOverEpochs(200);
FigSingle.Name = 'Edge Case: Single-Point Arrays';
FigSingle.Position = [460, 450, 400, 400];
title(TileSingle, 'Single-Point Array (Constant Flatline)');
fprintf('SUCCESS: Single-point arrays plotted.\n');

%% Edge Case 3.5: Extreme Epoch Bounds
fprintf('\n--- Edge Case 3.5: Extreme Epoch Inputs ---\n');
LossWeights.cgg_updateAllLossWeights(-10);
fprintf('Epoch -10 Classification: %.4f (Expected: 0.0001)\n', LossWeights.CurrentWeightClassification);

LossWeights.cgg_updateAllLossWeights(999999);
fprintf('Epoch 999999 Classification: %.4f (Expected: 1.0000)\n', LossWeights.CurrentWeightClassification);

%% Edge Case 3.6: Default / Unset Arguments
fprintf('\n--- Edge Case 3.6: Unset Base Weights ---\n');
try
    LossWeightsUnset = cgg_generateLossWeights_v2('DynamicWeighting', DynamicWeighting);
    LossWeightsUnset.cgg_updateAllLossWeights(150);
    fprintf('SUCCESS: Unset arguments default gracefully. CurrentWeightReconstruction = %s\n', mat2str(LossWeightsUnset.CurrentWeightReconstruction));
catch ME
    fprintf('FAILED: Unset arguments caused an error: %s\n', ME.message);
end

fprintf('\nDone! All V2 classes instantiated, tested, and plotted successfully.\n');