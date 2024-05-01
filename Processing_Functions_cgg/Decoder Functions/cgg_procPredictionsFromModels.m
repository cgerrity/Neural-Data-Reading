function [Y,ClassConfidence,ExtraInfo] = cgg_procPredictionsFromModels(Mdl,X)
%CGG_PROCPREDICTIONSFROMMODELS Summary of this function goes here
%   Detailed explanation goes here

isMdlCell=iscell(Mdl);

if isMdlCell
    ModelType=class(Mdl{1});
    NumModels=numel(Mdl);
else
    ModelType=class(Mdl);
end

switch ModelType
    case 'incrementalClassificationECOC'
        if isMdlCell
            Y=cell(1,NumModels);
            NegLoss=cell(1,NumModels);
            PBScore=cell(1,NumModels);
            for midx=1:NumModels
        [Y{midx},NegLoss{midx},PBScore{midx}] = predict(Mdl{midx},X);
            end
        else
        [Y,NegLoss,PBScore] = predict(Mdl,X);
        end
            ClassConfidence=PBScore;
            ExtraInfo=NegLoss;
    case 'incrementalClassificationNaiveBayes'
        if isMdlCell
            Y=cell(1,NumModels);
            Posterior=cell(1,NumModels);
            Cost=cell(1,NumModels);
            for midx=1:NumModels
        [Y{midx},Posterior{midx},Cost{midx}] = predict(Mdl,X);
        Cost{midx}=-Cost{midx}; % Higher Value is higher confidence
            end
        else
        [Y,Posterior,Cost] = predict(Mdl,X);
        Cost=-Cost; % Higher Value is higher confidence
        end
        ClassConfidence=Cost; % Higher Value is higher confidence
        ExtraInfo=Posterior;
    otherwise
end

end

