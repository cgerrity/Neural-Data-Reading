function cfg = cgg_generateNeuralPlottingCorrectErrorFolders(foldername,Field_Name,cfg)
%CGG_GENERATENEURALPLOTTINGCORRECTERRORFOLDERS Summary of this function goes here
%   Detailed explanation goes here


[cfg,~] = cgg_generateFolderAndPath(foldername,Field_Name,cfg);

cfg.(Field_Name) = cgg_generateFolderAndPath('Separate','Separate',cfg.(Field_Name));
cfg.(Field_Name) = cgg_generateFolderAndPath('Combined','Combined',cfg.(Field_Name));
cfg.(Field_Name) = cgg_generateFolderAndPath('Rewarded','Rewarded',cfg.(Field_Name));
cfg.(Field_Name) = cgg_generateFolderAndPath('Unrewarded','Unrewarded',cfg.(Field_Name));

end

