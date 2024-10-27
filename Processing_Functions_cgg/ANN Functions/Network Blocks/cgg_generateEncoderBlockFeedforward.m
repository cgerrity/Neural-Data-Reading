function [EncoderBlock] = cgg_generateEncoderBlockFeedforward(HiddenSize,EncoderLevel,varargin)
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



Name_FullyConnected=sprintf("fc_Encoder_%d",EncoderLevel);
Name_Activation=sprintf("activation_Encoder_%d",EncoderLevel);

if WantNormalization
    Name_Normalization=sprintf("normalization_Encoder_%d",EncoderLevel);
    NormalizationLayer = layerNormalizationLayer('Name',Name_Normalization);
else
    NormalizationLayer = [];
end


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
    Name_DropOut=sprintf("dropout_Encoder_%d",EncoderLevel);
    DropoutLayer=[dropoutLayer(Dropout,'Name',Name_DropOut)];
else
    DropoutLayer = [];
end

EncoderBlock = [
    fullyConnectedLayer(HiddenSize,"Name",Name_FullyConnected)
    DropoutLayer
    NormalizationLayer
    ActivationLayer
    ];


end

