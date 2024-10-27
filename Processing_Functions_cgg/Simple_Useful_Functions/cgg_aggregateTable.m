function aggregatedResult = cgg_aggregateTable(aggregatedResult,filePath)
%CGG_AGGREGATETABLE Summary of this function goes here
%   Detailed explanation goes here
    % Read the file into a table
    EncodingParameters = ReadYaml(filePath,0,true);
    EncodingParameters = rmfield(EncodingParameters,'varargin');

    FieldNames = fieldnames(EncodingParameters);

    for fidx = 1:length(FieldNames)
        this_FieldName = FieldNames{fidx};
        this_Variable = EncodingParameters.(this_FieldName);
        this_Variable = cgg_convertArrayToString(this_Variable);
        EncodingParameters.(this_FieldName) = this_Variable;
    end

    EncodingParameters = struct2table(EncodingParameters,"AsArray",true);
    newTable = EncodingParameters;
    
    % Aggregate the result by vertically concatenating the tables
    if isempty(aggregatedResult)
        % If this is the first file, the result is the first table
        aggregatedResult = newTable;
    else
        % Otherwise, append the new table to the existing one
        [aggregatedResult,~,idx] = outerjoin(aggregatedResult, newTable,"MergeKeys",true);
    end
end

