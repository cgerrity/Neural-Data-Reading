function OutNet = cgg_constructClassifierNetwork_v2(InputNet,Layers_Classifier)
%CGG_GETTUNINGNETFROMAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

LayerGraphOut = layerGraph(InputNet);

LayerNames={LayerGraphOut.Layers(:).Name};
LayerNamesBottleNeck=LayerNames{find(contains(LayerNames,'Encoder'),1,'last')};

NumDimensions=length(Layers_Classifier);

%%

for didx=1:NumDimensions

    this_Layer_Classifier=Layers_Classifier{didx};
    this_Layer_Classifier=this_Layer_Classifier.Layers;
    this_Layer_Classifier_Name=this_Layer_Classifier(1).Name;

LayerGraphOut = addLayers(LayerGraphOut,this_Layer_Classifier);
LayerGraphOut = connectLayers(LayerGraphOut,LayerNamesBottleNeck,this_Layer_Classifier_Name);

end

%%

OutNet=dlnetwork(LayerGraphOut);

end

