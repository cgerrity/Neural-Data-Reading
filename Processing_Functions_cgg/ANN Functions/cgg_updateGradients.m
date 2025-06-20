function gradients = cgg_updateGradients(gradients,priorgradient,InitialFun,PostFun)
%CGG_UPDATEGRADIENTS Summary of this function goes here
%   Detailed explanation goes here
    if ~isempty(priorgradient.Value)
        gradients = dlupdate(PostFun,gradients,priorgradient);
    else
        gradients = dlupdate(InitialFun,gradients);
    end
end

