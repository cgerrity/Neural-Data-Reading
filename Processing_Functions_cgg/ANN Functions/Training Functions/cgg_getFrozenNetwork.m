function FreezeFactor = cgg_getFrozenNetwork(InputNet,NetworkName,Freeze_cfg)
%CGG_GETFROZENNETWORK Summary of this function goes here
%   Detailed explanation goes here

FreezeFactor = NaN;

if isfield(Freeze_cfg,NetworkName) && ~isempty(InputNet)
    FreezeFactor = cgg_getNetworkLearningRateFactor(InputNet);
    fprintf('*** Freeze Information - Initial Learning Rate %s %.2f\n',...
        NetworkName,FreezeFactor);
end
end

