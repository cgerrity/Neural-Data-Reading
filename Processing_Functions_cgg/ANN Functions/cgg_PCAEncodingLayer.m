classdef cgg_PCAEncodingLayer < nnet.layer.Layer ...
        & nnet.layer.Formattable ...
        & nnet.layer.Acceleratable
    
    properties
        % Layer properties
        PCCoefficients  % Pre-calculated PCA coefficients
        PCMean          % Mean values used for centering before PCA
        ApplyPerTimePoint logical % Whether to apply PCA at each time point separately
        OutputDimension  % Desired output dimension after PCA
        SpatialDimensions % Original spatial dimensions to store for reconstruction
    end
    
    methods
        function layer = cgg_PCAEncodingLayer(args)
            % Constructor with named arguments
            % 
            % Required args:
            %   Name - Layer name
            %   PCCoefficients - PCA coefficients
            %   PCMean - Mean values for centering
            %
            % Optional args (with defaults):
            %   ApplyPerTimePoint - Whether to apply PCA at each time point (default: true)
            %   OutputDimension - Output dimension after PCA (default: inferred from coefficients)
            
            % Parse inputs
            arguments
                args.Name (1,1) string
                args.PCCoefficients
                args.PCMean
                args.ApplyPerTimePoint (1,1) logical = true
                args.OutputDimension (1,1) {mustBeInteger} = []
            end
            
            % Set the layer name
            layer.Name = args.Name;
            
            % Set PCA properties
            layer.PCCoefficients = args.PCCoefficients;
            layer.PCMean = args.PCMean;
            layer.ApplyPerTimePoint = args.ApplyPerTimePoint;
            
            % Set output dimension
            if isempty(args.OutputDimension)
                if iscell(args.PCCoefficients)
                    layer.OutputDimension = size(args.PCCoefficients{1}, 2);
                else
                    layer.OutputDimension = size(args.PCCoefficients, 2);
                end
            else
                layer.OutputDimension = args.OutputDimension;
            end
            
            % This layer has no learnable parameters
            layer.NumInputs = 1;
            layer.NumOutputs = 1;
        end
        
        function Z = predict(layer, X)
            % Forward pass for SSCBT data: [S1, S2, C, T, B]
            [PermuteDimensions,ReshapeSize] = ...
                cgg_getPCALayerInformation(X,...
                'WantPerTime',layer.ApplyPerTimePoint);

            FormatInformation = cgg_getDataFormatInformation(X);
 
            T = FormatInformation.Size.Time;
            B = FormatInformation.Size.Batch;
            % S = prod(FormatInformation.Size.Spatial);
            % C = FormatInformation.Size.Channel;
            % [S1, S2, C, T, B] = size(X);
            
            % Store spatial dimensions in the layer for future reference
            layer.SpatialDimensions = FormatInformation.Size.Spatial;
            X_Input = extractdata(X);
            % fprintf('Dimensions of Input: %s\n',X.dims);
            % fprintf('Size of Input: [%d,%d,%d,%d,%d]\n',size(X));
            if layer.ApplyPerTimePoint
                % Apply PCA at each time point separately
                Z = dlarray(zeros(layer.OutputDimension, B, T),'CBT');
                
                idx = repmat({':'}, 1, length(size(X_Input)));
                for t = 1:T
                    % Get PCA coefficients and mean for this time point
                    if iscell(layer.PCCoefficients)
                        coeff = layer.PCCoefficients{t};
                        mu = layer.PCMean{t};
                        outDim = min(layer.OutputDimension, size(coeff, 2));
                    else
                        coeff = layer.PCCoefficients;
                        mu = layer.PCMean;
                        outDim = layer.OutputDimension;
                    end
                    % Extract data for current time point
                    if ~(length(idx)< FormatInformation.Dimension.Time)
                    idx{FormatInformation.Dimension.Time} = t;
                    end
                    % fprintf('Size of Extracted: [%d,%d,%d]\n',size(X_Input));
                    % fprintf('Permuted Dimensions: [%d,%d,%d,%d,%d]\n',PermuteDimensions);

                    timeData = permute(X_Input(idx{:}), PermuteDimensions);
                    
                    % fprintf('Size of Permuted: [%d,%d,%d,%d]\n',size(timeData));
                    % fprintf('Reshape Size: [%d,%d]\n',ReshapeSize);
                    reshapedData = reshape(timeData, ReshapeSize);
                    
                    % Apply PCA transformation
                    centeredData = reshapedData - mu;
                    projectedData = centeredData * coeff(:, 1:outDim);
                    
                    % Output is channels only [outDim, 1, 1, B]
                    % We transpose to get [outDim, B] first, then reshape
                    Z(1:outDim,:,t) = reshape(projectedData', [outDim, 1, B]);
                end
            else
                % Apply PCA across all time points
                outDim = min(layer.OutputDimension, size(layer.PCCoefficients, 2));
                Z = dlarray(zeros(layer.OutputDimension, B, T),'CBT');
                
                % fprintf('Size of Extracted: [%d,%d,%d]\n',size(X_Input));
                % fprintf('Permuted Dimensions: [%d,%d,%d,%d,%d]\n',PermuteDimensions);
                % Permute to make batch and time dimensions adjacent for easier reshaping
                permutedX = permute(X_Input, PermuteDimensions); % [B, T, S1, S2, C]
                
                % fprintf('Size of Permuted: [%d,%d,%d,%d,%d]\n',size(permutedX));
                % fprintf('Reshape Size: [%d,%d]\n',ReshapeSize);
                % Reshape to [B*T, S1*S2*C] - each row is a sample
                reshapedData = reshape(permutedX, ReshapeSize);
                
                % fprintf('Size of Reshaped: [%d,%d]\n',size(reshapedData));
                % Apply PCA transformation
                centeredData = reshapedData - layer.PCMean;
                projectedData = centeredData * layer.PCCoefficients(:, 1:outDim);
                
                % Reshape to [B, T, outDim]
                reshaped = reshape(projectedData, [B, T, outDim]);
                
                % Permute to [outDim, T, B]
                Z = Z + permute(reshaped, [3, 1, 2]);
                
            end
        end
        
        % % Output size function
        % function outputSize = getOutputSize(layer, inputSize)
        %     % Input size is [S1, S2, C, T, B]
        %     % Output size should be [OutputDimension, 1, 1, T, B]
        %     outputSize = [layer.OutputDimension, 1, 1, inputSize(4), inputSize(5)];
        % end
    end
end