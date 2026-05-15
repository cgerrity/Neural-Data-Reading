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

if isfunction
WantSingleResidualBlock = CheckVararginPairs('WantSingleResidualBlock', false, varargin{:});
else
if ~(exist('WantSingleResidualBlock','var'))
WantSingleResidualBlock=false;
end
end

if isfunction
TemporalAndSpatialFusionSize = CheckVararginPairs('TemporalAndSpatialFusionSize', [1,1], varargin{:});
else
if ~(exist('TemporalAndSpatialFusionSize','var'))
TemporalAndSpatialFusionSize=[1,1];
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
IsGrouped = false;
FilterConcatenationLayer = depthConcatenationLayer(NumFilters,"Name",FilterConcatenationName);
% NumFiltersOnebyOne = round(FilterHiddenSizes(end)*NumFilters/2);
NumFiltersTemporalAndSpatialFusion = round(FilterHiddenSizes(end));
if isequal(TemporalAndSpatialFusionSize,[1,1])
% NumFiltersTemporalAndSpatialFusion = round(FilterHiddenSizes(end));
OnebyOneName = cgg_generateLayerName("Filter" + Coder_Name + Area_Name,"convolutional1x1",'IsGrouped',IsGrouped);
OnebyOneLayer = convolution2dLayer(TemporalAndSpatialFusionSize,NumFiltersTemporalAndSpatialFusion,"Name",OnebyOneName,"Padding",'same','Stride',[1,1],"WeightsInitializer","he");
else
% NumFiltersTemporalAndSpatialFusion = round(FilterHiddenSizes(end));
TemporalSpatialName = cgg_generateLayerName("Filter" + Coder_Name + Area_Name,"convolutionaltemporalspatial",'IsGrouped',IsGrouped);
switch Coder
    case 'Decoder'
        TemporalSpatialStride = 1;
    otherwise
        TemporalSpatialStride = ceil(TemporalAndSpatialFusionSize/2);
end
TemporalSpatialLayer = convolution2dLayer(TemporalAndSpatialFusionSize,NumFiltersTemporalAndSpatialFusion,"Name",TemporalSpatialName,"Padding",'same','Stride',TemporalSpatialStride,"WeightsInitializer","he");

OnebyOneLayer = TemporalSpatialLayer;
end
FilterLayer = [FilterConcatenationLayer
                OnebyOneLayer];
CoderBlock = layerGraph(FilterLayer);
end
%%

for fidx = 1:NumFilters
    
    if NumFilters > 1
        FilterNumber = fidx;
    else
        FilterNumber = NaN;
    end

    if iscell(FilterSizes)
        this_FilterSize = FilterSizes{fidx};
    else
        this_FilterSize = FilterSizes(fidx);
    end

    this_varargin = varargin;
    % if WantResidualBlock
    %     this_varargin = cgg_changeFieldFromVarargin(this_varargin,'WantResnet',false);
    % end

FilterBlocks = cgg_generateSingleConvolutionalPath(this_FilterSize,FilterHiddenSizes,FilterNumber,AreaIDX,this_varargin{:});

    if NumFilters > 1
        this_Destination = FilterConcatenationName + sprintf("/in%d",fidx);
        if isa(FilterBlocks,'nnet.cnn.LayerGraph')
            CoderBlock = cgg_connectLayerGraphs(FilterBlocks,CoderBlock,'DestinationHint',this_Destination);
        else
        CoderBlock = addLayers(CoderBlock,FilterBlocks);
        CoderBlock = connectLayers(CoderBlock,...
            FilterBlocks(end).Name,this_Destination);
        end
    else
        if strcmp(class(FilterBlocks),'nnet.cnn.layer.Layer')
            CoderBlock = layerGraph(FilterBlocks);
        else 
            CoderBlock = FilterBlocks;
        end
    end

end

if WantSingleResidualBlock
CoderBlock = cgg_constructMergedResidual(CoderBlock,true);
end

end

