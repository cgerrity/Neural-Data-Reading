function cgg_displayTrainingLossComponentUpdate(data,monitor,varargin)
%CGG_DISPLAYTRAININGUPDATE Summary of this function goes here
%   Detailed explanation goes here

iteration = data{1};

Loss_ReconstructionTraining = data{2};
Loss_KLTraining = data{3};
Loss_ClassificationTraining = data{4};

Loss_ReconstructionValidation = data{5};
Loss_KLValidation = data{6};
Loss_ClassificationValidation = data{7};

Loss_ReconstructionTrainingByComponent = data{8};
Loss_ReconstructionValidationByComponent = data{9};

Loss_ClassificationTrainingByDimension = data{10};
Loss_ClassificationValidationByDimension = data{11};

Loss_ConfidenceTraining = data{12};
Loss_ConfidenceValidation = data{13};
Loss_ConfidenceTrainingByType = data{14};
Loss_ConfidenceValidationByType = data{15};

%% Loss Tolerance for 0 loss
Loss_Tolerance = 0.00001;
Loss_ClassificationTrainingByDimension(Loss_ClassificationTrainingByDimension < Loss_Tolerance) = NaN;
Loss_ClassificationValidationByDimension(Loss_ClassificationValidationByDimension < Loss_Tolerance) = NaN;

%%

IsVariational=~isnan(Loss_KLTraining);
HasClassifier=~isnan(Loss_ClassificationTraining);
HasReconstruction=~isnan(Loss_ReconstructionTraining);
HasConfidence=~isnan(Loss_ConfidenceTraining);
UpdateValidation=(~isnan(Loss_ReconstructionValidation))||(~isnan(Loss_KLValidation))||(~isnan(Loss_ClassificationValidation))||(~isnan(Loss_ConfidenceValidation));
NumReconstructionByComponent=numel(Loss_ReconstructionTrainingByComponent);
NumClassificationByDimension=numel(Loss_ClassificationTrainingByDimension);
NumConfidenceByTypes=numel(Loss_ConfidenceTrainingByType);

%%

if UpdateValidation
    if HasClassifier
        updatePlot(monitor,'ClassificationLossTraining',[iteration,Loss_ClassificationTraining]);
        updatePlot(monitor,'ClassificationLossValidation',[iteration,Loss_ClassificationValidation]);
    end
    if IsVariational
        updatePlot(monitor,'KLLossTraining',[iteration,Loss_KLTraining]);
        updatePlot(monitor,'KLLossValidation',[iteration,Loss_KLValidation]);
    end
    if HasReconstruction
        updatePlot(monitor,'ReconstructionLossTraining',[iteration,Loss_ReconstructionTraining]);
        updatePlot(monitor,'ReconstructionLossValidation',[iteration,Loss_ReconstructionValidation]);
    end
    if HasConfidence
        updatePlot(monitor,'ConfidenceLossTraining',[iteration,Loss_ConfidenceTraining]);
        updatePlot(monitor,'ConfidenceLossValidation',[iteration,Loss_ConfidenceValidation]);
    end
    if NumReconstructionByComponent > 1 && HasReconstruction
        for cidx = 1:NumReconstructionByComponent
        this_PlotNameTraining = sprintf('Area_%d_ReconstructionLossTraining',cidx);
        this_PlotNameValidation = sprintf('Area_%d_ReconstructionLossValidation',cidx);

        updatePlot(monitor,this_PlotNameTraining,[iteration,Loss_ReconstructionTrainingByComponent(cidx)]);
        updatePlot(monitor,this_PlotNameValidation,[iteration,Loss_ReconstructionValidationByComponent(cidx)]);
        end
    end
    if NumClassificationByDimension > 1 && HasClassifier
        for cidx = 1:NumClassificationByDimension
        this_PlotNameTraining = sprintf('Dimension_%d_ClassificationLossTraining',cidx);
        this_PlotNameValidation = sprintf('Dimension_%d_ClassificationLossValidation',cidx);

        updatePlot(monitor,this_PlotNameTraining,[iteration,Loss_ClassificationTrainingByDimension(cidx)]);
        updatePlot(monitor,this_PlotNameValidation,[iteration,Loss_ClassificationValidationByDimension(cidx)]);
        end
    end
    if NumConfidenceByTypes > 1 && HasConfidence
        for tidx = 1:NumConfidenceByTypes
        this_PlotNameTraining = sprintf('%s_ConfidenceLossTraining',monitor.ConfidenceTypes(tidx));
        this_PlotNameValidation = sprintf('%s_ConfidenceLossValidation',monitor.ConfidenceTypes(tidx));

        updatePlot(monitor,this_PlotNameTraining,[iteration,Loss_ConfidenceTrainingByType(tidx)]);
        updatePlot(monitor,this_PlotNameValidation,[iteration,Loss_ConfidenceValidationByType(tidx)]);
        end
    end
else
    if HasClassifier
        updatePlot(monitor,'ClassificationLossTraining',[iteration,Loss_ClassificationTraining]);
    end
    if IsVariational
        updatePlot(monitor,'KLLossTraining',[iteration,Loss_KLTraining]);
    end
    if HasReconstruction
        updatePlot(monitor,'ReconstructionLossTraining',[iteration,Loss_ReconstructionTraining]);
    end
    if HasConfidence
        updatePlot(monitor,'ConfidenceLossTraining',[iteration,Loss_ConfidenceTraining]);
    end
    if NumReconstructionByComponent > 1 && HasReconstruction
        for cidx = 1:NumReconstructionByComponent
        this_PlotNameTraining = sprintf('Area_%d_ReconstructionLossTraining',cidx);

        updatePlot(monitor,this_PlotNameTraining,[iteration,Loss_ReconstructionTrainingByComponent(cidx)]);
        end
    end
    if NumClassificationByDimension > 1 && HasClassifier
        for cidx = 1:NumClassificationByDimension
        this_PlotNameTraining = sprintf('Dimension_%d_ClassificationLossTraining',cidx);

        updatePlot(monitor,this_PlotNameTraining,[iteration,Loss_ClassificationTrainingByDimension(cidx)]);
        end
    end
    if NumConfidenceByTypes > 1 && HasConfidence
        for tidx = 1:NumConfidenceByTypes
        this_PlotNameTraining = sprintf('%s_ConfidenceLossTraining',monitor.ConfidenceTypes(tidx));

        updatePlot(monitor,this_PlotNameTraining,[iteration,Loss_ConfidenceTrainingByType(tidx)]);
        end
    end
end

drawnow;
end

