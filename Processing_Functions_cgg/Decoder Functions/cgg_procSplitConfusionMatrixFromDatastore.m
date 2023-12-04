function [Window_Accuracy,Accuracy,Window_CM,Full_CM,AllSplits] = cgg_procSplitConfusionMatrixFromDatastore(InDatastore,Mdl,ClassNames,SplitValue)
%CGG_PROCSPLITCONFUSIONMATRIXFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

InDatastore_tmp=InDatastore;

FeatureDimension = 3; %Color

switch SplitValue
    case 'Dimension'
Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',FeatureDimension);
    otherwise
Target_Fun=@(x) cgg_loadTargetArray(x,SplitValue,true);
end

InDatastore_tmp.UnderlyingDatastores{2}.ReadFcn=Target_Fun;

TrialSplits=readall(InDatastore_tmp.UnderlyingDatastores{2});
TrialSplits=cell2mat(TrialSplits);

AllSplits=unique(TrialSplits);
NumSplits=length(AllSplits);

Window_Accuracy = cell(1,NumSplits);
Accuracy = cell(1,NumSplits);
Window_CM = cell(1,NumSplits);
Full_CM = cell(1,NumSplits);

for sidx=1:NumSplits

this_Split=TrialSplits==AllSplits(sidx);
this_InDatastore=subset(InDatastore_tmp,this_Split);

[Window_Accuracy{sidx},Accuracy{sidx},Window_CM{sidx},Full_CM{sidx}] = cgg_procConfusionMatrixFromDatastore(this_InDatastore,Mdl,ClassNames);

end

end

