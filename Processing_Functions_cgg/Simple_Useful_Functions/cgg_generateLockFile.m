function [success, lockFileName] = cgg_generateLockFile(FileName, FileContent)
% CGG_GENERATELOCKFILE Creates a lock file to prevent concurrent access
%
%   [SUCCESS, LOCKFILENAME] = CGG_GENERATELOCKFILE(FILENAME, FILECONTENT)
%   
%   Inputs:
%       FILENAME    - Name of the file to be locked (without .lock extension)
%       FILECONTENT - Text to include in the lock file explaining its purpose
%   
%   Outputs:
%       SUCCESS     - Boolean indicating if the lock was successfully created
%       LOCKFILENAME - Full name of the created lock file
%
%   Example:
%       [success, lockFile] = cgg_generateLockFile('data.mat', 'Processing data file');
%       if success
%           try
%               % Work with data.mat here
%               disp('Processing data...');
%               % Your processing code here
%           catch ME
%               disp(['Error occurred: ' ME.message]);
%           end
%           
%           % Clean up the lock file after processing (whether successful or not)
%           if exist(lockFile, 'file')
%               delete(lockFile);
%           end
%       else
%           disp('File is already being processed by another session');
%       end

    % Generate lock file name
    FileName = char(FileName);
    lockFileName = [FileName, '.lock'];
    success = false;
    
    % Check if lock file already exists
    if exist(lockFileName, 'file')
        % Lock file exists, cannot create a new one
        return;
    end
    
    try
        % Create temporary unique filename to avoid race conditions
        tempLockFile = [lockFileName, '_temp_', num2str(randi(1000000))];
        
        % Write to temporary file first
        lockFid = fopen(tempLockFile, 'w');
        if lockFid == -1
            % Couldn't open file for writing
            return;
        end
        
        % Add process info and timestamp to the content
        content = sprintf('%s\nLocked by MATLAB process ID: %d\nTime: %s\n', ...
            FileContent, feature('getpid'), datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        
        % Write the content
        fprintf(lockFid, '%s', content);
        
        % Close the file
        fclose(lockFid);
        
        % Attempt to rename temp file to actual lock file
        % This provides atomicity in file creation
        if exist(lockFileName, 'file')
            % Another process created the lock file in the meantime
            delete(tempLockFile);
            success = false;
        else
            [status, message] = movefile(tempLockFile, lockFileName);
            if status == 1
                success = true;
            else
                warning('Failed to create lock file: %s', message);
                if exist(tempLockFile, 'file')
                    delete(tempLockFile);
                end
                success = false;
            end
        end
        
    catch ME
        % If any error occurs, ensure we return false
        success = false;
        
        % Clean up temporary file if it exists
        if exist('tempLockFile', 'var') && exist(tempLockFile, 'file')
            delete(tempLockFile);
        end
        
        % Optional: For debugging purposes
        warning(ME.identifier,'Failed to create lock file: %s', ME.message);
    end
end