function aggregatedResult = cgg_getAllEncoderCMTable(aggregatedResult,filePath,varargin)
%CGG_AGGREGATETABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantFinished = CheckVararginPairs('WantFinished', false, varargin{:});
else
if ~(exist('WantFinished','var'))
WantFinished=false;
end
end

% if isfunction
% WantValidation = CheckVararginPairs('WantValidation', false, varargin{:});
% else
% if ~(exist('WantValidation','var'))
% WantValidation=false;
% end
% end

if isfunction
FieldsToRemove = CheckVararginPairs('FieldsToRemove', strings(0), varargin{:});
else
if ~(exist('FieldsToRemove','var'))
FieldsToRemove=strings(0);
end
end

if isfunction
KeepAllFields = CheckVararginPairs('KeepAllFields', false, varargin{:});
else
if ~(exist('KeepAllFields','var'))
KeepAllFields=false;
end
end

%% Hardcoded Fields to Remove

FieldsToRemove = [FieldsToRemove,'WantSaveOptimalNet'];
FieldsToRemove = [FieldsToRemove,'AccumulationInformation'];
FieldsToRemove = [FieldsToRemove,'NumEpochsFull'];
FieldsToRemove = [FieldsToRemove,'NumEpochsFull_Final'];
FieldsToRemove = [FieldsToRemove,'NumEpochsSession'];
FieldsToRemove = [FieldsToRemove,'Freeze_cfg'];
if ~KeepAllFields
FieldsToRemove = [FieldsToRemove,'GradientClipType'];
FieldsToRemove = [FieldsToRemove,'WeightOffsetAndScale'];
FieldsToRemove = [FieldsToRemove,'WantSeparateTimeShift'];
FieldsToRemove = [FieldsToRemove,'STDTimeShift'];
FieldsToRemove = [FieldsToRemove,'EncoderOutputType'];
FieldsToRemove = [FieldsToRemove,'MultipleInstanceLearningType'];
FieldsToRemove = [FieldsToRemove,'DynamicWeighting'];
FieldsToRemove = [FieldsToRemove,'DynamicFreezing'];
FieldsToRemove = [FieldsToRemove,'DynamicAugmentation'];
FieldsToRemove = [FieldsToRemove,'DynamicParameterSet'];
FieldsToRemove = [FieldsToRemove,'DynamicSetDescription'];
FieldsToRemove = [FieldsToRemove,'ParameterSetName'];
FieldsToRemove = [FieldsToRemove,'StitchingAndFusionLayer'];
end

%%
    % Read the file into a table
    EncodingParameters = ReadYaml(filePath,0,true);
    % disp(filePath)
    if isempty(EncodingParameters)
        fprintf('!!! Encoding Parameters File is Empty\n');
        return
    end
    if isfield(EncodingParameters,'varargin')
        EncodingParameters = rmfield(EncodingParameters,'varargin');
    end
    Fold = EncodingParameters.Fold;
    NumEpochsFull = EncodingParameters.NumEpochsFull;

    EncodingParameters = rmfield(EncodingParameters,'Fold');

    EncodingParameters = rmfield(EncodingParameters,FieldsToRemove(...
        isfield(EncodingParameters,FieldsToRemove)));
    
    if iscell(EncodingParameters.HiddenSizes)
    EncodingParameters.FirstHiddenSize = EncodingParameters.HiddenSizes{1};
    else
    EncodingParameters.FirstHiddenSize = EncodingParameters.HiddenSizes(1);
    end
    EncodingParameters.NumberOfLayers = length(EncodingParameters.HiddenSizes);
    %% Is Augmented
    % Determine if the encoding parameters contain data augmentation
    IsAugmented = false;
    DataAugmentationFields = ["STDChannelOffset","STDRandomWalk", ...
        "STDWhiteNoise","STDTimeShift","WantSeparateTimeShift"];
    for didx = 1:length(DataAugmentationFields)
        DataAugmentationField = DataAugmentationFields(didx);
        if ~IsAugmented && isfield(EncodingParameters,DataAugmentationField)
            DataAugmentation = EncodingParameters.(DataAugmentationField);
            if islogical(DataAugmentation)
            IsAugmented = DataAugmentation;
            else
            IsAugmented = ~isnan(DataAugmentation);
            end
        end
    end
EncodingParameters.IsAugmented = IsAugmented;

