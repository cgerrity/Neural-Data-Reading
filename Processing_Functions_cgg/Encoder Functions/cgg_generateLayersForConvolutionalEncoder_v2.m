function Layers_Custom = cgg_generateLayersForConvolutionalEncoder_v2(InputSize,HiddenSizes,LatentSize)
%CGG_GENERATELAYERSFORAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

FilterFactor = 2;
NumFilterChanges = 3;

%%

StrideFactor = FilterFactor;

%%

NumStacks=numel(HiddenSizes);
NumAreas = InputSize(3);
NumChannels = InputSize(1);
DataWidth = InputSize(2);

%%

Layers_Custom= dlnetwork(layerGraph([ ...
    sequenceInputLayer(InputSize,"Name","sequence_Encoder","Normalization","rescale-zero-one","NormalizationDimension","channel"), ...
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

    this_Encoder_FilterCombination = sprintf("combination_Encoder_%d",stidx);
    this_Decoder_FilterCombination = sprintf("combination_Decoder_%d",stidx);

    this_FilterSize = FilterSize(stidx);
    this_FilterSize_Channel = FilterSize_Channel(stidx);

    if stidx>1
    this_Decoder_Combination_Size = FilterSize_Channel(stidx-1);
    else
    this_Decoder_Combination_Size = NumChannels;
    end

    this_Layer_Encoder_Filter = cell(1,NumFilterChanges);
    this_Layer_Decoder_Filter = cell(1,NumFilterChanges);


    %%
    for lidx = 1:NumFilterChanges

        this_FilterFull = ceil([this_FilterSize_Channel,this_FilterSize]*((1/2)^(lidx-1)));
        this_Filter_Encoder_ConvolutionalName = sprintf(this_Encoder_ConvolutionalName + "_Filter_%d",lidx);
        this_Filter_Encoder_PointWiseConvolutionalName = sprintf(this_Encoder_PointWiseConvolutionalName + "_Filter_%d",lidx);
        this_Filter_Decoder_ConvolutionalName = sprintf(this_Decoder_ConvolutionalName + "_Filter_%d",lidx);
        this_Filter_Decoder_PointWiseConvolutionalName = sprintf(this_Decoder_PointWiseConvolutionalName + "_Filter_%d",lidx);


        this_Layer_Encoder_Filter{lidx} = [
        groupedConvolution2dLayer(this_FilterFull,this_HiddenSize,'channel-wise',"Name",this_Filter_Encoder_ConvolutionalName,"Padding",'same','Stride',[StrideSize,StrideSize])
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Filter_Encoder_PointWiseConvolutionalName,"Padding",'same')];
        
        this_Layer_Decoder_Filter{lidx} = [
        transposedConv2dLayer(this_FilterFull,this_HiddenSize*NumAreas,"Stride",[StrideSize,StrideSize],"Cropping","same","Name",this_Filter_Decoder_ConvolutionalName,"WeightsInitializer","glorot","BiasInitializer","zeros")
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Filter_Decoder_PointWiseConvolutionalName,"Padding",'same',"WeightsInitializer","glorot","BiasInitializer","zeros")];
    end
%%

this_Encoder_ConcatenationName=sprintf("concatenation_Filters_Encoder_%d",stidx);
this_Decoder_ConcatenationName=sprintf("concatenation_Filters_Decoder_%d",stidx);

this_Layer_Encoder = [concatenationLayer(1,NumFilterChanges,'Name',this_Encoder_ConcatenationName)];
this_Layer_Decoder = [concatenationLayer(1,NumFilterChanges,'Name',this_Decoder_ConcatenationName)];

for lidx = 1:NumFilterChanges
this_Layer_Encoder = [this_Layer_Encoder_Filter{lidx}
                        this_Layer_Encoder];
this_Layer_Decoder = [this_Layer_Decoder_Filter{lidx}
                        this_Layer_Decoder];
end

%%
    % if stidx ==1
    % this_Layer_Decoder = [
    %     transposedConv2dLayer([this_FilterSize_Channel,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[StrideSize,StrideSize],"Cropping","same","Name",this_Decoder_ConvolutionalName,"WeightsInitializer","glorot","BiasInitializer","zeros")
    %     groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same',"WeightsInitializer","glorot","BiasInitializer","zeros")
    %     crop2dLayer('centercrop','Name',this_Decoder_CropName)];
    % end
if stidx > 1
    Layers_AutoEncoder=[
        this_Layer_Encoder
        groupedConvolution2dLayer([NumFilterChanges,1],1,NumAreas,"Name",this_Encoder_FilterCombination,"WeightsInitializer","glorot","BiasInitializer","zeros","DilationFactor",[this_FilterSize_Channel,1])
        reluLayer("Name",this_Encoder_ActivationName);
        layerNormalizationLayer('Name',this_Encoder_NormalizationName)
        Layers_AutoEncoder
        layerNormalizationLayer('Name',this_Decoder_NormalizationName)
        this_Layer_Decoder
        groupedConvolution2dLayer([NumFilterChanges,1],1,NumAreas,"Name",this_Decoder_FilterCombination,"WeightsInitializer","glorot","BiasInitializer","zeros","DilationFactor",[this_Decoder_Combination_Size,1])
        crop2dLayer('centercrop','Name',this_Decoder_CropName)
        reluLayer("Name",this_Decoder_ActivationName)];
else
    Layers_AutoEncoder=[
        this_Layer_Encoder
        groupedConvolution2dLayer([NumFilterChanges,1],1,NumAreas,"Name",this_Encoder_FilterCombination,"WeightsInitializer","glorot","BiasInitializer","zeros","DilationFactor",[this_FilterSize_Channel,1])
        reluLayer("Name",this_Encoder_ActivationName);
        layerNormalizationLayer('Name',this_Encoder_NormalizationName)
        Layers_AutoEncoder
        layerNormalizationLayer('Name',this_Decoder_NormalizationName)
        this_Layer_Decoder
        groupedConvolution2dLayer([NumFilterChanges,1],1,NumAreas,"Name",this_Decoder_FilterCombination,"WeightsInitializer","glorot","BiasInitializer","zeros","DilationFactor",[this_Decoder_Combination_Size,1])
        crop2dLayer('centercrop','Name',this_Decoder_CropName)];
end

end

if ~isempty(Layers_AutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_AutoEncoder);
end


%%

for stidx = 1:NumStacks
for lidx = 1:NumFilterChanges
this_Filter_Encoder_ConvolutionalName=sprintf("convolutional_Encoder_%d_Filter_%d",stidx,lidx);
this_Filter_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d_Filter_%d",stidx,lidx);
this_Filter_Decoder_ConvolutionalName=sprintf("convolutional_Decoder_%d_Filter_%d",stidx,lidx);
this_Filter_Decoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Decoder_%d_Filter_%d",stidx,lidx);
% this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx-1);
this_Encoder_ActivationName=sprintf("normalization_Encoder_%d",stidx-1);
% this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx+1);
this_Decoder_ActivationName=sprintf("normalization_Decoder_%d",stidx);
this_Encoder_ConcatenationName=sprintf("concatenation_Filters_Encoder_%d/in%d",stidx,lidx);
this_Decoder_ConcatenationName=sprintf("concatenation_Filters_Decoder_%d/in%d",stidx,lidx);

