function [Loss_Confidence, LossInformation] = cgg_getConfidenceLossInformation(...
    LossInformation, TrialConfidence, TaskConfidence, ...
    Loss_TrialConfidence, Loss_TaskConfidence, Loss_TotalConfidence, ...
    ValidClassificationIndices, BatchFraction)
%CGG_GETCONFIDENCELOSSINFORMATION Tracks EMA and calculates dynamic confidence penalty.
%   Handles the stateful components of the selective classification architecture
%   including EMA dataset tracking and an Autonomous Equilibrium PD Controller.

%% Controller Hyperparameters
Confidence_Beta_Max  = 10;
Confidence_Beta_Min  = 0.1;  % Baseline equilibrium. Beta never drops below 1.0.
Confidence_Target    = 0.5;  % Always aim for perfect confidence
% Confidence_Push_Rate = 0.1; % Aggressive push when confidence is low
% Confidence_Relax_Rate= 0.01;% Gentle decay to relax Beta when confidence is high
Confidence_Difference_Rate= 1;% Gentle decay to relax Beta when confidence is high
% Confidence_Relax_Rate= 0.000001;% Gentle decay to relax Beta when confidence is high
% Confidence_Epsilon   = 0.0000001;  % Curvature control (prevents div-by-zero)
% Confidence_Beta_Settle_Factor = 0.99;
% Confidence_Beta_Settle_Factor_Min = 0.99;

