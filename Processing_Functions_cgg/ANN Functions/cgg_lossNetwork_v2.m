function [Loss,Gradients,State,Accuracy,LossReconstruction,...
    LossClassification,LossKL,Window_Accuracy,...
    Combined_Accuracy_Measure] = cgg_lossNetwork_v2(net,X,T,LossType,OutputInformation,ClassNames,varargin)
%CGG_LOSSNETWORK Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
wantPredict = CheckVararginPairs('wantPredict', false, varargin{:});
else
if ~(exist('wantPredict','var'))
wantPredict=false;
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
WantGradient = CheckVararginPairs('WantGradient', true, varargin{:});
else
if ~(exist('WantGradient','var'))
WantGradient=true;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'macroF1', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='macroF1';
end
end

if isfunction
Weights = CheckVararginPairs('Weights', cell(0), varargin{:});
else
if ~(exist('Weights','var'))
Weights=cell(0);
end
end

%%
if isnan(WeightReconstruction)
    WeightReconstruction=1;
end
if isnan(WeightKL)
    WeightKL=1;
end
WeightClassification=1;

IsWeightedLoss = iscell(Weights) && ~isempty(Weights);

%%

NumTimeSteps = size(X,finddim(X,"T"));
NumBatches = size(X,finddim(X,"B"));

NumMean=length(OutputInformation.Mean);
NumLogVar=length(OutputInformation.LogVar);
NumDimensions=length(OutputInformation.Classifier);
NumReconstruction=length(OutputInformation.Reconstruction);

AllOutputNames=[OutputInformation.Mean, OutputInformation.LogVar, ...
    OutputInformation.Classifier, OutputInformation.Reconstruction];

NumOutputs=length(AllOutputNames);
Y=cell(NumOutputs,1);

%%

if wantPredict
    [Y{:},State] = predict(net,X,Outputs=AllOutputNames);
else
    [Y{:},State] = forward(net,X,Outputs=AllOutputNames);
end

if NumMean>0
    mu=Y{1:NumMean};
else
    mu=[];
end
if NumLogVar>0
    logSigmaSq=Y{(1:NumLogVar)+NumMean};
else
    logSigmaSq=[];
end
if NumDimensions>0
    Y_Classification=Y((1:NumDimensions)+NumMean+NumLogVar);
else
    Y_Classification=[];
end
if NumReconstruction>0
    Y_Reconstruction=Y{(1:NumReconstruction)+NumMean+NumLogVar+NumDimensions};
else
    Y_Reconstruction=[];
end

T_Reconstruction=X;

%%
lossClassification=0;

if NumDimensions==0
    NumExamples=0;
else
    NumExamples=NumTimeSteps*NumBatches;
end

Prediction=NaN(NumExamples,NumDimensions);
TrueValue=NaN(NumExamples,NumDimensions);

Window_Prediction = NaN(NumDimensions,NumBatches,NumTimeSteps);
Window_TrueValue = NaN(NumDimensions,NumBatches,NumTimeSteps);

% if NumDimensions==1
% T_tmp=ones([1,size(T)]);
% T_tmp(1,:)=T;
% T=T_tmp;
% end

ClassConfidenceTMP=cell(1,NumDimensions);
Window_ClassConfidenceTMP=cell(1,NumDimensions);

%%

for didx=1:NumDimensions

    this_Y=Y_Classification{didx};
    this_T=T(didx,:,:);
    this_ClassNames=ClassNames{didx};
    this_NumClassNames=length(this_ClassNames);
    if IsWeightedLoss
        this_Weights = Weights{didx};
    else
        this_Weights = NaN;
    end

