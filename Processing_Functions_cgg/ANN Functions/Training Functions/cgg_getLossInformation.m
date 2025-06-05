function [LossInformation] = cgg_getLossInformation(Loss_Reconstruction,Loss_KL,Loss_Reconstruction_PerArea,Loss_Classification_PerDimension,LossInformation,WantUpdateLossPrior,WeightReconstruction,WeightKL,WeightClassification)
%CGG_GETLOSSINFORMATION Summary of this function goes here
%   Detailed explanation goes here

WantDisplay = false;

WantWeightedLoss_Reconstruction = ~isnan(WeightReconstruction);
WantWeightedLoss_KL = ~isnan(WeightKL);
WantWeightedLoss_Classification = ~isnan(WeightClassification);

%%
Loss_Classification = sum(Loss_Classification_PerDimension);
NumDimensions = length(Loss_Classification_PerDimension);

%%
if isempty(LossInformation)
LossInformation = struct;
LossInformation.Prior_Loss_Reconstruction = 1;
LossInformation.Prior_Loss_KL = 1;

LossInformation.Prior_Loss_Classification_PerDimension = ...
    ones(1,NumDimensions);
LossInformation.Prior_Loss_Classification = 1;
end

if isdlarray(Loss_Reconstruction)
    LossInformation.Loss_Reconstruction = ...
        extractdata(Loss_Reconstruction);
else
    LossInformation.Loss_Reconstruction = ...
        Loss_Reconstruction;
end
if isdlarray(Loss_KL)
    LossInformation.Loss_KL = ...
        extractdata(Loss_KL);
else
    LossInformation.Loss_KL = ...
        Loss_KL;
end
if isdlarray(Loss_Reconstruction_PerArea)
    LossInformation.Loss_Reconstruction_PerArea = ...
        extractdata(Loss_Reconstruction_PerArea);
else
    LossInformation.Loss_Reconstruction_PerArea = ...
        Loss_Reconstruction_PerArea;
end
if isdlarray(Loss_Classification_PerDimension)
    LossInformation.Loss_Classification_PerDimension = ...
        extractdata(Loss_Classification_PerDimension);
else
    LossInformation.Loss_Classification_PerDimension = ...
        Loss_Classification_PerDimension;
end
if isdlarray(Loss_Classification)
    LossInformation.Loss_Classification = ...
        extractdata(Loss_Classification);
else
    LossInformation.Loss_Classification = ...
        Loss_Classification;
end

if WantUpdateLossPrior
    LossInformation.Prior_Loss_Reconstruction = ...
        LossInformation.Loss_Reconstruction;
    LossInformation.Prior_Loss_KL = ...
        LossInformation.Loss_KL;
    LossInformation.Prior_Loss_Classification_PerDimension = ...
        LossInformation.Loss_Classification_PerDimension;
    LossInformation.Prior_Loss_Classification = ...
        LossInformation.Loss_Classification;
end

%% Normalize Loss

% Loss_Reconstruction_Normalized = Loss_Reconstruction;
% Loss_KL_Normalized = Loss_KL;
% Loss_Classification_PerDimension_Normalized = ...
%     Loss_Classification_PerDimension;
% Loss_Classification_Normalized = Loss_Classification;

if LossInformation.Prior_Loss_Reconstruction ~= 0 && ...
        WantWeightedLoss_Reconstruction
% Loss_Reconstruction_Normalized = Loss_Reconstruction./ ...
%     LossInformation.Prior_Loss_Reconstruction;
Loss_Reconstruction = Loss_Reconstruction./ ...
    LossInformation.Prior_Loss_Reconstruction;
end
if LossInformation.Prior_Loss_KL ~= 0 && ...
        WantWeightedLoss_KL
% Loss_KL_Normalized = Loss_KL./ ...
%     LossInformation.Prior_Loss_KL;
Loss_KL = Loss_KL./ ...
    LossInformation.Prior_Loss_KL;
end

if LossInformation.Prior_Loss_Classification_PerDimension ~= 0 && ...
        WantWeightedLoss_Classification
% Loss_Classification_PerDimension_Normalized = ...
%     Loss_Classification_PerDimension./ ...
%     LossInformation.Prior_Loss_Classification_PerDimension;
Loss_Classification_PerDimension = ...
    Loss_Classification_PerDimension./ ...
    LossInformation.Prior_Loss_Classification_PerDimension;
end

if LossInformation.Prior_Loss_Classification ~= 0 && ...
        WantWeightedLoss_Classification
% Loss_Classification_Normalized = Loss_Classification./ ...
%     LossInformation.Prior_Loss_Classification;
Loss_Classification = Loss_Classification./ ...
    LossInformation.Prior_Loss_Classification;
end

%% Save Normalized Loss

if isdlarray(Loss_Reconstruction)
    LossInformation.Loss_Reconstruction_Normalized = ...
       extractdata(Loss_Reconstruction);
