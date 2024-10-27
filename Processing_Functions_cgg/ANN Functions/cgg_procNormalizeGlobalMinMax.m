function DataNormalized = cgg_procNormalizeGlobalMinMax(Data,NormalizationTable,LimitsNorm)
%CGG_NORMALIZEGLOBALMINMAX Summary of this function goes here
%   Detailed explanation goes here

MaxChannels = NormalizationTable{:,"Max"};
MinChannels = NormalizationTable{:,"Min"};

MaxData = max(MaxChannels);
MinData = min(MinChannels);

DataNormalized = (Data-MinData)./(MaxData-MinData);

RangeNorm = range(LimitsNorm);

DataNormalized = DataNormalized*RangeNorm - (RangeNorm-LimitsNorm(2));

end

