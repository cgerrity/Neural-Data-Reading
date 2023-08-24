function [Connected_Channels,Disconnected_Channels,Debugging_Info] = ...
    cgg_getDisconnectedChannelsIteration_v2(InData,NumReplicates,...
    InDistance,Start_Group,End_Group,Disconnected_Channels_GT,...
    Disconnected_Threshold,NumIterations)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%%

% Start_Group=2;
% End_Group=7;
% NumReplicates=10; %10
% InDistance='sqeuclidean';
% NumIterations=10;
% Disconnected_Channels_GT=60:64;

% Disconnected_Threshold=0.5;

[NumChannels,~]=size(InData{1});
All_Channels=1:NumChannels;

%%
NumGroups_Iter=length(Start_Group:End_Group);
Disconnected_Count=cell(1,NumIterations);

[~,PCA_SCORE_LFP,~,~] = fastpca(InData{1});
[~,PCA_SCORE_WB,~,~] = fastpca(InData{2});

%%

for tidx=1:NumIterations
    
Disconnected_Channels_LFP_iter=cell(1,NumGroups_Iter);
Disconnected_Channels_WB_iter=cell(1,NumGroups_Iter);
    
for idx=Start_Group:End_Group
    %%
NumGroups=idx;

[Group_Labels_LFP,~,~] = cgg_procChannelClustering_v4(InData{1},NumGroups,NumReplicates,InDistance{1},tidx,'PCA_SCORE',PCA_SCORE_LFP);
[Group_Labels_WB,~,~] = cgg_procChannelClustering_v4(InData{2},NumGroups,NumReplicates,InDistance{2},tidx,'PCA_SCORE',PCA_SCORE_WB);

Disconnected_GT_IDX_LFP=Group_Labels_LFP(Disconnected_Channels_GT);
Disconnected_GT_IDX_WB=Group_Labels_WB(Disconnected_Channels_GT);

% Find unique values and their counts
[uniqueValues_LFP, ~, indices_LFP] = unique(Group_Labels_LFP);
counts_LFP = histcounts(indices_LFP, 1:numel(uniqueValues_LFP)+1);
[uniqueValues_WB, ~, indices_WB] = unique(Group_Labels_WB);
counts_WB = histcounts(indices_WB, 1:numel(uniqueValues_WB)+1);

% Find values that appear only once
valuesAppearingOnce_LFP = uniqueValues_LFP(counts_LFP == 1);
valuesAppearingOnce_WB = uniqueValues_WB(counts_WB == 1);

Disconnected_GT_IDX_LFP=[Disconnected_GT_IDX_LFP;setdiff(valuesAppearingOnce_LFP,Disconnected_GT_IDX_LFP)];
Disconnected_GT_IDX_WB=[Disconnected_GT_IDX_WB;setdiff(valuesAppearingOnce_WB,Disconnected_GT_IDX_WB)];

Disconnected_Channels_LFP_iter{idx-Start_Group+1}=All_Channels(ismember(Group_Labels_LFP,Disconnected_GT_IDX_LFP));
Disconnected_Channels_WB_iter{idx-Start_Group+1}=All_Channels(ismember(Group_Labels_WB,Disconnected_GT_IDX_WB));
end
%%
Disconnected_Count{tidx}=[cell2mat(Disconnected_Channels_LFP_iter),cell2mat(Disconnected_Channels_WB_iter)];
end

Disconnected_Count_Combined=cell2mat({Disconnected_Count{:}});
Disconnected_Possible = unique(Disconnected_Count_Combined)';
Disconnected_Histogram = [Disconnected_Possible,...
    histc(Disconnected_Count_Combined(:),Disconnected_Possible)];

Disconnected_Histogram_Probability=[Disconnected_Histogram(:,1),Disconnected_Histogram(:,2)/(NumIterations*NumGroups_Iter*2)];

Disconnected_IDX=Disconnected_Possible(Disconnected_Histogram_Probability(:,2)>=Disconnected_Threshold);

Connected_Channels=setdiff(All_Channels,Disconnected_IDX);
Disconnected_Channels=All_Channels(Disconnected_IDX);

Debugging_Info.Disconnected_Count_Combined=Disconnected_Count_Combined;
Debugging_Info.Disconnected_Histogram=Disconnected_Histogram;
Debugging_Info.Disconnected_Histogram_Probability=Disconnected_Histogram_Probability;

end