else
    LossInformation.Loss_Reconstruction_Normalized = Loss_Reconstruction;
end
if isdlarray(Loss_KL)
    LossInformation.Loss_KL_Normalized = ...
       extractdata(Loss_KL);
else
    LossInformation.Loss_KL_Normalized = Loss_KL;
end
if isdlarray(Loss_Classification_PerDimension)
    LossInformation.Loss_Classification_PerDimension_Normalized = ...
       extractdata(Loss_Classification_PerDimension);
else
    LossInformation.Loss_Classification_PerDimension_Normalized = Loss_Classification_PerDimension;
end
if isdlarray(Loss_Classification)
    LossInformation.Loss_Classification_Normalized = ...
       extractdata(Loss_Classification);
else
    LossInformation.Loss_Classification_Normalized = Loss_Classification;
end

% LossInformation.Loss_Reconstruction_Normalized = ...
%     Loss_Reconstruction_Normalized;
% LossInformation.Loss_KL_Normalized = ...
%     Loss_KL_Normalized;
% LossInformation.Loss_Classification_PerDimension_Normalized = ...
%     Loss_Classification_PerDimension_Normalized;
% LossInformation.Loss_Classification_Normalized = ...
%     Loss_Classification_Normalized;

%% Rescale Loss

% if isdlarray(Loss_Classification_Normalized)
if isdlarray(Loss_Classification)
    Rescale_Value = LossInformation.Prior_Loss_Classification;
% elseif isdlarray(Loss_Reconstruction_Normalized)
elseif isdlarray(Loss_Reconstruction)
    Rescale_Value = LossInformation.Prior_Loss_Reconstruction;
end

if WantWeightedLoss_Reconstruction
Loss_Reconstruction = Loss_Reconstruction.*Rescale_Value;
end
if WantWeightedLoss_KL
Loss_KL = Loss_KL.*Rescale_Value;
end
if WantWeightedLoss_Classification
Loss_Classification_PerDimension = Loss_Classification_PerDimension.*Rescale_Value;
end
if WantWeightedLoss_Classification
Loss_Classification = Loss_Classification.*Rescale_Value;
end

% Loss_Reconstruction_Rescaled = ...
%     Loss_Reconstruction_Normalized.*Rescale_Value;
% Loss_KL_Rescaled = ...
%     Loss_KL_Normalized.*Rescale_Value;
% Loss_Classification_PerDimension_Rescaled = ...
%     Loss_Classification_PerDimension_Normalized.*Rescale_Value;
% Loss_Classification_Rescaled = ...
%     Loss_Classification_Normalized.*Rescale_Value;

%% Save Rescale Loss

if isdlarray(Loss_Reconstruction)
    LossInformation.Loss_Reconstruction_Rescaled = ...
       extractdata(Loss_Reconstruction);
else
    LossInformation.Loss_Reconstruction_Rescaled = Loss_Reconstruction;
end
if isdlarray(Loss_KL)
    LossInformation.Loss_KL_Rescaled = ...
       extractdata(Loss_KL);
else
    LossInformation.Loss_KL_Rescaled = Loss_KL;
end
if isdlarray(Loss_Classification_PerDimension)
    LossInformation.Loss_Classification_PerDimension_Rescaled = ...
       extractdata(Loss_Classification_PerDimension);
else
    LossInformation.Loss_Classification_PerDimension_Rescaled = Loss_Classification_PerDimension;
end
if isdlarray(Loss_Classification)
    LossInformation.Loss_Classification_Rescaled = ...
       extractdata(Loss_Classification);
else
    LossInformation.Loss_Classification_Rescaled = Loss_Classification;
end

% LossInformation.Loss_Reconstruction_Rescaled = ...
%     Loss_Reconstruction_Rescaled;
% LossInformation.Loss_KL_Rescaled = ...
%     Loss_KL_Rescaled;
% LossInformation.Loss_Classification_PerDimension_Rescaled = ...
%     Loss_Classification_PerDimension_Rescaled;
% LossInformation.Loss_Classification_Rescaled = ...
%     Loss_Classification_Rescaled;

%% Weighted Loss

if WantWeightedLoss_Reconstruction
Loss_Reconstruction = Loss_Reconstruction .* WeightReconstruction;
end
if WantWeightedLoss_KL
Loss_KL = Loss_KL .* WeightKL;
end
if WantWeightedLoss_Reconstruction
Loss_Classification_PerDimension = Loss_Classification_PerDimension .* WeightClassification;
end
if WantWeightedLoss_Classification
Loss_Classification = Loss_Classification .* WeightClassification;
end

