function Layers_Classifier = cgg_selectClassifier(ClassifierName,NumClasses,LossType,varargin)
%CGG_SELECTCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

switch ClassifierName
    case 'Feedforward'
        NetworkType='Feedforward';
        Layers_Classifier = cgg_generateLayersForTuningNet(NumClasses,'LossType',LossType,'NetworkType',NetworkType);
    case 'Deep Feedforward'
        NetworkType='Feedforward';
        Layers_Classifier = cgg_generateLayersForClassifier(NumClasses,'LossType',LossType,'NetworkType',NetworkType,varargin{:});
    case 'Deep Feedforward - Dropout 0.5'
        DropoutPercent=0.5;
        NetworkType='Feedforward';
        Layers_Classifier = cgg_generateLayersForClassifier(NumClasses,'LossType',LossType,'DropoutPercent',DropoutPercent,'NetworkType',NetworkType,varargin{:});
    case 'Deep GRU - Dropout 0.5'
        DropoutPercent=0.5;
        NetworkType='GRU';
        Layers_Classifier = cgg_generateLayersForClassifier(NumClasses,'LossType',LossType,'DropoutPercent',DropoutPercent,'NetworkType',NetworkType,varargin{:});
    case 'LSTM'
        NetworkType='LSTM';
        Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,'LossType',LossType,'NetworkType',NetworkType);
    case 'Deep LSTM'
        NetworkType='LSTM';
        Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,'LossType',LossType,'NetworkType',NetworkType,varargin{:});
    case 'Deep LSTM - Dropout 0.5'
        DropoutPercent=0.5;
        NetworkType='LSTM';
        Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,'LossType',LossType,'DropoutPercent',DropoutPercent,'NetworkType',NetworkType,varargin{:});
    case 'Deep LSTM - Dropout 0.25'
        DropoutPercent=0.25;
        NetworkType='LSTM';
        Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,'LossType',LossType,'DropoutPercent',DropoutPercent,'NetworkType',NetworkType,varargin{:});
    otherwise
end

end

