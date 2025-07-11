function Block = cgg_generateSimpleBlock(HiddenSize,Level,varargin)
%CGG_GENERATESIMPLEBLOCK Summary of this function goes here
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

if isfunction
Coder = CheckVararginPairs('Coder', 'Encoder', varargin{:});
else
if ~(exist('Coder','var'))
Coder='Encoder';
end
end

if isfunction
Transform = CheckVararginPairs('Transform', 'Feedforward', varargin{:});
else
if ~(exist('Transform','var'))
Transform='Feedforward';
end
end

if isfunction
Activation = CheckVararginPairs('Activation', '', varargin{:});
else
if ~(exist('Activation','var'))
Activation='';
end
end

%%

if isnan(Level)
    CoderLevel_Name = sprintf("_%s",Coder);
else
    CoderLevel_Name = sprintf("_%s_%d",Coder,Level);
end

%%

switch Transform
    case 'Feedforward'
        TransformLayerName = 'fc';
        Name_Transform = ...
            sprintf("%s",TransformLayerName) + CoderLevel_Name;
        TransformLayer = ...
            fullyConnectedLayer(HiddenSize,"Name",Name_Transform,"WeightsInitializer","he");
    case 'GRU'
        TransformLayerName = 'gru';
        Name_Transform = ...
            sprintf("%s",TransformLayerName) + CoderLevel_Name;
        TransformLayer = ...
            gruLayer(HiddenSize,"Name",Name_Transform,"OutputMode","sequence");
    case 'LSTM'
        TransformLayerName = 'lstm';
        Name_Transform = ...
            sprintf("%s",TransformLayerName) + CoderLevel_Name;
        TransformLayer = ...
            lstmLayer(HiddenSize,"Name",Name_Transform,"OutputMode","sequence");
    otherwise
        TransformLayerName = 'fc';
        Name_Transform = ...
            sprintf("%s",TransformLayerName) + CoderLevel_Name;
        TransformLayer = ...
            fullyConnectedLayer(HiddenSize,"Name",Name_Transform);
end

switch WantNormalization
    case 'Batch'
        Name_Normalization="normalization" + CoderLevel_Name;
        NormalizationLayer = batchNormalizationLayer('Name',Name_Normalization);
    case true
        Name_Normalization="normalization" + CoderLevel_Name;
        NormalizationLayer = layerNormalizationLayer('Name',Name_Normalization);
    otherwise
        NormalizationLayer = [];
end

switch Activation
    case 'SoftSign'
        Name_Activation = "activation" + CoderLevel_Name;
        ActivationLayer = softplusLayer("Name",Name_Activation);
    case 'ReLU'
        Name_Activation = "activation" + CoderLevel_Name;
        ActivationLayer = reluLayer("Name",Name_Activation);
    case 'Leaky ReLU'
        Name_Activation = "activation" + CoderLevel_Name;
        ActivationLayer = leakyReluLayer("Name",Name_Activation);
    case 'GeLU'
        Name_Activation = "activation" + CoderLevel_Name;
        ActivationLayer = geluLayer("Name",Name_Activation);
    otherwise
        ActivationLayer = [];
end

WantDropout = false;
if Dropout > 0
WantDropout = true;
end

if WantDropout
    Name_DropOut = "dropout" + CoderLevel_Name;
    DropoutLayer = [dropoutLayer(Dropout,'Name',Name_DropOut)];
else
    DropoutLayer = [];
end

Block = [
    TransformLayer
    DropoutLayer
    NormalizationLayer
    ActivationLayer
    ];


end
