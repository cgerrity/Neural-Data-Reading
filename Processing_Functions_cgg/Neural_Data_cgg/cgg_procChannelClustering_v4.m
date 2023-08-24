function [Group_Labels,Group_Distance,SCORE] = cgg_procChannelClustering_v4(InData,NumGroups,NumReplicates,InDistance,NumComponents,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

PCA_SCORE = CheckVararginPairs('PCA_SCORE', '', varargin{:});

stream = RandStream('mlfg6331_64');  % Random number stream
opts = statset('UseParallel',1,'UseSubstreams',1,...
    'Streams',stream,'Display','off');

InPerplexity=60; % 30 45
InExaggeration=1; % 2 2
% InDistancetsne='seuclidean'; % seuclidean seuclidean
InDistancetsne='cosine'; % seuclidean seuclidean
InLearnRate=100; % 250 250
%%

if ~exist('PCA_SCORE','var')
[~,SCORE,~,~] = fastpca(InData);
PCA_SCORE=SCORE;
else
SCORE=PCA_SCORE;
end

[Group_Labels,~,~,Group_Distance] = kmeans(SCORE(:,1:NumComponents),NumGroups,'Distance',InDistance,...
    'Replicates',NumReplicates,'Options',opts);



end

