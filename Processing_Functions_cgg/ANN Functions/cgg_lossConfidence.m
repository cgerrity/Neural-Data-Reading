function [Y, Loss_Total, Loss_Trial, Loss_Task] = cgg_lossConfidence(Y, T, TrialConfidence, TaskConfidence, options)
%CGG_LOSSCONFIDENCE Calculates informative-ness loss and interpolates predictions.
%   Conjoins Trial and Task confidence, interpolates the network prediction Y 
%   with the target T, and computes the dataset-level regularization loss.

arguments (Input)
    Y
    T
    TrialConfidence
    TaskConfidence
    options.WantDatasetConfidence (1,1) logical = true
    options.DatasetTotalConfidence = []
    options.DatasetTrialConfidence = []
    options.DatasetTaskConfidence  = []
    options.BatchFraction (1,1) double = 1.0
    options.LossType = 'CrossEntropy'
    options.WantDisplay (1,1) logical = false
    options.WantBatchCorrection (1,1) logical = false
    options.ConfidenceDropout (1,1) double = 0.5
end

arguments (Output)
    Y
    Loss_Total
    Loss_Trial
    Loss_Task
end

%% 1. Default Initialization
Loss_Total = dlarray(0);
Loss_Trial = dlarray(0);
Loss_Task  = dlarray(0);
TotalConfidence = [];

%% 2. Tri-Partite Confidence Conjunction
if isdlarray(TaskConfidence)
    TaskConfidence = cgg_getLastSequenceValue(TaskConfidence);
    TaskConfidence_Dropped = TaskConfidence;
    DropoutMask = rand(size(TaskConfidence_Dropped), "like", ...
        TaskConfidence_Dropped) > options.ConfidenceDropout;
    TaskConfidence_Dropped(DropoutMask) = 1;
    TotalConfidence = TaskConfidence;
    TotalConfidence_Dropped = TaskConfidence_Dropped;
end

if isdlarray(TrialConfidence)
    TrialConfidence = cgg_getLastSequenceValue(TrialConfidence);
    TrialConfidence_Dropped = TrialConfidence;
    DropoutMask = rand(size(TrialConfidence), "like", ...
        TrialConfidence) > options.ConfidenceDropout;
    TrialConfidence_Dropped(DropoutMask) = 1;
    if ~isempty(TotalConfidence)
        TotalConfidence = TotalConfidence .* TrialConfidence; % Eq. 1
        TotalConfidence_Dropped = TotalConfidence_Dropped .* TrialConfidence_Dropped; % Eq. 1
    else
        TotalConfidence = TrialConfidence;
        TotalConfidence_Dropped = TrialConfidence_Dropped; % Eq. 1
    end
end

%% 3. The Interpolated Forward Pass & Loss Calculation
if isdlarray(TotalConfidence)
    TotalConfidence = cgg_getLastSequenceValue(TotalConfidence);
    % DropoutMask = rand(size(TotalConfidence), "like", TotalConfidence) > options.ConfidenceDropout;

    ConfidenceThreshold = 0.5;
    StringConfidence_PreDropout = cgg_getArrayListString(mean(cgg_extractData(TotalConfidence),"all"));
    StringConfidence_PreDropout_High = cgg_getArrayListString(sum(cgg_extractData(TotalConfidence) > ConfidenceThreshold,"all")/numel(cgg_extractData(TotalConfidence)));
    % TotalConfidence(DropoutMask) = 1;
    StringConfidence_PostDropout = cgg_getArrayListString(mean(cgg_extractData(TotalConfidence_Dropped),"all"));
    StringConfidence_PostDropout_High = cgg_getArrayListString(sum(cgg_extractData(TotalConfidence_Dropped) > ConfidenceThreshold,"all")/numel(cgg_extractData(TotalConfidence_Dropped)));
    fprintf('      ??? Dataset Confidence before and after dropout is [%s]:[%s] with high fraction before and after as [%s]:[%s]\n',StringConfidence_PreDropout,StringConfidence_PostDropout,StringConfidence_PreDropout_High,StringConfidence_PostDropout_High);
    
    % \hat{y}' = \omega^{total} * \hat{y} + (1 - \omega^{total}) * y (Eq. 2)
    Y = (TotalConfidence_Dropped) .* Y + (1 - TotalConfidence_Dropped) .* T;

    % Compute the differentiable loss for each of the three branches
    Loss_Total = compute_confidence_branch(TotalConfidence, options.DatasetTotalConfidence, 'Total', options);
    Loss_Trial = compute_confidence_branch(TrialConfidence, options.DatasetTrialConfidence, 'Trial', options);
    Loss_Task  = compute_confidence_branch(TaskConfidence,  options.DatasetTaskConfidence, 'Task',  options);
