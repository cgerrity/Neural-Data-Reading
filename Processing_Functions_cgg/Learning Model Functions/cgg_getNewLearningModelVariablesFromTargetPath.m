function LearningModelTable = cgg_getNewLearningModelVariablesFromTargetPath(AggregateTargetPath)
%CGG_GETNEWLEARNINGMODELVARIABLESFROMTARGETPATH
%   Reads trial-by-trial .mat files from a datastore, aggregates them into
%   matrices (padding with NaNs/Zeros for varying dimensions), and applies
%   the cgg_getCorrectedVariables logic to generate Target/Distractor tables.

    %% 1. Define Variables to Extract
    % These match the fields expected by cgg_getCorrectedVariables
    OtherValueNames = {'featureID', 'blocknumindx', 'datasetname', ...
        'Value_ObjectChosen_RL','Value_ObjectsNotChosen_RL', ...
        'PE_ObjectChosen', 'PE_ObjectsNotChosen'};

    %% 2. Define Helper Functions for Datastore
    % DataNumber_Fun extracts the trial number from the filename
    DataNumber_Fun = @(x) cgg_loadTargetArray(x, 'DataNumber', true);
    % OtherValue_Fun extracts the specific variables defined above
    OtherValue_Fun = @(x) cgg_loadTargetArray(x, 'OtherValue', OtherValueNames);

    % Combined Read Function: Returns a cell row {DataNumber, Val1, Val2, ...}
    % We helper wrap DataNumber in a cell to ensure valid concatenation if needed,
    % though strictly [num, cell] concat can be tricky in anonymous funcs.
    % Assuming cgg_loadTargetArray returns compatible types or this works in your context.
    Target_Fun = @(x) [num2cell(DataNumber_Fun(x)), OtherValue_Fun(x)];

    %% 3. Create Datastore and Read Data
    % We use 'FileExtensions' to ensure we only grab .mat files
    Target_ds = fileDatastore(AggregateTargetPath, 'ReadFcn', Target_Fun, 'FileExtensions', '.mat');
    
    % Read all files. Result is an N x 1 Cell Array, where each element is a 1x8 Cell Row.
    RawDataCellsNested = readall(Target_ds, 'UseParallel', true);

    if isempty(RawDataCellsNested)
        LearningModelTable = table();
        warning('No data found in path.');
        return;
    end
    
    % Flatten the nested cell array (N x 1 -> N x 8) so we can index columns directly
    RawDataCells = vertcat(RawDataCellsNested{:});

    %% 4. Sort Data by Trial Number
    % File systems don't guarantee order, so we sort by the extracted DataNumber
    DataNumbers = vertcat(RawDataCells{:, 1});
    [~, SortIdx] = sort(DataNumbers);
    SortedData = RawDataCells(SortIdx, :);

    %% 5. Extract and Pad Matrices
    % Blocks may have different dimensions (1D vs 2D vs 3D). 
    % We must pad matrices to the maximum width found in the dataset.
    
    % Simple scalars/strings
    BlockIDs     = vertcat(SortedData{:, 3});
    SessionNames = SortedData(:, 4); 

    % Matrices (Pad FeatureIDs with 0, Values/PEs with NaN)
    % Column 2: featureID
    FeatureIDs     = PadAndConcat(SortedData(:, 2), 0); 
    % Column 5: ValueChosen
    ValueChosen    = PadAndConcat(SortedData(:, 5), NaN);
    % Column 6: ValueNotChosen
    ValueNotChosen = PadAndConcat(SortedData(:, 6), NaN);
    % Column 7: PEChosen
    PEChosen       = PadAndConcat(SortedData(:, 7), NaN);
    % Column 8: PENotChosen
    PENotChosen    = PadAndConcat(SortedData(:, 8), NaN);

    %% 6. Run the Correction/Analysis Function
    [TargetData, DistractorData] = cgg_getCorrectedVariables(...
        BlockIDs, SessionNames, FeatureIDs, ...
        ValueChosen, ValueNotChosen, PEChosen, PENotChosen);

    %% 7. Construct Final Table
    LearningModelTable = table();
    LearningModelTable.DataNumber = DataNumbers(SortIdx);
    LearningModelTable.BlockID = BlockIDs;
    LearningModelTable.SessionName = SessionNames;

    % Add Target Data (Scalars)
    LearningModelTable.TargetValue = TargetData.Values;
    LearningModelTable.TargetPE = TargetData.PEs;
    LearningModelTable.TargetFeatureID = TargetData.FeatureIDs;

    % Add Distractor Data (Matrices)
    LearningModelTable.DistractorValues = DistractorData.Values;
    LearningModelTable.DistractorValuesMean = mean(DistractorData.Values,2,"omitnan");
    LearningModelTable.DistractorPEs = DistractorData.PEs;
    LearningModelTable.DistractorFeatureIDs = DistractorData.FeatureIDs;

end

function Mat = PadAndConcat(CellCol, FillValue)
    % Helper to vertically concatenate row vectors, padding with FillValue if widths differ
    NumRows = length(CellCol);
    if NumRows == 0
        Mat = [];
        return;
    end
    
    % 1. Determine the maximum width (number of columns)
    Widths = cellfun(@(x) size(x, 2), CellCol);
    MaxWidth = max(Widths);
    
    % 2. Preallocate matrix with the FillValue
    Mat = repmat(FillValue, NumRows, MaxWidth);
    
    % 3. Fill the data
    for i = 1:NumRows
        RowData = CellCol{i};
        w = size(RowData, 2);
        if w > 0
            Mat(i, 1:w) = RowData;
        end
    end
end