function [loss_Reconstruction,loss_KL] = cgg_lossELBO_v2(Y,T,mu,logSigmaSq)
%CGG_LOSSELBO Summary of this function goes here
%   Detailed explanation goes here

% Reconstruction loss.
% loss_Reconstruction = 0.5*sum((Y-T).^2,"all");
loss_Reconstruction = mse(Y,T);
% [extractdata(0.5*sum((Y-T).^2,"all")),extractdata(sum((Y).^2,"all")),extractdata(sum((T).^2,"all"))]
% sum((Y-T).^2,"all")

% KL divergence.
loss_KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq),1);
loss_KL = mean(loss_KL,"all");

end

