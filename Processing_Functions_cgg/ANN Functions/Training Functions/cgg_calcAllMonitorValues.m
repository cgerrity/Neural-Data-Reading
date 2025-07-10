function [Monitor_Values,IsOptimal] = cgg_calcAllMonitorValues(Monitor_Values,Encoder,Decoder,Classifier,epoch,iteration,learningrate,LossInformation_Training,LossInformation_Validation,CM_Table_Training,CM_Table_Validation,Gradients,Gradients_PreThreshold)
%CGG_CALCALLMONITORVALUES Summary of this function goes here
%   Detailed explanation goes here

Monitor_Values.Encoder = Encoder;
Monitor_Values.Decoder = Decoder;
Monitor_Values.Classifier = Classifier;
Monitor_Values.epoch = epoch;
Monitor_Values.iteration = iteration;
Monitor_Values.Iteration = iteration;
Monitor_Values.learningrate = learningrate;
Monitor_Values.LossInformation_Training = LossInformation_Training;
Monitor_Values.LossInformation_Validation = LossInformation_Validation;
Monitor_Values.CM_Table_Training = CM_Table_Training;
Monitor_Values.CM_Table_Validation = CM_Table_Validation;
Monitor_Values.Gradients = Gradients;
Monitor_Values.Gradients_PreThreshold = Gradients_PreThreshold;


