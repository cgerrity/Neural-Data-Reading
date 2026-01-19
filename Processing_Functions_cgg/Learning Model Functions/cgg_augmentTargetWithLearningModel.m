function NewTarget = cgg_augmentTargetWithLearningModel(Target, LearningModelTable)
%CGG_AUGMENTTARGETWITHLEARNINGMODEL Appends RL model variables to Target(s).
%   Takes a Target structure (or array of structures), finds the matching
%   DataNumber in the LearningModelTable, and adds the following fields:
%     - TargetValue
%     - TargetPE
%     - DistractorValuesMean
%
%   INPUTS:
%       Target             : Struct or Struct Array containing 'DataNumber'
%       LearningModelTable : Table created by cgg_getNewLearningModelVariablesFromTargetPath
%
%   OUTPUTS:
%       NewTarget          : The input structure with new fields added.

    %% 1. Input Checks
    if isempty(Target)
        NewTarget = Target;
        return;
    end

    if ~isfield(Target, 'DataNumber')
        error('Input Target structure must contain the field "DataNumber" for lookup.');
    end
    
    % Initialize output
    NewTarget = Target;
    
    %% 2. Extract Keys for Lookup
    % We expect DataNumber to be a scalar numeric in each Target element.
    % We concatenate them to allow fast vectorized lookup (ismember) 
    % instead of a slow for-loop.
    try
        TargetDataNumbers = [Target.DataNumber];
    catch
        error('Target.DataNumber must be a numeric scalar for every element in the array.');
    end
    
    % Verification: Ensure we extracted one ID per Target
    if length(TargetDataNumbers) ~= numel(Target)
        error('Extraction length mismatch. Ensure every Target has a non-empty DataNumber.');
    end

    %% 3. Find Matches in the Learning Model Table
    % LIA: Logical Index Array (True where Target ID exists in Table)
    % LOCB: Locations in Table (Index of the match in LearningModelTable)
    [Lia, Locb] = ismember(TargetDataNumbers, LearningModelTable.DataNumber);
    
    %% 4. Prepare Data Vectors (NaN for missing)
    NumTargets = numel(Target);
    
    % Pre-allocate vectors for the new fields
    Vec_TargetValue      = NaN(1, NumTargets);
    Vec_TargetPE         = NaN(1, NumTargets);
    Vec_DistractorMean   = NaN(1, NumTargets);
    
    % Identify valid matches
    % Locb(Lia) gives the row indices in the table for the successful matches
    TableIndices = Locb(Lia);
    
    if ~isempty(TableIndices)
        % Map data from Table -> Vectors using the Logical mask (Lia)
        Vec_TargetValue(Lia)    = LearningModelTable.TargetValue(TableIndices);
        Vec_TargetPE(Lia)       = LearningModelTable.TargetPE(TableIndices);
        Vec_DistractorMean(Lia) = LearningModelTable.DistractorValuesMean(TableIndices);
    end
    
    %% 5. Distribute Values back to Struct Array
    % To assign array values to a struct array field efficiently, we convert
    % the vector to a Cell Array and use a comma-separated list expansion.
    
    % 1. Target Value
    Cell_TargetValue = num2cell(Vec_TargetValue);
    [NewTarget.TargetValue] = Cell_TargetValue{:};
    
    % 2. Target PE
    Cell_TargetPE = num2cell(Vec_TargetPE);
    [NewTarget.TargetPE] = Cell_TargetPE{:};
    
    % 3. Distractor Mean
    Cell_DistractorMean = num2cell(Vec_DistractorMean);
    [NewTarget.DistractorValuesMean] = Cell_DistractorMean{:};

end