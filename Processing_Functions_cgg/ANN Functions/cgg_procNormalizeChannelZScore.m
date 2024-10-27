function DataNormalized = cgg_procNormalizeChannelZScore(Data,NormalizationTable)
%CGG_PROCNORMALIZECHANNELZSCORE Summary of this function goes here
%   Detailed explanation goes here

[NumChannels,NumSamples,NumProbes]=size(Data);

AreaIDX = NormalizationTable{:,"Area"};
ChannelIDX = NormalizationTable{:,"Channel"};
MeanChannels = NormalizationTable{:,"Mean"};
STDChannels = NormalizationTable{:,"STD"};

MeanData = NaN(NumChannels,1,NumProbes);
STDData = NaN(NumChannels,1,NumProbes);

IDX = sub2ind([NumChannels,1,NumProbes],ChannelIDX,AreaIDX);

MeanData(IDX) = MeanChannels;
STDData(IDX) = STDChannels;

MeanFull = repmat(MeanData,[1,NumSamples,1]);
STDFull = repmat(STDData,[1,NumSamples,1]);

DataNormalized = (Data-MeanFull)./(STDFull);

end