switch LossType
    case 'Regression'
    loss = mse(Y_Reconstruction,T_Reconstruction);
    case 'CTC'
        
        this_T_tmp=onehotencode(this_T,1,'ClassNames',this_ClassNames);
        this_T_CTC = onehotdecode(this_T_tmp,1:this_NumClassNames,1);
        this_T_CTC=double(this_T_CTC);

        this_T_CTC=dlarray(this_T_CTC,'TB');

        this_Y=dlarray(this_Y,'CBT');
        this_TMask=true(size(this_T_CTC));
        this_YMask=true(size(this_Y));

        loss = ctc(this_Y,this_T_CTC,this_YMask,this_TMask,'BlankIndex','last');

        [TargetSequence,TargetProbabilities_New] = cgg_getTargetSequenceFromCTC(this_Y,this_ClassNames);

        this_ClassConfidenceTMP=double(cgg_extractData(TargetProbabilities_New));
        this_ClassConfidenceTMP=this_ClassConfidenceTMP(:,:);
        ClassConfidenceTMP{didx}=this_ClassConfidenceTMP;

        this_T_Rep=repmat(this_T_tmp,1,1,NumTimeSteps);
        this_T_Rep=dlarray(this_T_Rep,this_Y.dims);

        this_T_Decoded = squeeze(onehotdecode(this_T_Rep,ClassNames{didx},1));

        this_TrueValue=ClassNames{didx}(this_T_Decoded(:));
        this_Prediction=TargetSequence(:);

        TrueValue(:,didx)=this_TrueValue;
        Prediction(:,didx)=this_Prediction;

    case 'Classification'
        
    this_T=onehotencode(this_T,1,'ClassNames',ClassNames{didx});
    this_T=repmat(this_T,1,1,NumTimeSteps);
    this_T=dlarray(this_T,this_Y.dims);
    if isnan(this_Weights)
    loss = crossentropy(this_Y,this_T);
    else
    loss = crossentropy(this_Y,this_T,this_Weights);
    end

    this_ClassConfidenceTMP=double(cgg_extractData(this_Y));
    this_ClassConfidenceTMP=this_ClassConfidenceTMP(:,:);
    ClassConfidenceTMP{didx}=this_ClassConfidenceTMP;

    this_Window_ClassConfidenceTMP=double(cgg_extractData(this_Y));
    Window_ClassConfidenceTMP{didx}=this_Window_ClassConfidenceTMP;
    
    this_T_Decoded = onehotdecode(this_T,ClassNames{didx},1);
    this_Y_Decoded = onehotdecode(this_Y,ClassNames{didx},1);

    this_TrueValue=ClassNames{didx}(this_T_Decoded(:));
    this_Prediction=ClassNames{didx}(this_Y_Decoded(:));

    this_Window_TrueValue=ClassNames{didx}(this_T_Decoded);
    this_Window_Prediction=ClassNames{didx}(this_Y_Decoded);

    TrueValue(:,didx)=this_TrueValue;
    Prediction(:,didx)=this_Prediction;

    Window_TrueValue(didx,:,:) = this_Window_TrueValue;
    Window_Prediction(didx,:,:) = this_Window_Prediction;

end

lossClassification=lossClassification+loss;

end

%%

if IsQuaddle
    wantZeroFeatureDetector=false;
    for eidx=1:NumExamples
        this_Prediction=Prediction(eidx,:);
        this_ClassConfidence=cellfun(@(x) x(:,eidx), ClassConfidenceTMP,"UniformOutput",false);

[this_Prediction] = cgg_procQuaddleInterpreter(this_Prediction,ClassNames,this_ClassConfidence,wantZeroFeatureDetector);
        Prediction(eidx,:)=this_Prediction;
    end
    for bidx=1:NumBatches
        for tidx=1:NumTimeSteps
            this_Window_Prediction = Window_Prediction(:,bidx,tidx)';
            this_Window_ClassConfidence = cellfun(@(x) x(:,bidx,tidx), Window_ClassConfidenceTMP,"UniformOutput",false);
        
            [this_Window_Prediction] = cgg_procQuaddleInterpreter(this_Window_Prediction,ClassNames,this_Window_ClassConfidence,wantZeroFeatureDetector);
            Window_Prediction(:,bidx,tidx) = this_Window_Prediction';
        end
    end
end

%%

[lossReconstruction,lossKL] = cgg_lossELBO_v2(Y_Reconstruction,T_Reconstruction,mu,logSigmaSq);

WeightedLossReconstruction=dlarray(0);
WeightedLossKL=dlarray(0);
WeightedLossClassification=dlarray(0);

if NumReconstruction>0
WeightedLossReconstruction=WeightReconstruction*lossReconstruction;
end
if NumMean>0 && NumLogVar>0
WeightedLossKL=WeightKL*lossKL;
end
if NumDimensions>0
WeightedLossClassification=WeightClassification*lossClassification;
end

Loss=WeightedLossReconstruction+WeightedLossKL+WeightedLossClassification;

LossReconstruction = {WeightedLossReconstruction,lossReconstruction};
LossKL = {WeightedLossKL,lossKL};
LossClassification = {WeightedLossClassification,lossClassification};


[Accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames);
[Accuracy_Measure] = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);

Window_Accuracy = NaN(1,NumTimeSteps);
Window_Accuracy_Measure = NaN(1,NumTimeSteps);
for tidx = 1:NumTimeSteps
    [Window_Accuracy(tidx)] = cgg_calcCombinedAccuracy(Window_TrueValue(:,:,tidx)', Window_Prediction(:,:,tidx)',ClassNames);
    [Window_Accuracy_Measure(tidx)] = cgg_calcAllAccuracyTypes(Window_TrueValue(:,:,tidx)', Window_Prediction(:,:,tidx)',ClassNames,MatchType);
end

%%

Combined_Accuracy_Measure = {Accuracy_Measure,Window_Accuracy_Measure};
%%
if WantGradient
    Gradients = dlgradient(Loss,net.Learnables);
else
    Gradients = [];
end
end

