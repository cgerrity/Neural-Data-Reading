function Encoder = cgg_getEncoderFromAutoEncoder(AutoEncoder)
%CGG_GETENCODERFROMAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

Layer_Names={AutoEncoder.Layers(:).Name};

% Layer_Decoder_IDX=contains(Layer_Names,'Decoder');
Layer_Encoder_IDX=contains(Layer_Names,'Encoder');

% Layers_Names_Decoder=Layer_Names(Layer_Decoder_IDX);
Layers_Names_NotEncoder=Layer_Names(~Layer_Encoder_IDX);

LayerGraphOut = layerGraph(AutoEncoder);
% LayerGraphOut = removeLayers(LayerGraphOut,Layers_Names_Decoder);
LayerGraphOut = removeLayers(LayerGraphOut,Layers_Names_NotEncoder);

Encoder=dlnetwork(LayerGraphOut);

end

