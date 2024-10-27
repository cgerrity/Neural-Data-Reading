function [OutputSize,InputSize] = cgg_getNetworkIOSize(InNetwork,LayerName)
%CGG_GETBOTTLENECKSIZE Summary of this function goes here
%   Detailed explanation goes here

LayerNameIDX = contains({InNetwork.Layers(:).Name},LayerName);

Layers = InNetwork.Layers(LayerNameIDX);

OutputSize = [];
InputSize = [];

for lidx = 1:length(Layers)
    this_Layer = Layers(lidx);
    this_FieldNames=fieldnames(this_Layer);
    if any(strcmp(this_FieldNames,'OutputSize'))
        OutputSize = this_Layer.OutputSize;
    elseif any(strcmp(this_FieldNames,'NumHiddenUnits'))
        OutputSize = this_Layer.NumHiddenUnits;
    end
end

for lidx = 1:length(Layers)
    this_Layer = Layers(lidx);
    this_FieldNames=fieldnames(this_Layer);
    if any(strcmp(this_FieldNames,'InputSize'))
        InputSize = this_Layer.InputSize;
    end
end

end

