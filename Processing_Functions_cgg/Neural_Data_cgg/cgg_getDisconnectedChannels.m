function [Connected_Channels,Disconnected_Channels,is_previously_rereferenced] = cgg_getDisconnectedChannels(NumTrials,Count_Sel_Trial,fullfilename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if Count_Sel_Trial>NumTrials
    Count_Sel_Trial=NumTrials;
end

Trial_Permutation=randperm(NumTrials);
Sel_Trial=Trial_Permutation(1:Count_Sel_Trial);
Sel_Trial=sort(Sel_Trial);

InData=cell(1,Count_Sel_Trial);
is_previously_rereferenced=zeros(1,Count_Sel_Trial);
parfor tidx=1:length(Sel_Trial)
    this_tidx=Sel_Trial(tidx);
recdata_wideband=load(sprintf(fullfilename,this_tidx));
recdata_wideband=recdata_wideband.this_recdata_wideband;

is_previously_rereferenced(tidx)=cgg_checkFTRereference(recdata_wideband);

InData{tidx}=recdata_wideband.trial{1};

end

is_previously_rereferenced=any(is_previously_rereferenced);

InData=cell2mat(InData);

NumGroups=2;
NumReplicates=10;
InDistance='sqeuclidean';

[Group_Labels,~,~] = cgg_procChannelClustering(InData,NumGroups,NumReplicates,InDistance);

NumChannels=length(Group_Labels);
Connected_IDX=mode(Group_Labels);

All_Channels=1:NumChannels;

Connected_Channels=All_Channels((Group_Labels==Connected_IDX));
Disconnected_Channels=All_Channels(~(Group_Labels==Connected_IDX));

end

