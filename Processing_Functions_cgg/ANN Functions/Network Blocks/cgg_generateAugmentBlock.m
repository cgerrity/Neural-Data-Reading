function AugmentBlock = cgg_generateAugmentBlock(HiddenSize,OutputSize,WantLearnableScale,WantLearnableOffset,BlockNameAddition,varargin)
%CGG_GENERATEAUGMENTBLOCK Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
UniqueDimension = CheckVararginPairs('UniqueDimension', [], varargin{:});
else
if ~(exist('UniqueDimension','var'))
UniqueDimension=[];
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', 'SSCBT', varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat='SSCBT';
end
end

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
Transform = CheckVararginPairs('Transform', 'Feedforward', varargin{:});
else
if ~(exist('Transform','var'))
Transform='Feedforward';
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
AugmentEquation = CheckVararginPairs('AugmentEquation', 'mX+b+X', varargin{:});
else
if ~(exist('AugmentEquation','var'))
AugmentEquation='mX+b+X';
end
end
%% Augment parameters

switch Transform
    case 'LSTM'
        Activation='';
    case 'GRU'
        Activation='';
    case 'Feedforward'
    otherwise
        Activation='';
end

if ~isempty(BlockNameAddition)
    BlockNameAddition = "_" + BlockNameAddition;
end

%%

NonUniqueDimension = 1:length(OutputSize);
NonUniqueDimension(UniqueDimension) = [];
InputSize_Reshape = OutputSize;
InputSize_Reshape(NonUniqueDimension) = 1;


NumAugmentValues = WantLearnableOffset + WantLearnableScale;

AddSpatialName = "addspatial_%s_Augment" + BlockNameAddition;
ReshapeName = "reshape_%s_Augment" + BlockNameAddition;
RepmatName = "repeat_%s_Augment" + BlockNameAddition;

RepmatSize = ones(1, length(DataFormat));
RepmatSize(NonUniqueDimension) = OutputSize(NonUniqueDimension);

MultiplicationReshapeRepeatBlock = [functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name=sprintf(AddSpatialName,'scale'))
        reshapeLayer_2(sprintf(ReshapeName,'scale'),InputSize_Reshape)
        functionLayer(@(X) repmat(X,RepmatSize),Formattable=true,Acceleratable=true,Name=sprintf(RepmatName,'scale'))];
AdditionReshapeRepeatBlock = [functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name=sprintf(AddSpatialName,'offset'))
        reshapeLayer_2(sprintf(ReshapeName,'offset'),InputSize_Reshape)
        functionLayer(@(X) repmat(X,RepmatSize),Formattable=true,Acceleratable=true,Name=sprintf(RepmatName,'offset'))];

%%

Name_Output = "output_Augment" + BlockNameAddition;
FullyConnectedName = "fullyconnected_Augment" + BlockNameAddition;

TargetName = "target_Augment" + BlockNameAddition;
TargetLayer = functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name=TargetName);
LearnableName = "learnable_Augment" + BlockNameAddition;
LearnableLayer = functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name=LearnableName);
%%

% AdditionFunctionName = "repeatreshape_offset" + BlockNameAddition;
% MultiplicationFunctionName = "repeatreshape_scale" + BlockNameAddition;

% RepeatReshapeFunction = @(X,T) cgg_getRepeatReshapeArray(X, size(T), UniqueDimension);
% AdditionFunctionLayer = functionLayer(RepeatReshapeFunction,Formattable=true,Acceleratable=true,Name=AdditionFunctionName);
% MultiplicationFunctionLayer = functionLayer(RepeatReshapeFunction,Formattable=true,Acceleratable=true,Name=MultiplicationFunctionName);

if ~isempty(UniqueDimension)
    SizeAugmentValues = prod(OutputSize(UniqueDimension))*NumAugmentValues;
end

AugmentBlock = cgg_generateSimpleBlock(HiddenSize,NaN, ...
    'Coder',"Augment" + BlockNameAddition,'Dropout',Dropout, ...
    'WantNormalization',WantNormalization,'Transform',Transform, ...
    'Activation',Activation);

AugmentBlock = [LearnableLayer
    AugmentBlock
    fullyConnectedLayer(SizeAugmentValues,"Name",FullyConnectedName,"WeightsInitializer","he")];

AugmentBlock = dlnetwork(AugmentBlock,Initialize=false);
[~,Source,~,~] = cgg_identifyUnconnectedLayers(AugmentBlock);
Source = Source{1};
Source_Offset = Source;
Source_Scale = Source;

AugmentBlock = addLayers(AugmentBlock,TargetLayer);

%%

Name_Addition = Name_Output;
Name_Multiplication = Name_Output;

