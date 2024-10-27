function [PreDecoderBlock,DecoderBlocks,PostDecoderBlock] = ...
    cgg_constructDecoderBlockFeedforward(HiddenSize,InputSize,varargin)
%CGG_GENERATEENCODERBLOCKFEEDFORWARD Summary of this function goes here
%   Detailed explanation goes here


NumLevels = length(HiddenSize);


DecoderBlocks = [];
PreDecoderBlock = [];

for lidx = NumLevels:-1:1
this_DecoderBlock = cgg_generateDecoderBlockFeedforward(HiddenSize(lidx),lidx,varargin{:});

DecoderBlocks = [DecoderBlocks
                 this_DecoderBlock];
end

PostDecoderBlock = [fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out")
                    functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder")];


end