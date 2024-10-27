classdef cgg_samplingLayer < nnet.layer.Layer
    properties
%         InputSize
        DataFormat
%         SetupSize
        ChannelDimension
        BatchDimension
        TimeDimension
%         TimeSize
        WantDisplay
    end
    properties (Learnable)
    end
    methods
        function layer = cgg_samplingLayer(args)
            % layer = samplingLayer creates a sampling layer for VAEs.
            %
            % layer = samplingLayer(Name=name) also specifies the layer 
            % name.

            % Parse input arguments.
            arguments
                args.Name = "";
                args.DataFormat = 'CBT';
            end

            % Layer properties.
            layer.Name = args.Name;
            layer.Type = "Sampling";
            layer.Description = "Mean and log-variance sampling";
            layer.OutputNames = ["out" "mean" "log-variance"];

            layer.DataFormat = char(args.DataFormat);
            layer.WantDisplay = false;

            ChannelDimensionIDX=layer.DataFormat=='C';
            BatchDimensionIDX=layer.DataFormat=='B';
            TimeDimensionIDX=layer.DataFormat=='T';
            layer.ChannelDimension = find(ChannelDimensionIDX==1);
            layer.BatchDimension = find(BatchDimensionIDX==1);
            layer.TimeDimension = find(TimeDimensionIDX==1);
        end

        function [Z,mu,logSigmaSq] = predict(layer,X)
            % [Z,mu,logSigmaSq] = predict(~,Z) Forwards input data through
            % the layer at prediction and training time and output the
            % result.
            %
            % Inputs:
            %         X - Concatenated input data where X(1:K,:) and 
            %             X(K+1:end,:) correspond to the mean and 
            %             log-variances, respectively, and K is the number 
            %             of latent channels.
            % Outputs:
            %         Z          - Sampled output
            %         mu         - Mean vector.
            %         logSigmaSq - Log-variance vector

            % Data dimensions.

            IsnumLatentChannelsOdd = mod(size(X,layer.ChannelDimension),2);
            numLatentChannels = floor(size(X,layer.ChannelDimension)/2);
            miniBatchSize = size(X,layer.BatchDimension);
            SizeTime = size(X,layer.TimeDimension);

            if layer.WantDisplay
            Message=sprintf('Number of Input Channels: Num %s; Number of Input Batches: Num %s',num2str(numLatentChannels),num2str(miniBatchSize));
            disp(Message);
            end

            if layer.WantDisplay
            Message=sprintf('Input Size: Size %s',num2str(size(X)));
            disp(Message);
            end

            % Split statistics.
            mu = X(1:numLatentChannels,:,:);
            logSigmaSq = X(numLatentChannels+1:(end-IsnumLatentChannelsOdd),:,:);

            % Sample output.
            epsilon = randn(numLatentChannels,miniBatchSize,SizeTime,"like",X);
            sigma = exp(.5 * logSigmaSq);
            if layer.WantDisplay
            Message_Before=sprintf('Epsilon: Size %s; Sigma: Size %s; Mu: Size %s',num2str(size(epsilon)),num2str(size(sigma)),num2str(size(mu)));
            disp(Message_Before);
            end
            Z = epsilon .* sigma + mu;
        
        end

    end
    
end