end

end

%% Local Helper Functions
function BranchLoss = compute_confidence_branch(BatchConfidenceInstances, HistoricalDatasetConfidence, ConfidenceType, options)
    % Safeguard against empty branches
    if isempty(BatchConfidenceInstances) || ~isdlarray(BatchConfidenceInstances)
        BranchLoss = dlarray(0); return;
    end
    
    % Batch mean (\bar{\omega}_b)
    BatchConfidenceMean = mean(BatchConfidenceInstances, 'all');
    
    if options.WantDatasetConfidence
        % Initialize history if empty
        if isempty(HistoricalDatasetConfidence) || any(isnan(cgg_extractData(HistoricalDatasetConfidence)), 'all')
            HistoricalDatasetConfidence_Detached = ones(size(BatchConfidenceMean), "like", BatchConfidenceMean);
            switch ConfidenceType
                case 'Total'
                    HistoryInitializationValue = 1;
                case 'Trial'
                    HistoryInitializationValue = 1;
                case 'Task'
                    HistoryInitializationValue = 1;
                otherwise
                    HistoryInitializationValue = 1;
            end
            HistoricalDatasetConfidence_Detached = HistoricalDatasetConfidence_Detached .* HistoryInitializationValue;
        else
            % STOP-GRADIENT on history ( \perp(\Omega_{t-1}) )
            HistoricalDatasetConfidence_Detached = HistoricalDatasetConfidence; 
        end
        
        HistoricalDatasetConfidence_Detached = cgg_extractData(HistoricalDatasetConfidence_Detached);
        gamma = options.BatchFraction;
        gamma = cgg_extractData(gamma);
        
        % Differentiable EMA Node (Eq. 7): \Omega_t = (1 - \gamma)\Omega_{t-1} + \gamma \bar{\omega}_b
        % Backprop only flows through the current batch's contribution
        UpdatedDatasetConfidence = HistoricalDatasetConfidence_Detached .* (1 - gamma) + BatchConfidenceMean .* gamma;
    else
        UpdatedDatasetConfidence = BatchConfidenceMean;
    end

    % Target is 1.0 (Maximize informativeness)
    targetOnes = ones(size(UpdatedDatasetConfidence), "like", UpdatedDatasetConfidence);

    switch options.LossType
        case 'L1'
            ConfidenceLossFunc = @(x,y) l1loss(x,y);
        case 'CrossEntropy'
            ConfidenceLossFunc = @(x,y) crossentropy(x,y);
        case 'L2'
            ConfidenceLossFunc = @(x,y) l2loss(x,y);
        case 'L1 & L2'
            ConfidenceLossFunc = @(x,y) l1loss(x,y) + l2loss(x,y);
        otherwise
            ConfidenceLossFunc = @(x,y) l1loss(x,y);
    end

    rawLoss = ConfidenceLossFunc(UpdatedDatasetConfidence,targetOnes);

    if options.WantDisplay
        StringConfidence_Before = cgg_getArrayListString(cgg_extractData(HistoricalDatasetConfidence_Detached));
        StringConfidence_After = cgg_getArrayListString(cgg_extractData(UpdatedDatasetConfidence));
        StringConfidence_Batch = cgg_getArrayListString(cgg_extractData(BatchConfidenceMean));
        fprintf('      ??? %s Dataset Confidence before and after updating with batch Confidence [%s] and batch fraction (%.4f) is [%s]:[%s]\n',ConfidenceType,StringConfidence_Batch,options.BatchFraction,StringConfidence_Before,StringConfidence_After);
    end

    if options.WantDatasetConfidence && options.WantBatchCorrection
        % Gradient Correction (Eq. 10): explicitly scale by 1/gamma
        BranchLoss = rawLoss / options.BatchFraction; 
        
        if options.WantDisplay
            StringLoss_BeforeCorrection = cgg_getArrayListString(cgg_extractData(rawLoss));
            StringLoss_AfterCorrection = cgg_getArrayListString(cgg_extractData(BranchLoss));
            fprintf('      ??? %s Confidence Loss before and after correction with batch fraction (%.4f) is [%s]:[%s]\n',ConfidenceType,options.BatchFraction,StringLoss_BeforeCorrection,StringLoss_AfterCorrection);
        end
    else
        BranchLoss = rawLoss;
    end
end