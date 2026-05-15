function DirPath = cgg_getDirectory(cfg, DirectoryName, ParentBranch)
%CGG_GETDIRECTORY Retrieves a directory path from a nested struct.
%   Optionally specify a ParentBranch to restrict the search.

    % 1. Handle optional arguments: Default to empty if not provided
    if nargin < 3
        ParentBranch = '';
    end
    
    DirPath = [];
    
    % 2. MODE A: Searching for a specific Parent Branch first
    if ~isempty(ParentBranch)
        % Check if the current level contains the specified parent branch
        if isfield(cfg, ParentBranch) && isstruct(cfg.(ParentBranch))
            % We found the branch! Now search exclusively inside it.
            % We drop the 3rd argument so it switches to standard search mode.
            DirPath = cgg_getDirectory(cfg.(ParentBranch), DirectoryName);
            return;
        end
        
        % If not found at this level, recursively search for the ParentBranch
        this_FieldNames = fieldnames(cfg);
        for idx = 1:length(this_FieldNames)
            this_cfg = cfg.(this_FieldNames{idx});
            if isstruct(this_cfg)
                DirPath = cgg_getDirectory(this_cfg, DirectoryName, ParentBranch);
                if ~isempty(DirPath)
                    return;
                end
            end
        end
        
        % If we finish this loop and didn't find the parent, exit this branch
        return; 
    end
    
    % 3. MODE B: Standard Search (Your original logic)
    this_FieldNames = fieldnames(cfg);
    for idx = 1:length(this_FieldNames)
        this_FieldName = this_FieldNames{idx};
        this_cfg = cfg.(this_FieldName);
        
        % Improvement: Use 'continue' to skip non-structs cleanly
        if ~isstruct(this_cfg)
            continue; 
            
        elseif strcmp(this_FieldName, DirectoryName)
            % Improvement: Safety check to ensure 'path' actually exists
            if isfield(this_cfg, 'path')
                DirPath = this_cfg.path;
            else
                DirPath = []; 
            end
            return;
            
        else
            % Recurse deeper
            DirPath = cgg_getDirectory(this_cfg, DirectoryName);
        end
        
        if ~isempty(DirPath)
            return;
        end
    end
end