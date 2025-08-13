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

if isfunction
PCAInformation = CheckVararginPairs('PCAInformation', [], varargin{:});
else
if ~(exist('PCAInformation','var'))
PCAInformation=[];
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

% cfg.WantLearnableScale = true;
% cfg.WantLearnableOffset = true;

if strcmp(ArchitectureType,'Logistic Regression')
    HiddenSize = [];
end

%%

if isfield(cfg_Encoder,'Dropout')
cfg.Dropout = cfg_Encoder.Dropout;
end

if isfield(cfg_Encoder,'WantNormalization')
cfg.WantNormalization = cfg_Encoder.WantNormalization;
end

if isfield(cfg_Encoder,'Activation')
    if ~isempty(cfg_Encoder.Activation)
    cfg.Activation = cfg_Encoder.Activation;
    end
end

if isfield(cfg_Encoder,'IsVariational')
cfg.IsVariational = cfg_Encoder.IsVariational;
end
if isfield(cfg_Encoder,'BottleNeckDepth')
cfg.BottleNeckDepth = cfg_Encoder.BottleNeckDepth;
end

% if isfield(cfg_Encoder,'WantLearnableScale')
% cfg.WantLearnableScale = cfg_Encoder.WantLearnableScale;
% end
% 
% if isfield(cfg_Encoder,'WantLearnableOffset')
% cfg.WantLearnableOffset = cfg_Encoder.WantLearnableOffset;
% end

%%

if ~isempty(PCAInformation)
cfg.PCAInformation = PCAInformation;
end
%%

HiddenSizeAutoEncoder = HiddenSize(1:end-1);
if ~isempty(HiddenSize)
HiddenSizeBottleNeck = HiddenSize(end);
else
HiddenSizeBottleNeck = [];
end

cfg.HiddenSizeBottleNeck = HiddenSizeBottleNeck;

RemoveNaNFunc = @(x) cgg_setNaNToValue(x,0);

InputEncoderBlock = [sequenceInputLayer(InputSize,"Name","Input_Encoder","Normalization",RemoveNaNFunc)];
InputEncoderBlock = layerGraph(InputEncoderBlock);

[PreEncoderBlock,EncoderBlocks,PostEncoderBlock] = ...
    cgg_selectEncoder(HiddenSizeAutoEncoder,cfg);

[PreDecoderBlock,DecoderBlocks,PostDecoderBlock] = ...
    cgg_selectDecoder(HiddenSizeAutoEncoder,cfg);

if cfg.IsVariational && ~(strcmp(ArchitectureType,'Logistic Regression')...
        || strcmp(ArchitectureType,'PCA'))
    
    PreDecoderBlock = [ cgg_samplingLayer("Name",'SamplingLayer')
        PreDecoderBlock];
    HiddenSizeBottleNeck = HiddenSizeBottleNeck*2;
end

if strcmp(ArchitectureType,'PCA')
    HiddenSizeBottleNeck = cfg.PCAInformation.OutputDimension;
end

if ~(isempty(PreDecoderBlock))
PreDecoderBlock = layerGraph(PreDecoderBlock);
end

if cfg.OutputFullyConnected
PostDecoderBlock = [
    PostDecoderBlock
    fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out")];
    % functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder")];
end

if ~(isempty(PostDecoderBlock)) && ~(isa(PostDecoderBlock,'nnet.cnn.LayerGraph') || isa(PostDecoderBlock,'dlnetwork'))
PostDecoderBlock = layerGraph(PostDecoderBlock);
end

if cfg.needReshape
    OutputBlock = [functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder")
        reshapeLayer_2("reshape_Decoder",InputSize)];
    OutputBlock = layerGraph(OutputBlock);
else
    OutputBlock = [];
end

BottleNeck = cgg_selectBottleNeck(HiddenSizeBottleNeck,cfg);

if ~isempty(HiddenSizeBottleNeck)
InputDecoderBlock = sequenceInputLayer(HiddenSizeBottleNeck,"Name","Input_Decoder");
else
InputDecoderBlock = sequenceInputLayer(prod(InputSize),"Name","Input_Decoder");
end

InputDecoderBlock = layerGraph(InputDecoderBlock);

% if cfg.WantLearnableScale || cfg.WantLearnableOffset
%     UniqueDimension = [1,3];
%     AugmentBlock = cgg_generateAugmentBlock(HiddenSizeAugment,InputSize,cfg.WantLearnableScale,cfg.WantLearnableOffset,"_Decoder",cfg,'UniqueDimension',UniqueDimension);
%     [Destination_Augment,~,~,~] = cgg_identifyUnconnectedLayers(AugmentBlock);
%     Destination_Augment_Target = Destination_Augment{contains(Destination_Augment,'target')};
%     Destination_Augment_Learnable = Destination_Augment{contains(Destination_Augment,'learnable')};
% end

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
% [~,Source_Augment_Learnable,~,~] = cgg_identifyUnconnectedLayers(Decoder);
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

% if cfg.WantLearnableScale || cfg.WantLearnableOffset
% [~,Source_Augment_Target,~,~] = cgg_identifyUnconnectedLayers(Decoder);
% Decoder = cgg_combineLayerGraphs(Decoder,AugmentBlock);
% Decoder = connectLayers(Decoder,Source_Augment_Learnable{1},Destination_Augment_Learnable);
% Decoder = connectLayers(Decoder,Source_Augment_Target{1},Destination_Augment_Target);
% end

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

