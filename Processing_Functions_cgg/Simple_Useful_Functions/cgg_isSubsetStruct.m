function isSubset = cgg_isSubsetStruct(mainStruct, subsetStruct)
%CGG_ISSUBSETSTRUCT Summary of this function goes here
%   Detailed explanation goes here
    isSubset = true;
    
    % Get field names
    subsetFields = fieldnames(subsetStruct);
    mainFields = fieldnames(mainStruct);
    
    % Loop through each field in the subset structure
    for i = 1:length(subsetFields)
        fieldName = subsetFields{i};
        
        % Check if the field exists in the main structure
        if ~isfield(mainStruct, fieldName)
            isSubset = false;
            % fprintf('!!! Inconsistent field names. Subset has field %s\n',fieldName);
            return;
        end
        
        % Check if the values of the field match
        subsetValue = subsetStruct.(fieldName);
        mainValue = mainStruct.(fieldName);
        
        if ~isequal(subsetValue, mainValue)
            isSubset = false;
            % fprintf('!!! Inconsistent values. Fieldname: %s. Subset: %f. Main: %f\n',fieldName,subsetValue,mainValue);
            return;
        end
    end
end