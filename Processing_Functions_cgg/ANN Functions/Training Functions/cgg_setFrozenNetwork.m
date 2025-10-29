function InputNet = cgg_setFrozenNetwork(Epoch,InputNet,NetworkName,Freeze_cfg)
%CGG_SETFROZENNETWORKS Summary of this function goes here
%   Detailed explanation goes here

if isfield(Freeze_cfg,NetworkName)
    FreezeFactor = cgg_annealWeight(Epoch,1, ...
        Freeze_cfg.(NetworkName).DelayEpochs, ...
        Freeze_cfg.(NetworkName).RampEpochs);
    InputNet = cgg_setNetworkLearningRateFactor(InputNet, ...
        FreezeFactor);
    fprintf('~~~ Current Epoch: %d ~~~ %s Learning Rate Factor: %.2f\n',...
        Epoch,NetworkName,FreezeFactor);
end
end

