function [LossInformation,CM_Table,Gradients] = cgg_lossComponents(...
    Encoder,Decoder,Classifier,InDatastore,varargin)
%CGG_LOSSCOMPONENTS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
end
end

if isfunction
wantPredict = CheckVararginPairs('wantPredict', true, varargin{:});
else
if ~(exist('wantPredict','var'))
wantPredict=true;
end
end

if isfunction
wantLoss = CheckVararginPairs('wantLoss', true, varargin{:});
else
if ~(exist('wantLoss','var'))
wantLoss=true;
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
WantGradient = CheckVararginPairs('WantGradient', true, varargin{:});
else
if ~(exist('WantGradient','var'))
WantGradient=true;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', cell(0), varargin{:});
else
if ~(exist('Weights','var'))
Weights=cell(0);
end
end

if isfunction
WantUpdateLossPrior = CheckVararginPairs('WantUpdateLossPrior', false, varargin{:});
else
if ~(exist('WantUpdateLossPrior','var'))
WantUpdateLossPrior=false;
end
end

if isfunction
LossInformation = CheckVararginPairs('LossInformation', [], varargin{:});
else
if ~(exist('LossInformation','var'))
LossInformation=[];
end
end

if isfunction
WeightReconstruction = CheckVararginPairs('WeightReconstruction', NaN, varargin{:});
else
if ~(exist('WeightReconstruction','var'))
WeightReconstruction=NaN;
end
end

if isfunction
WeightKL = CheckVararginPairs('WeightKL', NaN, varargin{:});
else
if ~(exist('WeightKL','var'))
WeightKL=NaN;
end
end

if isfunction
WeightClassification = CheckVararginPairs('WeightClassification', NaN, varargin{:});
else
if ~(exist('WeightClassification','var'))
WeightClassification=NaN;
end
end

if isfunction
ClassNames = CheckVararginPairs('ClassNames', [], varargin{:});
else
if ~(exist('ClassNames','var'))
ClassNames=[];
end
end

if isfunction
LossType_Decoder = CheckVararginPairs('LossType_Decoder', 'MSE', varargin{:});
else
if ~(exist('LossType_Decoder','var'))
LossType_Decoder='MSE';
end
end

if isfunction
L2Factor = CheckVararginPairs('L2Factor', 1e-4, varargin{:});
else
if ~(exist('L2Factor','var'))
L2Factor=1e-4;
end
end

if isfunction
DataType = CheckVararginPairs('DataType', 'Training', varargin{:});
else
if ~(exist('DataType','var'))
DataType='Training';
end
end
%%
HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);

%%

if HasDecoder
OutputNames_Decoder = Decoder.OutputNames;
NumOutputs_Decoder = length(OutputNames_Decoder);
end
if HasClassifier
OutputNames_Classifier = Classifier.OutputNames;
NumOutputs_Classifier = length(OutputNames_Classifier);
NumDimensions = NumOutputs_Classifier;
LossType_Classifier = repmat({'CrossEntropy'},1,NumDimensions);
LossType_Classifier(contains(OutputNames_Classifier,'CTC')) = {'CTC'};
    if isempty(ClassNames)
        [ClassNames,~,~,~] = cgg_getClassesFromDataStore(InDataStore);
    end
end

Loss_Reconstruction = NaN;
Loss_KL = NaN;
Loss_Reconstruction_PerArea = NaN;
Loss_Classification_PerDimension = NaN;
CM_Table = NaN;

%%

MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat);
NumTrials=numpartitions(InDatastore);

%%

while hasdata(MaxMbq)

[X,T,DataNumber] = next(MaxMbq);

Normalization_Factor = length(DataNumber)/NumTrials;

T_Classified = T;
T_Reconstruction = X;

%% Encoder
Encoder=resetState(Encoder);
if wantPredict
    [Y_Encoded] = predict(Encoder,X);
