function cfgOut = cgg_getResultsPlotsInputVariables(LoopType,LoopNumber,varargin)
%CGG_GETRESULTSPLOTSINPUTVARIABLES Summary of this function goes here
%   Detailed explanation goes here

% cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

EpochName = CheckVararginPairs('EpochName', 'Decision', varargin{:});
Decoders = CheckVararginPairs('Decoders', 'SVM', varargin{:});
ARModelOrder = CheckVararginPairs('ARModelOrder', 10, varargin{:});
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
DataWidth = CheckVararginPairs('DataWidth', 100, varargin{:});
WindowStride = CheckVararginPairs('WindowStride', 50, varargin{:});
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});

switch LoopType
    case cfg_Names.LoopDecoder
        Decoders = Decoders{LoopNumber};
    case cfg_Names.LoopAR
        ARModelOrder = ARModelOrder(LoopNumber);
    case cfg_Names.LoopProcessing
        EpochName = EpochName{LoopNumber};
    case cfg_Names.LoopSubset
        wantSubset = wantSubset(LoopNumber);
    case cfg_Names.LoopDataWidth
        DataWidth = DataWidth(LoopNumber);
    case cfg_Names.LoopWindowStride
        WindowStride = WindowStride(LoopNumber);
    case cfg_Names.LoopMatchType
        MatchType = MatchType{LoopNumber};
    otherwise
end

if iscell(Decoders)
    Decoders=Decoders{1};
end

cfgOut.(cfg_Names.LoopDecoder)=Decoders;
cfgOut.(cfg_Names.LoopAR)=ARModelOrder;
cfgOut.(cfg_Names.LoopProcessing)=EpochName;
cfgOut.(cfg_Names.LoopSubset)=wantSubset;
cfgOut.(cfg_Names.LoopDataWidth)=DataWidth;
cfgOut.(cfg_Names.LoopWindowStride)=WindowStride;
cfgOut.(cfg_Names.LoopMatchType)=MatchType;


end

