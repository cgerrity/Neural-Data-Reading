function OutNet = cgg_getTuningNetFromAutoEncoder(Encoder,LayerGraph_Tuning)
%CGG_GETTUNINGNETFROMAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here


LayerGraphOut = layerGraph(Encoder);

LayerName_EncoderLast=LayerGraphOut.Layers(end).Name;

NumDimensions=length(LayerGraph_Tuning);

%%

for didx=1:NumDimensions

    this_LayerGraph_Tuning=LayerGraph_Tuning{didx};
    this_Layer_Tuning=this_LayerGraph_Tuning.Layers;
    this_Layer_Tuning_Name=this_Layer_Tuning(1).Name;

LayerGraphOut = addLayers(LayerGraphOut,this_Layer_Tuning);
LayerGraphOut = connectLayers(LayerGraphOut,LayerName_EncoderLast,this_Layer_Tuning_Name);

end

%%

OutNet=dlnetwork(LayerGraphOut);

end

