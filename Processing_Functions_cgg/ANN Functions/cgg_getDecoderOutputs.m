function [Loss_Reconstruction,Loss_KL,Loss_Reconstruction_perchannel] = cgg_getDecoderOutputs(Y_Reconstruction,Y_Mean,Y_logSigmaSq,T_Reconstruction,InLoss_Reconstruction,InLoss_KL,InLoss_Reconstruction_perchannel,Normalization_Factor,varargin)
%CGG_GETDECODEROUTPUTS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
LossType_Decoder = CheckVararginPairs('LossType_Decoder', 'MSE', varargin{:});
else
if ~(exist('LossType_Decoder','var'))
LossType_Decoder='MSE';
end
end

if isfunction
WantGradient = CheckVararginPairs('WantGradient', false, varargin{:});
else
if ~(exist('WantGradient','var'))
WantGradient=false;
end
end

switch LossType_Decoder
    case 'MSE'
[Loss_Reconstruction,Loss_KL,Loss_Reconstruction_perchannel] = cgg_lossELBO_v2(Y_Reconstruction,T_Reconstruction,Y_Mean,Y_logSigmaSq);
    case 'MAE'
[Loss_Reconstruction,Loss_KL,Loss_Reconstruction_perchannel] = cgg_lossELBO_MAE(Y_Reconstruction,T_Reconstruction,Y_Mean,Y_logSigmaSq);
    otherwise
[Loss_Reconstruction,Loss_KL,Loss_Reconstruction_perchannel] = cgg_lossELBO_v2(Y_Reconstruction,T_Reconstruction,Y_Mean,Y_logSigmaSq);
end

%%
if ~WantGradient
    Loss_Reconstruction = cgg_extractData(Loss_Reconstruction);
    Loss_KL = cgg_extractData(Loss_KL);
    Loss_Reconstruction_perchannel = ...
        cgg_extractData(Loss_Reconstruction_perchannel);
end

%%

if isempty(InLoss_Reconstruction) || isnan(InLoss_Reconstruction)
Loss_Reconstruction = Loss_Reconstruction*Normalization_Factor;
else
Loss_Reconstruction = InLoss_Reconstruction + Loss_Reconstruction*Normalization_Factor;
end

if isempty(InLoss_KL) || isnan(InLoss_KL)
Loss_KL = Loss_KL*Normalization_Factor;
else
Loss_KL = InLoss_KL + Loss_KL*Normalization_Factor;
end

if isempty(InLoss_Reconstruction_perchannel) || all(isnan(InLoss_Reconstruction_perchannel))
Loss_Reconstruction_perchannel = Loss_Reconstruction_perchannel*Normalization_Factor;
else
Loss_Reconstruction_perchannel = InLoss_Reconstruction_perchannel + Loss_Reconstruction_perchannel.*Normalization_Factor;
end

end

