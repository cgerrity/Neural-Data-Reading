function [loss_Reconstruction,loss_KL,loss_Reconstruction_perchannel] = cgg_lossELBO_v2(Y,T,mu,logSigmaSq)
%CGG_LOSSELBO Summary of this function goes here
%   Detailed explanation goes here

% Reconstruction loss.
% loss_Reconstruction = 0.5*sum((Y-T).^2,"all");

Mask_NaN = ~isnan(T);
loss_Reconstruction = 0.5*l2loss(Y,T,Mask=Mask_NaN);

% loss_Reconstruction = mse(Y,T);
SizeData = size(Y);
NumAreas = SizeData(finddim(Y,"C"));
for aidx = 1:NumAreas
% loss_Reconstruction_perchannel(aidx) = mse(Y(:,:,aidx,:,:),T(:,:,aidx,:,:));
loss_Reconstruction_perchannel(aidx) = 0.5*l2loss(Y(:,:,aidx,:,:),T(:,:,aidx,:,:),Mask=Mask_NaN(:,:,aidx,:,:));
end
% [extractdata(0.5*sum((Y-T).^2,"all")),extractdata(sum((Y).^2,"all")),extractdata(sum((T).^2,"all"))]
% sum((Y-T).^2,"all")

% KL divergence.
if ~(any(isempty(mu))) && ~(any(isempty(logSigmaSq)))
loss_KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq),1);
loss_KL = mean(loss_KL,"all");
loss_KL = squeeze(loss_KL);
else
    loss_KL = NaN;
end

end

