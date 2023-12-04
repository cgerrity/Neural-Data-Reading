function LabelInformation = cgg_procDataLabelInformation(DataStore)
%CGG_PROCDATALABELINFORMATION Summary of this function goes here
%   Detailed explanation goes here


LabelInformation=countEachLabel(DataStore);

LabelInformation.Percent = 100 * LabelInformation.Count ./ ...
    sum(LabelInformation.Count);

end

