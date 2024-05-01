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


