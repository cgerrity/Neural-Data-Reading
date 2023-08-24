function [Connected_Channels,Disconnected_Channels,Debugging_Info] = ...
    cgg_getDisconnectedChannelsIteration(InData,NumReplicates,...
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

[NumChannels,~]=size(InData);
All_Channels=1:NumChannels;

%%
NumGroups_Iter=length(Start_Group:End_Group);
Disconnected_Count=cell(1,NumIterations);

%%

for tidx=1:NumIterations
    
Disconnected_Channels_iter=cell(1,NumGroups_Iter);
    
for idx=Start_Group:End_Group
NumGroups=idx;
[Group_Labels,~,~] = cgg_procChannelClustering_v3(InData,NumGroups,NumReplicates,InDistance);

Disconnected_GT_IDX=Group_Labels(Disconnected_Channels_GT);

% Find unique values and their counts
[uniqueValues, ~, indices] = unique(Group_Labels);
counts = histcounts(indices, 1:numel(uniqueValues)+1);

% Find values that appear only once
valuesAppearingOnce = uniqueValues(counts == 1);

Disconnected_GT_IDX=[Disconnected_GT_IDX;setdiff(valuesAppearingOnce,Disconnected_GT_IDX)];

Disconnected_Channels_iter{idx-Start_Group+1}=All_Channels(ismember(Group_Labels,Disconnected_GT_IDX));
end
Disconnected_Count{tidx}=cell2mat(Disconnected_Channels_iter);
end

Disconnected_Count_Combined=cell2mat({Disconnected_Count{:}});
Disconnected_Possible = unique(Disconnected_Count_Combined)';
Disconnected_Histogram = [Disconnected_Possible,...
    histc(Disconnected_Count_Combined(:),Disconnected_Possible)];

Disconnected_Histogram_Probability=[Disconnected_Histogram(:,1),Disconnected_Histogram(:,2)/(NumIterations*NumGroups_Iter)];

Disconnected_IDX=Disconnected_Possible(Disconnected_Histogram_Probability(:,2)>=Disconnected_Threshold);

Connected_Channels=setdiff(All_Channels,Disconnected_IDX);
Disconnected_Channels=All_Channels(Disconnected_IDX);

Debugging_Info.Disconnected_Count_Combined=Disconnected_Count_Combined;
Debugging_Info.Disconnected_Histogram=Disconnected_Histogram;
Debugging_Info.Disconnected_Histogram_Probability=Disconnected_Histogram_Probability;

end

