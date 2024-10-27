function DataNormalized = cgg_procNormalizeAreaMinMax(Data,NormalizationTable,LimitsNorm)
%CGG_PROCNORMALIZEAREAMINMAX Summary of this function goes here
%   Detailed explanation goes here

[NumChannels,NumSamples,NumProbes]=size(Data);

MaxAreasTable = groupsummary(NormalizationTable, "Area", 'max', "Max");
MinAreasTable = groupsummary(NormalizationTable, "Area", 'min', "Min");

AreaIDX = MaxAreasTable{:,"Area"};
MaxAreas = MaxAreasTable{:,"max_Max"};
MinAreas = MinAreasTable{:,"min_Min"};

MaxData = NaN(1,1,NumProbes);
MinData = NaN(1,1,NumProbes);

IDX = sub2ind([1,1,NumProbes],AreaIDX);

MaxData(IDX) = MaxAreas;
MinData(IDX) = MinAreas;

MaxFull = repmat(MaxData,[NumChannels,NumSamples,1]);
MinFull = repmat(MinData,[NumChannels,NumSamples,1]);

DataNormalized = (Data-MinFull)./(MaxFull-MinFull);

RangeNorm = range(LimitsNorm);

DataNormalized = DataNormalized*RangeNorm - (RangeNorm-LimitsNorm(2));

end

