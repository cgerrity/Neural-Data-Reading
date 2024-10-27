function [PreDecoderBlock,DecoderBlocks,PostDecoderBlock] = ...
    cgg_constructDecoderBlockGRU(HiddenSize,varargin)
%CGG_GENERATEDecoderBLOCKGRU Summary of this function goes here
%   Detailed explanation goes here


NumLevels = length(HiddenSize);

DecoderBlocks = [];
PreDecoderBlock = [];
PostDecoderBlock = [];

for lidx = 1:NumLevels
this_DecoderBlock = cgg_generateDecoderBlockGRU(HiddenSize(lidx),lidx,varargin{:});

DecoderBlocks = [DecoderBlocks
                 this_DecoderBlock];
end


end
