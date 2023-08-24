function cgg_gatherImageFromSingleSession(SessionDir,Activity,ActivitySubFolders,ImageName,TargetDir,varargin)
%CGG_GATHERIMAGEFROMSINGLESESSION Summary of this function goes here
%   Detailed explanation goes here

%%
isfunction=exist('varargin','var');

if isfunction
[cfg] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,...
    'Activity',Activity,'ActivitySubFolders',ActivitySubFolders);
else
    Existence_Array = [exist('TargetDir','var'), ...
        exist('Activity','var'), exist('ActivitySubFolders','var')];
    Existence_Value = bi2de(Existence_Array, 'left-msb');
    
    switch Existence_Value
        case 7 % TargetDir, Activity, ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Activity',Activity,...
                'ActivitySubFolders',ActivitySubFolders);
        case 6 % TargetDir, Activity, ~ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Activity',Activity);
        case 5 % TargetDir, ~Activity, ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,...
                'ActivitySubFolders',ActivitySubFolders);
        case 4 % TargetDir, ~Activity, ~ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir);
        case 3 % ~TargetDir, Activity, ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'Activity',Activity,...
                'ActivitySubFolders',ActivitySubFolders);
        case 2 % ~TargetDir, Activity, ~ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'Activity',Activity);
        case 1 % ~TargetDir, ~Activity, ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'ActivitySubFolders',ActivitySubFolders);
        case 0 % ~TargetDir, ~Activity, ~ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
        otherwise
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
    end % End for what directory variables are in the workspace currently
end % End for whether this is being called within a function

%%

PlotDir=[SessionDir filesep 'Plots'];

% get the folder contents
Area_Folder = dir(PlotDir);
% remove all files (isdir property is 0)
Area_Folder = Area_Folder([Area_Folder(:).isdir]);
% remove '.' and '..' and the 'Connected' Folder
Area_Folder = Area_Folder(~ismember({Area_Folder(:).name},{'.','..','.DS_Store','Connected'}));

Area_Names={Area_Folder.name};

%%

[~,SessionName,~]=fileparts(SessionDir);

FolderNumber=1;
ActivitySubFolder_Field=sprintf('ActivitySubFolder_%d',FolderNumber);

TargetLocation=cfg.TargetDir.Aggregate_Data.Plots.Activity.(ActivitySubFolder_Field).path;

%%

for aidx=1:length(Area_Names)
    this_Area=Area_Names{aidx};
    this_AreaDir=[PlotDir filesep this_Area];
    this_ImageDir=[this_AreaDir filesep Activity filesep ActivitySubFolders{FolderNumber}];
    this_Image=sprintf([this_ImageDir filesep ImageName],this_Area);
    
    existImage=isfile(this_Image);
    
    [~,ImageSourceName,ImageExtension]=fileparts(this_Image);
    
    if existImage
        this_ImageTargetName=[SessionName,'-', ImageSourceName, ImageExtension];
        this_ImageTarget=[TargetLocation filesep this_ImageTargetName];
        copyfile(this_Image, this_ImageTarget);
    end
    
end


end

