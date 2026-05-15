% =========================================================================
% CUSTOM VAE SAMPLER LAYER
% Defines the "new random generator" bottleneck
% =========================================================================
classdef VAESamplerLayer < nnet.layer.Layer
    properties
        ChannelDim % Explicitly track which dimension holds the channels
    end
    
    methods
        function layer = VAESamplerLayer(name, channelDim)
            layer.Name = name;
            layer.Description = 'VAE Reparameterization Sampler';
            
            % Default to 1 (Channel-Batch format) if not specified
            if nargin < 2
                layer.ChannelDim = 1;
            else
                layer.ChannelDim = channelDim;
            end
        end
        
        function Z = predict(layer, X)
            % During Inference/Testing: Only pass the Mean (mu)
            C = size(X, layer.ChannelDim); 
            halfC = round(C / 2);
            
            if layer.ChannelDim == 3 % SSCB (CNN)
                Z = X(:, :, 1:halfC, :);
            else % CB (MLP)
                Z = X(1:halfC, :);
            end
        end
        
        function Z = forward(layer, X)
            % During Training: Sample using the Reparameterization Trick
            C = size(X, layer.ChannelDim);
            halfC = round(C / 2);
            
            if layer.ChannelDim == 3 % SSCB (CNN)
                mu = X(:, :, 1:halfC, :);
                logvar = X(:, :, halfC+1:end, :);
            else % CB (MLP)
                mu = X(1:halfC, :);
                logvar = X(halfC+1:end, :);
            end
            
            % The unsynced random noise that breaks naive checkpointing
            epsilon = randn(size(mu), 'like', mu); 
            Z = mu + exp(0.5 * logvar) .* epsilon;
        end
        
        function [Z, outRngState] = forwardCheckpointed(layer, X, inRngState)
            % Custom method for Gradient Checkpointing to sync RNG state
            C = size(X, layer.ChannelDim);
            halfC = round(C / 2);
            
            if layer.ChannelDim == 3 % SSCB (CNN)
                mu = X(:, :, 1:halfC, :);
                logvar = X(:, :, halfC+1:end, :);
            else % CB (MLP)
                mu = X(1:halfC, :);
                logvar = X(halfC+1:end, :);
            end
            
            % If a previous state was passed in (Phase 2), restore it!
            if nargin >= 3 && ~isempty(inRngState)
                rng(inRngState);
            end
            
            % Capture the state RIGHT BEFORE generation to return it (Phase 1)
            outRngState = rng;
            
            % Generate the perfectly synced noise
            epsilon = randn(size(mu), 'like', mu); 
            Z = mu + exp(0.5 * logvar) .* epsilon;
        end
    end
end