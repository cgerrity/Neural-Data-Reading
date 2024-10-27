function [PreEncoderBlock,EncoderBlocks,PostEncoderBlock] = ...
    cgg_constructEncoderBlockFeedforward(HiddenSize,varargin)
%CGG_GENERATEENCODERBLOCKFEEDFORWARD Summary of this function goes here
%   Detailed explanation goes here


NumLevels = length(HiddenSize);


EncoderBlocks = [];
PreEncoderBlock = [];
PostEncoderBlock = [];

for lidx = 1:NumLevels
this_EncoderBlock = cgg_generateEncoderBlockFeedforward(HiddenSize(lidx),lidx,varargin{:});

EncoderBlocks = [EncoderBlocks
                 this_EncoderBlock];
end


end
