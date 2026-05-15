function [LossInformation,CM_Table,Gradients,State] = cgg_lossComponents(...
    Encoder,Decoder,Classifier,InDatastore,varargin)
%CGG_LOSSCOMPONENTS Computes and aggregates network losses over data partitions
%   Retrieves forward pass predictions, aggregates multidimensional losses, 
%   updates dynamic tracking via LossInformation, and generates gradients.

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
WeightOffsetAndScale = CheckVararginPairs('WeightOffsetAndScale', NaN, varargin{:});
else
if ~(exist('WeightOffsetAndScale','var'))
WeightOffsetAndScale=NaN;
end
end

if isfunction
WeightConfidence = CheckVararginPairs('WeightConfidence', NaN, varargin{:});
else
if ~(exist('WeightConfidence','var'))
WeightConfidence=NaN;
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
MultipleInstanceLearningType = CheckVararginPairs('MultipleInstanceLearningType', 'None', varargin{:});
else
if ~(exist('MultipleInstanceLearningType','var'))
MultipleInstanceLearningType='None';
end
end

if isfunction
WeightParameters = CheckVararginPairs('WeightParameters', [], varargin{:});
else
if ~(exist('WeightParameters','var'))
WeightParameters=[];
end
end

if isfunction
SetSize = CheckVararginPairs('SetSize', numpartitions(InDatastore), varargin{:});
else
if ~(exist('SetSize','var'))
SetSize=numpartitions(InDatastore);
end
end

if isfunction
w = getCurrentWorker;
WantPreFetch = CheckVararginPairs('WantPreFetch', isempty(w), varargin{:});
else
if ~(exist('WantPreFetch','var'))
w = getCurrentWorker;
WantPreFetch=isempty(w);
end
end


%%
HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);

IsEncoderLearnable = ~isempty(Encoder.Learnables);
IsDecoderLearnable = true;
IsClassifierLearnable = true;

% %% Potential for getting MIL type from Classifier instead of as a
% parameter
% 
% for lidx = 1:length(Classifier.Layers)
% if isprop(Classifier.Layers(lidx),'SoftmaxFormat')
% MILTYPE = Classifier.Layers(lidx).SoftmaxFormat;
% break
% end
% end

%% Dynamic Weighting

if ~isempty(WeightParameters)
WeightReconstruction = WeightParameters.CurrentWeightReconstruction;
WeightKL = WeightParameters.CurrentWeightKL;
WeightClassification = WeightParameters.CurrentWeightClassification;
WeightOffsetAndScale = WeightParameters.CurrentWeightOffsetAndScale;
WeightConfidence = WeightParameters.CurrentWeightConfidence;
end

%% Extract Output Names and State
OutputNames_Encoder = Encoder.OutputNames;
NumOutputs_Encoder = length(OutputNames_Encoder);
State = struct();
State.Encoder = Encoder.State;

if HasDecoder
OutputNames_Decoder = Decoder.OutputNames;
NumOutputs_Decoder = length(OutputNames_Decoder);
IsDecoderLearnable = ~isempty(Decoder.Learnables);
State.Decoder = Decoder.State;
end
if HasClassifier

[OutputInformation_Classifier,~] ...
    = cgg_getNetworkOutputInformation(Classifier);
OutputNames_Classifier = OutputInformation_Classifier.Classifier;
OutputNames_TrialConfidence = OutputInformation_Classifier.TrialConfidence;
OutputNames_TaskConfidence = OutputInformation_Classifier.TaskConfidence;

NumOutputs_Classifier = length(OutputNames_Classifier);
NumOutputs_TrialConfidence = length(OutputNames_TrialConfidence);
NumOutputs_TaskConfidence = length(OutputNames_TaskConfidence);
IsClassifierLearnable = ~isempty(Classifier.Learnables);
State.Classifier = Classifier.State;
NumDimensions = NumOutputs_Classifier;
LossType_Classifier = repmat({'CrossEntropy'},1,NumDimensions);
LossType_Classifier(contains(OutputNames_Classifier,'CTC')) = {'CTC'};
    if isempty(ClassNames)
        [ClassNames,~,~,~] = cgg_getClassesFromDataStore(InDatastore);
    end
    OutputNames_Classifier = [OutputNames_Classifier,OutputNames_TrialConfidence,OutputNames_TaskConfidence];
    NumOutputs_FullClassifier = length(OutputNames_Classifier);
end

