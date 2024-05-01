function [loss,gradients,state] = cgg_lossVariationalAutoEncoder(net,X,T,LossType,varargin)
%CGG_LOSSVARIATIONALAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

[mu,logSigmaSq,Y,state] = forward(net,X);

% Reconstruction loss.
reconstructionLoss = mse(Y,T);

% KL divergence.
KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq),1);
KL = mean(KL);

% Combined loss.
loss = reconstructionLoss + KL;

gradients = dlgradient(loss,net.Learnables);

end