%%
    K_Dimensions = sum(ValidClassificationIndices);

    %% 1. Initialize EMA Fields if Missing
    if ~isfield(LossInformation, 'DatasetTotalConfidence') || isnan(LossInformation.DatasetTotalConfidence)
        LossInformation.DatasetTotalConfidence = NaN;
        LossInformation.DatasetTrialConfidence = NaN;
        LossInformation.DatasetTaskConfidence = NaN;
        LossInformation.Confidence_Beta = 1.0;
        LossInformation.Confidence_Beta_Settle = 1.0;
        LossInformation.Prior_Loss_Confidence = 1.0;
        LossInformation.Loss_Confidence_PerType = [1,1,1];
    end
    if ~isfield(LossInformation, 'Confidence_Beta_Settle')
        LossInformation.Confidence_Beta_Settle = 1.0;
    end

    %% 2. EMA Tracking and Dynamic Confidence Budgeting (\beta_t)
    if ~isempty(TaskConfidence) && ~isempty(TrialConfidence)
        TotalConfidence = TaskConfidence .* TrialConfidence;
    elseif ~isempty(TrialConfidence)
        TotalConfidence = TrialConfidence;
    elseif ~isempty(TaskConfidence)
        TotalConfidence = TaskConfidence;
    else
        TotalConfidence = 1;
    end
    
    batchMeanTotal = mean(cgg_extractData(TotalConfidence), "all");
    gamma = BatchFraction;
    
    % Initialize the Total EMA if it's the very first batch
    if isnan(LossInformation.DatasetTotalConfidence)
        % LossInformation.DatasetTotalConfidence = batchMeanTotal;
        LossInformation.DatasetTotalConfidence = 1;
    end
    
    % --- Autonomous Equilibrium Controller ---
    % Term 1: Derivative (Reacts aggressively to sudden drops via EMA history)
    % DataConfidence_Difference = LossInformation.DatasetTotalConfidence - batchMeanTotal;
    DataConfidence_Difference = Confidence_Target - batchMeanTotal;
    
    % Term 2: Restorative Push (Always positive, aggressively defends against collapse)
    % Restorative_Push = Confidence_Push_Rate * ((Confidence_Target - batchMeanTotal) / (batchMeanTotal + Confidence_Epsilon));
    
    % Term 3: Relaxation Pull (Only overpowers the Push when confidence is extremely high and safe)
    % Relaxation_Pull = Confidence_Relax_Rate * (1/(1-batchMeanTotal + Confidence_Epsilon));
    
    % \beta_t = \beta_{t-1} * (1 + \Delta \Omega_t + Push - Pull)
    % Confidence_Beta = LossInformation.Confidence_Beta .* (1 + DataConfidence_Difference.*Confidence_Difference_Rate + Restorative_Push - Relaxation_Pull);
    Confidence_Beta = LossInformation.Confidence_Beta .* (1 + DataConfidence_Difference.*Confidence_Difference_Rate);
    Confidence_Beta = max(min(Confidence_Beta, Confidence_Beta_Max), Confidence_Beta_Min); 
    LossInformation.Confidence_Beta = Confidence_Beta;
    % LossInformation.Confidence_Beta_Settle = LossInformation.Confidence_Beta_Settle .* Confidence_Beta_Settle_Factor;
    % LossInformation.Confidence_Beta_Settle = min([LossInformation.Confidence_Beta_Settle,Confidence_Beta_Settle_Factor_Min]);
    % Confidence_Beta_Current = Confidence_Beta.*(LossInformation.Confidence_Beta_Settle);
    % Confidence_Beta_Prior = LossInformation.Confidence_Beta.*(1-LossInformation.Confidence_Beta_Settle);
    % LossInformation.Confidence_Beta = Confidence_Beta_Current + Confidence_Beta_Prior;

    % Update the Total Confidence EMA: \Omega_t = (1 - \gamma)\Omega_{t-1} + \gamma \bar{\omega}_b
    LossInformation.DatasetTotalConfidence = (1 - gamma) * LossInformation.DatasetTotalConfidence + gamma * batchMeanTotal;
    
    % Update the Trial Confidence EMA
    if ~isempty(TrialConfidence)
        batchMeanTrial = mean(cgg_extractData(TrialConfidence), "all");
        if isnan(LossInformation.DatasetTrialConfidence)
            % LossInformation.DatasetTrialConfidence = batchMeanTrial;
            LossInformation.DatasetTrialConfidence = 1;
        else
            LossInformation.DatasetTrialConfidence = (1 - gamma) * LossInformation.DatasetTrialConfidence + gamma * batchMeanTrial;
        end
    end

    % Update the Task Confidence EMA
    if ~isempty(TaskConfidence)
        batchMeanTask = mean(cgg_extractData(TaskConfidence), "all");
        if isnan(LossInformation.DatasetTaskConfidence)
            % LossInformation.DatasetTaskConfidence = batchMeanTask;
            LossInformation.DatasetTaskConfidence = 1;
        else
            LossInformation.DatasetTaskConfidence = (1 - gamma) * LossInformation.DatasetTaskConfidence + gamma * batchMeanTask;
        end
    end
    
    %% 3. Tri-partite Confidence Loss Formulation
    % Scale the Task and Total confidences by 1/K (via mean) so they 
    % balance perfectly against the singular trial confidence scalar.
    Loss_Confidence = dlarray(0);
    
    if ~any(isnan(cgg_extractData(Loss_TrialConfidence)), 'all')
        TrialConf_Scalar = sum(Loss_TrialConfidence(ValidClassificationIndices)) / K_Dimensions;
        LossInformation.Loss_Confidence_PerType(2) = cgg_extractData(TrialConf_Scalar);
        Loss_Confidence = Loss_Confidence + TrialConf_Scalar;
    end
    
    if ~any(isnan(cgg_extractData(Loss_TaskConfidence)), 'all')
        TaskConf_Scalar = sum(Loss_TaskConfidence(ValidClassificationIndices)) / K_Dimensions;
        LossInformation.Loss_Confidence_PerType(3) = cgg_extractData(TaskConf_Scalar);
        Loss_Confidence = Loss_Confidence + TaskConf_Scalar;
    end
    
    if ~any(isnan(cgg_extractData(Loss_TotalConfidence)), 'all')
        TotalConf_Scalar = sum(Loss_TotalConfidence(ValidClassificationIndices)) / K_Dimensions;
        LossInformation.Loss_Confidence_PerType(1) = cgg_extractData(TotalConf_Scalar);
        Loss_Confidence = Loss_Confidence + TotalConf_Scalar;
    end
    
    if any(Loss_Confidence == 0) && ~any(~isnan(cgg_extractData(Loss_TrialConfidence)))
        Loss_Confidence = NaN;
    end

    %%

    StringTotalConfidence = cgg_getArrayListString(LossInformation.DatasetTotalConfidence);
    StringTrialConfidence = cgg_getArrayListString(LossInformation.DatasetTrialConfidence);
    StringTaskConfidence = cgg_getArrayListString(LossInformation.DatasetTaskConfidence);

    fprintf('      ??? Confidence (Total:Trial:Task) is ([%s]:[%s]:[%s])\n', ...
        StringTotalConfidence,StringTrialConfidence,StringTaskConfidence);

    StringLoss_TotalConfidence = cgg_getArrayListString(cgg_extractData(Loss_TotalConfidence));
    StringLoss_TrialConfidence = cgg_getArrayListString(cgg_extractData(Loss_TrialConfidence));
    StringLoss_TaskConfidence = cgg_getArrayListString(cgg_extractData(Loss_TaskConfidence));
    StringLoss_Confidence = cgg_getArrayListString(cgg_extractData(Loss_Confidence));
    StringBeta = cgg_getArrayListString(cgg_extractData(Confidence_Beta));
    % StringBeta_Settle = cgg_getArrayListString(cgg_extractData(LossInformation.Confidence_Beta_Settle));

    fprintf('      ??? Confidence Losses (Combined:Total:Trial:Task) is ([%s]:[%s]:[%s]:[%s]) with Beta: %s\n', ...
        StringLoss_Confidence,StringLoss_TotalConfidence, ...
        StringLoss_TrialConfidence,StringLoss_TaskConfidence,StringBeta);
    % fprintf('      ??? Beta: %s and Beta Settling Factor: %s\n', ...
    %     StringBeta, StringBeta_Settle);

end
