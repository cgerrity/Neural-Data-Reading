function CorrelationTable = cgg_procFullLatentCorrelationAnalysis(cfg_Encoder,EpochDir,varargin)
%CGG_PROCFULLLATENTCORRELATIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','BT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','BT',''};
end
end

if isfunction
LMVariable = CheckVararginPairs('LMVariable', 'Absolute Prediction Error', varargin{:});
else
if ~(exist('LMVariable','var'))
LMVariable='Absolute Prediction Error';
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

%%
Target = cfg_Encoder.Target;
HiddenSize=cfg_Encoder.HiddenSizes;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName = cfg_Encoder.ModelName;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
MiniBatchSize = cfg_Encoder.MiniBatchSize;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
WeightReconstruction = cfg_Encoder.WeightReconstruction;
WeightKL = cfg_Encoder.WeightKL;
WeightClassification = cfg_Encoder.WeightClassification;
WeightedLoss = cfg_Encoder.WeightedLoss;
GradientThreshold = cfg_Encoder.GradientThreshold;
Optimizer = cfg_Encoder.Optimizer;
Normalization = cfg_Encoder.Normalization;
LossType_Decoder = cfg_Encoder.LossType_Decoder;

STDChannelOffset = cfg_Encoder.STDChannelOffset;
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
STDRandomWalk = cfg_Encoder.STDRandomWalk;

wantSubset = cfg_Encoder.wantSubset;
DataWidth = cfg_Encoder.DataWidth;
WindowStride = cfg_Encoder.WindowStride;

TargetDir = [EpochDir.Results filesep 'Encoding' filesep Target];

cfg_Network = cgg_generateEncoderSubFolders([TargetDir filesep 'Fold_1'],ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder);
EncodingParametersPath = cgg_getDirectory(cfg_Network,'Classifier');
EncodingParametersPath = extractAfter(EncodingParametersPath,'Fold_1/');

EncodingParametersPathNameExt = [EncodingParametersPath filesep 'EncodingParameters.yaml'];
%%
EncoderParameters = cgg_procDirectorySearchAndApply(TargetDir, EncodingParametersPathNameExt, @cgg_getAllEncoderParametersTable);
Folds = EncoderParameters.Fold;
Folds = Folds{1};
NumFolds = length(Folds);

% Run multiple instances working on different folds
Folds = Folds(randperm(NumFolds));
%
%%

cfg_LM = PARAMETERS_cggVariableToData(LMVariable);
PlotSubFolder = char(cfg_LM.PlotSubFolder);

%%
SessionName = 'Subset';
Correlation_Fold = cell(1,NumFolds);
P_Value_Fold = cell(1,NumFolds);
%%

for fidx = 1:NumFolds
    %%%% Iterate through folds
Fold = Folds(fidx);

CorrelationPathNameExt = fullfile(EpochDir.Results,'Analysis','Correlation',PlotSubFolder,sprintf('Fold %d',Fold),SessionName,'Correlation.mat');

if isfile(CorrelationPathNameExt)
m_Correlation = matfile(CorrelationPathNameExt,"Writable",false);
Correlation = m_Correlation.Correlation;
P_Value = m_Correlation.P_Value;
else

cfg_Encoder.Target = LMVariable;
[~,~,Testing,~] = cgg_getDatastore(EpochDir.Main,SessionName,Fold,cfg_Encoder,'ClassLowerCount',0);
%%

FoldDir = [EpochDir.Results filesep 'Encoding' filesep Target filesep sprintf('Fold_%d',Fold)];
cfg_Network = cgg_generateEncoderSubFolders(FoldDir,ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder);
Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');

EncoderPathNameExt = [Encoding_Dir filesep 'Encoder-Optimal.mat'];

HasEncoder = isfile(EncoderPathNameExt);

if HasEncoder
    m_Encoder = matfile(EncoderPathNameExt,"Writable",false);
    Encoder=m_Encoder.Encoder;
else
    return
end

[Correlation,P_Value] = cgg_procLatentCorrelationAnalysis(Testing,...
    Encoder,'maxworkerMiniBatchSize',maxworkerMiniBatchSize,...
    'DataFormat',DataFormat);

cgg_saveLatentCorrelationAnalysis(Correlation,P_Value,EpochDir.Results,...
    PlotSubFolder,Fold,SessionName,'IsTable',false);

end

Correlation_Fold{Fold} = Correlation;
P_Value_Fold{Fold} = P_Value;

end

%%

CorrelationTable = cgg_procLatentCorrelationPlot(Correlation_Fold,P_Value_Fold,'LMVariable',LMVariable,'SignificanceValue',SignificanceValue);

%%
end

