function aggregatedResult = cgg_getAllEncoderParametersTable(aggregatedResult,filePath)
%CGG_AGGREGATETABLE Summary of this function goes here
%   Detailed explanation goes here
    % Read the file into a table
    EncodingParameters = ReadYaml(filePath,0,true);
    EncodingParameters = rmfield(EncodingParameters,'varargin');
    Fold = EncodingParameters.Fold;
    % disp('Fold');
    % disp(Fold)
    EncodingParameters = rmfield(EncodingParameters,'Fold');

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
    else
        % Otherwise, append the new table to the existing one
        Current_Rows = height(aggregatedResult);
        aggregatedResult_NoFold = removevars(aggregatedResult,'Fold');
        [aggregatedResult_tmp,~,idx] = outerjoin(aggregatedResult_NoFold, newTable,"MergeKeys",true);
        idx = idx==1;
        newTable = aggregatedResult_tmp(idx,:); % newtable with same variables as aggregate
        newTable(:,ismissing(newTable)) = {"Missing"};
        [~,~,idx] = outerjoin(aggregatedResult_NoFold, newTable,"MergeKeys",true);
        IsMatchNewFold = length(idx) == Current_Rows;
        idx = idx==1;
        % disp({IsMatchNewFold,Fold});
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
    end
end

