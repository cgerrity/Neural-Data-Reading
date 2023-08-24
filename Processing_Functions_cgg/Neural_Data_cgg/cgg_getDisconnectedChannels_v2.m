function [Connected_Channels,Disconnected_Channels,is_previously_rereferenced] = cgg_getDisconnectedChannels_v2(Trial_Numbers,Count_Sel_Trial,fullfilename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumTrials=length(Trial_Numbers);
%%
if Count_Sel_Trial>NumTrials
    Count_Sel_Trial=NumTrials;
end

Trial_Permutation=randperm(NumTrials);
Trial_Numbers_Permute=Trial_Numbers(Trial_Permutation);
Sel_Trial=Trial_Numbers_Permute(1:Count_Sel_Trial);
Sel_Trial=sort(Sel_Trial);

InData=cell(1,Count_Sel_Trial);
is_previously_rereferenced=zeros(1,Count_Sel_Trial);
parfor tidx=1:length(Sel_Trial)
    this_tidx=Sel_Trial(tidx);
    
this_recdata=load(sprintf(fullfilename,this_tidx));
this_recdata_Field_Names=fieldnames(this_recdata);
this_recdata=this_recdata.(this_recdata_Field_Names{1});

is_previously_rereferenced(tidx)=cgg_checkFTRereference(this_recdata);

InData{tidx}=this_recdata.trial{1};

end

is_previously_rereferenced=any(is_previously_rereferenced);

InData=cell2mat(InData);
%%
% NumGroups=10;
NumReplicates=10; %10
InDistance='sqeuclidean';

Start_Group=2;
End_Group=15;
NumIterations=length(Start_Group:End_Group);

Connected_Channels_iter=cell(1,NumIterations);
Disconnected_Channels_iter=cell(1,NumIterations);

for idx=Start_Group:End_Group
NumGroups=idx;
[Group_Labels,~,~] = cgg_procChannelClustering(InData,NumGroups,NumReplicates,InDistance);

NumChannels=length(Group_Labels);
Disconnected_IDX_iter=Group_Labels(NumChannels-4:NumChannels);
% Connected_IDX=mode(Group_Labels);

All_Channels=1:NumChannels;

% Connected_Channels=All_Channels(~ismember(Group_Labels,Disconnected_IDX));
% Disconnected_Channels=All_Channels(ismember(Group_Labels,Disconnected_IDX));
Connected_Channels_iter{idx-Start_Group+1}=All_Channels(~ismember(Group_Labels,Disconnected_IDX_iter));
Disconnected_Channels_iter{idx-Start_Group+1}=All_Channels(ismember(Group_Labels,Disconnected_IDX_iter));
end

Disconnected_Count=cell2mat(Disconnected_Channels_iter);
Disconnected_Possible = unique(Disconnected_Count)';
Disconnected_Histogram = [Disconnected_Possible,...
    histc(Disconnected_Count(:),Disconnected_Possible)];

Disconnected_IDX=Disconnected_Possible(Disconnected_Histogram(:,2)/NumIterations>0.5);

Connected_Channels{aidx}=All_Channels(~Disconnected_IDX);
Disconnected_Channels{aidx}=All_Channels(Disconnected_IDX);

end

