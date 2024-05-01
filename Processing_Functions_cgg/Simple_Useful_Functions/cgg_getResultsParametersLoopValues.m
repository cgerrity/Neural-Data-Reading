function [LoopType,NumLoops,LoopNames,LoopTitle] = cgg_getResultsParametersLoopValues(varargin)
%CGG_GETRESULTSPARAMETERSLOOPVALUES Summary of this function goes here
%   Detailed explanation goes here

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

EpochName = CheckVararginPairs('EpochName', 'Decision', varargin{:});
Decoders = CheckVararginPairs('Decoders', 'SVM', varargin{:});
ARModelOrder = CheckVararginPairs('ARModelOrder', 10, varargin{:});
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
DataWidth = CheckVararginPairs('DataWidth', 100, varargin{:});
WindowStride = CheckVararginPairs('WindowStride', 50, varargin{:});
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});

NumEpochName = 1;
if iscell(EpochName)
NumEpochName = length(EpochName);
end
NumDecoders = 1;
if iscell(Decoders)
NumDecoders = length(Decoders);
end
NumARModelOrder = length(ARModelOrder);
NumwantSubset = length(wantSubset);
NumDataWidth = length(DataWidth);
NumWindowStride = length(WindowStride);
NumMatchType = 1;
if iscell(MatchType)
NumMatchType = length(MatchType);
end

if NumDecoders>1
    LoopType=cfg_Names.LoopDecoder;
    NumLoops=NumDecoders;
    LoopNames=Decoders;
    LoopTitle=cfg_Names.LoopTitleDecoder;
elseif NumARModelOrder>1
    LoopType=cfg_Names.LoopAR;
    NumLoops=NumARModelOrder;
    LoopNames=compose('%d',ARModelOrder);
    LoopTitle=cfg_Names.LoopTitleAR;
elseif NumEpochName>1
    LoopType=cfg_Names.LoopProcessing;
    NumLoops=NumEpochName;
    LoopNames=EpochName;
    LoopTitle=cfg_Names.LoopTitleProcessing;
elseif NumwantSubset==2
    LoopType=cfg_Names.LoopSubset;
    NumLoops=NumwantSubset;
    Subset={'Full Data','Subset'};
    LoopNames=Subset(wantSubset+1);
    LoopTitle=cfg_Names.LoopTitleSubset;
elseif NumDataWidth>1
    LoopType=cfg_Names.LoopDataWidth;
    NumLoops=NumDataWidth;
    LoopNames=compose('%d',DataWidth);
    LoopTitle=cfg_Names.LoopTitleDataWidth;
elseif NumWindowStride>1
    LoopType=cfg_Names.LoopWindowStride;
    NumLoops=NumWindowStride;
    LoopNames=compose('%d',WindowStride);
    LoopTitle=cfg_Names.LoopTitleWindowStride;
elseif NumMatchType>1
    LoopType=cfg_Names.LoopMatchType;
    NumLoops=NumMatchType;
    LoopNames=MatchType;
    LoopTitle=cfg_Names.LoopTitleMatchType;
else
    LoopType=cfg_Names.LoopUnknown;
    NumLoops=1;
    LoopNames={' _ '};
    LoopTitle=cfg_Names.LoopTitleUnknown;
end


end

