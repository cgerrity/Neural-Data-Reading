function CoderBlock = cgg_constructSingleAreaConvolutionalCoder(FilterSizes,FilterHiddenSizes,AreaIDX,varargin)
%CGG_CONSTRUCTCONVOLUTIONALCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Coder = CheckVararginPairs('Coder', 'Encoder', varargin{:});
else
if ~(exist('Coder','var'))
Coder='Encoder';
end
end

Coder_Name = sprintf("_%s",Coder);

NumFilters = length(FilterSizes);

if NumFilters > 1
    if ~isnan(AreaIDX)
        Area_Name = sprintf("_Area-%d",AreaIDX);
    else
        Area_Name = "";
    end
FilterConcatenationName="concatenationFilter" + Coder_Name + Area_Name;

FilterConcatenationLayer = depthConcatenationLayer(NumFilters,"Name",FilterConcatenationName);
CoderBlock = layerGraph(FilterConcatenationLayer);
end
%%

for fidx = 1:NumFilters
    
    if NumFilters > 1
        FilterNumber = fidx;
    else
        FilterNumber = NaN;
    end

this_FilterSize = FilterSizes(fidx);

FilterBlocks = cgg_generateSingleConvolutionalPath(this_FilterSize,FilterHiddenSizes,FilterNumber,AreaIDX,varargin{:});

    if NumFilters > 1
        CoderBlock = addLayers(CoderBlock,FilterBlocks);
        this_Destination = FilterConcatenationName + sprintf("/in%d",fidx);
        CoderBlock = connectLayers(CoderBlock,...
            FilterBlocks(end).Name,this_Destination);
    else
        if strcmp(class(FilterBlocks),'nnet.cnn.layer.Layer')
            CoderBlock = layerGraph(FilterBlocks);
        else 
            CoderBlock = FilterBlocks;
        end
    end

end

end

