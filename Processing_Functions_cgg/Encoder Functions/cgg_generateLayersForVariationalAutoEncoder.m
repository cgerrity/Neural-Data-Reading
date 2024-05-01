function [Layers_VariationalAutoEncoder,Layers_Custom] = cgg_generateLayersForVariationalAutoEncoder(InputSize,HiddenSizes,NumTimeWindows,DataFormat,varargin)
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

% Layers_AutoEncoder=[];
Layers_VariationalAutoEncoder=cgg_samplingLayer("Name",'SamplingLayer');

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

    this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    this_Encoder_NormalizationName=sprintf("normalization_Encoder_%d",stidx);
    this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);
    this_Decoder_NormalizationName=sprintf("normalization_Decoder_%d",stidx);

    this_Layer_Encoder = [
        fullyConnectedLayer(this_HiddenSize,"Name",this_Encoder_FullyConnectedName)
        layerNormalizationLayer('Name',this_Encoder_NormalizationName)
        dropoutLayer(DropoutPercent_Main,'Name',this_Encoder_DropOutName)
        softplusLayer("Name",this_Encoder_ActivationName)];
    this_Layer_Decoder = [
        fullyConnectedLayer(this_HiddenSize,"Name",this_Decoder_FullyConnectedName)
        layerNormalizationLayer('Name',this_Decoder_NormalizationName)
        dropoutLayer(DropoutPercent_Main,'Name',this_Decoder_DropOutName)
        softplusLayer("Name",this_Decoder_ActivationName)];
    % if stidx==NumStacks
    %     this_Layer_Decoder=[];
    % end

    Layers_VariationalAutoEncoder=[
        this_Layer_Encoder
        Layers_VariationalAutoEncoder
        this_Layer_Decoder];

end

if ~isempty(Layers_VariationalAutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_VariationalAutoEncoder);
end

Layers_VariationalAutoEncoder=[
    Layer_Input
    Layers_VariationalAutoEncoder
    Layer_Output];

Layers_VariationalAutoEncoder=layerGraph(Layers_VariationalAutoEncoder);

Layers_VariationalAutoEncoder = connectLayers(Layers_VariationalAutoEncoder,'fold_Encoder/miniBatchSize','unfold_Decoder/miniBatchSize');

end

