function CoderBlock_Name = cgg_generateCoderBlockName(Coder,AreaIDX,FilterNumber,Level,varargin)
%CGG_GENERATECODERBLOCKNAME Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
BlockDepth = CheckVararginPairs('BlockDepth', NaN, varargin{:});
else
if ~(exist('BlockDepth','var'))
BlockDepth=NaN; % Number of convolutional and activation layers in a single block
end
end

if isfunction
IsGrouped = CheckVararginPairs('IsGrouped', true, varargin{:});
else
if ~(exist('IsGrouped','var'))
IsGrouped=true; % Number of convolutional and activation layers in a single block
end
end
%%
if IsGrouped
    CoderBlock_Name = sprintf("%s",Coder);

if ~isnan(AreaIDX)
    this_Name = sprintf("Area-%d",AreaIDX);
    CoderBlock_Name = cgg_generateLayerName(CoderBlock_Name,this_Name,'IsGrouped',IsGrouped);
end

if ~isnan(FilterNumber)
    this_Name = sprintf("Filter-%d",FilterNumber);
    CoderBlock_Name = cgg_generateLayerName(CoderBlock_Name,this_Name,'IsGrouped',IsGrouped);
end

if ~isnan(Level)
    this_Name = sprintf("Layer-%d",Level);
    CoderBlock_Name = cgg_generateLayerName(CoderBlock_Name,this_Name,'IsGrouped',IsGrouped);
end

if ~isnan(BlockDepth)
    this_Name = sprintf("BlockDepth-%d",BlockDepth);
    CoderBlock_Name = cgg_generateLayerName(CoderBlock_Name,this_Name,'IsGrouped',IsGrouped);
end
%%
else
    CoderBlock_Name = sprintf("_%s",Coder);

if ~isnan(AreaIDX)
    CoderBlock_Name = sprintf("%s_Area-%d",CoderBlock_Name,AreaIDX);
end

if ~isnan(FilterNumber)
    CoderBlock_Name = sprintf("%s_Filter-%d",CoderBlock_Name,FilterNumber);
end

if ~isnan(Level)
    CoderBlock_Name = sprintf("%s_Layer-%d",CoderBlock_Name,Level);
end

if ~isnan(BlockDepth)
    CoderBlock_Name = sprintf("%s_BlockDepth-%d",CoderBlock_Name,BlockDepth);
end
 
end

end

