function DirPath = cgg_getDirectory(cfg,DirectoryName)
%CGG_GETDIRECTORY Summary of this function goes here
%   Detailed explanation goes here

this_FieldNames = fieldnames(cfg);

for idx = 1:length(this_FieldNames)
    this_FieldName = this_FieldNames{idx};
    this_cfg = cfg.(this_FieldName);
    if ~isstruct(this_cfg)
        DirPath = [];
    elseif strcmp(this_FieldName,DirectoryName)
        DirPath = this_cfg.path;
        return
    else
        DirPath = cgg_getDirectory(this_cfg,DirectoryName);
    end
    if ~isempty(DirPath)
        return
    end
end


end