% Monitor_Values.Loss_ReconstructionTraining = LossInformation_Training.Loss_Reconstruction;
% Monitor_Values.Loss_KLTraining = LossInformation_Training.Loss_KL;
% Monitor_Values.Loss_ClassificationTraining = LossInformation_Training.Loss_Classification;
% 
% Monitor_Values.Loss_ReconstructionValidation = LossInformation_Validation.Loss_Reconstruction;
% Monitor_Values.Loss_KLValidation = LossInformation_Validation.Loss_KL;
% Monitor_Values.Loss_ClassificationValidation = LossInformation_Validation.Loss_Classification;
% 
% Monitor_Values.Loss_ReconstructionTrainingByComponent = LossInformation_Training.Loss_Reconstruction_PerArea;
% Monitor_Values.Loss_ReconstructionValidationByComponent = LossInformation_Validation.Loss_Reconstruction_PerArea;
% 
% Monitor_Values.Loss_ClassificationTrainingByDimension = LossInformation_Training.Loss_Classification_PerDimension;
% Monitor_Values.Loss_ClassificationValidationByDimension = LossInformation_Validation.Loss_Classification_PerDimension;
% 
% Monitor_Values.epoch = epoch;
% Monitor_Values.iteration = iteration;
% Monitor_Values.learningrate = learningrate;
% 
% Monitor_Values.lossTraining = extractdata(LossInformation_Training.Loss_Encoder);
% Monitor_Values.lossValidation = extractdata(LossInformation_Validation.Loss_Encoder);
% 
% AccuracyMeasures = cfg_Monitor.AccuracyMeasures;
% for midx = 1:length(AccuracyMeasures)
%     MatchType = AccuracyMeasures{midx};
%     this_FieldName_MostCommon_Training = sprintf('MostCommon_%s_Training',MatchType);
%     this_FieldName_RandomChance_Training = sprintf('RandomChance_%s_Training',MatchType);
%     RandomChance_Baseline_Training = Monitor_Values.(this_FieldName_RandomChance_Training);
%     MostCommon_Baseline_Training = Monitor_Values.(this_FieldName_MostCommon_Training);
%     this_FieldName_MostCommon_Validation = sprintf('MostCommon_%s_Validation',MatchType);
%     this_FieldName_RandomChance_Validation = sprintf('RandomChance_%s_Validation',MatchType);
%     RandomChance_Baseline_Validation = Monitor_Values.(this_FieldName_RandomChance_Validation);
%     MostCommon_Baseline_Validation = Monitor_Values.(this_FieldName_MostCommon_Validation);
% 
%     [~,~,accuracyTraining] = cgg_procConfusionMatrixFromTable(CM_Table_Training,ClassNames,'MatchType',MatchType,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',RandomChance_Baseline_Training,'MostCommon',MostCommon_Baseline_Training);
%     [~,~,accuracyValidation] = cgg_procConfusionMatrixFromTable(CM_Table_Validation,ClassNames,'MatchType',MatchType,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',RandomChance_Baseline_Validation,'MostCommon',MostCommon_Baseline_Validation);
% 
%     [~,~,WindowAccuracyTraining] = cgg_procConfusionMatrixWindowsFromTable(CM_Table_Training,ClassNames,'MatchType',MatchType,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',RandomChance_Baseline_Training,'MostCommon',MostCommon_Baseline_Training);
%     [~,~,WindowAccuracyValidation] = cgg_procConfusionMatrixWindowsFromTable(CM_Table_Validation,ClassNames,'MatchType',MatchType,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',RandomChance_Baseline_Validation,'MostCommon',MostCommon_Baseline_Validation);
% 
%     this_FieldName_AccuracyTrain = sprintf('accuracyTrain_%s',MatchType);
%     this_FieldName_AccuracyTraining = sprintf('accuracyTraining_%s',MatchType);
%     this_FieldName_AccuracyValidation = sprintf('accuracyValidation_%s',MatchType);
% 
%     Monitor_Values.(this_FieldName_AccuracyTrain) = accuracyTraining;
%     Monitor_Values.(this_FieldName_AccuracyTraining) = accuracyTraining;
%     Monitor_Values.(this_FieldName_AccuracyValidation) = accuracyValidation;
% 
%     this_FieldName_WindowAccuracyTraining = sprintf('WindowAccuracyTraining_%s',MatchType);
%     this_FieldName_WindowAccuracyValidation = sprintf('WindowAccuracyValidation_%s',MatchType);
% 
%     Monitor_Values.(this_FieldName_WindowAccuracyTraining) = WindowAccuracyTraining;
%     Monitor_Values.(this_FieldName_WindowAccuracyValidation) = WindowAccuracyValidation;
% end
% 
% Monitor_Values.Loss_Reconstruction = Monitor_Values.Loss_ReconstructionTraining;
% Monitor_Values.Loss_KL = Monitor_Values.Loss_KLTraining;
% Monitor_Values.Loss_Classification = Monitor_Values.Loss_ClassificationTraining;
% 
% Monitor_Values.Iteration = iteration;
% 
% Encoding_Training = predict(Encoder,Monitor_Values.T_Reconstruction_Training);
% Encoding_Validation = predict(Encoder,Monitor_Values.T_Reconstruction_Validation);
% 
% if ~isempty(Classifier)
%     Y_Classification_Training = predict(Classifier,Encoding_Training);
%     Y_Classification_Validation = predict(Classifier,Encoding_Validation);
% else
%     Y_Classification_Training = [];
%     Y_Classification_Validation = [];
% end
% if ~isempty(Decoder)
%     Y_Reconstruction_Training = predict(Decoder,Encoding_Training);
%     Y_Reconstruction_Validation = predict(Decoder,Encoding_Validation);
% else
%     Y_Reconstruction_Training = [];
%     Y_Reconstruction_Validation = [];
% end
% 
% Monitor_Values.Y_Classification_Training = Y_Classification_Training;
% Monitor_Values.Y_Reconstruction_Training = Y_Reconstruction_Training;
% Monitor_Values.Y_Classification_Validation = Y_Classification_Validation;
% Monitor_Values.Y_Reconstruction_Validation = Y_Reconstruction_Validation;

IsOptimal = false;

HasValidationLoss = isstruct(LossInformation_Validation);
HasValidationCM_Table = istable(CM_Table_Validation);

if ~isempty(Classifier)
    if HasValidationCM_Table
    [~,~,WindowAccuracyValidation] = cgg_procConfusionMatrixWindowsFromTable(CM_Table_Validation,Monitor_Values.ClassNames,'MatchType',Monitor_Values.OptimalAccuracyMeasure,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',Monitor_Values.RandomChance_Optimal_Validation,'MostCommon',Monitor_Values.MostCommon_Optimal_Validation,'Stratified',Monitor_Values.Stratified_Optimal_Validation);
    if max(WindowAccuracyValidation) > Monitor_Values.MaximumValidationAccuracy
        IsOptimal = true;
        Monitor_Values.MaximumValidationAccuracy = max(WindowAccuracyValidation);
    end
    end
else
    if HasValidationLoss
    this_loss = extractdata(LossInformation_Validation.Loss_Encoder);
    if this_loss < Monitor_Values.MinimumValidationLoss
        IsOptimal = true;
        Monitor_Values.MinimumValidationLoss = this_loss;
    end
    end
end

Monitor_Values.IsOptimal = IsOptimal;

% %%
% 
% WeightIDX_Encoder = contains(Encoder.Learnables.Parameter,"Weights");
% GradientValuesNames_Encoder = Encoder.Learnables.Layer(WeightIDX_Encoder) + "-" + Encoder.Learnables.Parameter(WeightIDX_Encoder);
% 
% GradientValues_Encoder = Gradients.Encoder.Value(WeightIDX_Encoder);
% Gradients_PreThresholdValues_Encoder = Gradients_PreThreshold.Encoder.Value(WeightIDX_Encoder);
% for gidx = 1:length(GradientValues_Encoder)
%   Monitor_Values.MeanGradient_Encoder(iteration,gidx) = mean(Gradients_PreThresholdValues_Encoder{gidx},"all");
%   Monitor_Values.STDGradient_Encoder(iteration,gidx) = std(Gradients_PreThresholdValues_Encoder{gidx},[],"all");
%   Monitor_Values.MeanThresholdGradient_Encoder(iteration,gidx) = mean(GradientValues_Encoder{gidx},"all");
%   Monitor_Values.STDThresholdGradient_Encoder(iteration,gidx) = std(GradientValues_Encoder{gidx},[],"all");
% end
% 
% Monitor_Values.GradientValuesNames_Encoder = GradientValuesNames_Encoder;
% 
% GradientValuesNames
% MeanGradient
% STDGradient
% MeanThresholdGradient
% STDThresholdGradient




end

