function [Connected_Channels,Disconnected_Channels,is_any_previously_rereferenced] = cgg_loadChannelClusteringFromDirectories(cfg)
%cgg_loadChannelClusteringFromDirectories Summary of this function goes here
%   Detailed explanation goes here
this_area_clustering_file_name=...
    [cfg.outdatadir.Experiment.Session.Activity.Area.Connected.path ...
    filesep 'Clustering_Results.mat'];

m_Cluster = matfile(this_area_clustering_file_name,'Writable',true);
    Connected_Channels=m_Cluster.Connected_Channels;
    Disconnected_Channels=m_Cluster.Disconnected_Channels;
    is_any_previously_rereferenced=m_Cluster.is_any_previously_rereferenced;
    
end

