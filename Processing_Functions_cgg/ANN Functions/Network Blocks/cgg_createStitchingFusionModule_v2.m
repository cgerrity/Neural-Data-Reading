function lgraph = cgg_createStitchingFusionModule_v2(numAreas, filtersPerArea, varargin)
    % cgg_createStitchingFusionModule
    % Creates a stitching and fusion module for multi-area neural decoding.
    % Can be configured as an Encoder or Decoder.
    %
    % Options:
    %   'Mode'                  - 'Encoder' (default) or 'Decoder'
    %   'TargetSize'            - [best_x, best_y] derived from cgg_findOptimalDivisors
    %   'OutputSize'            - [C_final, T_final] the desired output dimensions (e.g., InputSize(1:2))
    %   'EncoderReduction'      - [SpatialReduce, TemporalReduce] factors for Encoder downsampling
    %   'ReductionMethod'       - 'maxpool' (default) or 'stride' 
    %   'StrideBypassMethod'    - 'kernel' (default) or 'avgpool'
    %   'TemporalKernelSizes'   - Array of sizes for temporal extraction (default: [3, 5, 7])
    %   'NumCascadeLayers'      - Number of sequential cascade stages (default: 1)
    %   'NumResidualLayers'     - Number of convolutional layers inside each cascade stage (default: 2)
    %   'CascadeStrideMode'     - 'single' (reduce at stage 1 only) or 'progressive' (reduce at every stage)
    %   'UseBottleneck'         - Compress channels before convolutions (default: false)
    %   'BottleneckFactor'      - Factor by which to compress channels in bottleneck (default: 2)
    %   'Normalization'         - 'none' (default), 'batchnorm', or 'layernorm'
    %   'UseDepthwiseSeparable' - Decouples spatial/temporal mapping from channel mixing (default: false)
    %   'DropoutRate'           - Adds dropout before addition layer to regularize branches (default: 0.0)
    %   'NameSuffix'            - String to append to the end of every layer name (default: '')
    
    % --- Parse Inputs ---
    p = inputParser;
    addRequired(p, 'numAreas');
    addRequired(p, 'filtersPerArea');
    addParameter(p, 'Mode', 'Encoder', @(x) any(validatestring(x, {'Encoder', 'Decoder'})));
    addParameter(p, 'TargetSize', [], @isnumeric);
    addParameter(p, 'OutputSize', [], @isnumeric);
    addParameter(p, 'EncoderReduction', [2, 2], @isnumeric);
    addParameter(p, 'ReductionMethod', 'maxpool', @(x) any(validatestring(x, {'maxpool', 'stride'})));
    addParameter(p, 'StrideBypassMethod', 'kernel', @(x) any(validatestring(x, {'kernel', 'avgpool'})));
    addParameter(p, 'TemporalKernelSizes', [3, 5, 7], @isnumeric);
    addParameter(p, 'NumCascadeLayers', 1, @isnumeric);
    addParameter(p, 'NumResidualLayers', 2, @isnumeric);
    addParameter(p, 'CascadeStrideMode', 'single', @(x) any(validatestring(x, {'single', 'progressive'})));
    addParameter(p, 'UseBottleneck', false, @islogical);
    addParameter(p, 'BottleneckFactor', 2, @isnumeric);
    addParameter(p, 'Normalization', 'none', @(x) any(validatestring(x, {'none', 'batchnorm', 'layernorm'})));
    addParameter(p, 'UseDepthwiseSeparable', false, @islogical);
    addParameter(p, 'DropoutRate', 0.0, @isnumeric);
    addParameter(p, 'NameSuffix', '', @(x) ischar(x) || isstring(x));
    parse(p, numAreas, filtersPerArea, varargin{:});
    
    mode = p.Results.Mode;
    targetSize = p.Results.TargetSize;
    outputSize = p.Results.OutputSize;
    encReduction = p.Results.EncoderReduction;
    reductionMethod = p.Results.ReductionMethod;
    strideBypassMethod = p.Results.StrideBypassMethod;
    tempKernelSizes = p.Results.TemporalKernelSizes;
    numTempKernels = length(tempKernelSizes);
    numCascadeLayers = p.Results.NumCascadeLayers;
    numResidualLayers = p.Results.NumResidualLayers;
    cascadeStrideMode = p.Results.CascadeStrideMode;
    
    useBottle = p.Results.UseBottleneck;
    botFactor = p.Results.BottleneckFactor;
    normType = p.Results.Normalization;
    useBN = ~strcmpi(normType, 'none');
    useDW = p.Results.UseDepthwiseSeparable;
    dropRate = p.Results.DropoutRate;
    nameSuffix = char(p.Results.NameSuffix);

    if ~strcmp(string(nameSuffix),"")
        nameSuffix = ['_' nameSuffix];
    end

    lgraph = layerGraph();

    if strcmpi(mode, 'Encoder')
        % =========================================================================
        % ENCODER GRAPH
        % =========================================================================
        
        inputIdentity = functionLayer(@(x) x, 'Name', ['module_input' nameSuffix]);
        layers = [inputIdentity];
        internalEdges = cell(0, 2);
        
        tempStride = [1, 1];
        spatStride = [1, 1];
        if strcmpi(reductionMethod, 'stride')
            tempStride = [1, encReduction(2)];
            spatStride = [encReduction(1), 1];
        end
        
        convFirstNode = cell(numTempKernels, numCascadeLayers, numResidualLayers);
        convLastNode = cell(numTempKernels, numCascadeLayers, numResidualLayers);
        extraFirstNode = cell(numTempKernels, numCascadeLayers);
        extraLastNode = cell(numTempKernels, numCascadeLayers);
        
        % 1. TEMPORAL EXTRACTION
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            for j = 1:numCascadeLayers
                if strcmpi(cascadeStrideMode, 'progressive') && strcmpi(reductionMethod, 'maxpool') && encReduction(2) > 1
                    namePool = ['temp_stage_pool_' num2str(kSize) '_' num2str(j) nameSuffix];
                    layers = [layers, maxPooling2dLayer([1, encReduction(2)], 'Stride', [1, encReduction(2)], 'Padding', 'same', 'Name', namePool)];
                end
                
                for k = 1:numResidualLayers
                    nameBase = ['temp_conv_' num2str(kSize) '_' num2str(j) '_' num2str(k)];
                    currStride = [1, 1];
                    if k == 1 && strcmpi(reductionMethod, 'stride') && encReduction(2) > 1
                        if strcmpi(cascadeStrideMode, 'progressive') || j == 1
                            currStride = tempStride;
                        end
                    end
                    
                    % Determine input channels for depthwise tracking
                    inFilters = filtersPerArea;
                    if j == 1 && k == 1
                        inFilters = 1; % Raw input has 1 filter per area mapping
                    end
                    
                    [blkLayers, e, fN, lN] = cgg_buildConvBlock(nameBase, nameSuffix, [1, kSize], inFilters, filtersPerArea, numAreas, currStride, useBN, normType, useDW, useBottle, botFactor);
                    layers = [layers, blkLayers];
                    internalEdges = [internalEdges; e];
                    convFirstNode{i,j,k} = fN;
                    convLastNode{i,j,k} = lN;
                    
                    if k < numResidualLayers
                        nameRelu = ['temp_res_relu_' num2str(kSize) '_' num2str(j) '_' num2str(k) nameSuffix];
                        layers = [layers, reluLayer('Name', nameRelu)];
                    end
                end
                
                if j < numCascadeLayers
                    nameCascadeRelu = ['temp_casc_relu_' num2str(kSize) '_' num2str(j) nameSuffix];
                    layers = [layers, reluLayer('Name', nameCascadeRelu)];
                end
                
                if strcmpi(cascadeStrideMode, 'progressive') && encReduction(2) > 1
                    stagesRemaining = numCascadeLayers - j;
                    if stagesRemaining > 0
                        extraStride = [1, encReduction(2)^stagesRemaining];
                        nameExtraBase = ['temp_extra_reduce_' num2str(kSize) '_' num2str(j)];
                        nameExtra = [nameExtraBase nameSuffix];
                        
                        if strcmpi(reductionMethod, 'maxpool')
                            layers = [layers, maxPooling2dLayer(extraStride, 'Stride', extraStride, 'Padding', 'same', 'Name', nameExtra)];
                            extraFirstNode{i,j} = nameExtra; extraLastNode{i,j} = nameExtra;
                        else
                            [L, e, fN, lN] = cgg_makeLayerWithNorm(groupedConvolution2dLayer(extraStride, filtersPerArea, numAreas, 'Stride', extraStride, 'Padding', 'same', 'Name', nameExtra), nameExtraBase, nameSuffix, useBN, normType);
                            layers = [layers, L];
                            internalEdges = [internalEdges; e];
                            extraFirstNode{i,j} = fN; extraLastNode{i,j} = lN;
                        end
                    end
                end
                
                % Add Dropout
                if dropRate > 0
                    nameDrop = ['temp_drop_' num2str(kSize) '_' num2str(j) nameSuffix];
                    layers = [layers, dropoutLayer(dropRate, 'Name', nameDrop)];
                end
            end
        end
        
        % Temporal projection (bypass)
        tempPoolStride = [1, 1];
        if encReduction(2) > 1
            if strcmpi(cascadeStrideMode, 'progressive')
                tempPoolStride = [1, encReduction(2)^numCascadeLayers];
            else
                tempPoolStride = [1, encReduction(2)];
            end
        end
        
        projFirstNode = ''; projSecondNode = ''; projLastNode = '';
        if encReduction(2) > 1 && (strcmpi(reductionMethod, 'stride') || strcmpi(cascadeStrideMode, 'progressive'))
            if strcmpi(strideBypassMethod, 'avgpool')
                projPoolName = ['temp_proj_pool' nameSuffix];
                layers = [layers, averagePooling2dLayer(tempPoolStride, 'Stride', tempPoolStride, 'Padding', 'same', 'Name', projPoolName)];
                [L, e, fN, lN] = cgg_makeLayerWithNorm(groupedConvolution2dLayer([1, 1], filtersPerArea, numAreas, 'Name', ['temp_proj' nameSuffix]), 'temp_proj', nameSuffix, useBN, normType);
                layers = [layers, L];
                internalEdges = [internalEdges; e];
                projFirstNode = projPoolName; projSecondNode = fN; projLastNode = lN;
            else
                [L, e, fN, lN] = cgg_makeLayerWithNorm(groupedConvolution2dLayer(tempPoolStride, filtersPerArea, numAreas, 'Stride', tempPoolStride, 'Padding', 'same', 'Name', ['temp_proj' nameSuffix]), 'temp_proj', nameSuffix, useBN, normType);
                layers = [layers, L];
                internalEdges = [internalEdges; e];
                projFirstNode = fN; projLastNode = lN;
            end
        else
            [L, e, fN, lN] = cgg_makeLayerWithNorm(groupedConvolution2dLayer([1, 1], filtersPerArea, numAreas, 'Name', ['temp_proj' nameSuffix]), 'temp_proj', nameSuffix, useBN, normType);
            layers = [layers, L];
            internalEdges = [internalEdges; e];
            projFirstNode = fN; projLastNode = lN;
        end
        
        if dropRate > 0
            layers = [layers, dropoutLayer(dropRate, 'Name', ['temp_proj_drop' nameSuffix])];
        end
        
        addTemp  = additionLayer(numTempKernels * numCascadeLayers + 1, 'Name', ['temporal_add' nameSuffix]);
        reluTemp = reluLayer('Name', ['temporal_relu' nameSuffix]);
        layers = [layers, addTemp, reluTemp];
        
        if encReduction(2) > 1 && strcmpi(reductionMethod, 'maxpool') && strcmpi(cascadeStrideMode, 'single')
            layers = [layers, maxPooling2dLayer([1, encReduction(2)], 'Stride', [1, encReduction(2)], 'Padding', 'same', 'Name', ['temporal_reduction' nameSuffix])];
        end
        
        % 2. SPATIAL EXTRACTION
        spatKernelSize = max(3, spatStride(1));
        [spatLayers, e, spatFirstNode, spatLastNode] = cgg_buildConvBlock('spatial_conv', nameSuffix, [spatKernelSize, 1], filtersPerArea, filtersPerArea, numAreas, spatStride, useBN, normType, useDW, useBottle, botFactor);
        reluSpatial = reluLayer('Name', ['spatial_relu' nameSuffix]);
        layers = [layers, spatLayers, reluSpatial];
        internalEdges = [internalEdges; e];
        
        if encReduction(1) > 1 && strcmpi(reductionMethod, 'maxpool')
            layers = [layers, maxPooling2dLayer([encReduction(1), 1], 'Stride', [encReduction(1), 1], 'Padding', 'same', 'Name', ['spatial_reduction' nameSuffix])];
        end
        
        % 3. AREA FUSION
        [fusionLayers, e, fusionFirstNode, fusionLastNode] = cgg_makeLayerWithNorm(convolution2dLayer([1, 1], filtersPerArea, 'Name', ['area_fusion' nameSuffix]), 'area_fusion', nameSuffix, useBN, normType);
        reluFusion = reluLayer('Name', ['fusion_relu' nameSuffix]);
        layers = [layers, fusionLayers, reluFusion];
        internalEdges = [internalEdges; e];
        
        % --- ADD ALL LAYERS & CONNECT ---
        for i = 1:length(layers), lgraph = addLayers(lgraph, layers(i)); end
        
        % INTERCONNECT INTERNAL BLOCKS (Prevents unconnected nodes error)
        for idx = 1:size(internalEdges, 1)
            lgraph = connectLayers(lgraph, internalEdges{idx, 1}, internalEdges{idx, 2});
        end
        
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            lastNode = ['module_input' nameSuffix];
            for j = 1:numCascadeLayers
                if strcmpi(cascadeStrideMode, 'progressive') && strcmpi(reductionMethod, 'maxpool') && encReduction(2) > 1
                    namePool = ['temp_stage_pool_' num2str(kSize) '_' num2str(j) nameSuffix];
                    lgraph = connectLayers(lgraph, lastNode, namePool);
                    lastNode = namePool;
                end
                
                for k = 1:numResidualLayers
                    lgraph = connectLayers(lgraph, lastNode, convFirstNode{i,j,k});
                    lastNode = convLastNode{i,j,k};
                    if k < numResidualLayers
                        nameRelu = ['temp_res_relu_' num2str(kSize) '_' num2str(j) '_' num2str(k) nameSuffix];
                        lgraph = connectLayers(lgraph, lastNode, nameRelu);
                        lastNode = nameRelu;
                    end
                end
                
                stageOutput = lastNode; 
                addInputIndex = (i - 1) * numCascadeLayers + j;
                targetAdd = ['temporal_add' nameSuffix '/in' num2str(addInputIndex)];
                
                branchEnd = stageOutput;
                if strcmpi(cascadeStrideMode, 'progressive') && encReduction(2) > 1 && (numCascadeLayers - j) > 0
                    lgraph = connectLayers(lgraph, stageOutput, extraFirstNode{i,j});
                    branchEnd = extraLastNode{i,j};
                end
                
                if dropRate > 0
                    nameDrop = ['temp_drop_' num2str(kSize) '_' num2str(j) nameSuffix];
                    lgraph = connectLayers(lgraph, branchEnd, nameDrop);
                    lgraph = connectLayers(lgraph, nameDrop, targetAdd);
                else
                    lgraph = connectLayers(lgraph, branchEnd, targetAdd);
                end
                
                if j < numCascadeLayers
                    nameCascadeRelu = ['temp_casc_relu_' num2str(kSize) '_' num2str(j) nameSuffix];
                    lgraph = connectLayers(lgraph, stageOutput, nameCascadeRelu);
                    lastNode = nameCascadeRelu;
                end
            end
        end
        
        % Connect Bypass
        if strcmp(projFirstNode, ['temp_proj_pool' nameSuffix])
            lgraph = connectLayers(lgraph, ['module_input' nameSuffix], projFirstNode);
            lgraph = connectLayers(lgraph, projFirstNode, projSecondNode); 
        else
            lgraph = connectLayers(lgraph, ['module_input' nameSuffix], projFirstNode);
        end
        
        targetAddBypass = ['temporal_add' nameSuffix '/in' num2str(numTempKernels * numCascadeLayers + 1)];
        if dropRate > 0
            dropProjName = ['temp_proj_drop' nameSuffix];
            lgraph = connectLayers(lgraph, projLastNode, dropProjName);
            lgraph = connectLayers(lgraph, dropProjName, targetAddBypass);
        else
            lgraph = connectLayers(lgraph, projLastNode, targetAddBypass);
        end
        
        lgraph = connectLayers(lgraph, ['temporal_add' nameSuffix], ['temporal_relu' nameSuffix]);
        
        lastTemporal = ['temporal_relu' nameSuffix];
        if encReduction(2) > 1 && strcmpi(reductionMethod, 'maxpool') && strcmpi(cascadeStrideMode, 'single')
            redTemporal = ['temporal_reduction' nameSuffix];
            lgraph = connectLayers(lgraph, lastTemporal, redTemporal);
            lastTemporal = redTemporal;
        end
        
        lgraph = connectLayers(lgraph, lastTemporal, spatFirstNode);
        lgraph = connectLayers(lgraph, spatLastNode, ['spatial_relu' nameSuffix]);
        
        lastSpatial = ['spatial_relu' nameSuffix];
        if encReduction(1) > 1 && strcmpi(reductionMethod, 'maxpool')
            redSpatial = ['spatial_reduction' nameSuffix];
            lgraph = connectLayers(lgraph, lastSpatial, redSpatial);
            lastSpatial = redSpatial;
        end
        
        lgraph = connectLayers(lgraph, lastSpatial, fusionFirstNode);
        lgraph = connectLayers(lgraph, fusionLastNode, ['fusion_relu' nameSuffix]);

    else
        % =========================================================================
        % DECODER GRAPH
        % =========================================================================
        cascadeExpand = 1;
        internalEdges = cell(0, 2);
        
        if encReduction(2) > 1
            if strcmpi(cascadeStrideMode, 'progressive')
                cascadeExpand = encReduction(2)^numCascadeLayers;
            else
                cascadeExpand = encReduction(2); 
            end
        end

        if ~isempty(outputSize) && ~isempty(targetSize)
            best_ty = targetSize(2);
            for f = 1:targetSize(2)
                if mod(targetSize(2), f) == 0
                    test_ty = targetSize(2) / f;
                    if test_ty * cascadeExpand >= outputSize(2)
                        best_ty = test_ty;
                    else
                        break; 
                    end
                end
            end
            targetSize(2) = best_ty;
            
            best_tx = targetSize(1);
            for f = 1:targetSize(1)
                if mod(targetSize(1), f) == 0
                    test_tx = targetSize(1) / f;
                    if test_tx * 1 >= outputSize(1)
                        best_tx = test_tx;
                    else
                        break;
                    end
                end
            end
            targetSize(1) = best_tx;
        end

        stride_spatial = 1; stride_temporal = 1;
        calculatedCrop = [0, 0];
        
        if ~isempty(outputSize) && ~isempty(targetSize)
            stride_spatial = ceil(outputSize(1) / targetSize(1));
            stride_temporal = ceil(outputSize(2) / targetSize(2));
        end

        base_stride_spatial = stride_spatial;
        base_stride_temporal = max(1, ceil(stride_temporal / cascadeExpand));

        if ~isempty(outputSize) && ~isempty(targetSize)
            actual_x = targetSize(1) * base_stride_spatial;
            actual_y = targetSize(2) * base_stride_temporal * cascadeExpand;
            calculatedCrop = [max(0, actual_x - outputSize(1)), max(0, actual_y - outputSize(2))];
        end

        totalDecoderChannels = numAreas * filtersPerArea;
        
        AddSpatialLayer = functionLayer(@(X) dlarray(X,"CBTSS"), 'Formattable', true, 'Name', ['module_addspatial' nameSuffix]);
        if ~isempty(targetSize)
            inputLayer = reshapeLayer(targetSize(1), targetSize(2), [], 'OperationDimension', 'spatial-channel', 'Name', ['module_input' nameSuffix]);
        else
            inputLayer = functionLayer(@(x) x, 'Name', ['module_input' nameSuffix]);
        end
        
        expansion_kernel_spatial = max(3, base_stride_spatial);
        expansion_kernel_temporal = max(3, base_stride_temporal);
        nameExpBase = 'area_defusion_expansion';
        nameExp = [nameExpBase nameSuffix];
        [expLayers, e_exp, expFirst, expLast] = cgg_makeLayerWithNorm(transposedConv2dLayer([expansion_kernel_spatial, expansion_kernel_temporal], totalDecoderChannels, ...
            'Stride', [base_stride_spatial, base_stride_temporal], 'Cropping', 'same', 'Name', nameExp), nameExpBase, nameSuffix, useBN, normType);
        reluExpansion = reluLayer('Name', ['expansion_relu' nameSuffix]);
        
        [spatLayers, e_spat, spatFirst, spatLast] = cgg_buildConvBlock('spatial_trans_conv', nameSuffix, [3, 1], filtersPerArea, filtersPerArea, numAreas, [1, 1], useBN, normType, useDW, useBottle, botFactor);
        reluSpatialTrans = reluLayer('Name', ['spatial_trans_relu' nameSuffix]);
        
        layers = [AddSpatialLayer, inputLayer, expLayers, reluExpansion, spatLayers, reluSpatialTrans];
        internalEdges = [internalEdges; e_exp; e_spat];
        
        convFirstNode = cell(numTempKernels, numCascadeLayers, numResidualLayers);
        convLastNode = cell(numTempKernels, numCascadeLayers, numResidualLayers);
        expandFirstNode = cell(numTempKernels, numCascadeLayers);
        expandLastNode = cell(numTempKernels, numCascadeLayers);
        extraExpandFirstNode = cell(numTempKernels, numCascadeLayers);
        extraExpandLastNode = cell(numTempKernels, numCascadeLayers);
        
        % 4. TEMPORAL EXPANSION
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            for j = 1:numCascadeLayers
                applyExpand = false;
                if encReduction(2) > 1
                    if strcmpi(cascadeStrideMode, 'progressive') || j == 1
                        applyExpand = true; 
                    end
                end
                
                if applyExpand
                    nameExpandBase = ['temp_expand_' num2str(kSize) '_' num2str(j)];
                    nameExpand = [nameExpandBase nameSuffix];
                    expandKernelSize = max(3, encReduction(2));
                    [L, e, fN, lN] = cgg_makeLayerWithNorm(transposedConv2dLayer([1, expandKernelSize], totalDecoderChannels, ...
                        'Stride', [1, encReduction(2)], 'Cropping', 'same', 'Name', nameExpand), nameExpandBase, nameSuffix, useBN, normType);
                    layers = [layers, L];
                    internalEdges = [internalEdges; e];
                    expandFirstNode{i,j} = fN; expandLastNode{i,j} = lN;
                end
                
                for k = 1:numResidualLayers
                    nameBase = ['temp_trans_conv_' num2str(kSize) '_' num2str(j) '_' num2str(k)];
                    [blkLayers, e, fN, lN] = cgg_buildConvBlock(nameBase, nameSuffix, [1, kSize], filtersPerArea, filtersPerArea, numAreas, [1, 1], useBN, normType, useDW, useBottle, botFactor);
                    layers = [layers, blkLayers];
                    internalEdges = [internalEdges; e];
                    convFirstNode{i,j,k} = fN; convLastNode{i,j,k} = lN;
                    
                    if k < numResidualLayers
                        nameRelu = ['temp_trans_res_relu_' num2str(kSize) '_' num2str(j) '_' num2str(k) nameSuffix];
                        layers = [layers, reluLayer('Name', nameRelu)];
                    end
                end
                
                if j < numCascadeLayers
                    nameCascadeRelu = ['temp_trans_casc_relu_' num2str(kSize) '_' num2str(j) nameSuffix];
                    layers = [layers, reluLayer('Name', nameCascadeRelu)];
                end
                
                if encReduction(2) > 1 && strcmpi(cascadeStrideMode, 'progressive')
                    stagesRemaining = numCascadeLayers - j;
                    if stagesRemaining > 0
                        extraStride = [1, encReduction(2)^stagesRemaining];
                        nameExtraBase = ['temp_extra_expand_' num2str(kSize) '_' num2str(j)];
                        nameExtra = [nameExtraBase nameSuffix];
                        extraExpandKernelSize = max(3, extraStride(2));
                        
                        [L, e, fN, lN] = cgg_makeLayerWithNorm(transposedConv2dLayer([1, extraExpandKernelSize], totalDecoderChannels, ...
                            'Stride', extraStride, 'Cropping', 'same', 'Name', nameExtra), nameExtraBase, nameSuffix, useBN, normType);
                        layers = [layers, L];
                        internalEdges = [internalEdges; e];
                        extraExpandFirstNode{i,j} = fN; extraExpandLastNode{i,j} = lN;
                    end
                end
                
                if dropRate > 0
                    nameDrop = ['temp_trans_drop_' num2str(kSize) '_' num2str(j) nameSuffix];
                    layers = [layers, dropoutLayer(dropRate, 'Name', nameDrop)];
                end
            end
        end
        
        if cascadeExpand > 1
            projExpandKernelSize = max(3, cascadeExpand);
            nameProjBase = 'temp_trans_proj';
            nameProj = [nameProjBase nameSuffix];
            [L, e, projFirstNode, projLastNode] = cgg_makeLayerWithNorm(transposedConv2dLayer([1, projExpandKernelSize], totalDecoderChannels, ...
                'Stride', [1, cascadeExpand], 'Cropping', 'same', 'Name', nameProj), nameProjBase, nameSuffix, useBN, normType);
        else
            nameProjBase = 'temp_trans_proj';
            nameProj = [nameProjBase nameSuffix];
            [L, e, projFirstNode, projLastNode] = cgg_makeLayerWithNorm(groupedConvolution2dLayer([1, 1], filtersPerArea, numAreas, 'Padding', 'same', 'Name', nameProj), nameProjBase, nameSuffix, useBN, normType);
        end
        layers = [layers, L];
        internalEdges = [internalEdges; e];
        
        if dropRate > 0
            layers = [layers, dropoutLayer(dropRate, 'Name', ['temp_trans_proj_drop' nameSuffix])];
        end
        
        addTransTemp  = additionLayer(numTempKernels * numCascadeLayers + 1, 'Name', ['temporal_trans_add' nameSuffix]);
        reluTransTemp = reluLayer('Name', ['temporal_trans_relu' nameSuffix]);
        
        finalChannelReduction = groupedConvolution2dLayer([1, 1], 1, numAreas, 'Name', ['decoder_final_reduction' nameSuffix]);
        finalCropLyr = cgg_cropLayer(['decoder_precision_crop' nameSuffix], calculatedCrop);
        
        layers = [layers, addTransTemp, reluTransTemp, finalChannelReduction, finalCropLyr];
        
        % --- ADD ALL LAYERS & CONNECT ---
        for i = 1:length(layers), lgraph = addLayers(lgraph, layers(i)); end
        
        % INTERCONNECT INTERNAL BLOCKS
        for idx = 1:size(internalEdges, 1)
            lgraph = connectLayers(lgraph, internalEdges{idx, 1}, internalEdges{idx, 2});
        end
        
        lgraph = connectLayers(lgraph, ['module_addspatial' nameSuffix], ['module_input' nameSuffix]);
        lgraph = connectLayers(lgraph, ['module_input' nameSuffix], expFirst);
        lgraph = connectLayers(lgraph, expLast, ['expansion_relu' nameSuffix]);
        lgraph = connectLayers(lgraph, ['expansion_relu' nameSuffix], spatFirst);
        lgraph = connectLayers(lgraph, spatLast, ['spatial_trans_relu' nameSuffix]);
        
        for i = 1:numTempKernels
            kSize = tempKernelSizes(i);
            lastNode = ['spatial_trans_relu' nameSuffix];
            
            for j = 1:numCascadeLayers
                if encReduction(2) > 1 && (strcmpi(cascadeStrideMode, 'progressive') || j == 1)
                    lgraph = connectLayers(lgraph, lastNode, expandFirstNode{i,j});
                    lastNode = expandLastNode{i,j};
                end
                
                for k = 1:numResidualLayers
                    lgraph = connectLayers(lgraph, lastNode, convFirstNode{i,j,k});
                    lastNode = convLastNode{i,j,k};
                    if k < numResidualLayers
                        nameRelu = ['temp_trans_res_relu_' num2str(kSize) '_' num2str(j) '_' num2str(k) nameSuffix];
                        lgraph = connectLayers(lgraph, lastNode, nameRelu);
                        lastNode = nameRelu;
                    end
                end
                
                stageOutput = lastNode;
                addInputIndex = (i - 1) * numCascadeLayers + j;
                targetAdd = ['temporal_trans_add' nameSuffix '/in' num2str(addInputIndex)];
                
                branchEnd = stageOutput;
                if encReduction(2) > 1 && strcmpi(cascadeStrideMode, 'progressive') && (numCascadeLayers - j) > 0
                    lgraph = connectLayers(lgraph, stageOutput, extraExpandFirstNode{i,j});
                    branchEnd = extraExpandLastNode{i,j};
                end
                
                if dropRate > 0
                    nameDrop = ['temp_trans_drop_' num2str(kSize) '_' num2str(j) nameSuffix];
                    lgraph = connectLayers(lgraph, branchEnd, nameDrop);
                    lgraph = connectLayers(lgraph, nameDrop, targetAdd);
                else
                    lgraph = connectLayers(lgraph, branchEnd, targetAdd);
                end
                
                if j < numCascadeLayers
                    nameCascadeRelu = ['temp_trans_casc_relu_' num2str(kSize) '_' num2str(j) nameSuffix];
                    lgraph = connectLayers(lgraph, stageOutput, nameCascadeRelu);
                    lastNode = nameCascadeRelu;
                end
            end
        end
        
        targetAddBypass = ['temporal_trans_add' nameSuffix '/in' num2str(numTempKernels * numCascadeLayers + 1)];
        if dropRate > 0
            dropProjName = ['temp_trans_proj_drop' nameSuffix];
            lgraph = connectLayers(lgraph, ['spatial_trans_relu' nameSuffix], projFirstNode);
            lgraph = connectLayers(lgraph, projLastNode, dropProjName);
            lgraph = connectLayers(lgraph, dropProjName, targetAddBypass);
        else
            lgraph = connectLayers(lgraph, ['spatial_trans_relu' nameSuffix], projFirstNode);
            lgraph = connectLayers(lgraph, projLastNode, targetAddBypass);
        end
        
        lgraph = connectLayers(lgraph, ['temporal_trans_add' nameSuffix], ['temporal_trans_relu' nameSuffix]);
        lgraph = connectLayers(lgraph, ['temporal_trans_relu' nameSuffix], ['decoder_final_reduction' nameSuffix]);
        lgraph = connectLayers(lgraph, ['decoder_final_reduction' nameSuffix], ['decoder_precision_crop' nameSuffix]);
    end
