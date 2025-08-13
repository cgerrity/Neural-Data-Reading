function FormatInformation = cgg_getDataFormatInformation(X)
%CGG_GETDATAFORMATINFORMATION Summary of this function goes here
%   Detailed explanation goes here

FormatInformation = struct();

FormatInformation.Dimension.Spatial = finddim(X,'S');
FormatInformation.Dimension.Channel = finddim(X,'C');
FormatInformation.Dimension.Batch = finddim(X,'B');
FormatInformation.Dimension.Time = finddim(X,'T');

AllSizes = size(X);

FormatInformation.Size.Spatial = AllSizes(FormatInformation.Dimension.Spatial);
FormatInformation.Size.Channel = AllSizes(FormatInformation.Dimension.Channel);
FormatInformation.Size.Batch = AllSizes(FormatInformation.Dimension.Batch);
FormatInformation.Size.Time = AllSizes(FormatInformation.Dimension.Time);

end

