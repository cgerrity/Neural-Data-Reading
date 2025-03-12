function [MostCommon,RandomChance] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType,IsQuaddle,varargin)
%CGG_GETBASELINEACCURACYMEASURES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NumIterRand = CheckVararginPairs('NumIterRand', 2000, varargin{:});
else
if ~(exist('NumIterRand','var'))
NumIterRand=2000;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

NumDimensions=length(ClassNames);
[Dim1,~]=size(TrueValue);
if Dim1==NumDimensions
    TrueValue=TrueValue';
end

[NumTrials,~]=size(TrueValue);

RandomChance=NaN(1,NumIterRand);
parfor idx=1:NumIterRand
Prediction=NaN(size(TrueValue));
for tidx=1:NumTrials
Prediction(tidx,:) = cgg_getRandomPrediction(ClassNames,IsQuaddle);
end
RandomChance(idx) = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType,'Weights',Weights);
end
RandomChance=mean(RandomChance);

switch MatchType
    case 'exact'
[UniqueTarget,~,UniqueValues] = unique(TrueValue,'rows');
ModeTargetIDX = mode(UniqueValues);
ModeTarget = UniqueTarget(ModeTargetIDX,:); %# the first output argument
MostCommonPrediction=ModeTarget;

    % case 'combinedaccuracy'
    otherwise

        ClassConfidence = cell(1, length(ClassNames));
        PredictionTMP=NaN(1,length(ClassNames));

        for idx = 1:length(ClassNames)
            this_TrueValue=TrueValue(:,idx);
            this_ClassNames=ClassNames{idx};
            this_ClassConfidence=NaN(1,length(this_ClassNames));
            for tidx=1:length(this_ClassNames)
                this_Class=this_ClassNames(tidx);
                this_ClassConfidence(tidx)=sum(this_TrueValue==this_Class);
            end
            ClassConfidence{idx}=this_ClassConfidence/sum(this_ClassConfidence);
            [~,this_PredictionTMPIDX]=max(this_ClassConfidence);
            PredictionTMP(idx)=this_ClassNames(this_PredictionTMPIDX);
        end

        if IsQuaddle
        wantZeroFeatureDetector=false;
        [MostCommonPrediction] = cgg_procQuaddleInterpreter(PredictionTMP,ClassNames,ClassConfidence,wantZeroFeatureDetector);
        else
            MostCommonPrediction=PredictionTMP;
        end
end

Prediction=repmat(MostCommonPrediction,NumTrials,1);
MostCommon = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType,'Weights',Weights);

end

