function [Encoder_FrontEnd,Encoder_BackEnd] = cgg_getEncoderPartsFromWhole(Encoder_FrontEnd_Ex,Encoder_BackEnd_Ex,Encoder_Full)
%CGG_GETENCODERPARTSFROMWHOLE Summary of this function goes here
%   Detailed explanation goes here

Encoder_FrontEnd=Encoder_FrontEnd_Ex;
Encoder_BackEnd=Encoder_BackEnd_Ex;

WeightsBiases_Full = getwb(Encoder_Full);

[Bias_Full,InputWeights_Full,LayerWeights_Full] = ...
    separatewb(Encoder_Full,WeightsBiases_Full);

Bias_FrontEnd=Bias_Full(1:end-1);
Bias_BackEnd=Bias_Full(end);

InputWeights_FrontEnd=InputWeights_Full(1:end-1);
InputWeights_BackEnd=LayerWeights_Full(end,end-1); % Input to the backend is the layer weight from front to back

LayerWeights_FrontEnd=LayerWeights_Full((1:end-1),(1:end-1));
LayerWeights_BackEnd=LayerWeights_Full(end,end);

WeightsBiases_FrontEnd=formwb(Encoder_FrontEnd,Bias_FrontEnd,InputWeights_FrontEnd,LayerWeights_FrontEnd);
WeightsBiases_BackEnd=formwb(Encoder_BackEnd,Bias_BackEnd,InputWeights_BackEnd,LayerWeights_BackEnd);

Encoder_FrontEnd = setwb(Encoder_FrontEnd,WeightsBiases_FrontEnd);
Encoder_BackEnd = setwb(Encoder_BackEnd,WeightsBiases_BackEnd);

end

