clc; clear; close all;

%% 1. Load Data (Adjust path as needed)
% Replace this with your actual loading logic
PathNameExt = '/Users/cgerrity/Downloads/FeatureValues_RLWMModelValues_01 (2).mat'; 
% load(PathNameExt); 

% --- MOCK DATA GENERATION FOR DEMONSTRATION (Delete this block if running on real data) ---
% Creating dummy data to simulate your structure for the explanation
rng(1);
NumTrials = 50;
% Assume 2D (2 features per object)
Dimensionality = 2; 
NumFeatures = Dimensionality * 3; % 1 Chosen + 2 Not Chosen objects? Or 1 Chosen + 1 Not Chosen with features?
% Let's match your logic:
BlockIDs = ones(NumTrials,1);
SessionNames = repmat({'Session1'}, NumTrials, 1);
% Feature IDs: Cols 1-2 (Chosen), Cols 3-6 (Not Chosen)
featureID = zeros(NumTrials, 6); 
% Let's say Target is ID 1 and 2 (e.g. Red Square).
% If Monkey chooses correctly (Indices 1:2 are Target):
featureID(1:25, :) = repmat([1, 2,  3, 4, 5, 6], 25, 1); 
% If Monkey chooses incorrectly (Indices 1:2 are Distractor):
featureID(26:50, :) = repmat([3, 4,  1, 2, 5, 6], 25, 1); 

% Mock Values
Value_ObjectChosen_RL = rand(NumTrials, 2); 
Value_ObjectsNotChosen_RL = rand(NumTrials, 4);
PE_ObjectChosen = rand(NumTrials, 2);
PE_ObjectsNotChosen = rand(NumTrials, 4);

RowIndices = 1:NumTrials;
this_IDs = featureID;
this_ChosenValue = Value_ObjectChosen_RL;
this_NotChosenValue = Value_ObjectsNotChosen_RL;
% -----------------------------------------------------------------------------------------

%% 2. Question: Is "Chosen" == "Target"?
% Logic: In RL tasks, "Chosen" variables track behavior, not the rule. 
% They only represent the Target if the monkey chose correctly.

% Identify the Target Feature ID for this block (Using your heuristic)
% Your heuristic checks for the column that never changes.
% Note: In real data, if the monkey switches choices, the 'Chosen' ID columns change!
% A more robust way is usually finding the ID that appears in *every* trial.
AllIDs = unique(this_IDs);
AllIDs(AllIDs==0) = [];
TargetID = [];

% Heuristic: Find the ID present in both Correct and Incorrect trials
% (For this demo, we assume we know TargetID = 1 for Dim 1).
% In your specific dataset, you used: TargetID = all(diff(this_IDs,2) == 0,1);
% We will simulate finding the Target ID.
RealTargetID = 1; % Assume Feature 1 is the high-value feature

% Comparison Plot
figure('Position', [100 100 1000 400]);
subplot(1,2,1);
imagesc(this_IDs);
colorbar;
title('Feature IDs Matrix');
xlabel('Feature Columns'); ylabel('Trial');
% You will see that columns 1:Dim change color (ID) when the monkey errors.

% Check correlation
IsChosenTarget = this_IDs(:,1) == RealTargetID;
fprintf('Percentage of trials where Chosen == Target: %.1f%%\n', mean(IsChosenTarget)*100);
fprintf('This confirms that "Chosen" variables are BEHAVIORAL, not rule-based.\n');

%% 3. Question: Why the weird variable order?
% You asked about the logic: stacked = [first_vals; second_vals]; ActiveNotChosenFull = stacked(:)';

% Let's visualize the mapping for a 3D case (hypothetical) to make it obvious
Dim_Demo = 3;
ActiveChosen_Demo = 1:Dim_Demo; % [1 2 3]

% Your logic derived:
first_vals = Dim_Demo + ActiveChosen_Demo;     % [4 5 6]
second_vals = first_vals + Dim_Demo;           % [7 8 9]
stacked = [first_vals; second_vals];           % [4 5 6; 7 8 9]
ActiveNotChosenFull_Demo = stacked(:)';        % [4 7 5 8 6 9]

fprintf('\n--- Variable Order Logic (3D Example) ---\n');
fprintf('Standard Linear Columns: %s\n', num2str(4:9));
fprintf('Your Re-Ordered Columns: %s\n', num2str(ActiveNotChosenFull_Demo));

% VISUAL EXPLANATION:
% MATLAB stores matrices in "Column-Major" order.
% Usually, raw "NotChosen" data is stored as: 
%   [Obj2_Feat1, Obj2_Feat2, Obj2_Feat3, Obj3_Feat1, Obj3_Feat2, Obj3_Feat3]
%
% But the "featureID" matrix (and the logical model state) is often interleaved by dimension:
%   [Obj2_Feat1, Obj3_Feat1, Obj2_Feat2, Obj3_Feat2, Obj2_Feat3, Obj3_Feat3]
% 
% Your code `stacked(:)'` effectively performs this interleaving transform.
% It maps the linear NotChosen list into the dimension-grouped ID list.

subplot(1,2,2);
bar([1:length(ActiveNotChosenFull_Demo)], ActiveNotChosenFull_Demo);
xlabel('Target Column Index in "AllValues"');
ylabel('Source Index from "NotChosen"');
title('Visualizing the Interleaving (Zig-Zag pattern)');
grid on;