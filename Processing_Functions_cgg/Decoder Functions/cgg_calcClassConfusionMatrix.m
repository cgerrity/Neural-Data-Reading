function [FullClassCM] = cgg_calcClassConfusionMatrix(TrueValue,Prediction,ClassNames)
%CGG_CALCCLASSCONFUSIONMATRIX Summary of this function goes here
%   Detailed explanation goes here


[~,NumDimension]=size(TrueValue);

% MatchInstances=TrueValue==Prediction;

FullClassCM=table();

for didx=1:NumDimension
this_ClassNames=ClassNames{didx};
NumClasses=length(this_ClassNames);
this_CM=confusionmat(TrueValue(:,didx),Prediction(:,didx),'Order',this_ClassNames);

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

