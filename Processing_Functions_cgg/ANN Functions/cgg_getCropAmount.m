function [CropSizes,UpSampleSizes] = cgg_getCropAmount(SpatialSizes,Stride,NumLayers)
%CGG_GETCROPAMOUNT Summary of this function goes here
%   Detailed explanation goes here

DownSampleSizes = cell(NumLayers+1,1);
DownSampleSizes{1} = SpatialSizes;

for lidx = 1:NumLayers
DownSampleSizes{lidx+1} = ceil(DownSampleSizes{lidx}./Stride);
end

UpSampleSizes = flipud(DownSampleSizes);
CropSizes = cell(NumLayers,1);

for lidx = 1:NumLayers
    CropSizes{lidx} = UpSampleSizes{lidx}*2 - UpSampleSizes{lidx+1};
end

CropSizes = flipud(CropSizes);

end

