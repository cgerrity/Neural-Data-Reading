function [Layers_AutoEncoder,Layers_Custom] = cgg_generateLayersForAutoEncoder(InputSize,HiddenSizes,NumTimeWindows,DataFormat,varargin)
%CGG_GENERATELAYERSFORAUTOENCODER Summary of this function goes here
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
DropoutPercent_Main=Dropout;

InputSize1D=prod(InputSize,"all");

ReshapeInputSize=[InputSize,NumTimeWindows,0];

NumStacks=numel(HiddenSizes);

Layer_Input = [
    sequenceInputLayer(InputSize,"Name","sequence_Encoder")
    sequenceFoldingLayer("Name",'fold_Encoder')
    ];

% Layer_Input = imageInputLayer(InputSize,"Name","imageinput");
% Layer_Output = [convolution2dLayer([1,1],1,"Name","convolution");
%     regressionLayer("Name","regressionoutput")];
Layer_Output = [
    fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out")
    depthToSpace2dLayer(InputSize(1:2),"Mode","crd","Name","depthToSpaceLayer_Decoder")
    sequenceUnfoldingLayer('Name','unfold_Decoder')
    regressionLayer("Name","regressionoutput_Decoder")
    ];

Layers_Custom= dlnetwork(layerGraph([ ...
    sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
    fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace"), ...
    fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out"), ...
    functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder"), ...
    reshapeLayer("reshape_Decoder",ReshapeInputSize,DataFormat) 
    ]));

Layers_AutoEncoder=[];

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

    this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    % this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
    this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);
    % this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);

    switch WantNormalization
        case 'Batch'
            this_Encoder_NormalizationName=sprintf("normalization_Encoder_%d",stidx);
            this_Decoder_NormalizationName=sprintf("normalization_Decoder_%d",stidx);
            
            this_Encoder_NormalizationLayer = batchNormalizationLayer('Name',this_Encoder_NormalizationName);
            this_Decoder_NormalizationLayer = batchNormalizationLayer('Name',this_Decoder_NormalizationName);
        case true
            this_Encoder_NormalizationName=sprintf("normalization_Encoder_%d",stidx);
            this_Decoder_NormalizationName=sprintf("normalization_Decoder_%d",stidx);
            
            this_Encoder_NormalizationLayer = layerNormalizationLayer('Name',this_Encoder_NormalizationName);
            this_Decoder_NormalizationLayer = layerNormalizationLayer('Name',this_Decoder_NormalizationName);
        otherwise
            this_Encoder_NormalizationLayer = [];
            this_Decoder_NormalizationLayer = [];
    end

    % if WantNormalization
    %     this_Encoder_NormalizationName=sprintf("normalization_Encoder_%d",stidx);
    %     this_Decoder_NormalizationName=sprintf("normalization_Decoder_%d",stidx);
    % 
    %     this_Encoder_NormalizationLayer = layerNormalizationLayer('Name',this_Encoder_NormalizationName);
    %     this_Decoder_NormalizationLayer = layerNormalizationLayer('Name',this_Decoder_NormalizationName);
    % else
    %     this_Encoder_NormalizationLayer = [];
    %     this_Decoder_NormalizationLayer = [];
    % end

    switch Activation
        case 'SoftSign'
            this_Encoder_ActivationLayer = softplusLayer("Name",this_Encoder_ActivationName);
            this_Decoder_ActivationLayer = softplusLayer("Name",this_Decoder_ActivationName);
        case 'ReLU'
            this_Encoder_ActivationLayer = reluLayer("Name",this_Encoder_ActivationName);
            this_Decoder_ActivationLayer = reluLayer("Name",this_Decoder_ActivationName);
        otherwise
            this_Encoder_ActivationLayer = softplusLayer("Name",this_Encoder_ActivationName);
            this_Decoder_ActivationLayer = softplusLayer("Name",this_Decoder_ActivationName);
    end

    % this_Layer_Encoder = [
    %     fullyConnectedLayer(this_HiddenSize,"Name",this_Encoder_FullyConnectedName)
    %     dropoutLayer(DropoutPercent_Main,'Name',this_Encoder_DropOutName)
    %     softplusLayer("Name",this_Encoder_ActivationName)];
    % this_Layer_Decoder = [
    %     fullyConnectedLayer(this_HiddenSize,"Name",this_Decoder_FullyConnectedName)
    %     dropoutLayer(DropoutPercent_Main,'Name',this_Decoder_DropOutName)
    %     softplusLayer("Name",this_Decoder_ActivationName)];
    this_Layer_Encoder = [
        fullyConnectedLayer(this_HiddenSize,"Name",this_Encoder_FullyConnectedName)
        dropoutLayer(DropoutPercent_Main,'Name',this_Encoder_DropOutName)
        this_Encoder_ActivationLayer
        this_Encoder_NormalizationLayer];
    this_Layer_Decoder = [
        fullyConnectedLayer(this_HiddenSize,"Name",this_Decoder_FullyConnectedName)
        dropoutLayer(DropoutPercent_Main,'Name',this_Decoder_DropOutName)
        this_Decoder_ActivationLayer
        this_Decoder_NormalizationLayer];
    % if stidx==NumStacks
    %     this_Layer_Decoder=[];
    % end

    Layers_AutoEncoder=[
        this_Layer_Encoder
        Layers_AutoEncoder
        this_Layer_Decoder];

end

if ~isempty(Layers_AutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_AutoEncoder);
end

Layers_AutoEncoder=[
    Layer_Input
    Layers_AutoEncoder
    Layer_Output];

Layers_AutoEncoder=layerGraph(Layers_AutoEncoder);

Layers_AutoEncoder = connectLayers(Layers_AutoEncoder,'fold_Encoder/miniBatchSize','unfold_Decoder/miniBatchSize');

end

