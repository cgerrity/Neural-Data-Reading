function Layers_Custom = cgg_generateLayersForConvolutionalEncoder(InputSize,HiddenSizes,NumTimeWindows,DataFormat)
%CGG_GENERATELAYERSFORAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

Pooling_Reduction=2;

InputSize1D=prod(InputSize,"all");

ReshapeInputSize=[InputSize,NumTimeWindows,0];

NumStacks=numel(HiddenSizes);

Layers_Custom= dlnetwork(layerGraph([ ...
    sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
    fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace"), ...
    fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out"), ...
    functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder"), ...
    reshapeLayer("reshape_Decoder",ReshapeInputSize,DataFormat) 
    ]));

FilterSize=InputSize(2)/2;

%%

Layers_AutoEncoder=[];

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

%     this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_ConvolutionalName=sprintf("convolutional_Encoder_%d",stidx);
%     this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    this_Encoder_PoolingName=sprintf("pooling_Encoder_%d",stidx);
    % this_Encoder_DropOutName=sprintf("dropout_Encoder_%d",stidx);
%     this_Decoder_ConcatenationName=sprintf("concatenation_Decoder_%d",stidx);
%     this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_ConvolutionalName=sprintf("convolutional_Decoder_%d",stidx);
%     this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);
    % this_Decoder_DropOutName=sprintf("dropout_Decoder_%d",stidx);

    this_Layer_Encoder = [
        convolution2dLayer([1,FilterSize],this_HiddenSize,"Name",this_Encoder_LSTMName,"Padding",'same')
        reluLayer("Name",this_Encoder_ActivationName)
        maxPooling2dLayer([1,Pooling_Reduction],"Name",this_Encoder_PoolingName)];
    this_Layer_Decoder = [
        lstmLayer(this_HiddenSize,"Name",this_Decoder_LSTMName,OutputMode="sequence")];

    Layers_AutoEncoder=[
        this_Layer_Encoder
        Layers_AutoEncoder
        this_Layer_Decoder];

end

%%

if ~isempty(Layers_AutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_AutoEncoder);
end


end

