function [LossInformation] = cgg_getLossInformation(Loss_Reconstruction, Loss_KL, Loss_Reconstruction_PerArea, Loss_Classification_PerDimension, Loss_OffsetAndScale, LossInformation, WantUpdateLossPrior, WeightReconstruction, WeightKL, WeightClassification, WeightOffsetAndScale, ClassNames, varargin)
%CGG_GETLOSSINFORMATION Normalizes, rescales, and weights multi-branch losses.
%   Delegates confidence tracking to cgg_getConfidenceLossInformation and uses 
%   a dynamic struct helper to systematically process and log all loss components.

isfunction=exist('varargin','var');
if isfunction
    WantDisplay = CheckVararginPairs('WantDisplay', false, varargin{:});
else
    if ~(exist('WantDisplay','var'))
        WantDisplay=false;
    end
end
if isfunction
    WeightConfidence = CheckVararginPairs('WeightConfidence', 0, varargin{:});
else
    if ~(exist('WeightConfidence','var'))
        WeightConfidence=0;
    end
end
if isfunction
    Loss_TotalConfidence = CheckVararginPairs('Loss_TotalConfidence', NaN, varargin{:});
else
    if ~(exist('Loss_TotalConfidence','var'))
        Loss_TotalConfidence=NaN;
    end
end
% if isfunction
%     Loss_TotalConfidence_PerDimension = CheckVararginPairs('Loss_TotalConfidence_PerDimension', NaN, varargin{:});
% else
%     if ~(exist('Loss_TotalConfidence_PerDimension','var'))
%         Loss_TotalConfidence_PerDimension=NaN;
%     end
% end
if isfunction
    Loss_TrialConfidence = CheckVararginPairs('Loss_TrialConfidence', NaN, varargin{:});
else
    if ~(exist('Loss_TrialConfidence','var'))
        Loss_TrialConfidence=NaN;
    end
end
if isfunction
    Loss_TaskConfidence = CheckVararginPairs('Loss_TaskConfidence', NaN, varargin{:});
else
    if ~(exist('Loss_TaskConfidence','var'))
        Loss_TaskConfidence=NaN;
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
    BatchFraction = CheckVararginPairs('BatchFraction', 1.0, varargin{:});
else
    if ~(exist('BatchFraction','var'))
        BatchFraction=1.0;
    end
end

WantWeightedLoss_Reconstruction = ~isnan(WeightReconstruction);
WantWeightedLoss_KL = ~isnan(WeightKL);
WantWeightedLoss_Classification = ~isnan(WeightClassification);
WantWeightedLoss_OffsetAndScale = ~isnan(WeightOffsetAndScale);
WantWeightedLoss_Confidence = ~isnan(WeightConfidence);

%% Identify Valid Classification Dimensions
ValidClassificationIndices = cellfun(@(x) length(x),ClassNames) > 1;
NumDimensions = length(ValidClassificationIndices);

%% Initialize Struct
if isempty(LossInformation)
    LossInformation = struct;
    LossInformation.Prior_Loss_Reconstruction = 1;
    LossInformation.Prior_Loss_KL = 1;
    LossInformation.Prior_Loss_Classification_PerDimension = ones(1,NumDimensions);
    LossInformation.Prior_Loss_Classification = 1;
    LossInformation.Prior_Loss_OffsetAndScale = 1;
    LossInformation.Prior_Loss_TotalConfidence = 1;
    LossInformation.Prior_Loss_TotalConfidence_PerDimension = ones(1,NumDimensions);
    LossInformation.Prior_Loss_TrialConfidence = ones(1,NumDimensions);
    LossInformation.Prior_Loss_TaskConfidence = ones(1,NumDimensions);
    LossInformation.Confidence_Beta = 1;
end

%% Delegate Confidence Tracking & Budgeting
[Loss_Confidence, LossInformation] = cgg_getConfidenceLossInformation(...
    LossInformation, TrialConfidence, TaskConfidence, ...
    Loss_TrialConfidence, Loss_TaskConfidence, Loss_TotalConfidence, ...
    ValidClassificationIndices, BatchFraction);

%% Compute Raw Classification (Summed across dimensions)
Loss_Classification = sum(Loss_Classification_PerDimension(ValidClassificationIndices));

% Track the PerArea reconstruction purely for logging
LossInformation.Loss_Reconstruction_PerArea = cgg_extractData(Loss_Reconstruction_PerArea);

%% Determine Rescale Value
% Pre-calculate the prior reference value to pass into the processing helper
if WantUpdateLossPrior
    Prior_Class = cgg_extractData(Loss_Classification);
    Prior_Recon = cgg_extractData(Loss_Reconstruction);
else
    Prior_Class = LossInformation.Prior_Loss_Classification;
    Prior_Recon = LossInformation.Prior_Loss_Reconstruction;
end

if isdlarray(Loss_Classification) || ~(all(isnan(cgg_extractData(Loss_Classification)),'all') || isempty(Loss_Classification))
    Rescale_Value = Prior_Class;
elseif isdlarray(Loss_Reconstruction) || ~(all(isnan(cgg_extractData(Loss_Reconstruction)),'all') || isempty(Loss_Reconstruction))
    Rescale_Value = Prior_Recon;
else
    Rescale_Value = 1;
end