end

% --- UTILITY: HELPER FOR CONVOLUTIONAL BLOCKS ---
function [blkLayers, internalEdges, firstName, lastName] = cgg_buildConvBlock(nameBase, nameSuffix, kSize, inFilters, outFilters, numAreas, currStride, useBN, normType, useDW, useBottle, botFactor)
    blkLayers = [];
    internalEdges = cell(0, 2);
    
    midFilters = outFilters;
    midInFilters = inFilters;
    midStride = currStride;

    if useBottle && prod(kSize) > 1
        midFilters = max(1, floor(outFilters / botFactor));
        botCompNameBase = [nameBase '_bot_comp'];
        botCompName = [botCompNameBase nameSuffix];
        [L, e, fN, ~] = cgg_makeLayerWithNorm(groupedConvolution2dLayer([1, 1], midFilters, numAreas, 'Stride', currStride, 'Name', botCompName), botCompNameBase, nameSuffix, useBN, normType);
        
        reluNodeName = [nameBase '_bot_comp_relu' nameSuffix];
        reluNode = reluLayer('Name', reluNodeName);
        blkLayers = [blkLayers, L, reluNode];
        internalEdges = [internalEdges; e; {L(end).Name, reluNode.Name}];
        
        midInFilters = midFilters;
        midStride = [1, 1];
    end

    if useDW && prod(kSize) > 1
        dwNameBase = [nameBase '_dw'];
        dwName = [dwNameBase nameSuffix];
        [L_dw, e_dw, fN_dw, lN_dw] = cgg_makeLayerWithNorm(groupedConvolution2dLayer(kSize, 1, numAreas * midInFilters, 'Stride', midStride, 'Padding', 'same', 'Name', dwName), dwNameBase, nameSuffix, useBN, normType);
        
        pwNameBase = [nameBase '_pw'];
        pwName = [pwNameBase nameSuffix];
        [L_pw, e_pw, fN_pw, lN_pw] = cgg_makeLayerWithNorm(groupedConvolution2dLayer([1, 1], midFilters, numAreas, 'Name', pwName), pwNameBase, nameSuffix, useBN, normType);
        
        if isempty(blkLayers)
            blkLayers = [L_dw, L_pw];
            internalEdges = [e_dw; {lN_dw, fN_pw}; e_pw];
        else
            internalEdges = [internalEdges; {blkLayers(end).Name, fN_dw}; e_dw; {lN_dw, fN_pw}; e_pw];
            blkLayers = [blkLayers, L_dw, L_pw];
        end
    else
        convNameBase = [nameBase '_conv'];
        convName = [convNameBase nameSuffix];
        [L_std, e_std, fN_std, lN_std] = cgg_makeLayerWithNorm(groupedConvolution2dLayer(kSize, midFilters, numAreas, 'Stride', midStride, 'Padding', 'same', 'Name', convName), convNameBase, nameSuffix, useBN, normType);
        if isempty(blkLayers)
            blkLayers = L_std;
            internalEdges = e_std;
        else
            internalEdges = [internalEdges; {blkLayers(end).Name, fN_std}; e_std];
            blkLayers = [blkLayers, L_std];
        end
    end

    if useBottle && prod(kSize) > 1
        reluMidName = [nameBase '_bot_mid_relu' nameSuffix];
        reluMid = reluLayer('Name', reluMidName);
        
        expNameBase = [nameBase '_bot_exp'];
        expName = [expNameBase nameSuffix];
        [L_exp, e_exp, fN_exp, lN_exp] = cgg_makeLayerWithNorm(groupedConvolution2dLayer([1, 1], outFilters, numAreas, 'Name', expName), expNameBase, nameSuffix, useBN, normType);
        
        internalEdges = [internalEdges; {blkLayers(end).Name, reluMid.Name}; {reluMid.Name, fN_exp}; e_exp];
        blkLayers = [blkLayers, reluMid, L_exp];
    end

    firstName = blkLayers(1).Name;
    lastName = blkLayers(end).Name;
end

function [blkLayers, internalEdges, fName, lName] = cgg_makeLayerWithNorm(baseLayer, baseName, nameSuffix, useBN, normType)
    blkLayers = baseLayer;
    internalEdges = cell(0, 2);
    fName = baseLayer.Name;
    lName = baseLayer.Name;
    if useBN
        normName = [baseName '_bn' nameSuffix];
        if strcmpi(normType, 'layernorm')
            normName = [baseName '_ln' nameSuffix];
        end
        if strcmpi(normType, 'batchnorm')
            normLayer = batchNormalizationLayer('Name', normName);
        else
            normLayer = layerNormalizationLayer('Name', normName);
        end
        blkLayers = [blkLayers, normLayer];
        internalEdges = {baseLayer.Name, normLayer.Name};
        lName = normLayer.Name;
    end
end
