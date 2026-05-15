% TEST_GEMINI_CGG_CALCCLASSIFICATIONLOSS Test suite covering edge cases

clc; clear; close all;
rng('shuffle');

disp('Starting tests for cgg_calcClassificationLoss...');

%% Setup Simple 1 batch data (Standard Classification)
% 3 classes, batch size of 1
NumBatches = 200;
NumClasses = 3;
ConfidenceLossType = 'CrossEntropy'; % CrossEntropy, L1, L2
Y_Correctness = 0.3;

Y_basic_B1 = dlarray(softmax(randn(NumClasses, NumBatches)), 'CB');
Random_Class = randi(NumClasses,[1,NumBatches]);
ind = sub2ind([NumClasses,NumBatches],Random_Class,1:NumBatches);
Y_basic_B1(ind) = Y_Correctness;
% Y_basic_B1(1) = 0.5;
% One-hot encoded targets
T_basic_B1 = zeros(NumClasses, NumBatches);
T_basic_B1(ind) = 1; 
T_basic_B1 = dlarray(T_basic_B1, 'CB');

C_range = 0:0.01:1;
Loss_Classification = NaN(size(C_range));
Loss_Confidence = NaN(size(C_range));
for cidx = 1:length(C_range)

this_c = C_range(cidx);
this_c = dlarray(this_c,'B'); 
this_Y = Y_basic_B1.*this_c + T_basic_B1.* (1-this_c);
Loss_Classification(cidx) = cgg_extractData(crossentropy(this_Y,T_basic_B1));
TargetOnes = ones(size(this_c), "like", this_c);
this_c = mean(this_c);
Loss_Confidence(cidx) = cgg_extractData(crossentropy(this_c,TargetOnes));

[Loss_Classification(cidx),Loss_Confidence(cidx)] = cgg_calcClassificationLoss(T_basic_B1,Y_basic_B1,'TrialConfidence',this_c,'ConfidenceLossType',ConfidenceLossType);

end

Loss_Classification = cgg_extractData(Loss_Classification);
Loss_Confidence = cgg_extractData(Loss_Confidence);

Loss_Summation = Loss_Confidence + Loss_Classification;
D_Loss_Classification = [NaN,diff(Loss_Classification)];
D_Loss_Confidence = [NaN,diff(Loss_Confidence)];
Change_Difference = [NaN,diff(Loss_Confidence) - diff(Loss_Classification)];
Loss_Classification = Loss_Classification./ max(Loss_Summation);
Loss_Confidence = Loss_Confidence./ max(Loss_Summation);
Loss_Summation = Loss_Summation./ max(Loss_Summation);

figure; 
plot(C_range,Loss_Classification,"DisplayName","Classification")
hold on
plot(C_range,Loss_Confidence,"DisplayName","Confidence")
plot(C_range,Loss_Summation,"DisplayName","Summation")
hold off
legend;
ylim([0,1]);

figure;
% plot(C_range,Change_Difference,"DisplayName","Difference")
% hold on
plot(C_range,D_Loss_Classification,"DisplayName","D-Classification")
hold on
plot(C_range,-D_Loss_Confidence,"DisplayName","D-Confidence")
hold off
legend;

[~,IDX] = min(Loss_Summation);
disp(C_range(IDX))

%% Setup Basic Dummy Data (Standard Classification)
% 3 classes, batch size of 4
Y_basic = dlarray(softmax(randn(3, 4)), 'CB');
% One-hot encoded targets
T_basic = zeros(3, 4);
T_basic([1, 5, 9, 11]) = 1; 
T_basic = dlarray(T_basic, 'CB');

%% Test 1: Default Behavior (No confidence, CrossEntropy, NaN Weights)
[Loss1, LC1] = cgg_calcClassificationLoss(T_basic, Y_basic);
assert(isnumeric(extractdata(LC1)) && extractdata(LC1) == 0, 'Test 1 Failed: Default Loss_Confidence should be 0.');
assert(~isempty(Loss1), 'Test 1 Failed: Main loss not calculated.');
disp('  Test 1 Passed: Default CrossEntropy logic with NaN weights');

%% Test 2: CrossEntropy with Valid Weights
% Passing a formatted dlarray of weights
weights = dlarray([0.1, 0.3, 0.6], 'C');
[Loss2, ~] = cgg_calcClassificationLoss(T_basic, Y_basic, 'Weights', weights);
assert(extractdata(Loss1) ~= extractdata(Loss2), 'Test 2 Failed: Weights did not affect the loss.');
disp('  Test 2 Passed: CrossEntropy with class weights');

%% Test 3: Confidence Injection (L1 Loss, Dataset Confidence = True)
% Mock confidence: 1 channel, 4 batches, 2 time steps
confData = dlarray(rand(1, 4, 2), 'CBT'); 
[Loss3, LC3] = cgg_calcClassificationLoss(T_basic, Y_basic, ...
    'TrialConfidence', confData, ...
    'WantDatasetConfidence', true, ...
    'ConfidenceLossType', 'L1');
assert(extractdata(LC3) > 0, 'Test 3 Failed: L1 Confidence Loss not calculated.');
disp('  Test 3 Passed: Confidence logic (L1, Dataset Mean)');

%% Test 4: Confidence Injection (CrossEntropy, Dataset Confidence = False)
[Loss4, LC4] = cgg_calcClassificationLoss(T_basic, Y_basic, ...
    'TrialConfidence', confData, ...
    'WantDatasetConfidence', false, ...
    'ConfidenceLossType', 'CrossEntropy');
assert(extractdata(LC4) > 0, 'Test 4 Failed: CrossEntropy Confidence Loss not calculated.');
disp('  Test 4 Passed: Confidence logic (CrossEntropy, Per-Trial)');

%% Test 5: Fallback/Otherwise Loss Type
[Loss5, LC5] = cgg_calcClassificationLoss(T_basic, Y_basic, 'LossType', 'UnknownTypeGibberish');
% Should default to CrossEntropy
assert(abs(extractdata(Loss5) - extractdata(Loss1)) < 1e-5, 'Test 5 Failed: Fallback loss did not match standard CrossEntropy.');
disp('  Test 5 Passed: Fallback "otherwise" condition');

disp('--------------------------------------------------');
disp('SUCCESS: All tests passed!');