function [Loss,Gradients,State,Accuracy,LossReconstruction,LossClassification,LossKL] = cgg_lossNetwork(net,X,T,LossType,OutputInformation,ClassNames,varargin)
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

%%
WeightReconstruction=1;
WeightKL=1;
WeightClassification=1;

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

if NumDimensions==1
T_tmp=ones([1,size(T)]);
T_tmp(1,:)=T;
T=T_tmp;
end

ClassConfidenceTMP=cell(1,NumDimensions);

for didx=1:NumDimensions

    this_Y=Y_Classification{didx};
    this_T=T(didx,:,:);
    this_ClassNames=ClassNames{didx};
    this_NumClassNames=length(this_ClassNames);

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

        this_ClassConfidenceTMP=double(extractdata(TargetProbabilities_New));
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
    loss = crossentropy(this_Y,this_T);

    this_ClassConfidenceTMP=double(extractdata(this_Y));
    this_ClassConfidenceTMP=this_ClassConfidenceTMP(:,:);
    ClassConfidenceTMP{didx}=this_ClassConfidenceTMP;
    
    this_T_Decoded = onehotdecode(this_T,ClassNames{didx},1);
    this_Y_Decoded = onehotdecode(this_Y,ClassNames{didx},1);

    this_TrueValue=ClassNames{didx}(this_T_Decoded(:));
    this_Prediction=ClassNames{didx}(this_Y_Decoded(:));

    TrueValue(:,didx)=this_TrueValue;
    Prediction(:,didx)=this_Prediction;

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
end

%%

[lossReconstruction,lossKL] = cgg_lossELBO_v2(Y_Reconstruction,T_Reconstruction,mu,logSigmaSq);

LossReconstruction=dlarray(0);
LossKL=dlarray(0);
LossClassification=dlarray(0);

if NumReconstruction>0
LossReconstruction=WeightReconstruction*lossReconstruction;
end
if NumMean>0 && NumLogVar>0
LossKL=WeightKL*lossKL;
end
if NumDimensions>0
LossClassification=WeightClassification*lossClassification;
end

Loss=LossReconstruction+LossKL+LossClassification;

[Accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames);
%%
Gradients = dlgradient(Loss,net.Learnables);
end

