function [Loss,CM_Table,Loss_TotalConfidence,Loss_TrialConfidence,...
    Loss_TaskConfidence] = ...
    cgg_getClassifierOutputsFromProbabilities(T,Y,ClassNames,...
    DataNumber,InLoss,InCM_Table,Normalization_Factor,varargin)
%CGG_GETCLASSIFIEROUTPUTSFROMPROBABILITIES Formats predictions into tables and accumulates loss

isfunction=exist('varargin','var');

if isfunction
    wantLoss = CheckVararginPairs('wantLoss', true, varargin{:});
else
    if ~(exist('wantLoss','var'))
        wantLoss=true;
    end
end
if isfunction
    Weights = CheckVararginPairs('Weights', cell(0), varargin{:});
else
    if ~(exist('Weights','var'))
        Weights=cell(0);
    end
end
if isfunction
    IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
    if ~(exist('IsQuaddle','var'))
        IsQuaddle=true;
    end
end
if isfunction
    NumTimeSteps = CheckVararginPairs('NumTimeSteps', size(Y{1},finddim(Y{1},"T")), varargin{:});
else
    if ~(exist('NumTimeSteps','var'))
        NumTimeSteps=size(Y{1},finddim(Y{1},"T"));
    end
end
if isfunction
    NumTrials = CheckVararginPairs('NumBatches', size(Y{1},finddim(Y{1},"B")), varargin{:});
else
    if ~(exist('NumBatches','var'))
        NumTrials=size(Y{1},finddim(Y{1},"B"));
    end
end
if isfunction
    LossType = CheckVararginPairs('LossType', 'CrossEntropy', varargin{:});
else
    if ~(exist('LossType','var'))
        LossType='CrossEntropy';
    end
end
if isfunction
    WantGradient = CheckVararginPairs('WantGradient', false, varargin{:});
else
    if ~(exist('WantGradient','var'))
        WantGradient=false;
    end
end
if isfunction
    MultipleInstanceLearningType = CheckVararginPairs('MultipleInstanceLearningType', 'None', varargin{:});
else
    if ~(exist('MultipleInstanceLearningType','var'))
        MultipleInstanceLearningType='None';
    end
end
if isfunction
    TrialConfidence = CheckVararginPairs('TrialConfidence', [], varargin{:});
else
    if ~(exist('TrialConfidence','var'))
        TrialConfidence=[];
    end
end
if isfunction
    TaskConfidence = CheckVararginPairs('TaskConfidence', [], varargin{:});
else
    if ~(exist('TaskConfidence','var'))
        TaskConfidence=[];
    end
end
if isfunction
    InLoss_TotalConfidence = CheckVararginPairs('InLoss_TotalConfidence', dlarray(0), varargin{:});
else
    if ~(exist('InLoss_TotalConfidence','var'))
        InLoss_TotalConfidence=dlarray(0);
    end
end
if isfunction
    InLoss_TrialConfidence = CheckVararginPairs('InLoss_TrialConfidence', dlarray(0), varargin{:});
else
    if ~(exist('InLoss_TrialConfidence','var'))
        InLoss_TrialConfidence=dlarray(0);
    end
end
if isfunction
    InLoss_TaskConfidence = CheckVararginPairs('InLoss_TaskConfidence', dlarray(0), varargin{:});
else
    if ~(exist('InLoss_TaskConfidence','var'))
        InLoss_TaskConfidence=dlarray(0);
    end
end
if isfunction
    BatchFraction = CheckVararginPairs('BatchFraction', 1, varargin{:});
else
    if ~(exist('BatchFraction','var'))
        BatchFraction=1;
    end
end

% Parse LossInformation
if isfunction
    LossInformation = CheckVararginPairs('LossInformation', [], varargin{:});
else
    if ~(exist('LossInformation','var'))
        LossInformation=[];
    end
end

if isfunction
WantBatchCorrection = CheckVararginPairs('WantBatchCorrection', false, varargin{:});
else
if ~(exist('WantBatchCorrection','var'))
WantBatchCorrection=false;
end
end

%% Predictor Delegation
% Delegate to the core predictor, passing along the newly parsed LossInformation struct
[Window_Prediction,Window_TrueValue,Loss,Aggregation_Prediction,...
    Aggregation_TrueValue,Loss_TotalConfidence,Loss_TrialConfidence,Loss_TaskConfidence] = ...
    cgg_getPredictionFromClassifierProbabilities(T,Y,ClassNames, ...
    'wantLoss', wantLoss, ...
    'Weights', Weights, ...
    'IsQuaddle', IsQuaddle, ...
    'LossType', LossType, ...
    'NumTimeSteps', NumTimeSteps, ...
    'NumBatches', NumTrials, ...
    'MultipleInstanceLearningType', MultipleInstanceLearningType, ...
    'TrialConfidence', TrialConfidence, ...
    'TaskConfidence', TaskConfidence, ...
    'BatchFraction', BatchFraction, ...
    'LossInformation', LossInformation, ...
    'WantBatchCorrection',WantBatchCorrection);

