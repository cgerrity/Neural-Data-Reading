function cleanedTable = cgg_procRemoveTableRows(inputTable, targetString)
%CGG_PROCREMOVETABLEROWS Summary of this function goes here
%   Detailed explanation goes here
    % function cleanedTable = removeRowsByString(inputTable, targetString)
    % Remove rows with row names containing targetString from table and nested tables
    %
    % Inputs:
    %   inputTable - MATLAB table to process
    %   targetString - string to search for in row names
    %
    % Output:
    %   cleanedTable - table with matching rows removed
    
    % Make a copy of the input table
    cleanedTable = inputTable;
    
    % Remove rows where row names contain the target string
    if ~isempty(cleanedTable.Properties.RowNames)
        rowsToKeep = ~contains(cleanedTable.Properties.RowNames, targetString, 'IgnoreCase', true);
        cleanedTable = cleanedTable(rowsToKeep, :);
    end
    
    % Check each variable in the table for nested tables
    varNames = cleanedTable.Properties.VariableNames;
    
    for i = 1:length(varNames)
        currentVar = cleanedTable.(varNames{i});
        
        % If the variable is a cell array, check each cell for tables
        if iscell(currentVar)
            for j = 1:numel(currentVar)
                if istable(currentVar{j})
                    currentVar{j} = cgg_procRemoveTableRows(currentVar{j}, targetString);
                end
            end
            cleanedTable.(varNames{i}) = currentVar;
            
        % If the variable is directly a table, process it recursively
        elseif istable(currentVar)
            cleanedTable.(varNames{i}) = cgg_procRemoveTableRows(currentVar, targetString);
        end
    end
% end
end

