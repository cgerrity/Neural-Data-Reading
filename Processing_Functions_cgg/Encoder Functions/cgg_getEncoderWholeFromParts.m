function [Encoder_Full] = cgg_getEncoderWholeFromParts(Encoder_FrontEnd,Encoder_BackEnd,Encoder_Full_Ex)
%CGG_GETENCODERWHOLEFROMPARTS Summary of this function goes here
%   Detailed explanation goes here

Encoder_Full=Encoder_Full_Ex;

WeightsBiases_FrontEnd = getwb(Encoder_FrontEnd);
WeightsBiases_BackEnd = getwb(Encoder_BackEnd);

[Bias_FrontEnd,InputWeights_FrontEnd,LayerWeights_FrontEnd] = ...
    separatewb(Encoder_FrontEnd,WeightsBiases_FrontEnd);
[Bias_BackEnd,InputWeights_BackEnd,LayerWeights_BackEnd] = ...
    separatewb(Encoder_BackEnd,WeightsBiases_BackEnd);

Bias_Full=[Bias_FrontEnd;Bias_BackEnd];

NumLayers=numel(Bias_Full);

InputWeights_Full=cell(NumLayers,1);
InputWeights_Full(1:end-1)=InputWeights_FrontEnd;

LayerWeights_Full=cell(NumLayers);

LayerWeights_Full(1:end-1,1:end-1)=LayerWeights_FrontEnd;
LayerWeights_Full(end,end-1)=InputWeights_BackEnd;

WeightsBiases_Full=formwb(Encoder_Full,Bias_Full,InputWeights_Full,LayerWeights_Full);

Encoder_Full = setwb(Encoder_Full,WeightsBiases_Full);

end