%% Process Core Loss Components via Dynamic Helper
[Loss_Reconstruction, LossInformation] = cgg_processLossComponent(...
    Loss_Reconstruction, 'Reconstruction', LossInformation, ...
    WantUpdateLossPrior, WantWeightedLoss_Reconstruction, Rescale_Value, WeightReconstruction);

[Loss_KL, LossInformation] = cgg_processLossComponent(...
    Loss_KL, 'KL', LossInformation, ...
    WantUpdateLossPrior, WantWeightedLoss_KL, Rescale_Value, WeightKL);

[Loss_Classification_PerDimension, LossInformation] = cgg_processLossComponent(...
    Loss_Classification_PerDimension, 'Classification_PerDimension', LossInformation, ...
    WantUpdateLossPrior, WantWeightedLoss_Classification, Rescale_Value, WeightClassification);

[Loss_Classification, LossInformation] = cgg_processLossComponent(...
    Loss_Classification, 'Classification', LossInformation, ...
    WantUpdateLossPrior, WantWeightedLoss_Classification, Rescale_Value, WeightClassification);

[Loss_OffsetAndScale, LossInformation] = cgg_processLossComponent(...
    Loss_OffsetAndScale, 'OffsetAndScale', LossInformation, ...
    WantUpdateLossPrior, WantWeightedLoss_OffsetAndScale, Rescale_Value, WeightOffsetAndScale);

[Loss_Confidence, LossInformation] = cgg_processLossComponent(...
    Loss_Confidence, 'TotalConfidence', LossInformation, ...
    WantUpdateLossPrior, WantWeightedLoss_Confidence, Rescale_Value, WeightConfidence);

%% Network Loss Construction
if ~isnan(Loss_Reconstruction)
    Loss_Decoder = Loss_Reconstruction;
else
    Loss_Decoder = NaN;
end

if ~isnan(Loss_KL) && ~isnan(Loss_Decoder)
    Loss_Decoder = Loss_Decoder + Loss_KL;
end
if ~isnan(Loss_OffsetAndScale) && ~isnan(Loss_Decoder) && Loss_OffsetAndScale ~= 0
    Loss_Decoder = Loss_Decoder + Loss_OffsetAndScale;
end

if ~isnan(Loss_Classification)
    Loss_Classifier = Loss_Classification;
else
    Loss_Classifier = NaN;
end

% Merge confidence penalty strictly into classifier gradients
if ~isnan(Loss_Confidence) && ~isnan(Loss_Classifier) && Loss_Confidence ~= 0
    Loss_Classifier = Loss_Classifier + Loss_Confidence;
end

if ~isnan(Loss_Decoder)
    Loss_Encoder = Loss_Decoder;
else
    Loss_Encoder = NaN;
end

if ~isnan(Loss_Classifier) && ~isnan(Loss_Encoder)
    Loss_Encoder = Loss_Encoder + Loss_Classifier;
elseif ~isnan(Loss_Classifier)
    Loss_Encoder = Loss_Classifier;
end

LossInformation.Loss_Decoder = Loss_Decoder;
LossInformation.Loss_Classifier = Loss_Classifier;
LossInformation.Loss_Encoder = Loss_Encoder;

if WantDisplay
    fprintf("      ||| Target Beta is %.2f\n", LossInformation.Confidence_Beta);
end

end

%% ================= HELPER FUNCTIONS ================= %%

function [Loss_Out, LossInformation] = cgg_processLossComponent(Loss_In, LossName, LossInformation, WantUpdatePrior, WantWeighted, Rescale_Value, Weight)
%CGG_PROCESSLOSSCOMPONENT Centralizes extraction, prior updating, normalization, rescaling, and weighting.
%   Uses dynamic field generation (struct.(['Name'])) to avoid repetitive assignments.

    % Define dynamic field names
    RawField     = ['Loss_' LossName];
    PriorField   = ['Prior_Loss_' LossName];
    NormField    = ['Loss_' LossName '_Normalized'];
    RescaleField = ['Loss_' LossName '_Rescaled'];
    WeightField  = ['Loss_' LossName '_Weighted'];

    % 1. Extract Raw Data
    RawData = cgg_extractData(Loss_In);
    LossInformation.(RawField) = RawData;
    
    % 2. Establish Prior
    if WantUpdatePrior
        PriorData = RawData;
    else
        % Fallback if field hasn't been initialized yet
        if isfield(LossInformation, PriorField)
            PriorData = LossInformation.(PriorField);
        else
            PriorData = 1;
        end
    end
    LossInformation.(PriorField) = PriorData;
    
    Loss_Working = Loss_In;
    
    % 3. Normalize
    % Ensure we do not divide by zero if prior tracking has not stabilized
    if WantWeighted && all(PriorData ~= 0, 'all')
        Loss_Working = Loss_Working ./ PriorData;
    end
    LossInformation.(NormField) = cgg_extractData(Loss_Working);
    
    % 4. Rescale
    if WantWeighted
        Loss_Working = Loss_Working .* Rescale_Value;
    end
    LossInformation.(RescaleField) = cgg_extractData(Loss_Working);
    
    % 5. Weight
    if WantWeighted
        Loss_Working = Loss_Working .* Weight;
    end
    LossInformation.(WeightField) = cgg_extractData(Loss_Working);
    
    % Return the final fully processed loss block (as a dlarray for gradients)
    Loss_Out = Loss_Working;
end