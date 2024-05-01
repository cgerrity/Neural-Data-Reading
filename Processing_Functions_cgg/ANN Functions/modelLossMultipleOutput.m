function [loss,gradients,state,accuracy] = modelLossMultipleOutput(net,X,T,LossType,OutputNames,ClassNames,varargin)
%MODELLOSSMULTIPLEOUTPUT Summary of this function goes here
%   Detailed explanation goes here

NumDimensions=length(OutputNames);

NumTimeSteps = size(X,finddim(X,"T"));
NumBatches = size(X,finddim(X,"B"));

Y=cell(NumDimensions,1);

isfunction=exist('varargin','var');

if isfunction
wantPredict = CheckVararginPairs('wantPredict', false, varargin{:});
else
if ~(exist('wantPredict','var'))
wantPredict=false;
end
end

if wantPredict
[Y{:},state] = predict(net,X,Outputs=OutputNames);
else
[Y{:},state] = forward(net,X,Outputs=OutputNames);
end

loss_Total=0;

NumExamples=NumTimeSteps*NumBatches;

Prediction=NaN(NumExamples,NumDimensions);
TrueValue=NaN(NumExamples,NumDimensions);

for didx=1:NumDimensions

    this_Y=Y{didx};

    this_T=T(didx,:,:);

switch LossType
    case 'Regression'
    loss = mse(Y,T);
    case 'Classification'
    this_T=onehotencode(this_T,1,'ClassNames',ClassNames{didx});
    this_T=repmat(this_T,1,1,NumTimeSteps);
    this_T=dlarray(this_T,this_Y.dims);
    loss = crossentropy(this_Y,this_T);

    
    this_T_Decoded = onehotdecode(this_T,ClassNames{didx},1);
    this_Y_Decoded = onehotdecode(this_Y,ClassNames{didx},1);

    TrueValue(:,didx)=ClassNames{didx}(this_T_Decoded(:));
    Prediction(:,didx)=ClassNames{didx}(this_Y_Decoded(:));

end

loss_Total=loss_Total+loss;

end

[accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames);

gradients = dlgradient(loss_Total,net.Learnables);

end

