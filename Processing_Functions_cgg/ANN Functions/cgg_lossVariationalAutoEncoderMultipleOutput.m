function [loss,gradients,state,accuracy,Loss_Vector] = cgg_lossVariationalAutoEncoderMultipleOutput(net,X,T,LossType,OutputNames,ClassNames,varargin)
%MODELLOSSMULTIPLEOUTPUT Summary of this function goes here
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
WeightReconstruction=0.01;
WeightKL=1;
WeightFeature=1;

%%

NumDimensions=length(OutputNames);

NumTimeSteps = size(X,finddim(X,"T"));
NumBatches = size(X,finddim(X,"B"));

OutputNamesVariational=["SamplingLayer/mean" "SamplingLayer/log-variance"];
OutputNamesDecoder="reshape_Decoder";

AllOutputNames=[OutputNamesVariational OutputNamesDecoder OutputNames];

Y_Classification=cell(NumDimensions,1);
T_Reconstruction=X;
%%

if wantPredict
    [mu,logSigmaSq,Y_Reconstruction,Y_Classification{:},state] = predict(net,X,Outputs=AllOutputNames);
% [Y_Classification{:},state] = predict(net,X,Outputs=OutputNames);
else
    [mu,logSigmaSq,Y_Reconstruction,Y_Classification{:},state] = forward(net,X,Outputs=AllOutputNames);
% [Y_Classification{:},state] = forward(net,X,Outputs=OutputNames);
end

loss_Feature=0;

NumExamples=NumTimeSteps*NumBatches;

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

loss_Feature=loss_Feature+loss;

end

if IsQuaddle
    wantZeroFeatureDetector=false;
    for eidx=1:NumExamples
        this_Prediction=Prediction(eidx,:);
        this_ClassConfidence=cellfun(@(x) x(:,eidx), ClassConfidenceTMP,"UniformOutput",false);

[this_Prediction] = cgg_procQuaddleInterpreter(this_Prediction,ClassNames,this_ClassConfidence,wantZeroFeatureDetector);
        Prediction(eidx,:)=this_Prediction;
    end
end

[loss_Reconstruction,loss_KL] = cgg_lossELBO_v2(Y_Reconstruction,T_Reconstruction,mu,logSigmaSq);

% Maximum_Loss_Reconstruction=max(extractdata(WeightReconstruction*loss_Reconstruction),[],"all");
% Maximum_Loss_KL=max(extractdata(WeightKL*loss_KL),[],"all");
% Maximum_Loss_Feature=max(extractdata(WeightFeature*loss_Feature),[],"all");

% Loss_Reconstruction=extractdata(WeightReconstruction*loss_Reconstruction);
% Loss_KL=extractdata(WeightKL*loss_KL);
% Loss_Feature=extractdata(WeightFeature*loss_Feature);

Loss_Reconstruction=WeightReconstruction*loss_Reconstruction;
Loss_KL=WeightKL*loss_KL;
Loss_Feature=WeightFeature*loss_Feature;

% Mean_Loss_Reconstruction=mean(extractdata(WeightReconstruction*loss_Reconstruction),"all");
% Mean_Loss_KL=mean(extractdata(WeightKL*loss_KL),"all");
% Mean_Loss_Feature=mean(extractdata(WeightFeature*loss_Feature),"all");

% Message_Loss=sprintf('Reconstruction Loss: %f, KL Loss: %f, Feature Loss: %f',Loss_Reconstruction,Loss_KL,Loss_Feature);
% disp(Message_Loss);

Loss_Vector=[Loss_Reconstruction, Loss_KL, Loss_Feature];

loss=WeightReconstruction*loss_Reconstruction+WeightKL*loss_KL+WeightFeature*loss_Feature;

[accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames);

gradients = dlgradient(loss,net.Learnables);

end

