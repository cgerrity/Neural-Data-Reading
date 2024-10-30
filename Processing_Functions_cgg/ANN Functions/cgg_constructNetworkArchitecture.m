function [Encoder,Decoder] = cgg_constructNetworkArchitecture(ArchitectureType,varargin)
%CGG_CONSTRUCTNETWORKARCHITECTURE Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
InputSize = CheckVararginPairs('InputSize', [10,100,6], varargin{:});
else
if ~(exist('InputSize','var'))
InputSize=[10,100,6];
end
end

if isfunction
HiddenSize = CheckVararginPairs('HiddenSize', [64,32,16], varargin{:});
else
if ~(exist('HiddenSize','var'))
HiddenSize=[64,32,16];
end
end

if isfunction
cfg_Encoder = CheckVararginPairs('cfg_Encoder', struct(), varargin{:});
else
if ~(exist('cfg_Encoder','var'))
cfg_Encoder=struct();
end
end

%% Parameters for Testing

% NumBatches = 10;
% NumWindows = 20;
% ArchitectureType = 'Variational GRU - Dropout 0.5';
% ArchitectureType = 'Convolutional 3x3';

%%

cfg = PARAMETERS_cgg_constructNetworkArchitecture(ArchitectureType);
cfg.InputSize = InputSize;

%%

if isfield(cfg_Encoder,'Dropout')
cfg.Dropout = cfg_Encoder.Dropout;
end

if isfield(cfg_Encoder,'WantNormalization')
cfg.WantNormalization = cfg_Encoder.WantNormalization;
end

if isfield(cfg_Encoder,'Activation')
cfg.Activation = cfg_Encoder.Activation;
end

if isfield(cfg_Encoder,'IsVariational')
cfg.IsVariational = cfg_Encoder.IsVariational;
end
if isfield(cfg_Encoder,'BottleNeckDepth')
cfg.BottleNeckDepth = cfg_Encoder.BottleNeckDepth;
end

%%

HiddenSizeAutoEncoder = HiddenSize(1:end-1);
HiddenSizeBottleNeck = HiddenSize(end);

RemoveNaNFunc = @(x) cgg_setNaNToValue(x,0);

InputEncoderBlock = [sequenceInputLayer(InputSize,"Name","Input_Encoder","Normalization",RemoveNaNFunc)];
InputEncoderBlock = layerGraph(InputEncoderBlock);

[PreEncoderBlock,EncoderBlocks,PostEncoderBlock] = ...
    cgg_selectEncoder(HiddenSizeAutoEncoder,cfg);

[PreDecoderBlock,DecoderBlocks,PostDecoderBlock] = ...
    cgg_selectDecoder(HiddenSizeAutoEncoder,cfg);

if cfg.IsVariational
    PreDecoderBlock = [ cgg_samplingLayer("Name",'SamplingLayer')
        PreDecoderBlock];
    HiddenSizeBottleNeck = HiddenSizeBottleNeck*2;
end

if ~(isempty(PreDecoderBlock))
PreDecoderBlock = layerGraph(PreDecoderBlock);
end

if cfg.OutputFullyConnected
PostDecoderBlock = [
    PostDecoderBlock
    fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out")
    functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder")];
end

if ~(isempty(PostDecoderBlock))
PostDecoderBlock = layerGraph(PostDecoderBlock);
end

if cfg.needReshape
    OutputBlock = [reshapeLayer_2("reshape_Decoder",InputSize)];
    OutputBlock = layerGraph(OutputBlock);
else
    OutputBlock = [];
end

BottleNeck = cgg_selectBottleNeck(HiddenSizeBottleNeck,cfg);

InputDecoderBlock = sequenceInputLayer(HiddenSizeBottleNeck,"Name","Input_Decoder");

InputDecoderBlock = layerGraph(InputDecoderBlock);


%%
Encoder = InputEncoderBlock;
if ~isempty(PreEncoderBlock)
Encoder = cgg_connectLayerGraphs(Encoder,PreEncoderBlock);
end
if ~isempty(EncoderBlocks)
Encoder = cgg_connectLayerGraphs(Encoder,EncoderBlocks);
end
if ~isempty(PostEncoderBlock)
Encoder = cgg_connectLayerGraphs(Encoder,PostEncoderBlock);
end
if ~isempty(BottleNeck)
Encoder = cgg_connectLayerGraphs(Encoder,BottleNeck);
end
%%

Decoder = InputDecoderBlock;
if ~isempty(PreDecoderBlock)
Decoder = cgg_connectLayerGraphs(Decoder,PreDecoderBlock);
end
if ~isempty(DecoderBlocks)
Decoder = cgg_connectLayerGraphs(Decoder,DecoderBlocks);
end
if ~isempty(PostDecoderBlock)
Decoder = cgg_connectLayerGraphs(Decoder,PostDecoderBlock);
end
if ~isempty(OutputBlock)
Decoder = cgg_connectLayerGraphs(Decoder,OutputBlock);
end

% Decoder = [InputDecoderBlock
%             PreDecoderBlock
%             DecoderBlocks
%             PostDecoderBlock
%             OutputBlock];

% AutoEncoder = [InputEncoderBlock
%             PreEncoderBlock
%             EncoderBlocks
%             PostEncoderBlock
%             BottleNeck
%             PreDecoderBlock
%             DecoderBlocks
%             PostDecoderBlock
%             OutputBlock];

%%

Encoder = dlnetwork(Encoder);
Decoder = dlnetwork(Decoder);
% AutoEncoder = dlnetwork(AutoEncoder);

%%

% X = randn([InputSize,NumBatches,NumWindows]);
% X = dlarray(X,'SSCBT');
% 
% EncoderOutput = predict(Encoder,X);
% DecoderOutput = predict(Decoder,EncoderOutput);
% AutoEncoderOutput = predict(AutoEncoder,X);

end

