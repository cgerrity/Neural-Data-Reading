function BottleNeckSize = cgg_getBottleNeckSize(InNetwork)
%CGG_GETBOTTLENECKSIZE Summary of this function goes here
%   Detailed explanation goes here

BottleNeckIDX = contains({InNetwork.Layers(:).Name},"BottleNeck");

Layers = InNetwork.Layers(BottleNeckIDX);

BottleNeckSize = [];

for lidx = 1:length(Layers)
    this_Layer = Layers(lidx);
    this_FieldNames=fieldnames(this_Layer);
    if any(strcmp(this_FieldNames,'OutputSize'))
        BottleNeckSize = this_Layer.OutputSize;
    elseif any(strcmp(this_FieldNames,'NumHiddenUnits'))
        BottleNeckSize = this_Layer.NumHiddenUnits;
    end
end

end

