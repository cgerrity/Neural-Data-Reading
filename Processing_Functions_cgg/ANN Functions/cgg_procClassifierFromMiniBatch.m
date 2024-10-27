function [CM_Table,Loss] = cgg_procClassifierFromMiniBatch(,T,DataNumber,NumTrials,ClassNames,InCM_Table,InLoss)
%CGG_PROCPREDICTIONSFROMMINIBATCH Summary of this function goes here
%   Detailed explanation goes here

NumDimensions=length(ClassNames);
NumBatches = size(X,finddim(X,"B"));

NumTimeSteps = size(X,finddim(X,"T"));
Window_Prediction = NaN(NumDimensions,NumTrials,NumTimeSteps);
Window_TrueValue = NaN(NumDimensions,NumTrials,NumTimeSteps);
DataNumber = NaN(NumTrials,1);

%%

CurrentTrialCount = 1;

%%%%%%%
if isdlarray(DataNumber)
DataNumber = extractdata(DataNumber);
end

Y=cell(NumOutputs,1);

if wantPredict
    [Y{:},State] = predict(InputNet,X,Outputs=AllOutputNames);
else
    [Y{:},State] = forward(InputNet,X,Outputs=AllOutputNames);
end

%%

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

NumBatches = size(X,finddim(X,"B"));
NumTrials = NumBatches;

this_TrialRange = CurrentTrialCount:(CurrentTrialCount+NumTrials-1);

[this_Window_Prediction,this_Window_TrueValue,~] = ...
    cgg_getPredictionFromClassifierProbabilities(T,Y_Classification,ClassNames,'wantLoss',wantLoss,'IsQuaddle',IsQuaddle,'NumTimeSteps',NumTimeSteps,'NumTrials',NumTrials,'LossType',LossType);

Window_TrueValue(:,this_TrialRange,:) = this_Window_TrueValue;
Window_Prediction(:,this_TrialRange,:) = this_Window_Prediction;
DataNumber(this_TrialRange) = DataNumber;

CurrentTrialCount = CurrentTrialCount+NumTrials;

%%%%%%%%



end

