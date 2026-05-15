function InputNet = cgg_setFrozenNetwork_v2(InputNet,NetworkName,FreezeParameters)
%CGG_SETFROZENNETWORKS Summary of this function goes here
%   Detailed explanation goes here

CurrentParameterName = "CurrentFactor" + string(NetworkName);

if isprop(FreezeParameters,CurrentParameterName)
    FreezeFactor = FreezeParameters.(CurrentParameterName);
    InputNet = cgg_setNetworkLearningRateFactor(InputNet, ...
        FreezeFactor);
    fprintf('~~~ %s Learning Rate Factor: %.2f\n',...
        NetworkName,FreezeFactor);
end
end

