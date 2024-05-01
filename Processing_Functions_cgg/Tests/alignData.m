function [aligned_data, aligned_time] = alignData(data_cell, time_cell, sampling_rate)
    % Determine the minimum and maximum time points
    min_time = min(cellfun(@min, time_cell));
    max_time = max(cellfun(@max, time_cell));
    
    % Determine the length of the aligned time vector
    aligned_length = ceil((max_time - min_time) * sampling_rate);
    
    % Initialize the aligned data and time arrays
    aligned_data = NaN(length(data_cell), aligned_length);
    aligned_time = (0:aligned_length-1) / sampling_rate + min_time;
    
    % Iterate over each data array and align it according to time
    for i = 1:length(data_cell)
        % Get data and time for current cell
        data = data_cell{i};
        time = time_cell{i};
        
        % Find indices of aligned time corresponding to time vector
        [~, start_index] = min(abs(aligned_time - time(1)));
        [~, end_index] = min(abs(aligned_time - time(end)));
        
        % Update the aligned data array
        aligned_data(i, start_index:end_index) = data;
    end
end
