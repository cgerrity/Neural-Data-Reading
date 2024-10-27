function DataNormalized = cgg_procNormalizeChannelMinMax(Data,NormalizationTable,LimitsNorm)
%CGG_PROCNORMALIZECHANNELMINMAX Summary of this function goes here
%   Detailed explanation goes here

[NumChannels,NumSamples,NumProbes]=size(Data);

AreaIDX = NormalizationTable{:,"Area"};
ChannelIDX = NormalizationTable{:,"Channel"};
MaxChannels = NormalizationTable{:,"Max"};
MinChannels = NormalizationTable{:,"Min"};

MaxData = NaN(NumChannels,1,NumProbes);
MinData = NaN(NumChannels,1,NumProbes);

IDX = sub2ind([NumChannels,1,NumProbes],ChannelIDX,AreaIDX);

MaxData(IDX) = MaxChannels;
MinData(IDX) = MinChannels;

MaxFull = repmat(MaxData,[1,NumSamples,1]);
MinFull = repmat(MinData,[1,NumSamples,1]);

DataNormalized = (Data-MinFull)./(MaxFull-MinFull);

RangeNorm = range(LimitsNorm);

DataNormalized = DataNormalized*RangeNorm - (RangeNorm-LimitsNorm(2));

end

