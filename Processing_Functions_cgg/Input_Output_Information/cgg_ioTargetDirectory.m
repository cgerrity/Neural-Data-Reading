function [TargetDir] = cgg_ioTargetDirectory(varargin)
%CGG_IOTARGETDIRECTORY Summary of this function goes here
%   Detailed explanation goes here
%%
isfunction=exist('varargin','var');

if isfunction
TargetDir = CheckVararginPairs('TargetDir', '', varargin{:});
if isempty(TargetDir)
    TargetDir = uigetdir(['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'], 'Choose the target folder');
end
else
    TargetDir = uigetdir(['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'], 'Choose the target folder');
end

end

