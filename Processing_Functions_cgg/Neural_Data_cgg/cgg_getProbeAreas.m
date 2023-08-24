function Area_Names = cgg_getProbeAreas(SessionDir)
%CGG_GETPROBEAREAS Summary of this function goes here
%   Detailed explanation goes here
ActivityDir=[SessionDir filesep 'Activity'];

% get the folder contents
Area_Folder = dir(ActivityDir);
% remove all files (isdir property is 0)
Area_Folder = Area_Folder([Area_Folder(:).isdir]);
% remove '.' and '..' and the 'Connected' Folder
Area_Folder = Area_Folder(~ismember({Area_Folder(:).name},{'.','..','.DS_Store','Connected'}));

Area_Names={Area_Folder.name};
end