% if isnan(WeightReconstruction)
% Loss_Reconstruction_Weighted = ...
%     Loss_Reconstruction;
% else
% Loss_Reconstruction_Weighted = ...
%     LossInformation.Loss_Reconstruction_Rescaled .* WeightReconstruction;
% end
% 
% if isnan(WeightKL)
% Loss_KL_Weighted = ...
%     Loss_KL;
% else
% Loss_KL_Weighted = ...
%     LossInformation.Loss_KL_Rescaled .* WeightKL;
% end
% 
% if isnan(WeightClassification)
% Loss_Classification_Weighted = ...
%     Loss_Classification;
% else
% Loss_Classification_Weighted = ...
%     LossInformation.Loss_Classification_Rescaled .* WeightClassification;
% end

%% Save Weighted Loss

if isdlarray(Loss_Reconstruction)
    LossInformation.Loss_Reconstruction_Weighted = ...
       extractdata(Loss_Reconstruction);
else
    LossInformation.Loss_Reconstruction_Weighted = Loss_Reconstruction;
end
if isdlarray(Loss_KL)
    LossInformation.Loss_KL_Weighted = ...
       extractdata(Loss_KL);
else
    LossInformation.Loss_KL_Weighted = Loss_KL;
end
if isdlarray(Loss_Classification_PerDimension)
    LossInformation.Loss_Classification_PerDimension_Weighted = ...
       extractdata(Loss_Classification_PerDimension);
else
    LossInformation.Loss_Classification_PerDimension_Weighted = Loss_Classification_PerDimension;
end
if isdlarray(Loss_Classification)
    LossInformation.Loss_Classification_Weighted = ...
       extractdata(Loss_Classification);
else
    LossInformation.Loss_Classification_Weighted = Loss_Classification;
end

%% Network Loss

if ~isnan(Loss_Reconstruction)
    Loss_Decoder = Loss_Reconstruction;
else
    Loss_Decoder = NaN;
end
if ~isnan(Loss_KL) && ~isnan(Loss_Decoder)
    Loss_Decoder = Loss_Decoder + Loss_KL;
end

if ~isnan(Loss_Classification)
    Loss_Classifier = Loss_Classification;
else
    Loss_Classifier = NaN;
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

% if ~isnan(Loss_Reconstruction_Weighted)
%     Loss_Decoder = Loss_Reconstruction_Weighted;
% else
%     Loss_Decoder = NaN;
% end
% if ~isnan(Loss_KL_Weighted) && ~isnan(Loss_Decoder)
%     Loss_Decoder = Loss_Decoder + Loss_KL_Weighted;
% end
% 
% if ~isnan(Loss_Classification_Weighted)
%     Loss_Classifier = Loss_Classification_Weighted;
% else
%     Loss_Classifier = NaN;
% end
% if ~isnan(Loss_Decoder)
%     Loss_Encoder = Loss_Decoder;
% else
%     Loss_Encoder = NaN;
% end
% if ~isnan(Loss_Classifier) && ~isnan(Loss_Encoder)
%     Loss_Encoder = Loss_Encoder + Loss_Classifier;
% elseif ~isnan(Loss_Classifier)
%     Loss_Encoder = Loss_Classifier;
% end

%%

% if isdlarray(Loss_Reconstruction_Weighted)
%     LossInformation.Loss_Reconstruction_Weighted = extractdata(Loss_Reconstruction_Weighted);
% else
%     LossInformation.Loss_Reconstruction_Weighted = Loss_Reconstruction_Weighted;
% end
% if isdlarray(Loss_KL_Weighted)
%     LossInformation.Loss_KL_Weighted = extractdata(Loss_KL_Weighted);
% else
%     LossInformation.Loss_KL_Weighted = Loss_KL_Weighted;
% end
% if isdlarray(Loss_Classification_Weighted)
%     LossInformation.Loss_Classification_Weighted = extractdata(Loss_Classification_Weighted);
% else
%     LossInformation.Loss_Classification_Weighted = Loss_Classification_Weighted;
% end

LossInformation.Loss_Decoder = Loss_Decoder;
LossInformation.Loss_Classifier = Loss_Classifier;
LossInformation.Loss_Encoder = Loss_Encoder;

%%

if WantDisplay
% fprintf('\tReconstruction = %f \n',extractdata(Loss_Reconstruction));
% fprintf('\tKL = %f \n',Loss_KL);
% 
% fprintf('\tReconstruction Prior = %f \n',LossInformation.Prior_Loss_Reconstruction);
% fprintf('\tKL Prior = %f \n',LossInformation.Prior_Loss_KL);
% 
% fprintf('\tReconstruction Normalized = %f \n',extractdata(Loss_Reconstruction_Normalized));
% fprintf('\tKL Normalized = %f \n',Loss_KL_Normalized);
% 
% fprintf('\tReconstruction Rescaled = %f \n',extractdata(Loss_Reconstruction_Rescaled));
% fprintf('\tKL Rescaled = %f \n',Loss_KL_Rescaled);
% 
% fprintf('\tReconstruction Weighted = %f \n',extractdata(Loss_Reconstruction_Weighted));
% fprintf('\tKL Weighted = %f \n',Loss_KL_Weighted);
end

end

