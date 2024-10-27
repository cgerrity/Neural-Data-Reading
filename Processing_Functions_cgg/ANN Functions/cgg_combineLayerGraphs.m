function LG_Combined = cgg_combineLayerGraphs(LG_1,LG_2)
%CGG_COMBINELAYERGRAPHS Summary of this function goes here
%   Detailed explanation goes here


Source_1 = LG_1.Connections.Source;
Destination_1 = LG_1.Connections.Destination;

Layers_2 = LG_2.Layers;
Source_2 = LG_2.Connections.Source;
Destination_2 = LG_2.Connections.Destination;

Source_Connect = [Source_1; Source_2];
Destination_Connect = [Destination_1; Destination_2];
NumConnections = length(Source_Connect);

LG_Combined = addLayers(LG_1,Layers_2);

Source_Disconnect = LG_Combined.Connections.Source;
Destination_Disconnect = LG_Combined.Connections.Destination;
NumDisconnections = length(Source_Disconnect);

%% Disconnect all layers
for cidx = 1:NumDisconnections
    this_Source = Source_Disconnect{cidx};
    this_Destination = Destination_Disconnect{cidx};
    LG_Combined = disconnectLayers(LG_Combined,this_Source,this_Destination);
end

%% Reconnect original layers
for cidx = 1:NumConnections
    this_Source = Source_Connect{cidx};
    this_Destination = Destination_Connect{cidx};
    LG_Combined = connectLayers(LG_Combined,this_Source,this_Destination);
end


%%
end