%% Initialize Accumulated Losses
Loss_Reconstruction = NaN;
Loss_KL = NaN;
Loss_Reconstruction_PerArea = NaN;
Loss_Classification_PerDimension = NaN;
Loss_OffsetAndScale = 0;

Loss_TotalConfidence = 0;
Loss_TrialConfidence = 0;
Loss_TaskConfidence = 0;
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

%% Datastore Setup
if ~isMATLABReleaseOlderThan("R2024a")
    PreprocessingEnvironment = "serial";
    if WantPreFetch
        PreprocessingEnvironment = "parallel";
        % PreprocessingEnvironment = "background";
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
BatchFraction = NumTrials/SetSize;
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
Encoder = cgg_updateState(Encoder,State.Encoder);
Y_Encoded=cell(NumOutputs_Encoder,1);
if wantPredict
    [Y_Encoded{:},~] = predict(Encoder,X,Outputs=OutputNames_Encoder);
else
    [Y_Encoded{:},State.Encoder] = forward(Encoder,X,Outputs=OutputNames_Encoder);
end

if any(contains(OutputNames_Encoder,'mean')) && any(contains(OutputNames_Encoder,'log-variance'))
    Y_Mean = Y_Encoded{contains(OutputNames_Encoder,'mean')};
    Y_logSigmaSq = Y_Encoded{contains(OutputNames_Encoder,'log-variance')};
    Y_Encoded = Y_Encoded{contains(OutputNames_Encoder,'out')};
else
    Y_Mean = [];
    Y_logSigmaSq = [];
    Y_Encoded = Y_Encoded{1};
end

%% Decoder
if HasDecoder
    Decoder=resetState(Decoder);
    Decoder = cgg_updateState(Decoder,State.Decoder);
    Y_Decoded=cell(NumOutputs_Decoder,1);
if wantPredict
    [Y_Decoded{:},~] = predict(Decoder,Y_Encoded,Outputs=OutputNames_Decoder);
else
    [Y_Decoded{:},State.Decoder] = forward(Decoder,Y_Encoded,Outputs=OutputNames_Decoder);
end
if any(contains(OutputNames_Decoder,'mean')) && any(contains(OutputNames_Decoder,'log-variance'))
Y_Mean = Y_Decoded{contains(OutputNames_Decoder,'mean')};
Y_logSigmaSq = Y_Decoded{contains(OutputNames_Decoder,'log-variance')};
% else
%     Y_Mean = [];
%     Y_logSigmaSq = [];
end
if (any(contains({Decoder.Layers(:).Name},"reshape_offset_Augment")) || ...
        any(contains({Decoder.Layers(:).Name},"reshape_scale_Augment"))) ...
        && ~isnan(WeightOffsetAndScale)
    this_Loss_OffsetAndScale = cgg_lossOffsetAndScale(X,Y_Encoded,Decoder,State,'wantPredict',wantPredict,'WantGradient',WantGradient);
    Loss_OffsetAndScale = Loss_OffsetAndScale + this_Loss_OffsetAndScale*Normalization_Factor;
else
    Loss_OffsetAndScale = NaN;
end
Y_Reconstruction = Y_Decoded{contains(OutputNames_Decoder,'Decoder')};

if IsEncoderLearnable || IsDecoderLearnable
[Loss_Reconstruction,Loss_KL,Loss_Reconstruction_PerArea] = ...
    cgg_getDecoderOutputs(Y_Reconstruction,Y_Mean,Y_logSigmaSq,...
    T_Reconstruction,Loss_Reconstruction,Loss_KL,...
    Loss_Reconstruction_PerArea,Normalization_Factor,...
    'LossType_Decoder',LossType_Decoder,'WantGradient',WantGradient);
end

end

%% Classifier
if HasClassifier
    Classifier=resetState(Classifier);
    Classifier = cgg_updateState(Classifier,State.Classifier);
    Y_Classified=cell(NumOutputs_FullClassifier,1);
if wantPredict
    [Y_Classified{:},~] = predict(Classifier,Y_Encoded,Outputs=OutputNames_Classifier);
else
    [Y_Classified{:},State.Classifier] = forward(Classifier,Y_Encoded,Outputs=OutputNames_Classifier);
end

if NumOutputs_TrialConfidence > 0
TrialConfidence = Y_Classified{NumOutputs_Classifier + 1:NumOutputs_Classifier + 1 + NumOutputs_TrialConfidence - 1};
else
TrialConfidence = [];
end

