function Accuracy = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType,varargin)
%CGG_CALCALLACCURACYTYPES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end


switch MatchType
    case 'exact'
        if iscell(ClassNames)
            this_CM_tmp=TrueValue==Prediction;
            this_CM_tmp=all(this_CM_tmp,2);
            this_CM=[sum(this_CM_tmp==1),0;sum(this_CM_tmp==0),0];
        else
            this_CM = confusionmat(TrueValue,...
                CombinedPrediction,'Order',ClassNames);
        end
            this_Full_CM = this_CM;
    
            TruePositives = trace(this_Full_CM);
            TotalObservations = sum(this_Full_CM(:));
            Accuracy = TruePositives/TotalObservations;
    
    case 'macroaccuracy'
        [Accuracy] = cgg_calcMacroAccuracy(TrueValue,Prediction,ClassNames,'Weights',Weights);
    case 'combinedaccuracy'
        [Accuracy] = cgg_calcCombinedAccuracy(TrueValue,Prediction,ClassNames,'Weights',Weights);
    case 'macroF1'
        [Accuracy] = cgg_calcMacroF1(TrueValue,Prediction,ClassNames,'Weights',Weights);
    case 'macroRecall'
        [Accuracy] = cgg_calcMacroRecall(TrueValue,Prediction,ClassNames,'Weights',Weights);
    case 'BalancedAccuracy'
        [Accuracy] = cgg_calcMacroRecall(TrueValue,Prediction,ClassNames,'Weights',Weights);
    otherwise
end

end

