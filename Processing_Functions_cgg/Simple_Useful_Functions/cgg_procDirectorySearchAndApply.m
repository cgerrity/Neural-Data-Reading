function aggregatedResult = cgg_procDirectorySearchAndApply(folderPath, fileName, funcHandle,varargin)
%CGG_PROCDIRECTORYSEARCHANDAPPLY Summary of this function goes here
%   Detailed explanation goes here
% function aggregatedResult = searchAndAggregate(folderPath, fileName, funcHandle, initialResult)
    % searchAndAggregate - Search for a specific file in a folder and
    % subfolders, and aggregate results using a function.
    %
    % Inputs:
    %   folderPath    - Path to the root folder where the search begins
    %   fileName      - Name of the file to search for
    %   funcHandle    - Handle to a function to apply to the directory and file
    %                   (the function should take current aggregate result and
    %                   update it)
    %   initialResult - The initial result that will be passed to the function
    %                   handle for aggregation (e.g., an empty table)
    %
    % Output:
    %   aggregatedResult - The result after aggregating across all files found
    %
    % Example usage:
    %   finalTable = searchAndAggregate('C:\example_folder', 'data.csv', @myAggregateFunction, initialTable)

isfunction=exist('varargin','var');

if isfunction
IsSingleLevel = CheckVararginPairs('IsSingleLevel', false, varargin{:});
else
if ~(exist('IsSingleLevel','var'))
IsSingleLevel=false;
end
end


    % Initialize the aggregated result with the initial input
    aggregatedResult = [];

    % Get the list of all files and folders in the folder and subfolders
    if IsSingleLevel
        filesAndFolders = dir(fullfile(folderPath, '*', fileName));
    else
        filesAndFolders = dir(fullfile(folderPath, '**', fileName));
    end

    % If no matching files are found, return the initial result
    if isempty(filesAndFolders)
        % disp('No files found.');
        return;
    end
    
    % Loop through each found file
    for i = 1:length(filesAndFolders)
        % Get the folder containing the file
        folderContainingFile = filesAndFolders(i).folder;
        fullFilePath = fullfile(folderContainingFile, filesAndFolders(i).name);
        
        % If a function handle is provided, apply the function to the file
        if nargin > 2 && isa(funcHandle, 'function_handle')
            % Update the aggregated result by calling the function
            % disp('FileNumber')
            % disp(fullFilePath);
            aggregatedResult = funcHandle(aggregatedResult, fullFilePath);
        end
    end
end



