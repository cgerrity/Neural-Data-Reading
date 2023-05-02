function [cfg,outdatadir] = cgg_generateFolderAndPath(foldername,Field_Name,cfg)
%CGG_GENERATEFOLDERANDPATH Summary of this function goes here
%   Detailed explanation goes here
outdatadir=[cfg.path, filesep, foldername];
cfg.(Field_Name).path=outdatadir;

if ~exist(outdatadir, 'dir')
    mkdir(outdatadir);
end
end

