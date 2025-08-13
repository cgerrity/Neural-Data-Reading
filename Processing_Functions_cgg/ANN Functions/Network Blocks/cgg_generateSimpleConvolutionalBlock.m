function Block = cgg_generateSimpleConvolutionalBlock(FilterSize,NumFilters,Level,FilterNumber,AreaIDX,varargin)
%CGG_GENERATESIMPLECONVOLUTIONALBLOCK Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Dropout = CheckVararginPairs('Dropout', 0, varargin{:});
else
if ~(exist('Dropout','var'))
Dropout=0;
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
Stride = CheckVararginPairs('Stride', 2, varargin{:});
else
if ~(exist('Stride','var'))
Stride=2;
end
end

if isfunction
Activation = CheckVararginPairs('Activation', 'ReLU', varargin{:});
else
if ~(exist('Activation','var'))
Activation='ReLU';
end
end

if isfunction
DownSampleMethod = CheckVararginPairs('DownSampleMethod', 'Same - Stride', varargin{:});
else
if ~(exist('DownSampleMethod','var'))
DownSampleMethod='Same - Stride';
end
end

if isfunction
UpSampleMethod = CheckVararginPairs('UpSampleMethod', 'None', varargin{:});
else
if ~(exist('UpSampleMethod','var'))
UpSampleMethod='None';
end
end

if isfunction
CropAmount = CheckVararginPairs('CropAmount', [0,0], varargin{:});
else
if ~(exist('CropAmount','var'))
CropAmount=[0,0];
end
end

if isfunction
WantResNet = CheckVararginPairs('WantResNet', false, varargin{:});
else
if ~(exist('WantResNet','var'))
WantResNet=false;
end
end

if isfunction
WantPreActivation = CheckVararginPairs('WantPreActivation', false, varargin{:});
else
if ~(exist('WantPreActivation','var'))
WantPreActivation=false;
end
end
%%

% CoderBlock_Name = sprintf("_%s",Coder);
% 
% if ~isnan(AreaIDX)
%     CoderBlock_Name = sprintf("%s_Area-%d",CoderBlock_Name,AreaIDX);
% end
% 
% if ~isnan(FilterNumber)
%     CoderBlock_Name = sprintf("%s_Filter-%d",CoderBlock_Name,FilterNumber);
% end
% 
% if ~isnan(Level)
%     CoderBlock_Name = sprintf("%s_Layer-%d",CoderBlock_Name,Level);
% end

CoderBlock_Name = cgg_generateCoderBlockName(Coder,AreaIDX,FilterNumber,Level);
%%

ConvolutionalFilterSize = FilterSize;

%%
switch DownSampleMethod
    case 'MaxPool'
        DownSampleName="maxpool" + CoderBlock_Name;
        DownSampleLayer = maxPooling2dLayer(Stride,"Name",DownSampleName,'Stride',Stride,"Padding",'same');
        ConvolutionalStride = 1;
    case 'Same - Stride'
        DownSampleLayer = [];
        ConvolutionalStride = Stride;
    case 'Separate - Stride'
        DownSampleName="convolutional1x1" + CoderBlock_Name;
        DownSampleLayer = convolution2dLayer(1,NumFilters,"Name",DownSampleName,"Padding",'same','Stride',[Stride,Stride],"WeightsInitializer","he");
        ConvolutionalStride = 1;
    case 'None'
        ConvolutionalStride = 1;
        DownSampleLayer = [];
end

%%
CropLayer = [];

switch UpSampleMethod
    case 'Transpose Convolution - Point-Wise'
        UpSampleName="transposeconv" + CoderBlock_Name;
        UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping","same","WeightsInitializer","he");
        % UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping",0,"WeightsInitializer","he");
        CropName="crop" + CoderBlock_Name;
        % UpSampleLayer = [UpSampleLayer
        %     cgg_cropLayer(CropName,CropAmount)];
        CropLayer = cgg_cropLayer(CropName,CropAmount);
        ConvolutionalStride = 1;
        ConvolutionalFilterSize = 1;
        ConvolutionalFilterSize = Stride*2;
    case 'Transpose Convolution'
        UpSampleName="transposeconv" + CoderBlock_Name;
        UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping","same","WeightsInitializer","he");
        % UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping",0,"WeightsInitializer","he");
        CropName="crop" + CoderBlock_Name;
        % UpSampleLayer = [UpSampleLayer
        %     cgg_cropLayer(CropName,CropAmount)];
        CropLayer = cgg_cropLayer(CropName,CropAmount);
        ConvolutionalStride = 1;
        ConvolutionalFilterSize = Stride*2;
    case 'None'
        ConvolutionalStride = 1;
        UpSampleLayer = [];
end

%%

ConvolutionalName="convolution" + CoderBlock_Name;

ConvolutionalLayer = convolution2dLayer(ConvolutionalFilterSize,NumFilters,"Name",ConvolutionalName,"Padding",'same','Stride',[ConvolutionalStride,ConvolutionalStride],"WeightsInitializer","he");

% if WantPointWiseConvolution
%     Name_PointWiseConvolution="point-wise_convolution" + CoderLevel_Name;
%     PointWiseConvolutionLayer = convolution2dLayer([1,1],1,"Name",Name_PointWiseConvolution,"Padding",'same');
% else
%     PointWiseConvolutionLayer = [];
% end
Name_PreActivation = "activation-pre" + CoderBlock_Name;
switch Activation
    case 'SoftSign'
        Name_Activation = "activation" + CoderBlock_Name;
        ActivationLayer = softplusLayer("Name",Name_Activation);
        PreActivationLayer = softplusLayer("Name",Name_PreActivation);
    case 'ReLU'
        Name_Activation = "activation" + CoderBlock_Name;
        ActivationLayer = reluLayer("Name",Name_Activation);
        PreActivationLayer = reluLayer("Name",Name_PreActivation);
    case 'Leaky ReLU'
        Name_Activation = "activation" + CoderBlock_Name;
        ActivationLayer = leakyReluLayer("Name",Name_Activation);
        PreActivationLayer = leakyReluLayer("Name",Name_PreActivation);
    case 'GeLU'
        Name_Activation = "activation" + CoderBlock_Name;
        ActivationLayer = geluLayer("Name",Name_Activation);
        PreActivationLayer = geluLayer("Name",Name_PreActivation);
    otherwise
        ActivationLayer = [];
        PreActivationLayer = [];
end

if ~WantPreActivation
    PreActivationLayer = [];
end

Name_Normalization="normalization" + CoderBlock_Name;
NormalizationLayer = cgg_selectNormalizationLayer(WantNormalization,Name_Normalization);

WantDropout = false;
if Dropout > 0
WantDropout = true;
end

if WantDropout
    Name_DropOut = "dropout" + CoderBlock_Name;
    DropoutLayer = [dropoutLayer(Dropout,'Name',Name_DropOut)];
else
    DropoutLayer = [];
end

if WantResNet
    Name_Addition="addition" + CoderBlock_Name;
    AdditionLayer = additionLayer(2,'Name',Name_Addition);
else
    AdditionLayer = [];
end

%%

Block = [
    UpSampleLayer
    PreActivationLayer
    ConvolutionalLayer
    CropLayer
    DropoutLayer
    ActivationLayer
    NormalizationLayer
    DownSampleLayer
    AdditionLayer
    ];

end

