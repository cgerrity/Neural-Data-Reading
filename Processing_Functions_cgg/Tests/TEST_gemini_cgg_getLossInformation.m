%% Setup Test Environment for cgg_getLossInformation
clear; clc;
rng(42); % For reproducibility

% --- Toggles ---
WantPlot = true; % Visualize the magnitude standardization pipeline

% Mock parameters matching the function signature
ClassNames = {{'Shape1', 'Shape2'}, {'Color1', 'Color2', 'Color3'}}; % 2 Valid Dimensions
NumDimensions = length(ClassNames);

% Base Mock Losses (Deliberately different magnitudes)
L_Rec = dlarray(2.0);
L_KL  = dlarray(0.05); % Tiny loss
L_Rec_Area = dlarray([1.0, 1.0]);
L_Class_Dim = dlarray([15.0, 25.0]); % Massive loss
L_OS  = dlarray(0.1);
L_TotalConf = dlarray([0.5, 0.7]); % FIX: Mock as a vector matching NumDimensions!

% Base Weights
W_Rec = 1.0; W_KL = 1.0; W_Class = 1.0; W_OS = 1.0; W_Conf = 1.0;

disp('--- Starting Unit Tests for cgg_getLossInformation ---');

%% Test 1: Initialization from Empty Struct
LossInfo_Empty = [];

% FIX: Pass L_TotalConf so the helper establishes a valid numeric Prior instead of NaN
LossInfo_Out1 = cgg_getLossInformation(L_Rec, L_KL, L_Rec_Area, L_Class_Dim, L_OS, ...
    LossInfo_Empty, true, W_Rec, W_KL, W_Class, W_OS, ClassNames, ...
    'Loss_TotalConfidence', L_TotalConf);

assert(isfield(LossInfo_Out1, 'Prior_Loss_Reconstruction'), 'Test 1 Failed: Struct not initialized.');
assert(LossInfo_Out1.Prior_Loss_Reconstruction == cgg_extractData(L_Rec), 'Test 1 Failed: Prior not updated.');
assert(isfield(LossInfo_Out1, 'Loss_KL_Normalized'), 'Test 1 Failed: Dynamic helper fields not generated.');
disp('Test 1 Passed: Empty struct initialized and dynamic helper fields generated.');

%% Test 2: Normalization & Rescaling Mathematics
% We use the output from Test 1 as our prior, and feed a new batch of losses
L_Rec_New = dlarray(4.0); % Double the previous loss (Prior was 2.0)

LossInfo_Out2 = cgg_getLossInformation(L_Rec_New, L_KL, L_Rec_Area, L_Class_Dim, L_OS, ...
    LossInfo_Out1, false, W_Rec, W_KL, W_Class, W_OS, ClassNames, ...
    'Loss_TotalConfidence', L_TotalConf);

% 1. Check Normalization (4.0 / 2.0 = 2.0)
Norm_Rec = cgg_extractData(LossInfo_Out2.Loss_Reconstruction_Normalized);
assert(abs(Norm_Rec - 2.0) < 1e-4, sprintf('Test 2 Failed: Expected Normalized Loss 2.0, got %.2f', Norm_Rec));

% 2. Check Rescaling (Normalized 2.0 * Prior Classification 40.0 = 80.0)
Prior_Class_Sum = sum(cgg_extractData(L_Class_Dim));
Rescaled_Rec = cgg_extractData(LossInfo_Out2.Loss_Reconstruction_Rescaled);
assert(abs(Rescaled_Rec - (Norm_Rec * Prior_Class_Sum)) < 1e-4, 'Test 2 Failed: Rescaling math incorrect.');
disp('Test 2 Passed: Historical priors successfully normalize and rescale incoming losses.');

%% Test 3: Missing Loss Handling (NaN Safety)
L_KL_Missing = NaN;
LossInfo_Out3 = cgg_getLossInformation(L_Rec, L_KL_Missing, L_Rec_Area, L_Class_Dim, L_OS, ...
    LossInfo_Out1, false, W_Rec, W_KL, W_Class, W_OS, ClassNames, ...
    'Loss_TotalConfidence', L_TotalConf);

Total_Encoder_Loss = cgg_extractData(LossInfo_Out3.Loss_Encoder);
assert(~isnan(Total_Encoder_Loss), 'Test 3 Failed: NaN in KL loss caused Total Encoder loss to crash to NaN.');
disp('Test 3 Passed: Missing/NaN loss branches gracefully ignored during total loss construction.');

