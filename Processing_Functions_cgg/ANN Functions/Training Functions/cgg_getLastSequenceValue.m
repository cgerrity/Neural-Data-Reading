function lastValue = cgg_getLastSequenceValue(DLArray)
%CGG_GETLASTSEQUENCEVALUE Returns the last time value from a sequence
%   Extracts the final element along the time ('T') dimension of a formatted 
%   dlarray. If the dlarray is unformatted or lacks a time dimension, the 
%   original array is returned.

arguments (Input)
    DLArray dlarray
end

arguments (Output)
    lastValue dlarray
end

% Extract the dimension labels of the dlarray
dimLabels = dims(DLArray);

% Check if the array is formatted and contains a time dimension 'T'
if ~isempty(dimLabels) && contains(dimLabels, 'T')
    % Find which dimension index corresponds to 'T'
    dimT = finddim(DLArray, 'T');
    
    % Initialize a cell array with ':' to index all existing dimensions
    idx = repmat({':'}, 1, max(ndims(DLArray), dimT));
    
    % Set the index for the 'T' dimension to its maximum length
    idx{dimT} = size(DLArray, dimT);
    
    % Extract the final sequence step
    extractedValue = DLArray(idx{:});
    
    %% -- Safely drop the physical dimension and apply your erase() logic --
    rawData = stripdims(extractedValue);
    
    % Calculate new size by explicitly dropping ONLY the dimT location
    sz = size(rawData);
    if length(sz) < dimT
        sz(end+1:dimT) = 1; % Pad in case dimT is a trailing singleton
    end
    sz(dimT) = []; % Physically drop the T dimension
    
    % MATLAB's reshape requires at least a 2D size vector
    if isempty(sz)
        sz = [1 1];
    elseif isscalar(sz)
        sz = [sz 1];
    end
    
    % Reconstruct the dlarray using your erase method
    lastValue = dlarray(reshape(rawData, sz), erase(dimLabels, 'T'));
    
else
    % Return the array unmodified if no 'T' dimension exists
    lastValue = DLArray;
end

end