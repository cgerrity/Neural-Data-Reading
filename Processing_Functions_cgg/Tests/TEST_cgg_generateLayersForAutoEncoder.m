

clc; clear; close all;


%%

HiddenSizes = [50,25];
LatentSize = [100];

ModelName = 'Convolution';

ClassifierName = 'Deep LSTM';
LossType = 'Classification';
ClassifierHiddenSize = [1];

NumChannels = 20;
DataWidth = 100;
NumWindows = 10;
NumAreas = 6;
NumExamples = 7;

NumClasses = [1,4,4,4];

DataFormat='SSCTB';

%%
X_TEST=randn(NumChannels,DataWidth,NumAreas,NumWindows,NumExamples);
X_TEST = dlarray(X_TEST,DataFormat);

HiddenSizes = [HiddenSizes,LatentSize];

%%

DataSize=size(X_TEST);
InputSize = NaN(1,3);

InputSize(1:2)=DataSize(finddim(X_TEST,"S"));
InputSize(3)=DataSize(finddim(X_TEST,"C"));
NumTimeWindows=DataSize(finddim(X_TEST,"T"));

ReshapeInputSize=[InputSize,NumTimeWindows,0];

NumStacks=numel(HiddenSizes);
NumAreas = InputSize(3);
NumChannels = InputSize(1);

% Layers_Custom= dlnetwork(layerGraph([ ...
%     sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
%     fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace"), ...
%     fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out"), ...
%     functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder"), ...
%     reshapeLayer("reshape_Decoder",ReshapeInputSize,DataFormat) 
%     ]));

Layers_Custom= dlnetwork(layerGraph([ ...
    sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
    fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace")
    ]));


%%

% FilterSize=InputSize(2)/2;

Layers_AutoEncoder=[];
Layers_AutoEncoder = [fullyConnectedLayer(HiddenSizes(1),"Name",'fc_Encoder')];

FilterSize = InputSize(2);
% StrideSize = InputSize(3);
FilterFactor = 2;
StrideFactor = FilterFactor;


this_StrideSize_Decoder = round(InputSize(2)/(FilterFactor^(length(HiddenSizes))));

FilterSize = FilterSize./(FilterFactor.^(1:length(HiddenSizes)));
FilterSize = ceil(FilterSize);
StrideSize = FilterSize./(StrideFactor);
StrideSize = ceil(StrideSize);
StrideSize = ceil(StrideSize*0+StrideFactor);

StrideSize_Decoder = StrideSize;

%%
% ceil(InputSize(2)/(FilterSize*(1/FilterFactor)*(1/StrideFactor)))
% Size_DecoderBottleNeck = FilterSize*(1/FilterFactor)^(NumStacks)
% 
% Layers_AutoEncoder = [
%         fullyConnectedLayer(HiddenSizes(end),"Name",'fc_Encoder')
%         softplusLayer("Name",'activation_Encoder')
%         fullyConnectedLayer(HiddenSizes(1),"Name",'fc_Decoder')
%         functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_BottleNeck")
%         ];
Layers_AutoEncoder = [
        fullyConnectedLayer(HiddenSizes(end),"Name",'fc_Encoder')
        softplusLayer("Name",'activation_Encoder')
        functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_BottleNeck")
        transposedConv2dLayer([NumChannels,FilterSize(end)],NumAreas,"Name","Convolution_BottleNeck")
        ];
