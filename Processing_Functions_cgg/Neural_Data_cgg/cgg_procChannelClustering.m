function [Group_Labels,Data_Reduced,Group_Distance] = cgg_procChannelClustering(InData,NumGroups,NumReplicates,InDistance)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

stream = RandStream('mlfg6331_64');  % Random number stream
opts = statset('UseParallel',1,'UseSubstreams',1,...
    'Streams',stream,'Display','off');
[Group_Labels,~,~,Group_Distance] = kmeans(InData,NumGroups,'Distance',InDistance,...
    'Replicates',NumReplicates,'Options',opts);

% NumChannels=length(Group_Labels);

InPerplexity=60; % 30 45
InExaggeration=1; % 2 2
InDistancetsne='seuclidean'; % seuclidean seuclidean
InLearnRate=100; % 250 250

Data_Reduced = tsne(InData,'Algorithm','barneshut','Distance',InDistancetsne,'Exaggeration',InExaggeration,'Perplexity',InPerplexity,'LearnRate',InLearnRate);
end

