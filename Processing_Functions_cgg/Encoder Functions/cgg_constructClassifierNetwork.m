function OutNet = cgg_constructClassifierNetwork(InputNet,Layers_Classifier)
%CGG_CONSTRUCTCLASSIFIERNETWORK Summary of this function goes here
%   Detailed explanation goes here


LayerGraphOut = layergraph(InputNet);

LayerNames = {LayerGraphOut.Layers{:}.Name};
LayerNamesBottleNeck = LayerNames{find(contains(LayerNames,'Encoder'),1,"last")};

NumDimensions = length(Layers_Classifier);
%%

for didx = 1:NumDimensions


end

end

