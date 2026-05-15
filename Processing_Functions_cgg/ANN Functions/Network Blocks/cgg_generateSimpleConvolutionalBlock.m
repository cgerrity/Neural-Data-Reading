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

if isfunction
BlockDepth = CheckVararginPairs('BlockDepth', NaN, varargin{:});
else
if ~(exist('BlockDepth','var'))
BlockDepth=NaN; % Number of convolutional and activation layers in a single block
end
end

if isfunction
IsGrouped = CheckVararginPairs('IsGrouped', true, varargin{:});
else
if ~(exist('IsGrouped','var'))
IsGrouped=true; % Number of convolutional and activation layers in a single block
end
end

if isfunction
IsLastDepth = CheckVararginPairs('IsLastDepth', true, varargin{:});
else
if ~(exist('IsLastDepth','var'))
IsLastDepth=true; % Number of convolutional and activation layers in a single block
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

%%
if ~IsLastDepth
    Stride = 1;
    DownSampleMethod = 'None';
    UpSampleMethod = 'None';
end

%%

CoderBlock_Name = cgg_generateCoderBlockName(Coder,AreaIDX,FilterNumber,Level,'IsGrouped',IsGrouped,'BlockDepth',BlockDepth);
%%

ConvolutionalFilterSize = FilterSize;

%%
switch DownSampleMethod
    case 'MaxPool'
        % DownSampleName="maxpool" + CoderBlock_Name;
        DownSampleName = cgg_generateLayerName(CoderBlock_Name,"maxpool",'IsGrouped',IsGrouped);
        DownSampleLayer = maxPooling2dLayer(Stride,"Name",DownSampleName,'Stride',Stride,"Padding",'same');
        ConvolutionalStride = 1;
    case 'Same - Stride'
        DownSampleLayer = [];
        ConvolutionalStride = Stride;
    case 'Separate - Stride'
        % DownSampleName="convolutional1x1" + CoderBlock_Name;
        DownSampleName = cgg_generateLayerName(CoderBlock_Name,"convolutional1x1",'IsGrouped',IsGrouped);
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
        % UpSampleName="transposeconv" + CoderBlock_Name;
        UpSampleName = cgg_generateLayerName(CoderBlock_Name,"transposeconv",'IsGrouped',IsGrouped);
        UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping","same","WeightsInitializer","he");
        % UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping",0,"WeightsInitializer","he");
        % CropName="crop" + CoderBlock_Name;
        CropName = cgg_generateLayerName(CoderBlock_Name,"crop",'IsGrouped',IsGrouped);
        % UpSampleLayer = [UpSampleLayer
        %     cgg_cropLayer(CropName,CropAmount)];
        CropLayer = cgg_cropLayer(CropName,CropAmount);
        ConvolutionalStride = 1;
        ConvolutionalFilterSize = 1;
        ConvolutionalFilterSize = Stride*2;
    case 'Transpose Convolution'
        % UpSampleName="transposeconv" + CoderBlock_Name;
        UpSampleName = cgg_generateLayerName(CoderBlock_Name,"transposeconv",'IsGrouped',IsGrouped);
        UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping","same","WeightsInitializer","he");
        % UpSampleLayer = transposedConv2dLayer(FilterSize,NumFilters,"Name",UpSampleName,'Stride',Stride,"Cropping",0,"WeightsInitializer","he");
        CropName="crop" + CoderBlock_Name;
        CropName = cgg_generateLayerName(CoderBlock_Name,"crop",'IsGrouped',IsGrouped);
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

% ConvolutionalName="convolution" + CoderBlock_Name;
ConvolutionalName = cgg_generateLayerName(CoderBlock_Name,"convolution",'IsGrouped',IsGrouped);

ConvolutionalLayer = convolution2dLayer(ConvolutionalFilterSize,NumFilters,"Name",ConvolutionalName,"Padding",'same','Stride',[ConvolutionalStride,ConvolutionalStride],"WeightsInitializer","he");

% if WantPointWiseConvolution
%     Name_PointWiseConvolution="point-wise_convolution" + CoderLevel_Name;
%     PointWiseConvolutionLayer = convolution2dLayer([1,1],1,"Name",Name_PointWiseConvolution,"Padding",'same');
% else
%     PointWiseConvolutionLayer = [];
% end
% Name_PreActivation = "activation-pre" + CoderBlock_Name;
Name_PreActivation = cgg_generateLayerName(CoderBlock_Name,"activation-pre",'IsGrouped',IsGrouped);
switch Activation
    case 'SoftSign'
        % Name_Activation = "activation" + CoderBlock_Name;
        Name_Activation = cgg_generateLayerName(CoderBlock_Name,"activation",'IsGrouped',IsGrouped);
        ActivationLayer = softplusLayer("Name",Name_Activation);
        PreActivationLayer = softplusLayer("Name",Name_PreActivation);
    case 'ReLU'
        % Name_Activation = "activation" + CoderBlock_Name;
        Name_Activation = cgg_generateLayerName(CoderBlock_Name,"activation",'IsGrouped',IsGrouped);
        ActivationLayer = reluLayer("Name",Name_Activation);
        PreActivationLayer = reluLayer("Name",Name_PreActivation);
    case 'Leaky ReLU'
        % Name_Activation = "activation" + CoderBlock_Name;
        Name_Activation = cgg_generateLayerName(CoderBlock_Name,"activation",'IsGrouped',IsGrouped);
        ActivationLayer = leakyReluLayer("Name",Name_Activation);
        PreActivationLayer = leakyReluLayer("Name",Name_PreActivation);
    case 'GeLU'
        % Name_Activation = "activation" + CoderBlock_Name;
        Name_Activation = cgg_generateLayerName(CoderBlock_Name,"activation",'IsGrouped',IsGrouped);
        ActivationLayer = geluLayer("Name",Name_Activation);
        PreActivationLayer = geluLayer("Name",Name_PreActivation);
    otherwise
        ActivationLayer = [];
        PreActivationLayer = [];
end

if ~WantPreActivation
    PreActivationLayer = [];
end

% Name_Normalization="normalization" + CoderBlock_Name;
Name_Normalization = cgg_generateLayerName(CoderBlock_Name,"normalization",'IsGrouped',IsGrouped);
NormalizationLayer = cgg_selectNormalizationLayer(WantNormalization,Name_Normalization);

WantDropout = false;
if Dropout > 0
WantDropout = true;
end

if WantDropout
    % Name_DropOut = "dropout" + CoderBlock_Name;
    Name_DropOut = cgg_generateLayerName(CoderBlock_Name,"dropout",'IsGrouped',IsGrouped);
    DropoutLayer = [dropoutLayer(Dropout,'Name',Name_DropOut)];
else
    DropoutLayer = [];
end

if IsLastDepth
    ActivationLayerLast = ActivationLayer;
    CoderBlockLast_Name = cgg_generateCoderBlockName(Coder,AreaIDX,FilterNumber,Level,'IsGrouped',IsGrouped,'BlockDepth',NaN);
    Name_ActivationLast = cgg_generateLayerName(CoderBlockLast_Name,"activation",'IsGrouped',IsGrouped);
    ActivationLayerLast.Name = Name_ActivationLast;
    ActivationLayer = [];
else
    ActivationLayerLast = [];
end

if WantResNet && IsLastDepth
    % Name_Addition="addition" + CoderBlock_Name;
    Name_Addition = cgg_generateLayerName(CoderBlockLast_Name,"addition",'IsGrouped',IsGrouped);
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
    ActivationLayerLast
    ];

end

