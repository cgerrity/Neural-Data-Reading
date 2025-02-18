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

if isfunction
WantValidation = CheckVararginPairs('WantValidation', false, varargin{:});
else
if ~(exist('WantValidation','var'))
WantValidation=false;
end
end

%%
    % Read the file into a table
    EncodingParameters = ReadYaml(filePath,0,true);
    EncodingParameters = rmfield(EncodingParameters,'varargin');
    Fold = EncodingParameters.Fold;

    EncodingParameters = rmfield(EncodingParameters,'Fold');

    [FolderPath,~,~] = fileparts(filePath);
    if WantValidation
    CM_TablePathNameExt = fullfile(FolderPath,'CM_Table_Validation.mat');
    else
        CM_TablePathNameExt = fullfile(FolderPath,'CM_Table.mat');
    end

    % disp(CM_TablePathNameExt);

    if isfile(CM_TablePathNameExt)
        m_CM_Table = matfile(CM_TablePathNameExt,"Writable",false);
        CM_Table = m_CM_Table.CM_Table;
    else
        return
    end

    IterationPathNameExt = fullfile(FolderPath,'CurrentIteration.mat');

    if isfile(IterationPathNameExt)
        m_Iteration= matfile(IterationPathNameExt,"Writable",false);
        Epoch = m_Iteration.Epoch;
    else
        return
    end

    if EncodingParameters.NumEpochsFull >= Epoch && WantFinished
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
    else
        % Otherwise, append the new table to the existing one
        Current_Rows = height(aggregatedResult);
        aggregatedResult_NoFold = removevars(aggregatedResult,["Fold","CM_Table"]);
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
    end
end

