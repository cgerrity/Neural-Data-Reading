function [PreEncoderBlock,EncoderBlocks,PostEncoderBlock] = ...
    cgg_constructEncoderBlockGRU(HiddenSize,varargin)
%CGG_GENERATEENCODERBLOCKGRU Summary of this function goes here
%   Detailed explanation goes here


NumLevels = length(HiddenSize);

EncoderBlocks = [];
PreEncoderBlock = [];
PostEncoderBlock = [];

for lidx = 1:NumLevels
this_EncoderBlock = cgg_generateEncoderBlockGRU(HiddenSize(lidx),lidx,varargin{:});

EncoderBlocks = [EncoderBlocks
                 this_EncoderBlock];
end


end
