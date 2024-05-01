function Layers_Classifier = cgg_selectClassifier(ClassifierName,NumClasses,LossType,varargin)
%CGG_SELECTCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

switch ClassifierName
    case 'Feedforward'
        Layers_Classifier = cgg_generateLayersForTuningNet(NumClasses,'LossType',LossType);
    case 'LSTM'
        Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,'LossType',LossType);
    case 'Deep LSTM'
        Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,'LossType',LossType,varargin{:});
    otherwise
end

end

