function FolderName = cgg_getDynamicFolderName(DynStructName, DynStruct)
% CGG_GETDYNAMICFOLDERNAME Generates a formatted folder name representing
% the dynamic parameter schedule for a given dynamic structure.
%
% Inputs:
%   DynStructName - String representing the name of the structure 
%                   (e.g., "DynamicWeighting", "DynamicFreezing")
%   DynStruct     - The structure containing the actual epoch and magnitude schedules
%
% Output:
%   FolderName    - Formatted string following the convention:
%                   "GroupName - {Param1 - [E1,E2_M1,M2] ~ Param2 - []}"
%                   or "GroupName - {All - [E1,E2_M1,M2]}" for global schedules.

    % Determine a clean Group Name based on the struct name
    switch string(DynStructName)
        case "DynamicWeighting"
            GroupName = "Wgt";
        case "DynamicFreezing"
            GroupName = "Frz";
        case "DynamicAugmentation"
            GroupName = "Aug";
        otherwise
            GroupName = erase(string(DynStructName), "Dynamic");
    end

    % Check if the struct is entirely empty
    IsEmpty = isempty(fieldnames(DynStruct));
    Parts = {};

    if IsEmpty
        % No dynamic parameters set at all
        Parts{1} = 'None';
    else
        % If 'EpochPoints' is at the root level, it is a global schedule
        HasIndividual = ~isfield(DynStruct, 'EpochPoints');
        
        if ~HasIndividual
            % Global schedule (root level EpochPoints/MagnitudePoints)
            if isfield(DynStruct, 'EpochPoints') && ~isempty(DynStruct.EpochPoints)
                E = DynStruct.EpochPoints;
                M = DynStruct.MagnitudePoints;
                valStr = sprintf('[%s]_[%s]', formatArray(E), formatMagnitudeArray(M));
                Parts{1} = sprintf('All-%s', valStr);
            else
                Parts{1} = 'None';
            end
        else
            % Individual parameters defined - STRICTLY use what is in the struct
            fields = fieldnames(DynStruct);
            for i = 1:numel(fields)
                fName = string(fields{i});
                
                % ONLY append to string if the schedule actually exists
                if isfield(DynStruct.(fName), 'EpochPoints') && ~isempty(DynStruct.(fName).EpochPoints)
                    E = DynStruct.(fName).EpochPoints;
                    M = DynStruct.(fName).MagnitudePoints;
                    valStr = sprintf('[%s]_[%s]', formatArray(E), formatMagnitudeArray(M));
                    
                    % Abbreviate common long parameter names to save path space
                    fShort = strrep(fName, 'Reconstruction', 'Recon');
                    fShort = strrep(fShort, 'Classification', 'Class');
                    fShort = strrep(fShort, 'ChannelOffset', 'ChanOff');
                    fShort = strrep(fShort, 'WhiteNoise', 'Noise');
                    fShort = strrep(fShort, 'RandomWalk', 'Walk');
                    fShort = strrep(fShort, 'TimeShift', 'Shift');
                    fShort = strrep(fShort, 'Classifier', 'Clf');
                    fShort = strrep(fShort, 'Encoder', 'Enc');
                    fShort = strrep(fShort, 'Decoder', 'Dec');
                    
                    Parts{end+1} = sprintf('%s-%s', fShort, valStr); %#ok<AGROW>
                end
            end
            
            % If all individual parameters were checked but were empty
            if isempty(Parts)
                Parts{1} = 'None';
            end
        end
    end

    % Join all parts with the requested delimiter and wrap in braces
    InnerStr = strjoin(Parts, '~');
    FolderName = sprintf('%s-{%s}', GroupName, InnerStr);
end

%% Helper Function
function s = formatArray(arr)
    % Formats an array to a succinct comma-separated string 
    % e.g., [100 200] -> 100,200
    
    if isempty(arr)
        s = '';
    else
        s = mat2str(arr);
        s = strrep(s, ' ', ',');  % Replace spaces with commas
        s = strrep(s, ';', ',');  % Handle column vectors safely
        s = strrep(s, '[', '');   % Remove brackets
        s = strrep(s, ']', '');
    end
end

function s = formatMagnitudeArray(arr)
    % Formats an array to scientific notation with 1 decimal place
    % e.g., [1 0.0001] -> 1.0e0,1.0e-4
    
    if isempty(arr)
        s = '';
    else
        % Flatten to row vector to ensure strjoin works cleanly
        arr = arr(:)';
        
        % Apply sprintf to each element to force scientific notation
        strCells = arrayfun(@(x) sprintf('%.1e', x), arr, 'UniformOutput', false);
        s = strjoin(strCells, ',');
        
        % Clean up the exponent format (e.g., 'e+00' -> 'e0', 'e-04' -> 'e-4')
        % This strips out the plus sign and leading zeros in the exponent
        s = regexprep(s, 'e\+0*(\d+)', 'e$1'); 
        s = regexprep(s, 'e\-0*(\d+)', 'e-$1');
    end
end