else
    [Y_Encoded] = forward(Encoder,X);
end

%% Decoder
if HasDecoder
    Decoder=resetState(Decoder);
    Y_Decoded=cell(NumOutputs_Decoder,1);
if wantPredict
    [Y_Decoded{:},~] = predict(Decoder,Y_Encoded,Outputs=OutputNames_Decoder);
else
    [Y_Decoded{:},~] = forward(Decoder,Y_Encoded,Outputs=OutputNames_Decoder);
end
if any(contains(OutputNames_Decoder,'mean')) && any(contains(OutputNames_Decoder,'log-variance'))
Y_Mean = Y_Decoded{contains(OutputNames_Decoder,'mean')};
Y_logSigmaSq = Y_Decoded{contains(OutputNames_Decoder,'log-variance')};
else
    Y_Mean = [];
    Y_logSigmaSq = [];
end
Y_Reconstruction = Y_Decoded{contains(OutputNames_Decoder,'Decoder')};

[Loss_Reconstruction,Loss_KL,Loss_Reconstruction_PerArea] = ...
    cgg_getDecoderOutputs(Y_Reconstruction,Y_Mean,Y_logSigmaSq,...
    T_Reconstruction,Loss_Reconstruction,Loss_KL,...
    Loss_Reconstruction_PerArea,Normalization_Factor,...
    'LossType_Decoder',LossType_Decoder);

end

%% Classifier
if HasClassifier
    Classifier=resetState(Classifier);
    Y_Classified=cell(NumDimensions,1);

if wantPredict
    [Y_Classified{:},~] = predict(Classifier,Y_Encoded,Outputs=OutputNames_Classifier);
else
    [Y_Classified{:},~] = forward(Classifier,Y_Encoded,Outputs=OutputNames_Classifier);
end

[Loss_Classification_PerDimension,CM_Table] = cgg_getClassifierOutputsFromProbabilities(...
    T_Classified,Y_Classified,ClassNames,DataNumber,...
    Loss_Classification_PerDimension,CM_Table,Normalization_Factor,...
    'IsQuaddle',IsQuaddle,'wantLoss',wantLoss,'Weights',Weights,...
    'LossType',LossType_Classifier);

end

%%

end

%% Get Loss Information

% fprintf('Data Type: %s \n',DataType);

[LossInformation] = cgg_getLossInformation(Loss_Reconstruction,...
    Loss_KL,Loss_Reconstruction_PerArea,...
    Loss_Classification_PerDimension,LossInformation,...
    WantUpdateLossPrior,WeightReconstruction,WeightKL,WeightClassification);

%% Get Loss

Loss_Decoder = LossInformation.Loss_Decoder;
Loss_Classifier = LossInformation.Loss_Classifier;
Loss_Encoder = LossInformation.Loss_Encoder;

%%
Gradients_Encoder = [];
Gradients_Decoder = [];
Gradients_Classifier = [];

if WantGradient
    %Regularize gradients
    L2Regularizer = @(grad,param) grad + L2Factor.*param;
    Gradients_Encoder = dlgradient(Loss_Encoder,Encoder.Learnables);
    Gradients_Encoder = dlupdate(L2Regularizer,Gradients_Encoder,Encoder.Learnables);
    if HasDecoder
        Gradients_Decoder = dlgradient(Loss_Decoder,Decoder.Learnables);
        Gradients_Decoder = dlupdate(L2Regularizer,Gradients_Decoder,Decoder.Learnables);
    end
    if HasClassifier
        Gradients_Classifier = dlgradient(Loss_Classifier,Classifier.Learnables);
        Gradients_Classifier = dlupdate(L2Regularizer,Gradients_Classifier,Classifier.Learnables);
    end
end

Gradients = struct();
Gradients.Encoder = Gradients_Encoder;
Gradients.Decoder = Gradients_Decoder;
Gradients.Classifier = Gradients_Classifier;
end

