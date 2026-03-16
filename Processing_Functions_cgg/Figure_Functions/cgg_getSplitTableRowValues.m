function TypeValues = cgg_getSplitTableRowValues(RowNames, TrialFilter)
%CGG_GETSPLITTABLEROWVALUES Summary of this function goes here
%   Takes RowNames (string array or cell array) and TrialFilter (cell array
%   of characters or string array), and extracts the numerical TypeValues 
%   that generated them.

    % Standardize TrialFilter input to cell array of characters
    if ischar(TrialFilter)
        TrialFilter = {TrialFilter};
    elseif isstring(TrialFilter)
        TrialFilter = cellstr(TrialFilter);
    end

    RowNames = string(RowNames);
    NumTypes = length(RowNames);
    NumColumns = length(TrialFilter);
    TypeValues = NaN(NumTypes, NumColumns);

    % Pre-build mapping definitions for each column
    FilterMaps = cell(1, NumColumns);
    for cidx = 1:NumColumns
        this_TrialFilter = TrialFilter{cidx};
        MapKeys = {};
        MapVals = [];

        switch this_TrialFilter
            case 'Dimensionality'
                MapKeys = {'1-D', '2-D', '3-D'};
                MapVals = [1, 2, 3];
            case 'Gain'
                MapKeys = {'Gain 2', 'Gain 3'};
                MapVals = [2, 3];
            case 'Loss'
                MapKeys = {'Loss -1', 'Loss -3'};
                MapVals = [-1, -3];
            case {'Correct Trial', 'Previous Trial', 'Previous Outcome Corrected', 'Previous'}
                MapKeys = {'Correct', 'Error'};
                MapVals = [1, 0];
            case 'Learned'
                MapKeys = {'Learned', 'Learning', 'Not Learned'};
                MapVals = [1, 0, -1];
            case 'All'
                MapKeys = {'Overall'};
                MapVals = 0;
            case 'Trials From Learning Point Category'
                MapKeys = {'Not Learned', 'fewer than 5', '-5 to -1', '0 to 9', '10 to 19', 'more than 20'};
                MapVals = [1, 2, 3, 4, 5, 6];
            case 'Multi Trials From Learning Point'
                try
                    [~,TrialBinName] = cgg_calcTrialsFromLPMultipleCategories([]);
                    MapKeys = TrialBinName;
                    MapVals = 1:length(TrialBinName);
                catch
                    warning('Could not load cgg_calcTrialsFromLPMultipleCategories for filter mapping.');
                end
            otherwise
                try
                    VariableInformation = PARAMETERS_cgg_VariableInformation(this_TrialFilter);
                    for vidx = 1:height(VariableInformation)
                        MapKeys{end+1} = char(VariableInformation.("Label")(vidx)); %#ok<AGROW>
                        MapVals(end+1) = double(VariableInformation.("Numeric Label")(vidx)); %#ok<AGROW>
                    end
                catch
                    % Ignore if function is not in path; will fallback to default pattern extraction
                end
        end

        % Sort MapKeys by length (longest first) to prevent partial matching bugs
        % (e.g., matching 'Learned' when the string is actually 'Not Learned')
        if ~isempty(MapKeys)
            [~, sortIdx] = sort(cellfun(@length, MapKeys), 'descend');
            FilterMaps{cidx}.Keys = MapKeys(sortIdx);
            FilterMaps{cidx}.Vals = MapVals(sortIdx);
        else
            FilterMaps{cidx}.Keys = {};
            FilterMaps{cidx}.Vals = [];
        end
    end

    % Parse each row string sequentially
    for tidx = 1:NumTypes
        % Convert to char for easier manipulation and shrinking
        remString = char(RowNames(tidx));

        for cidx = 1:NumColumns
            this_TrialFilter = TrialFilter{cidx};
            MapKeys = FilterMaps{cidx}.Keys;
            MapVals = FilterMaps{cidx}.Vals;
            
            matchFound = false;

            % 1. Try to match predefined literal labels
            for k = 1:length(MapKeys)
                % Regex: optional leading spaces/slashes, followed by the exact literal
                escapedKey = regexptranslate('escape', MapKeys{k});
                pattern = ['^\s*/?\s*', escapedKey];
                
                [startIdx, endIdx] = regexp(remString, pattern, 'once');
                
                if ~isempty(startIdx)
                    TypeValues(tidx, cidx) = MapVals(k);
                    remString(1:endIdx) = []; % Consume the matched portion
                    matchFound = true;
                    break;
                end
            end

            % 2. If no predefined label matched, try the default sprintf format
            if ~matchFound
                escapedFilter = regexptranslate('escape', this_TrialFilter);
                % Regex: matches "FilterName:NumericValue" formats optionally preceded by /
                pattern = ['^\s*/?\s*', escapedFilter, ':(-?\d+)'];
                
                [startIdx, endIdx, tokens] = regexp(remString, pattern, 'start', 'end', 'tokens', 'once');
                
                if ~isempty(startIdx)
                    TypeValues(tidx, cidx) = str2double(tokens{1});
                    remString(1:endIdx) = []; % Consume the matched portion
                else
                    warning('Could not parse column %d ("%s") from string: "%s"', cidx, this_TrialFilter, remString);
                end
            end
            
        end
    end
end