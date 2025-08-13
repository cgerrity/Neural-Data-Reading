classdef cgg_PCADecodingLayer < nnet.layer.Layer ...
        & nnet.layer.Formattable ...
        & nnet.layer.Acceleratable

    properties
        % Layer properties
        PCCoefficients  % Pre-calculated PCA coefficients
        PCMean          % Mean values used for centering before PCA
        ApplyPerTimePoint logical % Whether to apply PCA at each time point separately
        OriginalChannels % Original number of channels
        SpatialDimensions % Original spatial dimensions for reconstruction [S1, S2]
    end
    
    methods
        function layer = cgg_PCADecodingLayer(args)
            % Constructor with named arguments
            % 
            % Required args:
            %   Name - Layer name
            %   PCCoefficients - PCA coefficients
            %   PCMean - Mean values for centering
            %   OriginalChannels - Original number of channels
            %   SpatialDimensions - Original spatial dimensions [S1, S2]
            %
            % Optional args (with defaults):
            %   ApplyPerTimePoint - Whether to apply PCA at each time point (default: true)
            
            % Parse inputs
            arguments
                args.Name (1,1) string
                args.PCCoefficients
                args.PCMean
                args.OriginalChannels (1,1) {mustBeInteger}
                args.SpatialDimensions (1,2) {mustBeInteger}
                args.ApplyPerTimePoint (1,1) logical = true
            end
            
            % Set the layer name
            layer.Name = args.Name;
            
            % Set PCA properties
            layer.PCCoefficients = args.PCCoefficients;
            layer.PCMean = args.PCMean;
            layer.ApplyPerTimePoint = args.ApplyPerTimePoint;
            layer.OriginalChannels = args.OriginalChannels;
            layer.SpatialDimensions = args.SpatialDimensions;
            
            % This layer has no learnable parameters
            layer.NumInputs = 1;
            layer.NumOutputs = 1;
        end
        
        function Z = predict(layer, X)
            % Forward pass for CBT data: [C, 1, 1, T, B]
            FormatInformation = cgg_getDataFormatInformation(X);
            T = FormatInformation.Size.Time;
            B = FormatInformation.Size.Batch;
            S = layer.SpatialDimensions;
            C = FormatInformation.Size.Channel;
            ArrayFormat = [repmat('S',[1,length(S)]) 'CBT'];
            
            if layer.ApplyPerTimePoint
                % Apply inverse PCA at each time point separately
                Z = zeros([S, layer.OriginalChannels, B, T], 'like', X);
                Z = dlarray(Z,ArrayFormat);

                % fprintf('Dimensions of Input: %s\n',X.dims);
                % fprintf('Size of Input: [%d,%d,%d]\n',size(X));
                % fprintf('Size of Output: [%d,%d,%d,%d,%d]\n',size(Z));

                idx = repmat({':'}, 1, length(size(X)));
                idx_Z = repmat({':'}, 1, length(size(Z)));

                % PermuteDimensions = [1:length(S),[1,3,2]+length(S)];
                PermuteFormat = [repmat('S',[1,length(S)]) 'CTB'];
                
                for t = 1:T
                    % Get PCA coefficients and mean for this time point
                    if iscell(layer.PCCoefficients)
                        coeff = layer.PCCoefficients{t};
                        mu = layer.PCMean{t};
                    else
                        coeff = layer.PCCoefficients;
                        mu = layer.PCMean;
                    end

                    if ~(length(idx)< FormatInformation.Dimension.Time)
                    idx{FormatInformation.Dimension.Time} = t;
                    end
                    if ~(length(idx_Z)< FormatInformation.Dimension.Time)
                    idx_Z{3+length(S)} = t;
                    end

                    % Extract data for current time point [C, B, 1]
                    timeData = X(idx{:});
                    
                    % Reshape to [B, C] - each row is a sample
                    reshapedData = reshape(timeData, [C, B])';
                    
                    % Apply inverse PCA transformation
                    % Project back to original space using the transpose of the coefficient matrix
                    reconstructedData = reshapedData * coeff(:, 1:C)' + mu;
                    reconstructionreshapeData = reshape(reconstructedData', [S, layer.OriginalChannels, 1, B]);
                    % fprintf('Size of Reshape: [%d,%d,%d,%d,%d]\n',size(reconstructionreshapeData));
                    this_Z = dlarray(reconstructionreshapeData,PermuteFormat);
                    % fprintf('Size of Reformat: [%d,%d,%d,%d,%d]\n',size(this_Z));
                    % fprintf('Dimensions of Reformat: %s\n',this_Z.dims);

                    % Reshape back to [S1, S2, OriginalChannels, B]
                    Z(idx_Z{:}) = this_Z;
                    % fprintf('Size of Permute: [%d,%d,%d,%d]\n',size(Z(idx_Z{:})));
                end
            else
                % Apply inverse PCA across all time points
                % Z = zeros([S, layer.OriginalChannels, B, T], 'like', X);
                % Z = dlarray(Z,ArrayFormat);
                PermuteFormat = ['BT' repmat('S',[1,length(S)]) 'C'];
                
                % Reshape to [B*T, C]
                reshapedX = permute(stripdims(X), [2, 3, 1]); % [B, T, C, 1, 1]
                reshapedData = reshape(reshapedX, [B*T, C]);
                
                % Apply inverse PCA transformation
                reconstructedData = reshapedData * layer.PCCoefficients(:, 1:C)' + layer.PCMean;
                
                % Reshape back to [B, T, S1, S2, OriginalChannels]
                reshaped = reshape(reconstructedData, [B, T, S, layer.OriginalChannels]);
                
                % Permute back to [S1, S2, OriginalChannels, T, B]
                % Z = permute(reshaped, [3, 4, 5, 2, 1]);
                Z = dlarray(reshaped,PermuteFormat);
            end
        end
        
        % Output size function
        function outputSize = getOutputSize(layer, ~)
            % Input size is [C, 1, 1, T, B]
            % Output size should be [S1, S2, OriginalChannels, T, B]
            outputSize = [layer.SpatialDimensions, layer.OriginalChannels];
            % Note: T and B are inferred automatically
        end
    end
end