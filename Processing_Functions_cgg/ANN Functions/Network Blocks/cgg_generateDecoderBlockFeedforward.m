function [DecoderBlock] = cgg_generateDecoderBlockFeedforward(HiddenSize,DecoderLevel,varargin)
%CGG_GENERATEENCODERBLOCKFEEDFORWARD Summary of this function goes here
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
Activation = CheckVararginPairs('Activation', 'SoftSign', varargin{:});
else
if ~(exist('Activation','var'))
Activation='SoftSign';
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



Name_FullyConnected=sprintf("fc_Decoder_%d",DecoderLevel);
Name_Activation=sprintf("activation_Decoder_%d",DecoderLevel);

Name_Normalization=sprintf("normalization_Decoder_%d",DecoderLevel);
NormalizationLayer = cgg_selectNormalizationLayer(WantNormalization,Name_Normalization);

switch Activation
    case 'SoftSign'
        ActivationLayer = softplusLayer("Name",Name_Activation);
    case 'ReLU'
        ActivationLayer = reluLayer("Name",Name_Activation);
    otherwise
        ActivationLayer = softplusLayer("Name",Name_Activation);
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
    fullyConnectedLayer(HiddenSize,"Name",Name_FullyConnected)
    DropoutLayer
    NormalizationLayer
    ActivationLayer
    ];


end

