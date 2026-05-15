function [cfg,SetDescription] = PARAMETERS_cgg_selectGeneralParamterSets(cfg,ParameterSet)
%PARAMETERS_CGG_GETGENERALPARAMTERSETS Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    cfg struct
    ParameterSet (1,1) string
end
arguments (Output)
    cfg struct
    SetDescription (1,1) string
end

switch ParameterSet
    
    case 'Fast Training'
        SetDescription = "Reduce all additional training updates to minimum to reduce training time significantly.";
        
        cfg.WantProgressMonitor = false;
        cfg.WantExampleMonitor = false;
        cfg.WantComponentMonitor = false;
        cfg.WantAccuracyMonitor = false;
        cfg.WantWindowMonitor = false;
        cfg.WantReconstructionMonitor = false;
        cfg.WantGradientMonitor = false;
        
        cfg.AccuracyMeasures = cfg.AccuracyMeasures(1);
    case 'Base Model'
        SetDescription = "Base model without additional elements";

        % Weighting
        cfg.WeightReconstruction = NaN;
        cfg.WeightKL = NaN;
        cfg.WeightClassification = NaN;
        cfg.WeightOffsetAndScale = 0;
        cfg.WeightConfidence = 0;

        % Confidence
        cfg.ConfidenceType = '';

        % Multiple Instance Learning
        cfg.MultipleInstanceLearningType = 'None';

        % Data Augmentation
        cfg.STDChannelOffset = NaN;
        cfg.STDWhiteNoise = NaN;
        cfg.STDRandomWalk = NaN;
        cfg.STDTimeShift = NaN;
        cfg.WantSeparateTimeShift = false;

        % Dynamic Parameter
        cfg.DynamicParameterSet = 'None';

        % Data Stratification
        cfg.wantStratifiedPartition = false;

        % Model Input Layer
        cfg.StitchingAndFusionLayer = '';

    otherwise
end

end