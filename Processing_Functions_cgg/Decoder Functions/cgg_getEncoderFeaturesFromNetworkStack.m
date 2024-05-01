function [FeatureVector] = cgg_getEncoderFeaturesFromNetworkStack(InNetworkStack,Input)
%CGG_GETENCODERFEATURESFROMNETWORKSTACK Summary of this function goes here
%   Detailed explanation goes here

NumStacks=numel(InNetworkStack);
this_FeatureVector=Input;

for sidx=1:NumStacks
    this_Network=InNetworkStack{sidx};
    this_FeatureVector=cgg_getEncoderFeaturesFromNetwork(this_Network,this_FeatureVector);
end
FeatureVector=this_FeatureVector;

end

