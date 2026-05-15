function [Loss, Loss_Confidence, Loss_TrialConfidence, Loss_TaskConfidence] = cgg_calcClassificationLoss(T, Y, options)
%CGG_CALCCLASSIFICATIONLOSS Calculates classification loss with optional confidence interpolation.
%   Passes predictions through the confidence interpolation framework, 
%   retrieves the dataset-level informative-ness losses, and then calculates 
%   the final classification error on the interpolated predictions.

arguments (Input)
    T
    Y
    options.Weights = NaN
    options.LossType = 'CrossEntropy'
    options.TrialConfidence = []
    options.TaskConfidence = []
    options.YMask = []
    options.TMask = []
    options.WantDatasetConfidence = true
    options.DatasetConfidence = []
    options.DatasetTrialConfidence = []
    options.DatasetTaskConfidence = []
    options.BatchFraction = 1
    options.ConfidenceLossType = 'CrossEntropy'
end

arguments (Output)
    Loss
    Loss_Confidence
    Loss_TrialConfidence
    Loss_TaskConfidence
end

%% 1. Apply Confidence Interpolation and Informative-ness Loss
% Pass the raw predictions (Y) and targets (T) through the confidence 
% function. This cleanly isolates Eq. 1 and Eq. 2 from the methodology.
[Y, Loss_Confidence, Loss_TrialConfidence, Loss_TaskConfidence] = ...
    cgg_lossConfidence(Y, T, options.TrialConfidence, options.TaskConfidence, ...
        'WantDatasetConfidence', options.WantDatasetConfidence, ...
        'DatasetTotalConfidence', options.DatasetConfidence, ...
        'DatasetTrialConfidence', options.DatasetTrialConfidence, ...
        'DatasetTaskConfidence', options.DatasetTaskConfidence, ...
        'BatchFraction', options.BatchFraction, ...
        'LossType', options.ConfidenceLossType);

%% 2. Calculate Standard Classification Error
% Compute the primary objective loss using the newly interpolated Y.
switch options.LossType
    case 'CTC'
        % ctc strictly requires 4 positional arguments before Name-Value pairs.
        % Generate default masks of all ones if they are missing.
        this_YMask = options.YMask;
        this_TMask = options.TMask;
        
        if isempty(this_YMask)
            this_YMask = ones(size(Y), "like", Y);
        end
        if isempty(this_TMask)
            this_TMask = ones(size(T), "like", T);
        end
        
        Loss = ctc(Y, T, this_YMask, this_TMask, 'BlankIndex', 'last');
        
    case 'CrossEntropy'
        if all(isnan(options.Weights), 'all')
            Loss = crossentropy(Y,T);
        else
            Loss = crossentropy(Y,T,options.Weights);
        end
        
    case 'Classification'
        if all(isnan(options.Weights), 'all')
            Loss = crossentropy(Y,T);
        else
            Loss = crossentropy(Y,T,options.Weights);
        end
        
    otherwise
        if all(isnan(options.Weights), 'all')
            Loss = crossentropy(Y,T);
        else
            Loss = crossentropy(Y,T,options.Weights);
        end
end

end