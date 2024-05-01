function loss = cgg_lossELBO(Y,T,mu,logSigmaSq,WeightReconstruction,WeightKL)
%CGG_LOSSELBO Summary of this function goes here
%   Detailed explanation goes here

% Reconstruction loss.
reconstructionLoss = mse(Y,T);

% KL divergence.
KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq),1);
KL = mean(KL);

Maximum_Loss_Reconstruction=max(extractdata(reconstructionLoss),[],"all");
Maximum_Loss_KL=max(extractdata(KL),[],"all");

Message_Loss=sprintf('Reconstruction Loss: %f, KL Loss: %f',Maximum_Loss_Reconstruction,Maximum_Loss_KL);
disp(Message_Loss);

% Combined loss.
loss = WeightReconstruction*reconstructionLoss + WeightKL*KL;

end

