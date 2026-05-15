function lgraph = cgg_createStitchingFusionModule(numAreas, filtersPerArea, varargin)
    % cgg_createStitchingFusionModule
    % Creates a stitching and fusion module for multi-area neural decoding.
    % Can be configured as an Encoder or Decoder.
    %
    % Options:
    %   'Mode'                - 'Encoder' (default) or 'Decoder'
    %   'TargetSize'          - [best_x, best_y] derived from cgg_findOptimalDivisors
    %   'OutputSize'          - [C_final, T_final] the desired output dimensions (e.g., InputSize(1:2))
    %   'EncoderReduction'    - [SpatialReduce, TemporalReduce] factors for Encoder downsampling
    %   'ReductionMethod'     - 'maxpool' (default) or 'stride' 
    %   'StrideBypassMethod'  - 'kernel' (default) or 'avgpool' (handles bypass downsampling if ReductionMethod is 'stride')
    %   'TemporalKernelSizes' - Array of sizes for temporal extraction (default: [3, 5, 7])
    %   'NumResidualLayers'   - Number of convolutional layers in the residual block branches (default: 2)
    
    % --- Parse Inputs ---
    p = inputParser;
    addRequired(p, 'numAreas');
    addRequired(p, 'filtersPerArea');
    addParameter(p, 'Mode', 'Encoder', @(x) any(validatestring(x, {'Encoder', 'Decoder'})));
    addParameter(p, 'TargetSize', [], @isnumeric);
    addParameter(p, 'OutputSize', [], @isnumeric);
    addParameter(p, 'EncoderReduction', [2, 2], @isnumeric); % Default to [2, 2] reduction
    addParameter(p, 'ReductionMethod', 'maxpool', @(x) any(validatestring(x, {'maxpool', 'stride'})));
    addParameter(p, 'StrideBypassMethod', 'kernel', @(x) any(validatestring(x, {'kernel', 'avgpool'})));
    addParameter(p, 'TemporalKernelSizes', [3, 5, 7], @isnumeric); % Default FastSlow kernels
    addParameter(p, 'NumResidualLayers', 2, @isnumeric); % Controls depth of residual branches
    parse(p, numAreas, filtersPerArea, varargin{:});
    
    mode = p.Results.Mode;
    targetSize = p.Results.TargetSize;
    outputSize = p.Results.OutputSize;
    encReduction = p.Results.EncoderReduction;
    reductionMethod = p.Results.ReductionMethod;
    strideBypassMethod = p.Results.StrideBypassMethod;
    tempKernelSizes = p.Results.TemporalKernelSizes;
    numTempKernels = length(tempKernelSizes);
    numResidualLayers = p.Results.NumResidualLayers;

    lgraph = layerGraph();

    if strcmpi(mode, 'Encoder')
        % =========================================================================
        % ENCODER GRAPH (Neural Area Stitching)
        % =========================================================================
        
        inputIdentity = functionLayer(@(x) x, 'Name', 'module_input');
        layers = [inputIdentity];
        
        % Determine strides based on ReductionMethod
        tempStride = [1, 1];
        spatStride = [1, 1];
        if strcmpi(reductionMethod, 'stride')
            tempStride = [1, encReduction(2)];
            spatStride = [encReduction(1), 1];
        end
        
        % 1. TEMPORAL EXTRACTION (Dynamic multi-scale, Residual Block)
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            
            for j = 1:numResidualLayers
                nameConv = ['temp_conv' num2str(j) '_' num2str(kSize)];
                
                % If using stride, apply it only to the first convolution of the block
                currStride = [1, 1];
                if j == 1
                    currStride = tempStride;
                end
                
                layers = [layers, ...
                    groupedConvolution2dLayer([1, kSize], filtersPerArea, numAreas, 'Stride', currStride, 'Padding', 'same', 'Name', nameConv)];
                
                % Add ReLU after all but the last convolution in the branch
                if j < numResidualLayers
                    nameRelu = ['temp_relu' num2str(j) '_' num2str(kSize)];
                    layers = [layers, reluLayer('Name', nameRelu)];
                end
            end
        end
        
        % Temporal projection (acts as the linear bypass for the residual connection)
        if strcmpi(reductionMethod, 'stride') && strcmpi(strideBypassMethod, 'avgpool')
            % Average pool downsampling prior to 1x1 projection convolution
            layers = [layers, ...
                averagePooling2dLayer(tempStride, 'Stride', tempStride, 'Padding', 'same', 'Name', 'temp_proj_pool'), ...
                groupedConvolution2dLayer([1, 1], filtersPerArea, numAreas, 'Name', 'temp_proj')];
        else
            % Kernel size dynamically matches the stride to avoid dropping un-sampled inputs
            layers = [layers, ...
                groupedConvolution2dLayer(tempStride, filtersPerArea, numAreas, 'Stride', tempStride, 'Padding', 'same', 'Name', 'temp_proj')];
        end
        
        addTemp  = additionLayer(numTempKernels + 1, 'Name', 'temporal_add');
        reluTemp = reluLayer('Name', 'temporal_relu');
        layers = [layers, addTemp, reluTemp];
        
        % Add Temporal Max Pool if requested
        if encReduction(2) > 1 && strcmpi(reductionMethod, 'maxpool')
            layers = [layers, maxPooling2dLayer([1, encReduction(2)], 'Stride', [1, encReduction(2)], 'Padding', 'same', 'Name', 'temporal_reduction')];
        end
        
        % 2. SPATIAL EXTRACTION
        spatialConv = groupedConvolution2dLayer([3, 1], filtersPerArea, numAreas, 'Stride', spatStride, 'Padding', 'same', 'Name', 'spatial_conv');
        reluSpatial = reluLayer('Name', 'spatial_relu');
        layers = [layers, spatialConv, reluSpatial];
        
        % Add Spatial Max Pool if requested
        if encReduction(1) > 1 && strcmpi(reductionMethod, 'maxpool')
            layers = [layers, maxPooling2dLayer([encReduction(1), 1], 'Stride', [encReduction(1), 1], 'Padding', 'same', 'Name', 'spatial_reduction')];
        end
        
        % 3. AREA FUSION
        fusionConv = convolution2dLayer([1, 1], filtersPerArea, 'Name', 'area_fusion');
        reluFusion = reluLayer('Name', 'fusion_relu');
        layers = [layers, fusionConv, reluFusion];
        
        % Add all layers
        for i = 1:length(layers), lgraph = addLayers(lgraph, layers(i)); end
        
        % Connect Temporal Multi-Scale Extraction (Residual Block)
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            lastNode = 'module_input';
            
            for j = 1:numResidualLayers
                nameConv = ['temp_conv' num2str(j) '_' num2str(kSize)];
                lgraph = connectLayers(lgraph, lastNode, nameConv);
                lastNode = nameConv;
                
                if j < numResidualLayers
                    nameRelu = ['temp_relu' num2str(j) '_' num2str(kSize)];
                    lgraph = connectLayers(lgraph, lastNode, nameRelu);
                    lastNode = nameRelu;
                end
            end
            
            lgraph = connectLayers(lgraph, lastNode, ['temporal_add/in' num2str(i)]);
        end
        
        % Connect linear projection bypass
        if strcmpi(reductionMethod, 'stride') && strcmpi(strideBypassMethod, 'avgpool')
            lgraph = connectLayers(lgraph, 'module_input', 'temp_proj_pool');
            lgraph = connectLayers(lgraph, 'temp_proj_pool', 'temp_proj');
        else
            lgraph = connectLayers(lgraph, 'module_input', 'temp_proj');
        end
        lgraph = connectLayers(lgraph, 'temp_proj', ['temporal_add/in' num2str(numTempKernels + 1)]);
        
        lgraph = connectLayers(lgraph, 'temporal_add', 'temporal_relu');
        
        % Connect Temporal -> Spatial
        lastTemporal = 'temporal_relu';
        if encReduction(2) > 1 && strcmpi(reductionMethod, 'maxpool')
            lgraph = connectLayers(lgraph, lastTemporal, 'temporal_reduction');
            lastTemporal = 'temporal_reduction';
        end
        
        lgraph = connectLayers(lgraph, lastTemporal, 'spatial_conv');
        lgraph = connectLayers(lgraph, 'spatial_conv', 'spatial_relu');
        
        % Connect Spatial -> Fusion
        lastSpatial = 'spatial_relu';
        if encReduction(1) > 1 && strcmpi(reductionMethod, 'maxpool')
            lgraph = connectLayers(lgraph, lastSpatial, 'spatial_reduction');
            lastSpatial = 'spatial_reduction';
        end
        
        lgraph = connectLayers(lgraph, lastSpatial, 'area_fusion');
        lgraph = connectLayers(lgraph, 'area_fusion', 'fusion_relu');

    else
        % =========================================================================
        % DECODER GRAPH (Neural Area Expansion)
        % =========================================================================
        
        % 0. STRIDE & CROP CALCULATION
        stride_spatial = 1; stride_temporal = 1;
        calculatedCrop = [0, 0];
        
        if ~isempty(outputSize) && ~isempty(targetSize)
            stride_spatial = ceil(outputSize(1) / targetSize(1));
            stride_temporal = ceil(outputSize(2) / targetSize(2));
            
            diff_x = (targetSize(1) * stride_spatial) - outputSize(1);
            diff_y = (targetSize(2) * stride_temporal) - outputSize(2);
            calculatedCrop = [max(0, diff_x), max(0, diff_y)];
        end

        totalDecoderChannels = numAreas * filtersPerArea;

        % 1. DATA FORMATTING & RESHAPE
        AddSpatialLayer = functionLayer(@(X) dlarray(X,"CBTSS"), 'Formattable', true, 'Name', "module_addspatial");
        if ~isempty(targetSize)
            inputLayer = reshapeLayer(targetSize(1), targetSize(2), [], 'OperationDimension', 'spatial-channel', 'Name', 'module_input');
        else
            inputLayer = functionLayer(@(x) x, 'Name', 'module_input');
        end
        
        % 2. SPATIAL RESOLUTION RECOVERY
        expansionConv = transposedConv2dLayer([3, 3], totalDecoderChannels, ...
            'Stride', [stride_spatial, stride_temporal], 'Cropping', 'same', 'Name', 'area_defusion_expansion');
        reluExpansion = reluLayer('Name', 'expansion_relu');
        
        % 3. INDEPENDENT AREA PROCESSING (Grouped Convolutions)
        spatialTransConv = groupedConvolution2dLayer([3, 1], filtersPerArea, numAreas, 'Padding', 'same', 'Name', 'spatial_trans_conv');
        reluSpatialTrans = reluLayer('Name', 'spatial_trans_relu');
        
        layers = [AddSpatialLayer, inputLayer, expansionConv, reluExpansion, spatialTransConv, reluSpatialTrans];
        
        % 4. TEMPORAL EXPANSION (Dynamic multi-scale, Residual Block)
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            
            for j = 1:numResidualLayers
                nameConv = ['temp_trans_conv' num2str(j) '_' num2str(kSize)];
                
                layers = [layers, ...
                    groupedConvolution2dLayer([1, kSize], filtersPerArea, numAreas, 'Padding', 'same', 'Name', nameConv)];
                
                if j < numResidualLayers
                    nameRelu = ['temp_trans_relu' num2str(j) '_' num2str(kSize)];
                    layers = [layers, reluLayer('Name', nameRelu)];
                end
            end
        end
        
        % Temporal projection (acts as the linear bypass for the residual connection)
        % Stride is [1,1] here, so kernel remains [1,1]
        tempTransProj  = groupedConvolution2dLayer([1, 1], filtersPerArea, numAreas, 'Padding', 'same', 'Name', 'temp_trans_proj');
        addTransTemp  = additionLayer(numTempKernels + 1, 'Name', 'temporal_trans_add');
        reluTransTemp = reluLayer('Name', 'temporal_trans_relu');
        
        % 5. FINAL CHANNEL REDUCTION (Independent per Area)
        finalChannelReduction = groupedConvolution2dLayer([1, 1], 1, numAreas, 'Name', 'decoder_final_reduction');
        
        % 6. PRECISION CROP LAYER
        finalCropLyr = cgg_cropLayer('decoder_precision_crop', calculatedCrop);
        
        layers = [layers, tempTransProj, addTransTemp, reluTransTemp, finalChannelReduction, finalCropLyr];
        
        for i = 1:length(layers), lgraph = addLayers(lgraph, layers(i)); end
        
        % Connections
        lgraph = connectLayers(lgraph, 'module_addspatial', 'module_input');
        lgraph = connectLayers(lgraph, 'module_input', 'area_defusion_expansion');
        lgraph = connectLayers(lgraph, 'area_defusion_expansion', 'expansion_relu');
        lgraph = connectLayers(lgraph, 'expansion_relu', 'spatial_trans_conv');
        lgraph = connectLayers(lgraph, 'spatial_trans_conv', 'spatial_trans_relu');
        
        % Connect Temporal Multi-Scale Extraction (Residual Block)
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            lastNode = 'spatial_trans_relu';
            
            for j = 1:numResidualLayers
                nameConv = ['temp_trans_conv' num2str(j) '_' num2str(kSize)];
                lgraph = connectLayers(lgraph, lastNode, nameConv);
                lastNode = nameConv;
                
                if j < numResidualLayers
                    nameRelu = ['temp_trans_relu' num2str(j) '_' num2str(kSize)];
                    lgraph = connectLayers(lgraph, lastNode, nameRelu);
                    lastNode = nameRelu;
                end
            end
            
            lgraph = connectLayers(lgraph, lastNode, ['temporal_trans_add/in' num2str(i)]);
        end
        
        % Connect linear projection bypass
        lgraph = connectLayers(lgraph, 'spatial_trans_relu', 'temp_trans_proj');
        lgraph = connectLayers(lgraph, 'temp_trans_proj', ['temporal_trans_add/in' num2str(numTempKernels + 1)]);
        
        lgraph = connectLayers(lgraph, 'temporal_trans_add', 'temporal_trans_relu');
        
        % Final touches
        lgraph = connectLayers(lgraph, 'temporal_trans_relu', 'decoder_final_reduction');
        lgraph = connectLayers(lgraph, 'decoder_final_reduction', 'decoder_precision_crop');
    end
end