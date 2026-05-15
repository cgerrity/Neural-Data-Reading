function new_dlnet = cgg_addTaskConfidenceToClassifier(dlnet, displayFlag)
    % Set displayFlag to false if not provided by the user
    if nargin < 2
        displayFlag = false;
    end

    [OutputInformation,~] = cgg_getNetworkOutputInformation(dlnet);
    % 1. Convert to layerGraph for modification
    lgraph = layerGraph(dlnet);
    classifiers = OutputInformation.Classifier; 

    for i = 1:numel(classifiers)
        % Identify the branch output name based on your struct format
        if iscell(classifiers)
            branchName = char(classifiers{i});
        elseif isstruct(classifiers)
            branchName = char(classifiers(i).LayerName); 
        else
            branchName = char(classifiers(i));
        end
        
        % Extract the branch number from the branch name using regular expressions
        % This finds all digit sequences and we grab the last one.
        numMatches = regexp(branchName, '\d+', 'match');
        if ~isempty(numMatches)
            branchNum = numMatches{end}; % e.g., '2' from 'softmax_Tuning_Dim_2'
        else
            % Fallback just in case no number is found in the name
            branchNum = num2str(i); 
        end
        
        % 2. Walk backwards to find the final Fully Connected Layer
        currLayer = branchName;
        fcLayerName = '';
        
        while ~isempty(currLayer)
            % Locate the current layer object
            layerIdx = find({lgraph.Layers.Name} == string(currLayer));
            if isempty(layerIdx)
                break;
            end
            
            % Check if this layer is a Fully Connected layer
            if isa(lgraph.Layers(layerIdx), 'nnet.cnn.layer.FullyConnectedLayer')
                fcLayerName = currLayer;
                break;
            end
            
            % Step backward: find where currLayer is the destination
            dests = lgraph.Connections.Destination;
            % Strip out port names (e.g., 'layer/in') for matching
            baseDests = cellfun(@(x) strtok(x, '/'), dests, 'UniformOutput', false);
            connIdx = strcmp(baseDests, currLayer);
            
            if any(connIdx)
                % Get the source of this connection and strip its port for the next loop
                srcStr = lgraph.Connections.Source{find(connIdx, 1)};
                currLayer = strtok(srcStr, '/'); 
            else
                break; % Reached the beginning of the network
            end
        end
        
        if isempty(fcLayerName)
            warning('Could not find a fully connected layer on branch %s. Skipping.', branchName);
            continue;
        end
        
        % 3. Find the layer RIGHT BEFORE that final fully connected layer
        dests = lgraph.Connections.Destination;
        baseDests = cellfun(@(x) strtok(x, '/'), dests, 'UniformOutput', false);
        connIdx = strcmp(baseDests, fcLayerName);
        
        if ~any(connIdx)
            warning('Fully connected layer "%s" has no preceding layer to connect to. Skipping.', fcLayerName);
            continue;
        end
        
        % Extract the source. We keep the port name here so MATLAB routes the new connection correctly.
        layerRightBeforePort = lgraph.Connections.Source{find(connIdx, 1)}; 
        
        % Print a confirmation to the console so you can verify the connection point
        if displayFlag
            fprintf('Branch %s: Found final FC "%s". Branching TaskConfidence from preceding layer "%s".\n', ...
                branchNum, fcLayerName, layerRightBeforePort);
        end
        
        % 4. Define the new layers using the extracted branch number
        newFcName = sprintf('fc_TaskConfidence_%s', branchNum);
        newSigmoidName = sprintf('sigmoid_TaskConfidence_%s', branchNum);
        
        newLayers = [
            fullyConnectedLayer(1, 'Name', newFcName)
            sigmoidLayer('Name', newSigmoidName)
        ];
        
        % 5. Add to the graph and connect it to the layer right before the final FC
        lgraph = addLayers(lgraph, newLayers);
        lgraph = connectLayers(lgraph, layerRightBeforePort, newFcName);
    end
    
    % 6. Rebuild the dlnetwork
    new_dlnet = dlnetwork(lgraph);
end


