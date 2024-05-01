% Sample data and time arrays
data1 = randn(1, numel(-1.5:0.01:-1.41)); % Example data array 1
time1 = -1.5:0.01:-1.41; % Corresponding time points for data array 1

data2 = randn(1, numel(-1.45:0.01:-1.21)); % Example data array 2
time2 = -1.45:0.01:-1.21; % Corresponding time points for data array 2

% Ensure consistency in data and time lengths
if numel(data1) ~= numel(time1)
    error('Data1 and Time1 lengths do not match.');
end

if numel(data2) ~= numel(time2)
    error('Data2 and Time2 lengths do not match.');
end

% Align the data arrays
[aligned_data, aligned_time] = alignData({data1, data2}, {time1, time2}, 100); % 100 Hz sampling rate

% Display the aligned data and time
disp('Aligned Data:');
disp(aligned_data);
disp('Aligned Time:');
disp(aligned_time);
