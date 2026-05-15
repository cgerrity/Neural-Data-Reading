function OutName = cgg_generateLayerName(AdditionalName,LayerName,varargin)
%CGG_GENERATELAYERNAME Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
IsGrouped = CheckVararginPairs('IsGrouped', false, varargin{:});
else
if ~(exist('IsGrouped','var'))
IsGrouped=false; % Number of convolutional and activation layers in a single block
end
end

if startsWith(AdditionalName,"_")
    AdditionalName = extractAfter(AdditionalName, 1);
end

if IsGrouped
    OutName= AdditionalName + ":" + LayerName;
else
    OutName = LayerName + "_" + AdditionalName;
end
end