%         transposedConv2dLayer([2,2],NumAreas,"Name","Convolution_BottleNeck")
% fullyConnectedLayer()

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

    this_Encoder_LayerName=sprintf("name_Encoder_%d",stidx);
    this_Decoder_LayerName=sprintf("name_Decoder_%d",stidx);

    this_Encoder_ConvolutionalName=sprintf("convolutional_Encoder_%d",stidx);
    this_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d",stidx);
    this_Decoder_ConvolutionalName=sprintf("convolutional_Decoder_%d",stidx);
    this_Decoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Decoder_%d",stidx);
    this_Decoder_CropName = sprintf("crop_Decoder_%d",stidx);
    % this_Encoder_DepthToSpaceName=sprintf("depthtospace_Encoder_%d",stidx);

    this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    
    this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);

    % convolution2dLayer([1,FilterSize],this_HiddenSize,"Name",this_Encoder_ConvolutionalName,"Padding",'same')

    this_FilterSize = FilterSize(stidx);
    this_StrideSize = StrideSize(stidx);
    % StrideSize = round(FilterSize/StrideFactor);
    this_StrideSize_Decoder = StrideSize_Decoder(stidx);
    
    this_Layer_Encoder = [
        groupedConvolution2dLayer([1,this_FilterSize],this_HiddenSize,'channel-wise',"Name",this_Encoder_ConvolutionalName,"Padding",'same','Stride',[1,this_StrideSize])
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Encoder_PointWiseConvolutionalName,"Padding",'same')
        reluLayer("Name",this_Encoder_ActivationName)];
    % Add 1x1 convolution over the corresponding channels to reduce the
    % channels back to the number of areas?
    % this_Layer_Decoder = [];
    % this_Layer_Decoder = [
    %     transposedConv2dLayer([1,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[1,this_StrideSize_Decoder],"Cropping","same","Name",this_Decoder_ConvolutionalName)
    %     groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same')
    %     reluLayer("Name",this_Decoder_ActivationName)];
    this_Layer_Decoder = [
        transposedConv2dLayer([1,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[1,this_StrideSize_Decoder],"Cropping","same","Name",this_Decoder_ConvolutionalName)
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same')
        crop2dLayer('centercrop','Name',this_Decoder_CropName)
        reluLayer("Name",this_Decoder_ActivationName)];

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

% Layers_Custom = connectLayers(Layers_Custom,this_Encoder_PointWiseConvolutionalName,[this_Decoder_CropName '/ref'])

%%
Layers_Custom_func = cgg_selectAutoEncoder(ModelName,InputSize,HiddenSizes,NumWindows,DataFormat);
% Layers_Custom_func = cgg_generateLayersForConvolutionalEncoder(InputSize,HiddenSizes,LatentSize);
% Layers_Custom_func = cgg_generateLayersForReccurentEncoder(InputSize,HiddenSizes,NumWindows,DataFormat);
% Layers_Custom_func = removeLayers(Layers_Custom_func,{Layers_Custom_func.Layers(33:44).Name});
NetBase= initialize(Layers_Custom_func);

Layers_Classifier = cgg_selectClassifier(ClassifierName,NumClasses,LossType,'ClassifierHiddenSize',ClassifierHiddenSize);
NetFull = cgg_constructClassifierNetwork_v2(NetBase,Layers_Classifier);

% InputNet= initialize(Layers_Custom);
InputNet= initialize(NetFull);

% LastLayerIDX = 10;
% Remove_Layers = [1:20,22:43];
% InputSize_Modified = [100];
% 
% InputNet_Modified = removeLayers(InputNet,{InputNet.Layers(Remove_Layers).Name});
% InputNet_Modified = addLayers(InputNet_Modified,sequenceInputLayer(InputSize_Modified,"Name","sequence_Encoder"));
% InputNet_Modified = connectLayers(InputNet_Modified,"sequence_Encoder","activation_Encoder");
% 
% X_TEST_Modified=randn(100,7,10);
% X_TEST_Modified(1,1,1) = 0;
% X_TEST_Modified = dlarray(X_TEST_Modified,'CBT');
% 
% InputNet_Modified = initialize(InputNet_Modified);

%%

% X_TEST(1,1,1,1,1)=1000;
% InputNet_Modified = resetState(InputNet_Modified);
% OutputNames_Modified={InputNet_Modified.Layers(:).Name};
% OutputExample_Modified=cell(1,length(OutputNames_Modified));
% [OutputExample_Modified{:}]=forward(InputNet_Modified,X_TEST_Modified,Outputs=OutputNames_Modified);

OutputNames=cellfun(@(x) [x '/out'],{InputNet.Layers(:).Name},'UniformOutput',false);
OutputExample=cell(1,length(OutputNames));
[OutputExample{:}]=forward(InputNet,X_TEST,Outputs=OutputNames);

%%
% IDX = 1; {OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))}
OutputTable_Cell = cell(length(OutputExample),5);
for IDX = 1:length(OutputNames)
    OutputTable_Cell{IDX,1} = OutputNames{IDX};
    OutputTable_Cell{IDX,2} = IDX;
    OutputTable_Cell{IDX,3} = OutputExample{IDX}.dims;
    OutputTable_Cell{IDX,4} = size(OutputExample{IDX});
    OutputTable_Cell{IDX,5} = numel(OutputExample{IDX});
    OutputTable_Cell{IDX,6} = double([min(extractdata(OutputExample{IDX}(:))),max(extractdata(OutputExample{IDX}(:)))]);
    OutputTable_Cell{IDX,7} = OutputTable_Cell{IDX,6}(2)-OutputTable_Cell{IDX,6}(1);
    % OutputTable_Cell{IDX} = {OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))};
% disp({OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))})
end

OutputTable = table(OutputTable_Cell);
% sel_Channel = 1:6;
% aaaa = squeeze(extractdata(OutputExample{IDX}(1,1,sel_Channel,1,1)));

% %%
% 
% OutputTable_Cell_Modified = cell(length(OutputExample_Modified),5);
% for IDX = 1:length(OutputNames_Modified)
%     OutputTable_Cell_Modified{IDX,1} = OutputNames_Modified{IDX};
%     OutputTable_Cell_Modified{IDX,2} = IDX;
%     OutputTable_Cell_Modified{IDX,3} = OutputExample_Modified{IDX}.dims;
%     OutputTable_Cell_Modified{IDX,4} = size(OutputExample_Modified{IDX});
%     OutputTable_Cell_Modified{IDX,5} = numel(OutputExample_Modified{IDX});
%     OutputTable_Cell_Modified{IDX,6} = [min(extractdata(OutputExample_Modified{IDX}(:))),max(extractdata(OutputExample_Modified{IDX}(:)))];
%     % OutputTable_Cell{IDX} = {OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))};
% % disp({OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))})
% end
% 
% OutputTable_Modified = table(OutputTable_Cell_Modified);

%%

% GradientValues = workerGradients.Value(WeightIDX);
% for gidx = 1:length(GradientValues)
%   MeanThresholdGradient(iteration,gidx) = mean(GradientValues{gidx},"all");
%   STDThresholdGradient(iteration,gidx) = std(GradientValues{gidx},[],"all");
% end