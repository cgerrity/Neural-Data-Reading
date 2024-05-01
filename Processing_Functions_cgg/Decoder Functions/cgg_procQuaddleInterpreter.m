function [Prediction] = cgg_procQuaddleInterpreter(Prediction,ClassNames,ClassConfidence,wantZeroFeatureDetector)
%CGG_PROCQUADDLEINTERPRETER Summary of this function goes here
%   Detailed explanation goes here

% Real Quaddle parameters go here

QuaddleDimMax=3; % Maximum dimensionality of the quaddles
QuaddleDimMin=1; % Minimum dimensionality of the quaddles

%%

Prediction=diag(diag(Prediction));

% [~,PredictionClassIDX]=cellfun(@(x) max(x),ClassConfidence,'UniformOutput',false);
%     Prediction=cellfun(@(x1,x2) x1(x2),ClassNames,PredictionClassIDX);

%%

QuaddleCheck=~(Prediction==[0;0;0;0]);
NumDim=sum(QuaddleCheck);

DecreaseFeatures=NumDim>QuaddleDimMax;
IncreaseFeatures=NumDim<QuaddleDimMin;

if IncreaseFeatures||DecreaseFeatures

% NumFeatureValues=cellfun(@(x) numel(x)-1,ClassNames);
NeutralIDX=cellfun(@(x) find(x==0),ClassNames,'UniformOutput',false);

ClassConfidence_NoNeutral=ClassConfidence;

for didx=1:length(ClassConfidence_NoNeutral)
ClassConfidence_NoNeutral{didx}(NeutralIDX{didx})=-Inf;
end

NeutralConfidence=cellfun(@(x1,x2) x1(x2),ClassConfidence,NeutralIDX);
[FeatureConfidence,FeatureIDX]=cellfun(@(x) max(x),ClassConfidence_NoNeutral);

% NumFeatureValues==0

if wantZeroFeatureDetector
    CostConfidence=NeutralConfidence;
else
CostConfidence=NeutralConfidence-FeatureConfidence;
end

if IncreaseFeatures
NumChanges=QuaddleDimMin-NumDim;
[~,SortedCostConfidenceIDX]=sort(CostConfidence,'ascend');
for cidx=1:NumChanges
this_DimIDX=SortedCostConfidenceIDX(cidx);
this_ClassNames=ClassNames{this_DimIDX};
this_FeatureIDX=FeatureIDX(this_DimIDX);
Prediction(this_DimIDX)=this_ClassNames(this_FeatureIDX);
end

elseif DecreaseFeatures
NumChanges=NumDim-QuaddleDimMax;
[~,SortedCostConfidenceIDX]=sort(CostConfidence,'descend');
for cidx=1:NumChanges
this_DimIDX=SortedCostConfidenceIDX(cidx);
Prediction(this_DimIDX)=0;
end

end


end

Prediction=Prediction';
end

