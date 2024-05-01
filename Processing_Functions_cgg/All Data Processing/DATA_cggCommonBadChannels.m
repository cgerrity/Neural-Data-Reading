%% DATA_cggAllSessionVariableAggregation

clc; clear; close all;

%%

MatNameExt='Clustering_Results.mat';
TargetName='Clustering_Results';
SessionSubDir='Activity';
SubAreaDir='Connected';
Folder='Variables';
SubFolder=SubAreaDir;

cgg_gatherMatVariableFromAllSessions(MatNameExt,TargetName,SessionSubDir,SubAreaDir,Folder,SubFolder);

%%

[cfg_Session] = DATA_cggAllSessionInformationConfiguration;

TargetDir=cfg_Session(1).outdatadir;

[cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Folder',Folder,...
                'SubFolder',SubFolder);

ClusteringDir=cfg.TargetDir.Aggregate_Data.Folder.SubFolder.path;

FolderContents=dir(ClusteringDir);
FolderContents([FolderContents.isdir])=[];

NumFiles=numel(FolderContents);

All_Disconnected=[];

for fidx=1:NumFiles

this_FilePathNameExt=[FolderContents(fidx).folder filesep FolderContents(fidx).name];

m_Clustering=matfile(this_FilePathNameExt,"Writable",false);

this_DisconnectedChannels=m_Clustering.Disconnected_Channels;

All_Disconnected=[All_Disconnected,this_DisconnectedChannels];

end

[Disconnected_Count,~]=histcounts(All_Disconnected,'BinMethod','integers');

CommonDisconnectedChannels=find(Disconnected_Count==NumFiles);

CommonNameExt='CommonBadChannels.mat';
CommonPathNameExt=[ClusteringDir filesep CommonNameExt];

m_CommonClustering=matfile(CommonPathNameExt,"Writable",true);
m_CommonClustering.CommonDisconnectedChannels=CommonDisconnectedChannels;