if NumAugmentValues>1
    AugmentSplitName="splitAugment" + BlockNameAddition;
    % AugmentInputSize = 2;
    AugmentSplitLayer = cgg_splitLayer(AugmentSplitName,SizeAugmentValues,1,'OutputNames',["offset","scale"],'NumNewSplits',2);
    AugmentBlock = addLayers(AugmentBlock,AugmentSplitLayer);
    AugmentBlock = connectLayers(AugmentBlock,Source,AugmentSplitName);
    Source_Offset = AugmentSplitName + "/offset";
    Source_Scale = AugmentSplitName + "/scale";
    Name_Addition="addition_Augment" + BlockNameAddition;
    Name_Multiplication="multiplication_Augment" + BlockNameAddition;

end

%%

if WantLearnableOffset
AdditionLayer = additionLayer(2,'Name',Name_Addition);
% AugmentBlock = addLayers(AugmentBlock,AdditionFunctionLayer);
% AugmentBlock = connectLayers(AugmentBlock,Source_Offset,AdditionFunctionName + "/in1");
AugmentBlock = addLayers(AugmentBlock,AdditionReshapeRepeatBlock);
AugmentBlock = connectLayers(AugmentBlock,Source_Offset,sprintf(AddSpatialName,'offset'));
AugmentBlock = addLayers(AugmentBlock,AdditionLayer);
% AugmentBlock = connectLayers(AugmentBlock,AdditionFunctionName,Name_Addition + "/in1");
AugmentBlock = connectLayers(AugmentBlock,sprintf(RepmatName,'offset'),Name_Addition + "/in1");
AugmentBlock = connectLayers(AugmentBlock,TargetName,Name_Addition + "/in2");
% AugmentBlock = connectLayers(AugmentBlock,TargetName,AdditionFunctionName + "/in2");

switch AugmentEquation
    case 'm(X+b)'
        TargetName = Name_Addition;
    case 'mX+b+X'
    otherwise
end
end

%%
if WantLearnableScale
MultiplicationLayer = multiplicationLayer(2,'Name',Name_Multiplication);
% AugmentBlock = addLayers(AugmentBlock,MultiplicationFunctionLayer);
% AugmentBlock = connectLayers(AugmentBlock,Source_Scale,MultiplicationFunctionName + "/in1");
AugmentBlock = addLayers(AugmentBlock,MultiplicationReshapeRepeatBlock);
AugmentBlock = connectLayers(AugmentBlock,Source_Scale,sprintf(AddSpatialName,'scale'));
AugmentBlock = addLayers(AugmentBlock,MultiplicationLayer);
% AugmentBlock = connectLayers(AugmentBlock,MultiplicationFunctionName,Name_Multiplication + "/in1");
AugmentBlock = connectLayers(AugmentBlock,sprintf(RepmatName,'scale'),Name_Multiplication + "/in1");
AugmentBlock = connectLayers(AugmentBlock,TargetName,Name_Multiplication + "/in2");
% AugmentBlock = connectLayers(AugmentBlock,TargetName,MultiplicationFunctionName + "/in2");

switch AugmentEquation
    case 'm(X+b)'
        TargetName = Name_Multiplication;
    case 'mX+b+X'
    otherwise
end
end

%%

if NumAugmentValues > 1
switch AugmentEquation
    case 'm(X+b)'
        OuputLayer = functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name=Name_Output);
        AugmentBlock = addLayers(AugmentBlock,OuputLayer);
        AugmentBlock = connectLayers(AugmentBlock,TargetName,Name_Output);
    case 'mX+b+X'
        OuputLayer = additionLayer(NumAugmentValues,'Name',Name_Output);
        AugmentBlock = addLayers(AugmentBlock,OuputLayer);
        AugmentBlock = connectLayers(AugmentBlock,Name_Addition,Name_Output + "/in1");
        AugmentBlock = connectLayers(AugmentBlock,Name_Multiplication,Name_Output + "/in2");
    otherwise
        OuputLayer = additionLayer(NumAugmentValues,'Name',Name_Output);
        AugmentBlock = addLayers(AugmentBlock,OuputLayer);
        AugmentBlock = connectLayers(AugmentBlock,Name_Addition,Name_Output + "/in1");
        AugmentBlock = connectLayers(AugmentBlock,Name_Multiplication,Name_Output + "/in2");
end
% % OuputLayer = additionLayer(NumAugmentValues,'Name',Name_Output);
% OuputLayer = functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name=Name_Output);
% AugmentBlock = addLayers(AugmentBlock,OuputLayer);
% % AugmentBlock = connectLayers(AugmentBlock,Name_Addition,Name_Output + "/in1");
% % AugmentBlock = connectLayers(AugmentBlock,Name_Multiplication,Name_Output + "/in2");
% AugmentBlock = connectLayers(AugmentBlock,TargetName,Name_Output);
end


end

