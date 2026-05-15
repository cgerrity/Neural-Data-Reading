function [Monitor_Values,IsOptimal] = cgg_calcAllMonitorValues(Monitor_Values,Encoder,Decoder,Classifier,epoch,iteration,learningrate,LossInformation_Training,LossInformation_Validation,CM_Table_Training,CM_Table_Validation,Gradients,Gradients_PreThreshold,varargin)
%CGG_CALCALLMONITORVALUES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
AccuracyType = CheckVararginPairs('AccuracyType', 'Aggregate', varargin{:});
else
if ~(exist('AccuracyType','var'))
AccuracyType='Aggregate';
end
end

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



%%

IsOptimal = false;

HasValidationLoss = isstruct(LossInformation_Validation);
HasValidationCM_Table = istable(CM_Table_Validation);

if ~isempty(Classifier)
    if HasValidationCM_Table
    [~,~,WindowAccuracyValidation] = cgg_procConfusionMatrixWindowsFromTable(CM_Table_Validation,Monitor_Values.ClassNames,'MatchType',Monitor_Values.OptimalAccuracyMeasure,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',Monitor_Values.RandomChance_Optimal_Validation,'MostCommon',Monitor_Values.MostCommon_Optimal_Validation,'Stratified',Monitor_Values.Stratified_Optimal_Validation);
    [~,~,Metric_Aggregated] = cgg_procConfusionMatrixFromTable(CM_Table_Validation,Monitor_Values.ClassNames,'MatchType',Monitor_Values.OptimalAccuracyMeasure,'IsQuaddle',Monitor_Values.IsQuaddle,'RandomChance',Monitor_Values.RandomChance_Optimal_Validation,'MostCommon',Monitor_Values.MostCommon_Optimal_Validation,'Stratified',Monitor_Values.Stratified_Optimal_Validation,'PredictionColumn','Aggregation_Prediction');
    
    if max(WindowAccuracyValidation) > Monitor_Values.MaximumValidationAccuracy
        if strcmp(AccuracyType,'Peak')
        IsOptimal = true;
        end
        Monitor_Values.MaximumValidationAccuracy = max(WindowAccuracyValidation);
    end
    if Metric_Aggregated > Monitor_Values.AggregateValidationAccuracy
        if strcmp(AccuracyType,'Aggregate')
        IsOptimal = true;
        end
        Monitor_Values.AggregateValidationAccuracy = Metric_Aggregated;
    end
    end

else
    if HasValidationLoss
        this_loss = ...
            cgg_extractData(LossInformation_Validation.Loss_Encoder);
    if this_loss < Monitor_Values.MinimumValidationLoss
        IsOptimal = true;
        Monitor_Values.MinimumValidationLoss = this_loss;
    end
    end
end

Monitor_Values.IsOptimal = IsOptimal;

%%

if ~isfield(Monitor_Values,'EpochIterationTable')
EpochIterationTable = cgg_generateBlankTable({'Epoch','Iteration'},{'single','single'});
EpochIterationTable(1,:) = {1,1};
Monitor_Values.EpochIterationTable = EpochIterationTable;
end
if ~(Monitor_Values.EpochIterationTable{end,"Epoch"} == epoch)
    Monitor_Values.EpochIterationTable(end+1,:) = {epoch,iteration};
end

end

