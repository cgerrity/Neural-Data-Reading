function targetStruct = cgg_mergeStructs(targetStruct, sourceStruct)
    % CGG_MERGESTRUCTS Adds fields from sourceStruct to targetStruct
    % without overwriting any existing fields in targetStruct.
    
    % Get a cell array of all field names in the source structure
    sourceFields = fieldnames(sourceStruct);
    
    % Loop through each field name
    for i = 1:numel(sourceFields)
        currentField = sourceFields{i};
        
        % Check if the field is missing from the target structure
        if ~isfield(targetStruct, currentField)
            % If it doesn't exist, add the field and its data
            targetStruct.(currentField) = sourceStruct.(currentField);
        end
    end
end