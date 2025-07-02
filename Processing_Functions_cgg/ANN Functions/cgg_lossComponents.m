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

if isfunction
WantPreFetch = CheckVararginPairs('WantPreFetch', true, varargin{:});
else
if ~(exist('WantPreFetch','var'))
WantPreFetch=true;
end
end
%%
HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);

IsEncoderLearnable = ~isempty(Encoder.Learnables);
IsDecoderLearnable = true;
IsClassifierLearnable = true;

%%

if HasDecoder
OutputNames_Decoder = Decoder.OutputNames;
NumOutputs_Decoder = length(OutputNames_Decoder);
IsDecoderLearnable = ~isempty(Decoder.Learnables);
end
if HasClassifier
OutputNames_Classifier = Classifier.OutputNames;
NumOutputs_Classifier = length(OutputNames_Classifier);
IsClassifierLearnable = ~isempty(Classifier.Learnables);
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

if ~(IsEncoderLearnable || IsDecoderLearnable)
WeightReconstruction=NaN;
WeightKL=NaN;
end
if ~IsEncoderLearnable
    Encoder = initialize(Encoder);
end
if ~IsDecoderLearnable
    Decoder = initialize(Decoder);
end
if ~IsClassifierLearnable
    Classifier = initialize(Classifier);
end

%%
if ~isMATLABReleaseOlderThan("R2024a")
    PreprocessingEnvironment = "serial";
    if WantPreFetch
        PreprocessingEnvironment = "parallel";
    end
MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat,...
        PreprocessingEnvironment=PreprocessingEnvironment,...
        OutputEnvironment="auto");
else
MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat,...
        DispatchInBackground=WantPreFetch,...
        OutputEnvironment="auto");
end
NumTrials=numpartitions(InDatastore);

%%
NumPasses = 0;
while hasdata(MaxMbq)
NumPasses = NumPasses + 1;
% fprintf('??? Current gradient aggregation pass through is %d\n',NumPasses);
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

if IsEncoderLearnable || IsDecoderLearnable
[Loss_Reconstruction,Loss_KL,Loss_Reconstruction_PerArea] = ...
    cgg_getDecoderOutputs(Y_Reconstruction,Y_Mean,Y_logSigmaSq,...
    T_Reconstruction,Loss_Reconstruction,Loss_KL,...
    Loss_Reconstruction_PerArea,Normalization_Factor,...
    'LossType_Decoder',LossType_Decoder);
end

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

% %% Get Loss
% 
% Loss_Decoder = LossInformation.Loss_Decoder;
% Loss_Classifier = LossInformation.Loss_Classifier;
% Loss_Encoder = LossInformation.Loss_Encoder;

%%
% Gradients_Encoder = [];
% Gradients_Decoder = [];
% Gradients_Classifier = [];

Gradients = struct();
Gradients.Encoder = [];
Gradients.Decoder = [];
Gradients.Classifier = [];

if WantGradient
    %Regularize gradients
    L2Regularizer = @(grad,param) grad + L2Factor.*param;
    if IsEncoderLearnable
    Gradients.Encoder = dlgradient(LossInformation.Loss_Encoder,Encoder.Learnables);
    Gradients.Encoder = dlupdate(L2Regularizer,Gradients.Encoder,Encoder.Learnables);
    end
    if HasDecoder && IsDecoderLearnable
        Gradients.Decoder = dlgradient(LossInformation.Loss_Decoder,Decoder.Learnables);
        Gradients.Decoder = dlupdate(L2Regularizer,Gradients.Decoder,Decoder.Learnables);
    end
    if HasClassifier && IsClassifierLearnable
        Gradients.Classifier = dlgradient(LossInformation.Loss_Classifier,Classifier.Learnables);
        Gradients.Classifier = dlupdate(L2Regularizer,Gradients.Classifier,Classifier.Learnables);
    end
end

end

