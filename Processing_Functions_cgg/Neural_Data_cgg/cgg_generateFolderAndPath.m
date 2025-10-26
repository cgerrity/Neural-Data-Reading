function [cfg,outdatadir] = cgg_generateFolderAndPath(foldername,Field_Name,cfg,varargin)
%CGG_GENERATEFOLDERANDPATH Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=true;
end
end
%%
% outdatadir=[cfg.path, filesep, foldername];
outdatadir=fullfile(cfg.path,foldername);
cfg.(Field_Name).path=outdatadir;

if WantDirectory
if ~exist(outdatadir, 'dir')
    mkdir(outdatadir);
end
end
end

