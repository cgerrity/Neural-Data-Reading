function OutNet = cgg_getTuningNetFromFullVariationalAutoEncoder(VariationalAutoEncoder,LayerGraph_Tuning)
%CGG_GETTUNINGNETFROMAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

InputNet=VariationalAutoEncoder;

LayerGraphOut = layerGraph(InputNet);

% OutputNames=InputNet.OutputNames;
LayerNames={LayerGraphOut.Layers(:).Name};
LayerNamesEndEncoder=LayerNames{find(contains(LayerNames,'Encoder'),1,'last')};
% OutputNameVariance=OutputNames{contains(OutputNames,'variance')};

NumDimensions=length(LayerGraph_Tuning);

%%

for didx=1:NumDimensions

    this_LayerGraph_Tuning=LayerGraph_Tuning{didx};
    this_Layer_Tuning=this_LayerGraph_Tuning.Layers;
    this_Layer_Tuning_Name=this_Layer_Tuning(1).Name;

LayerGraphOut = addLayers(LayerGraphOut,this_Layer_Tuning);
LayerGraphOut = connectLayers(LayerGraphOut,LayerNamesEndEncoder,this_Layer_Tuning_Name);

end

%%

OutNet=dlnetwork(LayerGraphOut);

end