if ~WantGradient
    Loss = cgg_extractData(Loss);
    Loss_TotalConfidence = cgg_extractData(Loss_TotalConfidence);
    Loss_TrialConfidence = cgg_extractData(Loss_TrialConfidence);
    Loss_TaskConfidence = cgg_extractData(Loss_TaskConfidence);
end

%% Formatting Tensors to Tables
Window_TrueValue_Table = permute(Window_TrueValue,[2,3,1]);
Window_TrueValue_Table = Window_TrueValue_Table(:,1,:);
Window_TrueValue_Table = squeeze(Window_TrueValue_Table);

Window_Prediction_Table = permute(Window_Prediction,[2,3,1]);

Aggregation_TrueValue_Table = permute(Aggregation_TrueValue,[2,3,1]);
Aggregation_TrueValue_Table = Aggregation_TrueValue_Table(:,1,:);
Aggregation_TrueValue_Table = squeeze(Aggregation_TrueValue_Table);

Aggregation_Prediction_Table = permute(Aggregation_Prediction,[2,3,1]);

if NumTrials == 1
    Window_TrueValue_Table = Window_TrueValue_Table';
    Aggregation_TrueValue_Table = Aggregation_TrueValue_Table';
end

DataNumber = cgg_extractData(DataNumber);
DataNumber = diag(diag(DataNumber));

%% Build CM_Table
for widx=1:NumTimeSteps
    this_WindowName = sprintf('Window_%d',widx);
    this_Window_Prediction = squeeze(Window_Prediction_Table(:,widx,:));
    
    if NumTrials == 1
        this_Window_Prediction = this_Window_Prediction';
    end
    
    if widx == 1
        CM_Table = table(DataNumber, Window_TrueValue_Table, this_Window_Prediction, ...
            'VariableNames', {'DataNumber', 'TrueValue', this_WindowName});
    else
        CM_Table.(this_WindowName) = this_Window_Prediction;
    end
end

%% Append Aggregation Prediction
this_Aggregation_Prediction = squeeze(Aggregation_Prediction_Table(:,1,:));
if NumTrials == 1
    this_Aggregation_Prediction = this_Aggregation_Prediction';
end
CM_Table.('Aggregation_Prediction') = this_Aggregation_Prediction;

%% Append Confidence Values
if isdlarray(TrialConfidence)
    TrialConfidence = cgg_getLastSequenceValue(TrialConfidence);
    TrialConfidence = cgg_extractData(TrialConfidence);
    CM_Table.('TrialConfidence') = TrialConfidence(:);
else
    CM_Table.('TrialConfidence') = ones(size(CM_Table.('DataNumber')));
end

if ~isempty(TaskConfidence) && iscell(TaskConfidence)
    if isdlarray(TaskConfidence{1})
        TaskConfidence = cat(finddim(TaskConfidence{1},"C"),TaskConfidence{:});
        TaskConfidence = cgg_getLastSequenceValue(TaskConfidence);
        TaskConfidence = cgg_extractData(TaskConfidence);
        TaskConfidence = TaskConfidence';
        CM_Table.('TaskConfidence') = TaskConfidence;
    else
        CM_Table.('TaskConfidence') = ones(size(CM_Table.('Aggregation_Prediction')));
    end
else
    CM_Table.('TaskConfidence') = ones(size(CM_Table.('Aggregation_Prediction')));
end

%% Accumulate Final Losses with Normalization Factor
% Main Classification Loss
if any(isempty(InLoss)) || any(isnan(InLoss))
    Loss = Loss .* Normalization_Factor;
else
    Loss = InLoss + Loss .* Normalization_Factor;
end

% Total Confidence Loss
if any(isempty(InLoss_TotalConfidence)) || any(isnan(InLoss_TotalConfidence))
    Loss_TotalConfidence = Loss_TotalConfidence .* Normalization_Factor;
else
    Loss_TotalConfidence = InLoss_TotalConfidence + Loss_TotalConfidence .* Normalization_Factor;
end

% Trial Confidence Loss
if any(isempty(InLoss_TrialConfidence)) || any(isnan(InLoss_TrialConfidence))
    Loss_TrialConfidence = Loss_TrialConfidence .* Normalization_Factor;
else
    Loss_TrialConfidence = InLoss_TrialConfidence + Loss_TrialConfidence .* Normalization_Factor;
end

% Task Confidence Loss
if any(isempty(InLoss_TaskConfidence)) || any(isnan(InLoss_TaskConfidence))
    Loss_TaskConfidence = Loss_TaskConfidence .* Normalization_Factor;
else
    Loss_TaskConfidence = InLoss_TaskConfidence + Loss_TaskConfidence .* Normalization_Factor;
end

%% Concatenate Historical CM_Table
if istable(InCM_Table) || ~isnan(InLoss)
    CM_Table = [InCM_Table; CM_Table];
end

end