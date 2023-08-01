function [Group_Labels,Data_Reduced,Group_Distance] = cgg_procChannelClustering_v3(InData,NumGroups,NumReplicates,InDistance)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

stream = RandStream('mlfg6331_64');  % Random number stream
opts = statset('UseParallel',1,'UseSubstreams',1,...
    'Streams',stream,'Display','off');

InPerplexity=60; % 30 45
InExaggeration=1; % 2 2
InDistancetsne='seuclidean'; % seuclidean seuclidean
InLearnRate=100; % 250 250
%%


Data_Reduced = tsne(InData,'Algorithm','barneshut','Distance',InDistancetsne,'Exaggeration',InExaggeration,'Perplexity',InPerplexity,'LearnRate',InLearnRate,'NumDimensions',2);

[Group_Labels,~,~,Group_Distance] = kmeans(Data_Reduced,NumGroups,'Distance',InDistance,...
    'Replicates',NumReplicates,'Options',opts);



end

