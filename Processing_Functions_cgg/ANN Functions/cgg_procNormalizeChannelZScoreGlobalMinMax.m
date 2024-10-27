function DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,varargin)
%CGG_PROCNORMALIZECHANNELZSCOREGLOBALMINMAX Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantZeroCentered = CheckVararginPairs('WantZeroCentered', false, varargin{:});
else
if ~(exist('WantZeroCentered','var'))
WantZeroCentered=false;
end
end

if isfunction
ExpandedRange_Percent = CheckVararginPairs('ExpandedRange_Percent', [], varargin{:});
else
if ~(exist('ExpandedRange_Percent','var'))
ExpandedRange_Percent=[];
end
end

[NumChannels,NumSamples,NumProbes]=size(Data);

AreaIDX = NormalizationTable{:,"Area"};
ChannelIDX = NormalizationTable{:,"Channel"};
MeanChannels = NormalizationTable{:,"Mean"};
STDChannels = NormalizationTable{:,"STD"};
MaxChannels = NormalizationTable{:,"Max"};
MinChannels = NormalizationTable{:,"Min"};

MeanData = NaN(NumChannels,1,NumProbes);
STDData = NaN(NumChannels,1,NumProbes);

MaxChannelsZScore = (MaxChannels - MeanChannels)./STDChannels;
MinChannelsZScore = (MinChannels - MeanChannels)./STDChannels;

MaxData = max(MaxChannelsZScore);
MinData = min(MinChannelsZScore);

IDX = sub2ind([NumChannels,1,NumProbes],ChannelIDX,AreaIDX);

MeanData(IDX) = MeanChannels;
STDData(IDX) = STDChannels;

MeanFull = repmat(MeanData,[1,NumSamples,1]);
STDFull = repmat(STDData,[1,NumSamples,1]);

DataNormalized = (Data-MeanFull)./(STDFull);

if ~isempty(ExpandedRange_Percent)
[~,STDGlobal] = cgg_calcGlobalMeanSTDFromNormalizationTable(NormalizationTable,NumSamples);
RangeMinMax = range([MinData,MaxData]);
ExpandedRange_Percent = 1;
ExpandedRange_Target = ExpandedRange_Percent/2/(range(LimitsNorm));
ExpandedRange_Multiplier = ExpandedRange_Target/(STDGlobal/RangeMinMax);

DataNormalized = DataNormalized*ExpandedRange_Multiplier;

end

if WantZeroCentered
MeanGlobal = mean(MeanData,"all","omitnan");
RangeMinMax = range([MinData,MaxData]);
DataNormalized = (DataNormalized-(MeanGlobal-RangeMinMax/2))./(MaxData-MinData);
else
DataNormalized = (DataNormalized-MinData)./(MaxData-MinData);
end

RangeNorm = range(LimitsNorm);

DataNormalized = DataNormalized*RangeNorm - (RangeNorm-LimitsNorm(2));

end

