function FileAge = cgg_getFileAge(FileName, timeUnit)
    % Function to calculate the age of a file
    % 
    % Usage: FileAge = getFileAge(FileName, timeUnit)
    % Inputs: 
    %   - FileName: Name of the file as a string
    %   - timeUnit: Optional argument to define the time unit ('seconds', 'minutes', 'hours', 'days')
    % Outputs:
    %   - FileAge: Age of the file in specified time units

    FileAge = NaN;
    % Default time unit
    if nargin < 2
        timeUnit = 'days';
    end

    % Get file information
    fileInfo = dir(FileName);

    if isempty(fileInfo)
        % error('File not found.');
        return
    end

    % Retrieve the date of the last modification
    modificationDatetime = datetime(fileInfo.datenum, 'ConvertFrom', 'datenum');
    
    % Current date
    currentDatetime = datetime('now');

    % Calculate the age of the file in days
    timeDifference = currentDatetime - modificationDatetime;

    % Convert to specified time unit
    switch lower(timeUnit)
        case 'seconds'
            FileAge = seconds(timeDifference);
        case 'minutes'
            FileAge = minutes(timeDifference);
        case 'hours'
            FileAge = hours(timeDifference);
        case 'days'
            FileAge = days(timeDifference);
        otherwise
            error('Invalid time unit. Choose "seconds", "minutes", "hours", or "days".');
    end
end