%% Has Loss Weighting
    % Determine if the encoding parameters contain loss weighting
    HasLossWeighting = false;
    LossWeightingFields = ["WeightReconstruction","WeightClassification","WeightKL","WeightOffsetAndScale"];
    for widx = 1:length(LossWeightingFields)
        LossWeightingField = LossWeightingFields(widx);
        if ~HasLossWeighting && isfield(EncodingParameters,LossWeightingField)
            LossWeighting = EncodingParameters.(LossWeightingField);
            if islogical(LossWeighting)
            HasLossWeighting = LossWeighting;
            else
            HasLossWeighting = ~isnan(LossWeighting) && LossWeighting ~= 0;
            end
        end
    end

EncodingParameters.HasLossWeighting = HasLossWeighting;

    %%

    [FolderPath,~,~] = fileparts(filePath);
    % if WantValidation
    %     CM_TablePathNameExt = fullfile(FolderPath,'CM_Table_Validation.mat');
    % else
    %     CM_TablePathNameExt = fullfile(FolderPath,'CM_Table.mat');
    % end

    % disp(CM_TablePathNameExt);

    CM_TablePathNameExt = fullfile(FolderPath,'CM_Table.mat');
    if isfile(CM_TablePathNameExt)
        % m_CM_Table = matfile(CM_TablePathNameExt,"Writable",false);
        m_CM_Table = load(CM_TablePathNameExt);
        CM_Table = m_CM_Table.CM_Table;
    else
        return
    end

    CM_TableValidationPathNameExt = fullfile(FolderPath,'CM_Table_Validation.mat');
    if isfile(CM_TableValidationPathNameExt)
        % m_CM_Table = matfile(CM_TablePathNameExt,"Writable",false);
        m_CM_Table_Validation = load(CM_TableValidationPathNameExt);
        CM_Table_Validation = m_CM_Table_Validation.CM_Table;
    else
        return
    end

    IterationPathNameExt = fullfile(FolderPath,'CurrentIteration.mat');

    if isfile(IterationPathNameExt)
        % m_Iteration= matfile(IterationPathNameExt,"Writable",false);
        m_Iteration= load(IterationPathNameExt);
        Epoch = m_Iteration.Epoch;
    else
        return
    end

    if NumEpochsFull >= Epoch && WantFinished
        return
    end
    
    FieldNames = fieldnames(EncodingParameters);

    for fidx = 1:length(FieldNames)
        this_FieldName = FieldNames{fidx};
        this_Variable = EncodingParameters.(this_FieldName);
        this_Variable = cgg_convertArrayToString(this_Variable);
        EncodingParameters.(this_FieldName) = this_Variable;
    end

    EncodingParameters = struct2table(EncodingParameters,"AsArray",true);
    newTable = EncodingParameters;
    
    %% Aggregate the result by vertically concatenating the tables
    if isempty(aggregatedResult)
        % If this is the first file, the result is the first table
        aggregatedResult = newTable;
        aggregatedResult.Fold = {Fold};
        aggregatedResult.CM_Table = {{CM_Table}};
        aggregatedResult.CM_Table_Validation = {{CM_Table_Validation}};
    else
        % Otherwise, append the new table to the existing one
        Current_Rows = height(aggregatedResult);
        % aggregatedResult_NoFold = removevars(aggregatedResult,["Fold","CM_Table"]);
        aggregatedResult_NoFold = removevars(aggregatedResult,["Fold","CM_Table","CM_Table_Validation"]);
        [aggregatedResult_tmp,~,idx] = outerjoin(aggregatedResult_NoFold, newTable,"MergeKeys",true);
        idx = idx==1;
        newTable = aggregatedResult_tmp(idx,:); % newtable with same variables as aggregate
        newTable(:,ismissing(newTable)) = {"Missing"};
        [~,~,idx] = outerjoin(aggregatedResult_NoFold, newTable,"MergeKeys",true);
        IsMatchNewFold = length(idx) == Current_Rows;
        idx = idx==1;
        %%
        if ~IsMatchNewFold
            [aggregatedResult,~,idx] = outerjoin(aggregatedResult, newTable,"MergeKeys",true);
            MissingAggregate = ismissing(aggregatedResult);
            for hidx = 1:height(aggregatedResult)
            aggregatedResult(hidx,MissingAggregate(hidx,:)) = {"Missing"};
            end
            idx = idx==1;
        end
        aggregatedResult{idx,"Fold"} = {[aggregatedResult{idx,"Fold"}{1}, Fold]};
        aggregatedResult{idx,"CM_Table"} = {[aggregatedResult{idx,"CM_Table"}{1}, {CM_Table}]};
        aggregatedResult{idx,"CM_Table_Validation"} = {[aggregatedResult{idx,"CM_Table_Validation"}{1}, {CM_Table_Validation}]};
    end
end

