function cfg = cgg_generateNeuralPlottingCorrectErrorFolders(foldername,Field_Name,cfg,varargin)
%CGG_GENERATENEURALPLOTTINGCORRECTERRORFOLDERS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});
else
if ~(exist('WantDirectory','var'))
WantDirectory=true;
end
end

[cfg,~] = cgg_generateFolderAndPath(foldername,Field_Name,cfg,'WantDirectory',WantDirectory);

cfg.(Field_Name) = cgg_generateFolderAndPath('Separate','Separate',cfg.(Field_Name),'WantDirectory',WantDirectory);
cfg.(Field_Name) = cgg_generateFolderAndPath('Combined','Combined',cfg.(Field_Name),'WantDirectory',WantDirectory);
cfg.(Field_Name) = cgg_generateFolderAndPath('Rewarded','Rewarded',cfg.(Field_Name),'WantDirectory',WantDirectory);
cfg.(Field_Name) = cgg_generateFolderAndPath('Unrewarded','Unrewarded',cfg.(Field_Name),'WantDirectory',WantDirectory);

end

