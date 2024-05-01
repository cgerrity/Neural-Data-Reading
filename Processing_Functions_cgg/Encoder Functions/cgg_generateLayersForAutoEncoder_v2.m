function [Layers_AutoEncoder,Layers_Custom] = cgg_generateLayersForAutoEncoder_v2(InputSize,HiddenSizes,NumTimeWindows,DataFormat,varargin)
%CGG_GENERATELAYERSFORAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Dropout_Main = CheckVararginPairs('Dropout_Main', 0.5, varargin{:});
else
if ~(exist('Dropout_Main','var'))
Dropout_Main=0.5;
end
end

if isfunction
Dropout_Skip = CheckVararginPairs('Dropout_Skip', 0.9, varargin{:});
else
if ~(exist('Dropout_Skip','var'))
Dropout_Skip=0.9;
end
end
%%
DropoutPercent_Skip=Dropout_Skip;
DropoutPercent_Main=Dropout_Main;

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
    fullyConnectedLayer(HiddenSizes(1)*2,"Name","Layer_To_Replace"), ...
    fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out"), ...
    functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder"), ...
    reshapeLayer("reshape_Decoder",ReshapeInputSize,DataFormat) 
    ]));

%%

Layers_AutoEncoder=[];

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

    this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    % this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
    this_Decoder_ConcatenationName=sprintf("concatenation_Skip_Decoder_%d",stidx);
    this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);
    % this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);

    this_Layer_Encoder = [
        fullyConnectedLayer(this_HiddenSize,"Name",this_Encoder_FullyConnectedName)
        dropoutLayer(DropoutPercent_Main,'Name',this_Encoder_DropOutName)
        softplusLayer("Name",this_Encoder_ActivationName)];
    this_Layer_Decoder = [
        fullyConnectedLayer(this_HiddenSize,"Name",this_Decoder_FullyConnectedName)
        dropoutLayer(DropoutPercent_Main,'Name',this_Decoder_DropOutName)
        concatenationLayer(1,2,'Name',this_Decoder_ConcatenationName)
        softplusLayer("Name",this_Decoder_ActivationName)];
    % if stidx==NumStacks
    %     this_Layer_Decoder=[];
    % end

    Layers_AutoEncoder=[
        this_Layer_Encoder
        Layers_AutoEncoder
        this_Layer_Decoder];

end

%%

if ~isempty(Layers_AutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_AutoEncoder);
end

%%
for stidx=NumStacks:-1:1

    this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Decoder_ConcatenationName=sprintf("concatenation_Skip_Decoder_%d",stidx);
    this_Skip_DropoutName=sprintf("dropout_Skip_%d",stidx);


    Layers_Custom = addLayers(Layers_Custom,dropoutLayer(DropoutPercent_Skip,'Name',this_Skip_DropoutName));

    Layers_Custom = connectLayers(Layers_Custom,this_Encoder_FullyConnectedName,this_Skip_DropoutName);
    Layers_Custom = connectLayers(Layers_Custom,this_Skip_DropoutName,this_Decoder_ConcatenationName+"/in2");

%     Layers_Custom = connectLayers(Layers_Custom,this_Encoder_FullyConnectedName,this_Decoder_ConcatenationName+"/in2");

end
%%

Layers_AutoEncoder=[
    Layer_Input
    Layers_AutoEncoder
    Layer_Output];

Layers_AutoEncoder=layerGraph(Layers_AutoEncoder);

Layers_AutoEncoder = connectLayers(Layers_AutoEncoder,'fold_Encoder/miniBatchSize','unfold_Decoder/miniBatchSize');

end

