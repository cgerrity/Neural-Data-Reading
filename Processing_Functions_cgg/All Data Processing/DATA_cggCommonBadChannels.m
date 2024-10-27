%% DATA_cggAllSessionVariableAggregation

clc; clear; close all;

%%

wantDisconnected = false;
wantRegression = true;

% % MatNameExt='Clustering_Results.mat';
% MatNameExt='Regression_Results.mat';
% % TargetName='Clustering_Results';
% TargetName='Regression_Results';
% % SessionSubDir='Activity';
% SessionSubDir='Regression';
% % SubAreaDir='Connected';
% SubAreaDir='';
% Folder='Variables';
% % SubFolder=SubAreaDir;
% SubFolder=SessionSubDir;

if wantDisconnected
MatNameExt='Clustering_Results.mat';
TargetName='Clustering_Results';
SessionSubDir='Activity';
SubAreaDir='Connected';
SubFolder=SubAreaDir;
elseif wantRegression
MatNameExt='Regression_Results.mat';
TargetName='Regression_Results';
SessionSubDir='Regression';
SubAreaDir='';
SubFolder=SessionSubDir;
end

Folder='Variables';

%%

cgg_gatherMatVariableFromAllSessions(MatNameExt,TargetName,SessionSubDir,SubAreaDir,Folder,SubFolder);

%%

[cfg_Session] = DATA_cggAllSessionInformationConfiguration;

TargetDir=cfg_Session(1).outdatadir;

[cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Folder',Folder,...
                'SubFolder',SubFolder);

VariableDir=cfg.TargetDir.Aggregate_Data.Folder.SubFolder.path;
SummaryDir=[cfg.TargetDir.Aggregate_Data.Folder.path filesep 'Summary'];

FolderContents=dir(VariableDir);
FolderContents([FolderContents.isdir])=[];

NumFiles=numel(FolderContents);

if wantDisconnected
All_Disconnected=[];
elseif wantRegression
All_NotSignificant = [];
end

for fidx=1:NumFiles

this_FilePathNameExt=[FolderContents(fidx).folder filesep FolderContents(fidx).name];

m_Variable=matfile(this_FilePathNameExt,"Writable",false);

if wantDisconnected
this_DisconnectedChannels=m_Variable.Disconnected_Channels;
All_Disconnected=[All_Disconnected,this_DisconnectedChannels];
elseif wantRegression
this_NotSignificant=m_Variable.NotSignificant_Channels;
All_NotSignificant=[All_NotSignificant,this_NotSignificant];
end

end

if wantDisconnected
[Disconnected_Count,~]=histcounts(All_Disconnected,'BinMethod','integers');
CommonDisconnectedChannels=find(Disconnected_Count==NumFiles);
All_DisconnectedPerProbe = numel(All_Disconnected)/NumFiles;

CommonNameExt='BadChannels.mat';
CommonPathNameExt=[SummaryDir filesep CommonNameExt];
BadChannelsSavePathNameExt=[SummaryDir filesep CommonNameExt];

BadChannelsSaveVariables={CommonDisconnectedChannels,All_Disconnected,All_DisconnectedPerProbe};
BadChannelsSaveVariablesName={'CommonDisconnectedChannels','All_Disconnected','All_DisconnectedPerProbe'};
cgg_saveVariableUsingMatfile(BadChannelsSaveVariables,BadChannelsSaveVariablesName,BadChannelsSavePathNameExt);

elseif wantRegression
[NotSignificant_Count,~]=histcounts(All_NotSignificant,'BinMethod','integers');
CommonNotSignificant=find(NotSignificant_Count==NumFiles);
All_NotSignificantPerProbe = numel(All_NotSignificant)/NumFiles;

NotSignificantNameExt='NotSignificantChannels.mat';
NotSignificantPathNameExt=[SummaryDir filesep NotSignificantNameExt];
NotSignificantSavePathNameExt=[SummaryDir filesep NotSignificantNameExt];

NotSignificantSaveVariables={CommonNotSignificant,All_NotSignificant,All_NotSignificantPerProbe};
NotSignificantSaveVariablesName={'CommonNotSignificant','All_NotSignificant','All_NotSignificantPerProbe'};
cgg_saveVariableUsingMatfile(NotSignificantSaveVariables,NotSignificantSaveVariablesName,NotSignificantSavePathNameExt);
end
% m_CommonClustering=matfile(CommonPathNameExt,"Writable",true);
% m_CommonClustering.CommonDisconnectedChannels=CommonDisconnectedChannels;
