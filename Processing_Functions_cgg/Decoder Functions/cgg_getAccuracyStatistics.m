function [Accuracy,Accuracy_STE,Accuracy_NoZero,Accuracy_NoZero_STE,...
    ConfusionMatrix_Mean,ConfusionMatrix_STE,ConfusionMatrix_Order] = ...
    cgg_getAccuracyStatistics(ConfusionMatrix,Order)
%CGG_GETACCURACYSTATISTICS Summary of this function goes here
%   Detailed explanation goes here

%%
if iscell(ConfusionMatrix)
NumFolds = length(ConfusionMatrix);
MatrixType='cell';
[Dim1,Dim2]=size(ConfusionMatrix);
if Dim1>Dim2
ConfusionMatrix=ConfusionMatrix';
end
elseif isnumeric(ConfusionMatrix)
NumFolds = 1;
MatrixType='array';
else
NumFolds = NaN;
MatrixType='NaN';
end

%%
if iscell(Order)
ConfusionMatrix_Order=mode(cell2mat(Order),2);
elseif isnumeric(Order)
ConfusionMatrix_Order=mode(Order,2);
else
ConfusionMatrix_Order=NaN;
end

%%

NumGroups=length(ConfusionMatrix_Order);

Zero_IDX=find(ConfusionMatrix_Order==0);
Accuracy_All=NaN(1,NumFolds);
Accuracy_NoZero_All=NaN(1,NumFolds);

%%
for fidx=1:NumFolds
    switch MatrixType
        case 'cell'
            this_ConfusionMatrix=ConfusionMatrix{fidx};
        case 'array'
            this_ConfusionMatrix=ConfusionMatrix;
        case 'NaN'
            this_ConfusionMatrix=NaN;
        otherwise
    end
    
    this_ConfusionMatrix_NoZero=this_ConfusionMatrix;
    this_ConfusionMatrix_NoZero(Zero_IDX,:)=[];
    this_ConfusionMatrix_NoZero(:,Zero_IDX)=[];
    
[~,~,Accuracy_All(fidx)] = ...
    cgg_getStatisticsFromSingleConfusionMatrix(this_ConfusionMatrix);

[~,~,Accuracy_NoZero_All(fidx)] = ...
    cgg_getStatisticsFromSingleConfusionMatrix(...
    this_ConfusionMatrix_NoZero);
end

Accuracy=mean(Accuracy_All);
Accuracy_NoZero=mean(Accuracy_NoZero_All);

Accuracy_STE=std(Accuracy_All)/sqrt(NumFolds);
Accuracy_NoZero_STE=std(Accuracy_NoZero_All)/sqrt(NumFolds);

%%

if iscell(ConfusionMatrix)
ConfusionMatrix_tmp=cell2mat(ConfusionMatrix);
ConfusionMatrix_tmp=reshape(ConfusionMatrix_tmp,NumGroups,NumGroups,NumFolds);
ConfusionMatrix_Mean=mean(ConfusionMatrix_tmp,3);
ConfusionMatrix_STE=std(ConfusionMatrix_tmp,[],3)/sqrt(NumFolds);
elseif isnumeric(ConfusionMatrix)
ConfusionMatrix_Mean=ConfusionMatrix;
ConfusionMatrix_STE=ones(size(ConfusionMatrix));
else
ConfusionMatrix_Mean=NaN;
ConfusionMatrix_STE=NaN;
end

end

