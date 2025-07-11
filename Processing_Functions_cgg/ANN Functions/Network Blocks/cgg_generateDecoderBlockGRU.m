function [DecoderBlock] = cgg_generateDecoderBlockGRU(HiddenSize,DecoderLevel,varargin)
%CGG_GENERATEDecoderBLOCKGRU Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Dropout = CheckVararginPairs('Dropout', 0.5, varargin{:});
else
if ~(exist('Dropout','var'))
Dropout=0.5;
end
end

if isfunction
WantNormalization = CheckVararginPairs('WantNormalization', false, varargin{:});
else
if ~(exist('WantNormalization','var'))
WantNormalization=false;
end
end

%%


Name_GRU=sprintf("gru_Decoder_%d",DecoderLevel);

switch WantNormalization
    case 'Batch'
        Name_Normalization=sprintf("normalization_Decoder_%d",DecoderLevel);
        NormalizationLayer = batchNormalizationLayer('Name',Name_Normalization);
    case true
        Name_Normalization=sprintf("normalization_Decoder_%d",DecoderLevel);
        NormalizationLayer = layerNormalizationLayer('Name',Name_Normalization);
    otherwise
        NormalizationLayer = [];
end

WantDropout = false;
if Dropout > 0
WantDropout = true;
end

if WantDropout
    Name_DropOut=sprintf("dropout_Decoder_%d",DecoderLevel);
    DropoutLayer=[dropoutLayer(Dropout,'Name',Name_DropOut)];
else
    DropoutLayer = [];
end

DecoderBlock = [
    gruLayer(HiddenSize,"Name",Name_GRU,"OutputMode","sequence")
    DropoutLayer
    NormalizationLayer
    ];


end

