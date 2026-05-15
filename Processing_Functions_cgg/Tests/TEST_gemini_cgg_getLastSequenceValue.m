% function TEST_gemini_cgg_getLastSequenceValue()
% TEST_GEMINI_CGG_GETLASTSEQUENCEVALUE Test suite for cgg_getLastSequenceValue
%   Executes multiple scenarios to verify the correct extraction of the 
%   final time step from dlarray objects.

clc; clear; close all;
rng('shuffle');
%%

disp('Starting tests for cgg_getLastSequenceValue...');

%% Test 1: Standard case with 'T' at the end (e.g., CBT - Channel, Batch, Time)
% Create dummy data: 3 channels, 2 batches, 4 time steps
rawData1 = reshape(1:24, 3, 2, 4);
dlA1 = dlarray(rawData1, 'CBT');

out1 = cgg_getLastSequenceValue(dlA1);
expected1 = rawData1(:, :, end); % Expected: The 4th time step slice

assert(isequal(extractdata(out1), expected1), 'Test 1 Failed: Incorrect values extracted for CBT array.');
disp('  Test 1 Passed: Standard CBT format');

%% Test 2: Time dimension is NOT the last dimension (e.g., TCB)
% Create dummy data: 4 time steps, 3 channels, 2 batches
rawData2 = reshape(1:24, 4, 3, 2);
dlA2 = dlarray(rawData2, 'TCB');

out2 = cgg_getLastSequenceValue(dlA2);
expected2 = rawData2(end, :, :); % Expected: The 4th time step slice

% Using squeeze to safely compare underlying data structures 
assert(isequal(squeeze(extractdata(out2)), squeeze(expected2)), 'Test 2 Failed: Incorrect values extracted for TCB array.');
disp('  Test 2 Passed: TCB format (T is first dimension)');

%% Test 3: Formatted array WITHOUT a 'T' dimension (e.g., CB - Channel, Batch)
% Create dummy data: 3 channels, 2 batches (no time component)
rawData3 = [1 2; 3 4; 5 6];
dlA3 = dlarray(rawData3, 'CB');

out3 = cgg_getLastSequenceValue(dlA3);

assert(isequal(extractdata(out3), rawData3), 'Test 3 Failed: Array without T dimension should be returned unmodified.');
disp('  Test 3 Passed: Formatted array with no T dimension');

%% Test 4: Unformatted array
% Create dummy data without any dimensional labels
rawData4 = rand(5, 5, 5);
dlA4 = dlarray(rawData4);

out4 = cgg_getLastSequenceValue(dlA4);

assert(isequal(extractdata(out4), rawData4), 'Test 4 Failed: Unformatted array should be returned unmodified.');
disp('  Test 4 Passed: Unformatted array');

%% Test 5: Single Time Step (Edge Case)
% Create dummy data: 3 channels, 2 batches, 1 time step
rawData5 = rand(3, 2, 1);
dlA5 = dlarray(rawData5, 'CBT');

out5 = cgg_getLastSequenceValue(dlA5);
expected5 = rawData5(:, :, end); 

assert(isequal(extractdata(out5), expected5), 'Test 5 Failed: Failed on array with a single time step.');
disp('  Test 5 Passed: Array with a single time step');

%% Test 6: 'BT' format (Batch, Time)
% Create dummy data: 2 batches, 3 time steps
rawData6 = [1 2 3; 4 5 6];
dlA6 = dlarray(rawData6, 'BT');

out6 = cgg_getLastSequenceValue(dlA6);
expected6 = rawData6(:, end); % Expected: The 3rd time step column

assert(isequal(extractdata(out6), expected6), 'Test 6 Failed: Incorrect values extracted for BT array.');
disp('  Test 6 Passed: BT format (Batch, Time)');

disp('--------------------------------------------------');
disp('SUCCESS: All tests passed!');

% end