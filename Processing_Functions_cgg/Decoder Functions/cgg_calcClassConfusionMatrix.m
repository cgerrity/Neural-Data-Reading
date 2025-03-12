function [FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames,varargin)
%CGG_CALCCLASSCONFUSIONMATRIX Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

[~,NumDimension]=size(TrueValue);

HasWeights = ~isempty(Weights);

% MatchInstances=TrueValue==Prediction;

FullClassCM=table();

for didx=1:NumDimension
this_ClassNames=ClassNames{didx};
NumClasses=length(this_ClassNames);

if HasWeights
this_CM = zeros(NumClasses);
Single_TrueValue = TrueValue(:,didx);
Single_Prediction = Prediction(:,didx);
Single_Weight = Weights(:,didx);
[Indices,TrueLabels,PredictionLabels] = findgroups(Single_TrueValue, Single_Prediction);

CM_Vector = accumarray(Indices,Single_Weight);

% Get the CM in the correct order
[~, ~, CM_Rows] = unique(TrueLabels);
[~, CM_RowsIDX] = ismember(unique(TrueLabels), this_ClassNames);
CM_Rows = CM_RowsIDX(CM_Rows);
[~, ~, CM_Columns] = unique(PredictionLabels);
[~, CM_ColumnsIDX] = ismember(unique(PredictionLabels), this_ClassNames);
CM_Columns = CM_ColumnsIDX(CM_Columns);

CM_Indices = sub2ind(size(this_CM), CM_Rows, CM_Columns);
this_CM(CM_Indices) = CM_Vector;

% 
% for eidx = 1:NumEntries
% this_CMtmp = confusionmat(TrueValue(eidx,didx),Prediction(eidx,didx),'Order',this_ClassNames).*Weights(eidx,didx);
% this_CM = this_CM + this_CMtmp;
% end
else
this_CM=confusionmat(TrueValue(:,didx),Prediction(:,didx),'Order',this_ClassNames);
end

this_ClassIndices=1:NumClasses;

this_DimensionCM=[];

for cidx=1:NumClasses

    this_Class=this_ClassNames(cidx);

this_ClassRemoved=this_ClassIndices;
this_ClassRemoved(cidx)=[];

this_ClassTP=sum(this_CM(cidx,cidx),"all");
this_ClassTN=sum(this_CM(this_ClassRemoved,this_ClassRemoved),"all");
this_ClassFP=sum(this_CM(this_ClassRemoved,cidx),"all");
this_ClassFN=sum(this_CM(cidx,this_ClassRemoved),"all");

this_ClassCM=table(this_ClassTP,this_ClassFN,this_ClassFP,this_ClassTN,'VariableNames',{'TP','FN','FP','TN'},'RowNames',{num2str(this_Class)});

this_DimensionCM=[this_DimensionCM;this_ClassCM];

% this_ClassInstance=TrueValue(:,didx)==this_ClassNames(cidx);
% this_ClassPrediction=Prediction(:,didx)==this_ClassNames(cidx);
% 
% this_ClassTP=this_ClassInstance & this_ClassPrediction;
% this_ClassTN=~this_ClassInstance & ~this_ClassPrediction;
% this_ClassFP=~this_ClassInstance & this_ClassPrediction;
% this_ClassFN=this_ClassInstance & ~this_ClassPrediction;
end

this_Dimension=sprintf('Dimension_%d',didx);

FullClassCM.(this_Dimension)={this_DimensionCM};

end


end