if stidx==1
this_Encoder_ActivationName = "sequence_Encoder";
end
% if stidx==NumStacks
% % this_Decoder_ActivationName = "Convolution_BottleNeck";
% this_Decoder_ActivationName = "activation_BottleNeck_2";
% end

%
Connections_Destination = Layers_Custom.Connections.Destination;
Connections_Source = Layers_Custom.Connections.Source;

Disconnect_IDX = strcmp(Connections_Destination,this_Filter_Encoder_ConvolutionalName);
if any(Disconnect_IDX)
Layers_Custom = disconnectLayers(Layers_Custom,Connections_Source{Disconnect_IDX},this_Filter_Encoder_ConvolutionalName);
end
Layers_Custom = connectLayers(Layers_Custom,this_Encoder_ActivationName,this_Filter_Encoder_ConvolutionalName);
%
Connections_Destination = Layers_Custom.Connections.Destination;
Connections_Source = Layers_Custom.Connections.Source;

Disconnect_IDX = strcmp(Connections_Source,this_Filter_Encoder_PointWiseConvolutionalName);
if any(Disconnect_IDX)
Layers_Custom = disconnectLayers(Layers_Custom,this_Filter_Encoder_PointWiseConvolutionalName,Connections_Destination{Disconnect_IDX});
end
Layers_Custom = connectLayers(Layers_Custom,this_Filter_Encoder_PointWiseConvolutionalName,this_Encoder_ConcatenationName);
%
Connections_Destination = Layers_Custom.Connections.Destination;
Connections_Source = Layers_Custom.Connections.Source;

Disconnect_IDX = strcmp(Connections_Destination,this_Filter_Decoder_ConvolutionalName);
if any(Disconnect_IDX)
Layers_Custom = disconnectLayers(Layers_Custom,Connections_Source{Disconnect_IDX},this_Filter_Decoder_ConvolutionalName);
end
Layers_Custom = connectLayers(Layers_Custom,this_Decoder_ActivationName,this_Filter_Decoder_ConvolutionalName);
%
Connections_Destination = Layers_Custom.Connections.Destination;
Connections_Source = Layers_Custom.Connections.Source;

Disconnect_IDX = strcmp(Connections_Source,this_Filter_Decoder_PointWiseConvolutionalName);
if any(Disconnect_IDX)
Layers_Custom = disconnectLayers(Layers_Custom,this_Filter_Decoder_PointWiseConvolutionalName,Connections_Destination{Disconnect_IDX});
end
Layers_Custom = connectLayers(Layers_Custom,this_Filter_Decoder_PointWiseConvolutionalName,this_Decoder_ConcatenationName);


end
end
%%
this_Decoder_CropName = sprintf("crop_Decoder_%d",1);
Layers_Custom = connectLayers(Layers_Custom,Layers_Custom.Layers(1).Name,this_Decoder_CropName + "/ref");

for stidx = 2:NumStacks
    this_Encoder_FilterCombination = sprintf("combination_Encoder_%d",stidx-1);
    % this_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d",stidx-1);
    this_Decoder_CropName = sprintf("crop_Decoder_%d",stidx);
    Layers_Custom = connectLayers(Layers_Custom,this_Encoder_FilterCombination,this_Decoder_CropName + "/ref");
end

end

