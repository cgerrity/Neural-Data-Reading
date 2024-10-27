function DataNormalized = cgg_selectNormalization(Data,NormalizationTable,Normalization)
%CGG_SELECTNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here

if ~istable(NormalizationTable)
if isnan(NormalizationTable)
Normalization = 'None';
end
end

switch Normalization
    case 'None'
        DataNormalized = Data;
    case 'Channel - MinMax - [-1,1]'
        LimitsNorm = [-1,1];
        DataNormalized = cgg_procNormalizeChannelMinMax(Data,NormalizationTable,LimitsNorm);
    case 'Channel - MinMax - [0,1]'
        LimitsNorm = [0,1];
        DataNormalized = cgg_procNormalizeChannelMinMax(Data,NormalizationTable,LimitsNorm);
    case 'Area - MinMax - [-1,1]'
        LimitsNorm = [-1,1];
        DataNormalized = cgg_procNormalizeAreaMinMax(Data,NormalizationTable,LimitsNorm);
    case 'Area - MinMax - [0,1]'
        LimitsNorm = [0,1];
        DataNormalized = cgg_procNormalizeAreaMinMax(Data,NormalizationTable,LimitsNorm);
    case 'Global - MinMax - [-1,1]'
        LimitsNorm = [-1,1];
        DataNormalized = cgg_procNormalizeGlobalMinMax(Data,NormalizationTable,LimitsNorm);
    case 'Global - MinMax - [0,1]'
        LimitsNorm = [0,1];
        DataNormalized = cgg_procNormalizeGlobalMinMax(Data,NormalizationTable,LimitsNorm);
    case 'Channel - Z-Score'
        DataNormalized = cgg_procNormalizeChannelZScore(Data,NormalizationTable);
    case 'Area - Z-Score'
        DataNormalized = cgg_procNormalizeAreaZScore(Data,NormalizationTable);
    case 'Global - Z-Score'
        DataNormalized = cgg_procNormalizeGlobalZScore(Data,NormalizationTable);
    case 'Channel - Z-Score - Global - MinMax - [0,1]'
        LimitsNorm = [0,1];
        WantZeroCentered = false;
        DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,'WantZeroCentered',WantZeroCentered);
    case 'Channel - Z-Score - Global - MinMax - [-1,1]'
        LimitsNorm = [-1,1];
        WantZeroCentered = false;
        DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,'WantZeroCentered',WantZeroCentered);
    case 'Channel - Z-Score - Global - MinMax - [0,1] - Zero Centered'
        LimitsNorm = [0,1];
        WantZeroCentered = true;
        DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,'WantZeroCentered',WantZeroCentered);
    case 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered'
        LimitsNorm = [-1,1];
        WantZeroCentered = true;
        DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,'WantZeroCentered',WantZeroCentered);
    case 'Channel - Z-Score - Global - MinMax - [0,1] - Zero Centered - Range 0.5'
        LimitsNorm = [0,1];
        WantZeroCentered = true;
        ExpandedRange_Percent = 0.5;
        DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,'WantZeroCentered',WantZeroCentered,'ExpandedRange_Percent',ExpandedRange_Percent);
    case 'Channel - Z-Score - Global - MinMax - [-1,1] - Zero Centered - Range 0.5'
        LimitsNorm = [-1,1];
        WantZeroCentered = true;
        ExpandedRange_Percent = 0.5;
        DataNormalized = cgg_procNormalizeChannelZScoreGlobalMinMax(Data,NormalizationTable,LimitsNorm,'WantZeroCentered',WantZeroCentered,'ExpandedRange_Percent',ExpandedRange_Percent);
    otherwise
        DataNormalized = Data;
end


end

