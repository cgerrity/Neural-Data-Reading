function cgg_gatherMatVariableFromSingleSession(MatNameExt,TargetName,SessionDir,SessionSubDir,SubAreaDir,Folder,SubFolder,TargetDir,varargin)
%CGG_GATHERIMAGEFROMSINGLESESSION Summary of this function goes here
%   Detailed explanation goes here

% MatNameExt is the name of the file to be copied. This can have a '%s' if
% there is area specific naming with the extension
% ex. 'Clustering_Results.mat'
% TargetName is the name of the file in the target location which is
% typically the same as the name above but without the extension
% ex. 'Clustering_Results'
% SessionDir the Absolute path to the overall session
% ex. '/Volumes/gerritcg's
% home/Data_Neural/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-13_003_01'
% SessionSubDir the relative path to the folder that leads to the variable
% split over each area
% ex. 'Activity'
% SubAreaDir the relative path to the matfile after going into a specific
% area
% ex. 'Connected'
% Folder and SubFolder refer to the organization of the file within Data
% Aggregate in TargetDir
% ex. 'Variables' and then 'Connected'

%%
isfunction=exist('varargin','var');

if isfunction
[cfg] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,...
    'Folder',Folder,'SubFolder',SubFolder);
else
    Existence_Array = [exist('TargetDir','var'), ...
        exist('Folder','var'), exist('SubFolder','var')];
    Existence_Value = bi2de(Existence_Array, 'left-msb');
    
    switch Existence_Value
        case 7 % TargetDir, Folder, SubFolder
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Folder',Folder,...
                'SubFolder',SubFolder);
        case 6 % TargetDir, Folder, ~SubFolder
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Folder',Folder);
        case 5 % TargetDir, ~Folder, SubFolder
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'SubFolder',SubFolder);
        case 4 % TargetDir, ~Folder, ~SubFolder
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir);
        case 3 % ~TargetDir, Folder, SubFolder
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'Folder',Folder,'SubFolder',SubFolder);
        case 2 % ~TargetDir, Folder, ~SubFolder
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'Folder',Folder);
        case 1 % ~TargetDir, ~Folder, SubFolder
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'SubFolder',SubFolder);
        case 0 % ~TargetDir, ~Folder, ~SubFolder
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
        otherwise
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
    end % End for what directory variables are in the workspace currently
end % End for whether this is being called within a function

%%

AreasDir=[SessionDir filesep SessionSubDir];

% get the folder contents
Area_Folder = dir(AreasDir);
% remove all files (isdir property is 0)
Area_Folder = Area_Folder([Area_Folder(:).isdir]);
% remove '.' and '..' and the 'Connected' Folder
Area_Folder = Area_Folder(~ismember({Area_Folder(:).name},{'.','..','.DS_Store','Connected'}));

Area_Names={Area_Folder.name};

%%

[~,SessionName,~]=fileparts(SessionDir);

TargetPath=cfg.TargetDir.Aggregate_Data.Folder.SubFolder.path;

[~,MatName,MatExt]=fileparts(MatNameExt);

TargetNameExt=[TargetName '_%s' MatExt];

%%

for aidx=1:length(Area_Names)
    this_Area=Area_Names{aidx};
    this_AreaDir=[AreasDir filesep this_Area];
    if isempty(SubAreaDir)
    this_MatPath=this_AreaDir;
    else
    this_MatPath=[this_AreaDir filesep SubAreaDir];
    end

    this_MatNameExt=sprintf(MatNameExt,this_Area);
    this_MatPathNameExt=[this_MatPath filesep this_MatNameExt];

    this_TargetNameExt=[SessionName,'-',sprintf(TargetNameExt,this_Area)];
    this_TargetPathNameExt=[TargetPath filesep this_TargetNameExt];
    
    existMat=isfile(this_MatPathNameExt);
    
    if existMat
        copyfile(this_MatPathNameExt, this_TargetPathNameExt);
    end
    
end


end

