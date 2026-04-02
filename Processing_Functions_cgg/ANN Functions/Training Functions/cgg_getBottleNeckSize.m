function BottleNeckSize = cgg_getBottleNeckSize(InNetwork)
%CGG_GETBOTTLENECKSIZE Summary of this function goes here
%   Detailed explanation goes here

BottleNeckIDX = contains({InNetwork.Layers(:).Name},"BottleNeck");
PCAIDX = contains({InNetwork.Layers(:).Name},"PCA");
Layers = InNetwork.Layers(BottleNeckIDX);

BottleNeckSize = [];
HasFlatten = false;

for lidx = 1:length(Layers)
    this_Layer = Layers(lidx);
    this_FieldNames=fieldnames(this_Layer);
    if any(strcmp(this_FieldNames,'OutputSize'))
        BottleNeckSize = this_Layer.OutputSize;
    elseif any(strcmp(this_FieldNames,'NumHiddenUnits'))
        BottleNeckSize = this_Layer.NumHiddenUnits;
    elseif contains(this_Layer.Name,"flatten")
        HasFlatten = true;
    end
end

if HasFlatten && isempty(BottleNeckSize)
Layers = InNetwork.Layers;
    for lidx = 1:length(Layers)
        this_Layer = Layers(lidx);
        this_FieldNames=fieldnames(this_Layer);
        if any(strcmp(this_FieldNames,'OutputSize'))
            BottleNeckSize = this_Layer.OutputSize;
        elseif any(strcmp(this_FieldNames,'NumHiddenUnits'))
            BottleNeckSize = this_Layer.NumHiddenUnits;
        elseif any(strcmp(this_FieldNames,'InputSize'))
            BottleNeckSize = prod(this_Layer.InputSize);
        end
    end
end

if any(PCAIDX) && isempty(BottleNeckSize)
Layers = InNetwork.Layers(PCAIDX);
    for lidx = 1:length(Layers)
        this_Layer = Layers(lidx);
        this_FieldNames=fieldnames(this_Layer);
        if any(strcmp(this_FieldNames,'OutputDimension'))
            BottleNeckSize = this_Layer.OutputDimension;
        end
    end
end

%%

% 1. Run analysis and explicitly suppress the visual plot/UI window
    analyzer = analyzeNetwork(InNetwork, Plots="none");
    
    % 2. Extract the table containing activation sizes
    layerTable = analyzer.LayerInfo;
    
    % 3. Identify the output layers (dlnetworks can have multiple outputs)
    outputNames = InNetwork.OutputNames;
    
    outSize = struct();
    
    % 4. Match the output names to the analyzed activation sizes
    for i = 1:numel(outputNames)
        currentOutput = outputNames{i};
        
        % Handle formatted names like "LayerName/OutputName"
        if contains(currentOutput, '/')
            parts = split(currentOutput, '/');
            layerName = parts{1};
            portName = parts{2};
        else
            layerName = currentOutput;
            portName = '';
        end
        
        % Ensure the name is a valid MATLAB structure field name 
        % (handles slashes, dashes like in 'log-variance', etc.)
        validFieldName = matlab.lang.makeValidName(currentOutput);
        
        % Find the row corresponding to this base layer
        idx = strcmp(layerTable.Name, layerName);
        
        % Extract the size from the table
        if iscell(layerTable.ActivationSizes)
            layerSizes = layerTable.ActivationSizes{idx};
        else
            layerSizes = layerTable.ActivationSizes(idx);
        end
        
        if ~isempty(layerSizes)
            % Check if the activation size is stored as a dictionary or map
            if isa(layerSizes, 'dictionary') || isa(layerSizes, 'containers.Map')
                if ~isempty(portName)
                    % Extract using the port name directly
                    try
                        sz = layerSizes(portName);
                        if iscell(sz), sz = sz{1}; end
                        outSize.(validFieldName) = sz;
                    catch
                        outSize.(validFieldName) = [];
                    end
                else
                    % If no port name, grab the first available value
                    szVals = values(layerSizes);
                    if iscell(szVals)
                        outSize.(validFieldName) = szVals{1};
                    elseif ismatrix(szVals)
                        outSize.(validFieldName) = szVals(1, :);
                    else
                        outSize.(validFieldName) = szVals;
                    end
                end
            else
                % Fallback for older MATLAB versions (cell arrays / matrices)
                if ~isempty(portName)
                    % For multiple outputs, find the correct port index
                    layerIdx = strcmp({InNetwork.Layers.Name}, layerName);
                    theLayer = InNetwork.Layers(layerIdx);
                    
                    if isprop(theLayer, 'OutputNames')
                        portIdx = find(strcmp(theLayer.OutputNames, portName));
                        if iscell(layerSizes) && numel(layerSizes) >= portIdx
                            outSize.(validFieldName) = layerSizes{portIdx};
                        else
                            outSize.(validFieldName) = layerSizes;
                        end
                    else
                        outSize.(validFieldName) = layerSizes;
                    end
                else
                    % Extract if it's nested in a single-element cell
                    if iscell(layerSizes) && isscalar(layerSizes)
                        outSize.(validFieldName) = layerSizes{1};
                    else
                        outSize.(validFieldName) = layerSizes;
                    end
                end
            end
        else
            outSize.(validFieldName) = [];
        end
    end
    
    % 5. Simplify the return variable
    if numel(outputNames) > 1
        % If multiple outputs exist, isolate the one corresponding to '/out' if it exists
        idxOut = endsWith(outputNames, '/out');
        if any(idxOut)
            targetOutput = outputNames{find(idxOut, 1)};
            targetField = matlab.lang.makeValidName(targetOutput);
            outSize = outSize.(targetField);
        end
    elseif numel(outputNames) == 1
        % If it's a standard single-output network, simplify the struct to array
        fields = fieldnames(outSize);
        outSize = outSize.(fields{1});
    end

    BottleNeckSize = max(outSize);
end

