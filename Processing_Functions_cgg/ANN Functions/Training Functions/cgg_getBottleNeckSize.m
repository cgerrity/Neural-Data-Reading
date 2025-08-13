function BottleNeckSize = cgg_getBottleNeckSize(InNetwork)
%CGG_GETBOTTLENECKSIZE Summary of this function goes here
%   Detailed explanation goes here

BottleNeckIDX = contains({InNetwork.Layers(:).Name},"BottleNeck");
PCAIDX = contains({InNetwork.Layers(:).Name},"PCA");
Layers = InNetwork.Layers(BottleNeckIDX);

BottleNeckSize = [];
HasFlatten = false;

for lidx = 1:length(Layers)
    this_Layer = Layers(lidx);
    this_FieldNames=fieldnames(this_Layer);
    if any(strcmp(this_FieldNames,'OutputSize'))
        BottleNeckSize = this_Layer.OutputSize;
    elseif any(strcmp(this_FieldNames,'NumHiddenUnits'))
        BottleNeckSize = this_Layer.NumHiddenUnits;
    elseif contains(this_Layer.Name,"flatten")
        HasFlatten = true;
    end
end

if HasFlatten && isempty(BottleNeckSize)
Layers = InNetwork.Layers;
    for lidx = 1:length(Layers)
        this_Layer = Layers(lidx);
        this_FieldNames=fieldnames(this_Layer);
        if any(strcmp(this_FieldNames,'OutputSize'))
            BottleNeckSize = this_Layer.OutputSize;
        elseif any(strcmp(this_FieldNames,'NumHiddenUnits'))
            BottleNeckSize = this_Layer.NumHiddenUnits;
        elseif any(strcmp(this_FieldNames,'InputSize'))
            BottleNeckSize = prod(this_Layer.InputSize);
        end
    end
end

if any(PCAIDX) && isempty(BottleNeckSize)
Layers = InNetwork.Layers(PCAIDX);
    for lidx = 1:length(Layers)
        this_Layer = Layers(lidx);
        this_FieldNames=fieldnames(this_Layer);
        if any(strcmp(this_FieldNames,'OutputDimension'))
            BottleNeckSize = this_Layer.OutputDimension;
        end
    end
end

end

