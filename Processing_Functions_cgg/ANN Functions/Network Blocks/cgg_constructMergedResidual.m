function lgraph = cgg_constructMergedResidual(lgraph, combineInputs)
    % cgg_constructMergedResidual Consolidates parallel filters into a single 
    % addition and activation layer per Layer-#, maintaining only ONE residual path.

    if nargin < 2
        combineInputs = false;
    end

    % Extract current layers and connections
    layers = lgraph.Layers;
    connections = lgraph.Connections;
    layerNames = {layers.Name};

    % Convert connection tables to string arrays for robust searching
    destStrings = string(connections.Destination);
    srcStrings = string(connections.Source);

    % Identify unique Layer IDs (e.g., 'Layer-1', 'Layer-2')
    tokens = regexp(layerNames, 'Layer-(\d+)', 'tokens');
    layerIdx = cellfun(@(x) ~isempty(x), tokens);
    foundLayers = cellfun(@(x) x{1}{1}, tokens(layerIdx), 'UniformOutput', false);
    uniqueLayers = unique(foundLayers);

    for i = 1:numel(uniqueLayers)
        layerID = ['Layer-' uniqueLayers{i}];
        
        % 1. Identify all addition and activation layers for this ID
        % (Excluding internal 'BlockDepth' layers)
        isThisLayer = contains(layerNames, layerID) & ~contains(layerNames, 'BlockDepth');
        
        addNodes = layerNames(isThisLayer & contains(layerNames, 'addition_'));
        actNodes = layerNames(isThisLayer & contains(layerNames, 'activation_'));

        numFilters = numel(addNodes);
        
        % Only consolidate if there are multiple filters converging
        if numFilters > 1
            % Create cleaner names for the new merged nodes by stripping the "Filter-#" tag
            masterAddName = regexprep(addNodes{1}, '_Filter-\d+', ''); 
            masterActName = regexprep(actNodes{1}, '_Filter-\d+', '');

            % 2. Categorize incoming connections into Main (BlockDepth) and Residual
            mainConnsSources = string.empty;
            resConnsSources = string.empty;
            
            for f = 1:numFilters
                % Find all incoming connections to this specific addition node
                idxIn = startsWith(destStrings, string(addNodes{f}) + "/");
                nodeInConns = connections(idxIn, :);
                
                for c = 1:height(nodeInConns)
                    src = string(nodeInConns.Source{c});
                    % Differentiate paths based on your 'BlockDepth' naming scheme
                    if contains(src, 'BlockDepth')
                        mainConnsSources(end+1) = src; %#ok<AGROW> 
                    else
                        resConnsSources(end+1) = src; %#ok<AGROW>
                    end
                end
            end
            
            % 3. Isolate the single Master Residual and identify redundant ones for deletion
            masterResidualSrc = resConnsSources(1);
            redundantResiduals = resConnsSources(2:end);
            
            % 3a. Build list of entire master residual path to rename (tracing backward)
            nodesToRename = string.empty;
            currNode = masterResidualSrc;
            for backtrack = 1:10
                nodesToRename(end+1) = currNode; %#ok<AGROW>
                idxIn = startsWith(destStrings, currNode + "/") | (destStrings == currNode);
                if any(idxIn)
                    srcNode = srcStrings(find(idxIn, 1));
                    prevNode = regexprep(srcNode, '/.*', ''); % remove ports
                    if contains(prevNode, 'residual', 'IgnoreCase', true)
                        currNode = prevNode;
                    else
                        break;
                    end
                else
                    break;
                end
            end
            
            % Rename the master residual path layers to remove the filter number
            for k = 1:numel(nodesToRename)
                oldName = char(nodesToRename(k));
                masterResLayerIdx = find(strcmp(layerNames, oldName));
                if ~isempty(masterResLayerIdx)
                    resLayerToRename = layers(masterResLayerIdx);
                    newName = regexprep(oldName, '_Filter-\d+', '');
                    if ~strcmp(oldName, newName)
                        resLayerToRename.Name = char(newName);
                        lgraph = replaceLayer(lgraph, oldName, resLayerToRename);
                        if k == 1
                            masterResidualSrc = newName; % Update reference for Step 6
                        end
                        layers = lgraph.Layers;
                        layerNames = {layers.Name};
                    end
                end
            end
            
            % Update connection lists after renaming
            connections = lgraph.Connections;
            destStrings = string(connections.Destination);
            srcStrings = string(connections.Source);
            
            layersToDelete = [string(addNodes), string(actNodes)];
            
            % 3b. Trace backward to prune redundant residual branches completely
            for r = 1:numel(redundantResiduals)
                currNode = redundantResiduals(r);
                if contains(currNode, 'residual', 'IgnoreCase', true)
                    for backtrack = 1:10
                        layersToDelete(end+1) = currNode; %#ok<AGROW>
                        idxIn = startsWith(destStrings, currNode + "/") | (destStrings == currNode);
                        if any(idxIn)
                            srcNode = srcStrings(find(idxIn, 1));
                            currNode = regexprep(srcNode, '/.*', '');
                            if ~contains(currNode, 'residual', 'IgnoreCase', true)
                                break;
                            end
                        else
                            break;
                        end
                    end
                end
            end

            % Determine target number of channels for the 1x1 convolution
            % Trace backward along master residual path until a layer with NumFilters is found
            targetFilters = 1;
            currNode = masterResidualSrc;
            for backtrack = 1:10
                lIdx = find(strcmp(layerNames, currNode));
                if ~isempty(lIdx) && isprop(layers(lIdx), 'NumFilters')
                    targetFilters = layers(lIdx).NumFilters;
                    break;
                end
                
                idxIn = startsWith(destStrings, currNode + "/") | (destStrings == currNode);
                if any(idxIn)
                    srcNode = srcStrings(find(idxIn, 1));
                    currNode = regexprep(srcNode, '/.*', '');
                else
                    break;
                end
            end

            % Fallback just in case
            if targetFilters == 1
                try
                    prefix = extractBefore(mainConnsSources(1), '_BlockDepth');
                    for k = 1:numel(layers)
                        if contains(layers(k).Name, prefix) && isprop(layers(k), 'NumFilters')
                            targetFilters = layers(k).NumFilters;
                            break;
                        end
                    end
                catch
                end
            end

            % 4. Create the new dynamic layers (Concat -> 1x1 Conv -> Addition)
            concatName = regexprep(masterAddName, 'addition_', 'concat_main_');
            conv1x1Name = regexprep(masterAddName, 'addition_', 'conv1x1_main_');
            
            concatLayer = depthConcatenationLayer(numel(mainConnsSources), 'Name', concatName);
            conv1x1Layer = convolution2dLayer(1, targetFilters, 'Name', conv1x1Name, 'Padding', 'same', 'Stride', 1);
            masterAddLayer = additionLayer(2, 'Name', masterAddName);

            % 5. Copy the first activation layer to preserve properties (like Leaky ReLU scale)
            idxAct = find(strcmp(layerNames, actNodes{1}));
            masterActLayer = layers(idxAct);
            masterActLayer.Name = masterActName; % Update its name

            % Add the new layers to the graph
            lgraph = addLayers(lgraph, concatLayer);
            lgraph = addLayers(lgraph, conv1x1Layer);
            lgraph = addLayers(lgraph, masterAddLayer);
            lgraph = addLayers(lgraph, masterActLayer);

            % 6. Connect sources to the new layers
            % Connect all main convolutional paths to the concatenation layer
            for c = 1:numel(mainConnsSources)
                newDestPort = sprintf('%s/in%d', concatName, c);
                lgraph = connectLayers(lgraph, char(mainConnsSources(c)), newDestPort);
            end
            
            % Connect the concatenation output to the 1x1 convolution
            lgraph = connectLayers(lgraph, concatName, conv1x1Name);

            % Connect the 1x1 convolution to port 2 of the final addition layer
            lgraph = connectLayers(lgraph, conv1x1Name, [masterAddName '/in2']);
            
            % Connect the single residual path to port 1 of the final addition layer
            lgraph = connectLayers(lgraph, char(masterResidualSrc), [masterAddName '/in1']);

            % Connect the new Addition to the new Activation
            lgraph = connectLayers(lgraph, masterAddName, masterActName);

            % 7. Re-route outgoing connections from old activations to downstream layers
            allOutConns = table();
            for f = 1:numFilters
                idxOut = strcmp(srcStrings, string(actNodes{f}));
                allOutConns = [allOutConns; connections(idxOut, :)];
            end
            
            destLayersProcessed = string.empty;
            
            for c = 1:height(allOutConns)
                dest = char(allOutConns.Destination(c));
                oldSrc = char(allOutConns.Source(c));
                destLayerName = regexprep(dest, '/in\d+', ''); % Extract layer name without port
                
                lgraph = disconnectLayers(lgraph, oldSrc, dest);
                
                % Check if the destination is a concatenation layer
                if contains(destLayerName, 'concatenation', 'IgnoreCase', true)
                    % Bypass and remove downstream concatenation layers
                    if ~ismember(string(destLayerName), destLayersProcessed)
                        % Find where the concatenation layer outputs to
                        idxConcatOut = strcmp(srcStrings, string(destLayerName));
                        concatOutConns = connections(idxConcatOut, :);
                        
                        % Connect master activation directly to concatenation's targets
                        for cOut = 1:height(concatOutConns)
                            finalDest = char(concatOutConns.Destination(cOut));
                            lgraph = disconnectLayers(lgraph, destLayerName, finalDest);
                            lgraph = connectLayers(lgraph, masterActName, finalDest);
                        end
                        
                        % Mark concatenation layer for deletion
                        layersToDelete(end+1) = string(destLayerName); %#ok<AGROW>
                        destLayersProcessed(end+1) = string(destLayerName); %#ok<AGROW>
                    end
                else
                    % Standard re-routing for non-concatenation downstream layers
                    lgraph = connectLayers(lgraph, masterActName, dest);
                end
            end

            % 8. Clean up: Remove old additions, activations, and redundant residual layers
            layersToDelete = unique(layersToDelete);
            for d = 1:numel(layersToDelete)
                lgraph = removeLayers(lgraph, char(layersToDelete(d)));
            end

            % Update internal variables for the next layer iteration
            layers = lgraph.Layers;
            connections = lgraph.Connections;
            layerNames = {layers.Name};
            destStrings = string(connections.Destination);
            srcStrings = string(connections.Source);
        end
    end

    % OPTIONAL: Combine all unconnected inputs into a single identity layer
    if combineInputs
        layers = lgraph.Layers;
        connections = lgraph.Connections;
        destStrings = string(connections.Destination);
        destLayerNames = regexprep(destStrings, '/.*', ''); % Remove port suffixes
        
        unconnectedLayers = string.empty;
        for k = 1:numel(layers)
            L = layers(k);
            % Check if it's not a built-in input layer
            isInputClass = contains(class(L), 'InputLayer', 'IgnoreCase', true);
            if ~isInputClass && ~ismember(string(L.Name), destLayerNames)
                unconnectedLayers(end+1) = string(L.Name); %#ok<AGROW>
            end
        end
        
        if ~isempty(unconnectedLayers)
            % Extract contextual name from the first unconnected layer
            firstUnconnected = char(unconnectedLayers(1));
            contextName = firstUnconnected;
            
            % Remove common layer prefixes (expanded for upsampling support)
            prefixes = {'conv_residual_', 'crop_residual_', 'convolution_', 'transposeconv_', 'crop_', 'activation_', 'maxpool_', 'addition_', 'concatenationFilter_', 'convolutional1x1_'};
            for p = 1:numel(prefixes)
                if startsWith(contextName, prefixes{p})
                    contextName = extractAfter(contextName, prefixes{p});
                    break;
                end
            end
            
            % Remove common suffixes
            contextName = regexprep(contextName, '_Filter-\d+.*', '');
            contextName = regexprep(contextName, '_Layer-\d+.*', '');
            contextName = regexprep(contextName, '_BlockDepth-\d+.*', '');
            
            % Define the base name for the identity layer
            if ~isempty(contextName)
                identityBaseName = ['merged_identity_input_', contextName];
            else
                identityBaseName = 'merged_identity_input';
            end
            
            % Create a unique name for the input layer
            identityName = identityBaseName;
            counter = 1;
            while ismember(identityName, {lgraph.Layers.Name})
                identityName = sprintf('%s_%d', identityBaseName, counter);
                counter = counter + 1;
            end
            
            try
                % Modern MATLAB implementation
                idLayer = identityLayer('Name', identityName);
            catch
                % Fallback for older MATLAB versions
                idLayer = functionLayer(@(x) x, 'Name', identityName);
            end
            
            lgraph = addLayers(lgraph, idLayer);
            
            % Connect the new single input to all previously unconnected branches
            for k = 1:numel(unconnectedLayers)
                lgraph = connectLayers(lgraph, identityName, char(unconnectedLayers(k)));
            end
        end
    end
end

