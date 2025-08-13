function PostDecoderBlock = cgg_generatePostDecoderConvolution(Name,OutputSize,FilterSize,FilterHiddenSizes,varargin)
%CGG_GENERATEPOSTDECODERCONVOLUTION Summary of this function goes here
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

% if isfunction
% Stride = CheckVararginPairs('Stride', 1, varargin{:});
% else
% if ~(exist('Stride','var'))
% Stride=1;
% end
% end

if isfunction
Activation = CheckVararginPairs('Activation', 'ReLU', varargin{:});
else
if ~(exist('Activation','var'))
Activation='ReLU';
end
end

% if isfunction
% DownSampleMethod = CheckVararginPairs('DownSampleMethod', 'None', varargin{:});
% else
% if ~(exist('DownSampleMethod','var'))
% DownSampleMethod='None';
% end
% end
% 
% if isfunction
% UpSampleMethod = CheckVararginPairs('UpSampleMethod', 'None', varargin{:});
% else
% if ~(exist('UpSampleMethod','var'))
% UpSampleMethod='None';
% end
% end

% if isfunction
% CropAmount = CheckVararginPairs('CropAmount', [0,0], varargin{:});
% else
% if ~(exist('CropAmount','var'))
% CropAmount=[0,0];
% end
% end

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
FilterNumber = NaN;
AreaIDX = NaN;

PostDecoderBlock = cgg_generateSingleConvolutionalPath(FilterSize,FilterHiddenSizes,FilterNumber,AreaIDX,'Coder',Name,'DownSampleMethod','None','UpSampleMethod','None','Stride',1,'WantNormalization',WantNormalization,'Activation',Activation,'WantResnet',WantResNet,'WantPreActivation',WantPreActivation,'Dropout',Dropout);
PostDecoderBlock = dlnetwork(PostDecoderBlock,Initialize=false);

InputName = "input_" + Name;
InputLayer = functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name=InputName);
InputLayer = dlnetwork(InputLayer,Initialize=false);

[Inputs,~,~,~] = cgg_identifyUnconnectedLayers(PostDecoderBlock);
PostDecoderBlock = cgg_combineLayerGraphs(InputLayer,PostDecoderBlock);
for idx = 1:length(Inputs)
PostDecoderBlock = connectLayers(PostDecoderBlock,InputName,Inputs{idx});
end
ConvolutionalOutputName = "output_" + Name;
OutputLayer = convolution2dLayer(FilterSize,OutputSize,"Name",ConvolutionalOutputName,"Padding",'same','Stride',1,"WeightsInitializer","he");
OutputLayer = dlnetwork(OutputLayer,Initialize=false);

PostDecoderBlock = cgg_connectLayerGraphs(PostDecoderBlock,OutputLayer);

end