%% Test 4: Beta Controller Bug Fix Verification
% Inject a strong dataset confidence history
LossInfo_Strong = LossInfo_Out1;
LossInfo_Strong.DatasetTotalConfidence = 0.95;
LossInfo_Strong.Confidence_Beta = 1.0;

% Pass extremely low batch confidence (0.1) to force Beta to spike > 1.0
Low_TrialConf = dlarray(sqrt(0.1) * ones(1, 10));
Low_TaskConf  = dlarray(sqrt(0.1) * ones(1, 10));

LossInfo_Out4 = cgg_getLossInformation(L_Rec, L_KL, L_Rec_Area, L_Class_Dim, L_OS, ...
    LossInfo_Strong, false, W_Rec, W_KL, W_Class, W_OS, ClassNames, ...
    'WeightConfidence', W_Conf, 'Loss_TotalConfidence', L_TotalConf, ...
    'TrialConfidence', Low_TrialConf, 'TaskConfidence', Low_TaskConf, ...
    'BatchFraction', 0.1);

% Extract values
Rescaled_Conf = cgg_extractData(LossInfo_Out4.Loss_Confidence_Rescaled);
Weighted_Conf = cgg_extractData(LossInfo_Out4.Loss_Confidence_Weighted);
Current_Beta  = LossInfo_Out4.Confidence_Beta;

% VERIFICATION: Did the dynamic multiplier actually get applied to the gradients?
Expected_Weighted_Conf = Rescaled_Conf * W_Conf * Current_Beta;

assert(Current_Beta > 1.0, 'Test 4 Failed: Beta did not react to low confidence input.');
assert(abs(Weighted_Conf - Expected_Weighted_Conf) < 1e-4, ...
    'Test 4 Failed: The Confidence_Beta multiplier was NOT applied to the Weighted Confidence loss!');
disp('Test 4 Passed: Beta Controller mathematically verified and properly wired into the Weighted Loss!');

disp('--- All Unit Tests Passed! ---');

%% Visualization: Magnitude Standardization Pipeline
if WantPlot
    figure('Name', 'Loss Standardization Pipeline', 'Position', [150, 150, 1000, 500]);
    
    % Get data from the successful LossInfo_Out2 run
    LossNames = {'Reconstruction', 'KL Divergence', 'Classification'};
    
    % Raw
    RawVals = [cgg_extractData(LossInfo_Out2.Loss_Reconstruction), ...
               cgg_extractData(LossInfo_Out2.Loss_KL), ...
               cgg_extractData(LossInfo_Out2.Loss_Classification)];
           
    % Normalized (Divided by their respective priors)
    NormVals = [cgg_extractData(LossInfo_Out2.Loss_Reconstruction_Normalized), ...
                cgg_extractData(LossInfo_Out2.Loss_KL_Normalized), ...
                cgg_extractData(LossInfo_Out2.Loss_Classification_Normalized)];
            
    % Rescaled (Multiplied by the shared Classification Prior anchor)
    RescaleVals = [cgg_extractData(LossInfo_Out2.Loss_Reconstruction_Rescaled), ...
                   cgg_extractData(LossInfo_Out2.Loss_KL_Rescaled), ...
                   cgg_extractData(LossInfo_Out2.Loss_Classification_Rescaled)];
    
    % Plot 1: Raw Magnitudes (Shows the massive discrepancy)
    subplot(1,3,1);
    bar(RawVals, 'FaceColor', [0.8 0.4 0.4]);
    set(gca, 'XTickLabel', LossNames, 'XTickLabelRotation', 45);
    title('Raw Loss Magnitudes');
    ylabel('Loss Value');
    grid on;
    
    % Plot 2: Normalized (Shows them brought to unitless ratio)
    subplot(1,3,2);
    bar(NormVals, 'FaceColor', [0.4 0.8 0.4]);
    set(gca, 'XTickLabel', LossNames, 'XTickLabelRotation', 45);
    title('Normalized (\mathcal{L} / \mu)');
    grid on;
    
    % Plot 3: Rescaled (Shows them safely brought back up to optimizer scale)
    subplot(1,3,3);
    bar(RescaleVals, 'FaceColor', [0.4 0.6 0.9]);
    set(gca, 'XTickLabel', LossNames, 'XTickLabelRotation', 45);
    title('Rescaled (\mathcal{L}^{norm} \times R)');
    grid on;
    
    % Add explanatory text spanning bottom
    annotation('textbox', [0.15 0.01 0.75 0.08], 'String', ...
        'This proves the helper successfully standardizes extreme magnitude discrepancies (e.g., KL vs Classification) prior to applying structural weights or the dynamic Beta controller.', ...
        'HorizontalAlignment', 'center', 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'FontSize', 10);
end
