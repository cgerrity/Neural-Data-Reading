function Epoch = cgg_getEpochNameFromString(EpochName)
%CGG_GETEPOCHNAMEFROMSTRING Summary of this function goes here
%   Detailed explanation goes here

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Epoch_Decision=cfg_Names.Epoch_Decision;
Epoch_1=cfg_Names.Epoch_1;
Epoch_2=cfg_Names.Epoch_2;
Epoch_3=cfg_Names.Epoch_3;

if contains(EpochName,Epoch_Decision)
    Epoch=Epoch_Decision;
elseif contains(EpochName,Epoch_1)
    Epoch=Epoch_1;
elseif contains(EpochName,Epoch_2)
    Epoch=Epoch_2;
elseif contains(EpochName,Epoch_3)
    Epoch=Epoch_3;
else
    Epoch='Unknown Epoch';
end

end

