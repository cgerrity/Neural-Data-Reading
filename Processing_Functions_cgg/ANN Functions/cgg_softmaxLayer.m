classdef cgg_softmaxLayer < nnet.layer.Layer & nnet.layer.Formattable
    % cgg_softmaxLayer Softmax over specified data format dimensions.
    % This layer is useful for Multiple Instance Learning (MIL) where 
    % attention or probabilities need to be computed over spatial ('S'), 
    % channel ('C'), or time ('T') dimensions.
    
    properties
        % Dimension formats to apply the softmax operation over. 
        % E.g., 'SCT' for Spatial, Channel, and Time.
        SoftmaxFormat
    end
    
    methods
        function layer = cgg_softmaxLayer(formatStr, name)
            % layer = cgg_softmaxLayer(formatStr, name) creates a 
            % cgg_softmaxLayer with the specified format and name.
            
            % Set layer name.
            if nargin == 2
                layer.Name = name;
            end
            
            % Ensure the format is stored as an uppercase char array
            layer.SoftmaxFormat = upper(char(formatStr));
            
            % Set layer description.
            layer.Description = "Softmax over format " + string(layer.SoftmaxFormat);
        end
        
        function Z = predict(layer, X)
            % Z = predict(layer, X) forwards the input data X through the layer.
            
            % Get the dimension format of the input dlarray (e.g., 'SSCTB')
            fmt = dims(X);
            
            if isempty(fmt)
                % During dlnetwork initialization and analyzeNetwork, MATLAB 
                % passes unformatted dummy data to infer layer output sizes. 
                % Since softmax does not change the size of the data, we can 
                % safely return X here to allow initialization to complete.
                Z = X;
                return;
            end
            
            % Find numeric indices of dimensions that match the requested format.
            % This dynamically creates a vector of dimensions (e.g., [1, 2, 3])
            dimsToOperate = find(ismember(fmt, layer.SoftmaxFormat));
            
            % If none of the requested dimensions exist in the input, return X.
            if isempty(dimsToOperate)
                Z = X;
                return;
            end
            
            % 1. Find the maximum value along ALL specified dimensions simultaneously.
            maxX = max(X, [], dimsToOperate);
            maxX = cgg_extractData(maxX);
            
            % 2. Subtract max and calculate exponentials for numerical stability.
            expX = exp(X - maxX);
            
            % 3. Sum the exponentials along ALL specified dimensions simultaneously.
            sumExpX = sum(expX, dimsToOperate);
            
            % 4. Normalize to get the true softmax probabilities.
            Z = expX ./ sumExpX;
        end
    end
end