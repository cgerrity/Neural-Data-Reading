function [TargetData, DistractorData] = cgg_getCorrectedVariables(BlockIDs, SessionNames, FeatureIDs, ValueChosen, ValueNotChosen, PEChosen, PENotChosen)
% ProcessRLWMData organises RLWM data into Target vs Distractor formats.
%
% INPUTS:
%   BlockIDs       : Vector of block numbers
%   SessionNames   : Cell array of session names
%   FeatureIDs     : Matrix of Feature IDs per trial
%   ValueChosen    : Matrix of Values for Chosen objects
%   ValueNotChosen : Matrix of Values for Not Chosen objects
%   PEChosen       : Matrix of PE for Chosen objects
%   PENotChosen    : Matrix of PE for Not Chosen objects
%
% OUTPUTS:
%   TargetData     : Struct containing .Values, .PEs, and .FeatureIDs (Trials x 1)
%   DistractorData : Struct containing .Values, .PEs, and .FeatureIDs (Trials x N)
%                    Columns are sorted to ensure consistent ordering.

    %% 1. Initialization
    NumTrials = length(BlockIDs);
    
    % Prepare Output containers (NaN filled for safety)
    % We estimate max dimensions to pre-allocate, but dynamic is safer for varying dimensions
    TargetData.Values     = NaN(NumTrials, 1);
    TargetData.PEs        = NaN(NumTrials, 1);
    TargetData.FeatureIDs = NaN(NumTrials, 1);
    
    % We need to handle the fact that different blocks have different dimensions.
    % We will store Distractors in a matrix wide enough for the max case (3D).
    % Max Distractors = (Total Features - 1). If Max Dim=3, Total Features=9, Distractors=8.
    MaxDistractors = 8; 
    DistractorData.Values     = NaN(NumTrials, MaxDistractors);
    DistractorData.PEs        = NaN(NumTrials, MaxDistractors);
    DistractorData.FeatureIDs = NaN(NumTrials, MaxDistractors);
    
    UniqueSessions = unique(SessionNames);
    
    %% 2. Loop through Sessions and Blocks
    for sIdx = 1:length(UniqueSessions)
        this_SessionName = UniqueSessions{sIdx};
        SessionMask = strcmp(SessionNames, this_SessionName);
        
        UniqueBlocks = unique(BlockIDs(SessionMask));
        
        for bIdx = 1:length(UniqueBlocks)
            this_BlockID = UniqueBlocks(bIdx);
            
            % Get Trial Indices for this specific Block
            TrialIndices = find(SessionMask & BlockIDs == this_BlockID);
            
            if isempty(TrialIndices); continue; end
            
            % Extract Block Data
            b_IDs = FeatureIDs(TrialIndices, :);
            b_ValChosen = ValueChosen(TrialIndices, :);
            b_ValNotChosen = ValueNotChosen(TrialIndices, :);
            b_PEChosen = PEChosen(TrialIndices, :);
            b_PENotChosen = PENotChosen(TrialIndices, :);
            
            %% 3. Dimensionality & Mapping Logic
            % (Logic adapted from your snippet)
            AllIDs = unique(b_IDs);
            AllIDs(AllIDs == 0) = [];
            NumFeaturesInBlock = length(AllIDs);
            
            % Calculate Dimensionality
            Dim = round(NumFeaturesInBlock / 3); 
            if Dim < 1; Dim = 1; end % Safety check
            
            % Create Column Indices
            ActiveChosen = 1:Dim;
            
            % The "Stacked" Logic to map NotChosen columns to IDs
            first_vals = Dim + ActiveChosen;
            second_vals = first_vals + Dim;
            stacked = [first_vals; second_vals];
            ActiveNotChosenFull = stacked(:)';
            
            % Reconstruct the "AllValues" State Matrix for this block
            % This aligns values to the physical column slots in featureID
            b_AllValues = NaN(size(b_IDs));
            b_AllPEs    = NaN(size(b_IDs));
            
            % Map Chosen
            b_AllValues(:, ActiveChosen) = b_ValChosen(:, 1:Dim);
            b_AllPEs(:, ActiveChosen)    = b_PEChosen(:, 1:Dim);
            
            % Map Not Chosen (using the complex index order)
            % Ensure we don't exceed matrix bounds if data is sparse
            ColsToMap = min(length(ActiveNotChosenFull), size(b_ValNotChosen, 2));
            b_AllValues(:, ActiveNotChosenFull(1:ColsToMap)) = b_ValNotChosen(:, 1:ColsToMap);
            b_AllPEs(:, ActiveNotChosenFull(1:ColsToMap))    = b_PENotChosen(:, 1:ColsToMap);
            
            %% 4. Identify Target ID
            % Your logic: The Target ID is the one where the 2nd derivative is 0
            % (Implies the feature column is constant or linearly stable).
            % We wrap this in try-catch or checks to make it robust.
            
            % Strategy: The Target is usually the feature ID that appears in 
            % the Chosen list most frequently in high-performance blocks, 
            % OR follows your `diff` logic.
            
            % Using your specific `diff` logic:
            try
                TargetMask = all(diff(b_IDs, 2) == 0, 1);
                % If multiple columns satisfy this, take the first valid ID found
                PossibleTargets = b_IDs(1, TargetMask);
                PossibleTargets(PossibleTargets == 0) = [];
                CurrentTargetID = PossibleTargets(1); 
            catch
                % Fallback: Mode of the IDs (assuming monkey learned correct choice)
                % Or specifically looking for the Feature ID common to all trials if structure dictates
                CurrentTargetID = mode(b_IDs(b_IDs~=0)); 
            end
            
            %% 5. Extract Target vs Distractors per Trial
            
            for t = 1:length(TrialIndices)
                GlobalRow = TrialIndices(t);
                
                % Get the features and values for this specific trial
                TrialIDs = b_IDs(t, :);
                TrialVals = b_AllValues(t, :);
                TrialPEs  = b_AllPEs(t, :);
                
                % Find indices
                idx_Target = (TrialIDs == CurrentTargetID);
                idx_Distractors = (TrialIDs ~= CurrentTargetID) & (TrialIDs ~= 0) & ~isnan(TrialIDs);
                
                % 1. Store Target (Scalar)
                if any(idx_Target)
                    TargetData.Values(GlobalRow)     = TrialVals(idx_Target);
                    TargetData.PEs(GlobalRow)        = TrialPEs(idx_Target);
                    TargetData.FeatureIDs(GlobalRow) = CurrentTargetID;
                end
                
                % 2. Store Distractors (Vector)
                % To ensure "consistent ordering" as requested, we sort by FeatureID.
                % This ensures that Distractor Feature "A" is always in Column 1, 
                % regardless of whether it appeared on the Left or Right object.
                
                DistIDs = TrialIDs(idx_Distractors);
                DistVals = TrialVals(idx_Distractors);
                DistPEs  = TrialPEs(idx_Distractors);
                
                [SortedIDs, SortOrder] = sort(DistIDs); % Sort by ID for consistency
                
                NumDist = length(SortOrder);
                DistractorData.Values(GlobalRow, 1:NumDist)     = DistVals(SortOrder);
                DistractorData.PEs(GlobalRow, 1:NumDist)        = DistPEs(SortOrder);
                DistractorData.FeatureIDs(GlobalRow, 1:NumDist) = SortedIDs;
            end
        end
    end
end