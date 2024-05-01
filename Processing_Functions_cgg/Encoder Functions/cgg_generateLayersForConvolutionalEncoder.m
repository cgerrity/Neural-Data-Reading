function Layers_Custom = cgg_generateLayersForConvolutionalEncoder(InputSize,HiddenSizes,LatentSize)
%CGG_GENERATELAYERSFORAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

FilterFactor = 2;

%%

StrideFactor = FilterFactor;

%%

NumStacks=numel(HiddenSizes);
NumAreas = InputSize(3);
NumChannels = InputSize(1);
DataWidth = InputSize(2);

%%

Layers_Custom= dlnetwork(layerGraph([ ...
    sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
    fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace"), ...
    functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name="Format_Decoder_Output")
    ]));

%%
FilterSize = DataWidth;

FilterSize = FilterSize./(FilterFactor.^(1:length(HiddenSizes)));
FilterSize = ceil(FilterSize);
StrideSize = StrideFactor;

FilterSize_Channel = NumChannels;

FilterSize_Channel = FilterSize_Channel./(FilterFactor.^(1:length(HiddenSizes)));
FilterSize_Channel = ceil(FilterSize_Channel);

%%

Layers_AutoEncoder = [
        fullyConnectedLayer(LatentSize,"Name",'fc_Encoder')
        reluLayer("Name",'activation_BottleNeck_1')
        functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_BottleNeck")
        transposedConv2dLayer([FilterSize_Channel(end),FilterSize(end)],NumAreas,"Name","Convolution_BottleNeck")
        reluLayer("Name",'activation_BottleNeck_2')
        ];

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

    % this_HiddenSize=ceil(HiddenSizes(stidx)/(DataWidth/NumAreas));
    % this_Encoder_LayerName=sprintf("name_Encoder_%d",stidx);
    % this_Decoder_LayerName=sprintf("name_Decoder_%d",stidx);

    this_Encoder_ConvolutionalName=sprintf("convolutional_Encoder_%d",stidx);
    this_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d",stidx);
    this_Encoder_NormalizationName=sprintf("normalization_Encoder_%d",stidx);
    this_Decoder_ConvolutionalName=sprintf("convolutional_Decoder_%d",stidx);
    this_Decoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Decoder_%d",stidx);
    this_Decoder_CropName = sprintf("crop_Decoder_%d",stidx);
    this_Decoder_NormalizationName=sprintf("normalization_Decoder_%d",stidx);
    % this_Encoder_DepthToSpaceName=sprintf("depthtospace_Encoder_%d",stidx);

    % this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    
    % this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);

    this_FilterSize = FilterSize(stidx);
    this_FilterSize_Channel = FilterSize_Channel(stidx);
    
    this_Layer_Encoder = [
        groupedConvolution2dLayer([this_FilterSize_Channel,this_FilterSize],this_HiddenSize,'channel-wise',"Name",this_Encoder_ConvolutionalName,"Padding",'same','Stride',[StrideSize,StrideSize])
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Encoder_PointWiseConvolutionalName,"Padding",'same')
        reluLayer("Name",this_Encoder_ActivationName)
        layerNormalizationLayer('Name',this_Encoder_NormalizationName)];

    this_Layer_Decoder = [
        layerNormalizationLayer('Name',this_Decoder_NormalizationName)
        transposedConv2dLayer([this_FilterSize_Channel,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[StrideSize,StrideSize],"Cropping","same","Name",this_Decoder_ConvolutionalName,"WeightsInitializer","glorot","BiasInitializer","zeros")
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same',"WeightsInitializer","glorot","BiasInitializer","zeros")
        crop2dLayer('centercrop','Name',this_Decoder_CropName)
        reluLayer("Name",this_Decoder_ActivationName)];

    if stidx ==1
    this_Layer_Decoder = [
        layerNormalizationLayer('Name',this_Decoder_NormalizationName)
        transposedConv2dLayer([this_FilterSize_Channel,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[StrideSize,StrideSize],"Cropping","same","Name",this_Decoder_ConvolutionalName,"WeightsInitializer","glorot","BiasInitializer","zeros")
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same',"WeightsInitializer","glorot","BiasInitializer","zeros")
        crop2dLayer('centercrop','Name',this_Decoder_CropName)];
    end

    Layers_AutoEncoder=[
        this_Layer_Encoder
        Layers_AutoEncoder
        this_Layer_Decoder];

end

if ~isempty(Layers_AutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_AutoEncoder);
end

%%
this_Decoder_CropName = sprintf("crop_Decoder_%d",1);
Layers_Custom = connectLayers(Layers_Custom,Layers_Custom.Layers(1).Name,this_Decoder_CropName + "/ref");

for stidx = 2:NumStacks
    this_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d",stidx-1);
    this_Decoder_CropName = sprintf("crop_Decoder_%d",stidx);
    Layers_Custom = connectLayers(Layers_Custom,this_Encoder_PointWiseConvolutionalName,this_Decoder_CropName + "/ref");
end

end