if NumOutputs_TaskConfidence > 0
IDXStart_Task = NumOutputs_Classifier + NumOutputs_TrialConfidence + 1;
IDXEnd_Task = IDXStart_Task + NumOutputs_TaskConfidence - 1;
TaskConfidence = Y_Classified(IDXStart_Task:IDXEnd_Task);
else
TaskConfidence = {};
end

Y_Classified = Y_Classified(1:NumOutputs_Classifier);

        [Loss_Classification_PerDimension,CM_Table,...
            Loss_TotalConfidence,Loss_TrialConfidence,Loss_TaskConfidence] = ...
            cgg_getClassifierOutputsFromProbabilities(...
            T_Classified,Y_Classified,ClassNames,DataNumber,...
            Loss_Classification_PerDimension,CM_Table,Normalization_Factor,...
            'IsQuaddle',IsQuaddle,'wantLoss',wantLoss,'Weights',Weights,...
            'LossType',LossType_Classifier,'WantGradient',WantGradient, ...
            'MultipleInstanceLearningType',MultipleInstanceLearningType, ...
            'InLoss_TotalConfidence',Loss_TotalConfidence, ...
            'InLoss_TrialConfidence',Loss_TrialConfidence, ...
            'InLoss_TaskConfidence',Loss_TaskConfidence, ...
            'TrialConfidence',TrialConfidence,'TaskConfidence',TaskConfidence, ...
            'LossInformation', LossInformation, ...
            'BatchFraction', BatchFraction);
end

%%

end

%% Get Loss Information

if istable(CM_Table)
    if any(strcmp(CM_Table.Properties.VariableNames,'TrialConfidence'))
    TrialConfidence = CM_Table.TrialConfidence;
    else
    TrialConfidence = [];
    end

    if any(strcmp(CM_Table.Properties.VariableNames,'TaskConfidence'))
    TaskConfidence = CM_Table.TaskConfidence;
    else
    TaskConfidence = [];
    end
else
    TrialConfidence = [];
    TaskConfidence = [];
end

% fprintf('Data Type: %s \n',DataType);

[LossInformation] = cgg_getLossInformation(Loss_Reconstruction,...
    Loss_KL,Loss_Reconstruction_PerArea,...
    Loss_Classification_PerDimension,Loss_OffsetAndScale, ...
    LossInformation,WantUpdateLossPrior,WeightReconstruction, ...
    WeightKL,WeightClassification,WeightOffsetAndScale,ClassNames, ...
    'Loss_TotalConfidence',Loss_TotalConfidence, ...
    'Loss_TrialConfidence',Loss_TrialConfidence, ...
    'Loss_TaskConfidence',Loss_TaskConfidence, ...
    'WeightConfidence',WeightConfidence,...
    'TrialConfidence',TrialConfidence,...
    'TaskConfidence',TaskConfidence, ...
    'BatchFraction', BatchFraction);
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
    fprintf('      ??? Encoder Gradient is: %d\n',mean(cellfun(@(x) mean(double(cgg_extractData(x)),"all"),{Gradients.Encoder.Value{:}})));
    Gradients.Encoder = dlupdate(L2Regularizer,Gradients.Encoder,Encoder.Learnables);
    end
    if HasDecoder && IsDecoderLearnable
        Gradients.Decoder = dlgradient(LossInformation.Loss_Encoder,Decoder.Learnables);
        fprintf('      ??? Decoder Gradient is: %d\n',mean(cellfun(@(x) mean(double(cgg_extractData(x)),"all"),{Gradients.Decoder.Value{:}})));
        Gradients.Decoder = dlupdate(L2Regularizer,Gradients.Decoder,Decoder.Learnables);
    end
    if HasClassifier && IsClassifierLearnable
        Gradients.Classifier = dlgradient(LossInformation.Loss_Encoder,Classifier.Learnables);
        Gradients.Classifier = dlupdate(L2Regularizer,Gradients.Classifier,Classifier.Learnables);
    end
end

% No gradient is calculated after this point so this will only add to the
% memory requirements if it is passed as a dlarray
LossInformation.Loss_Encoder = ...
    cgg_extractData(LossInformation.Loss_Encoder);
LossInformation.Loss_Decoder = ...
    cgg_extractData(LossInformation.Loss_Decoder);
LossInformation.Loss_Classifier = ...
    cgg_extractData(LossInformation.Loss_Classifier);

end

