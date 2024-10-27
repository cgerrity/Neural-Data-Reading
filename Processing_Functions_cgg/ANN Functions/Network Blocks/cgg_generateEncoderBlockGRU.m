function [EncoderBlock] = cgg_generateEncoderBlockGRU(HiddenSize,EncoderLevel,varargin)
%CGG_GENERATEENCODERBLOCKGRU Summary of this function goes here
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


Name_GRU=sprintf("gru_Encoder_%d",EncoderLevel);

if WantNormalization
    Name_Normalization=sprintf("normalization_Encoder_%d",EncoderLevel);
    NormalizationLayer = layerNormalizationLayer('Name',Name_Normalization);
else
    NormalizationLayer = [];
end

WantDropout = false;
if Dropout > 0
WantDropout = true;
end

if WantDropout
    Name_DropOut=sprintf("dropout_Encoder_%d",EncoderLevel);
    DropoutLayer=[dropoutLayer(Dropout,'Name',Name_DropOut)];
else
    DropoutLayer = [];
end

EncoderBlock = [
    gruLayer(HiddenSize,"Name",Name_GRU,"OutputMode","sequence")
    DropoutLayer
    NormalizationLayer
    ];


end

