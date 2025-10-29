function [MaximumRemovals,NumChannels,NumAreas,LatentSize,BadChannelTable] = cgg_getMaximumNumberOfRemovals(cfg_Encoder,cfg_Epoch,varargin)
%CGG_GETMAXIMUMNUMBEROFREMOVALS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
RemovalType = CheckVararginPairs('RemovalType', 'Channel', varargin{:});
else
if ~(exist('RemovalType','var'))
RemovalType='Channel';
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='Subset';
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

%%
EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');
Fold = 1;
% [~,~,Datastore,~] = cgg_getDatastore(cfg_Epoch.Main,SessionName,Fold,cfg_Encoder);
[~,~,Datastore,~] = cgg_getDatastore(EpochDir_Main,SessionName,Fold,cfg_Encoder);
%%

% FoldDir = [cfg_Epoch.Results filesep 'Encoding' filesep Target filesep sprintf('Fold_%d',Fold)];
FoldDir = [EpochDir_Results filesep 'Encoding' filesep Target filesep sprintf('Fold_%d',Fold)];
cfg_Network = cgg_generateEncoderSubFolders(FoldDir,ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder);
Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');

EncoderPathNameExt = [Encoding_Dir filesep 'Encoder-Optimal.mat'];
ClassifierPathNameExt = [Encoding_Dir filesep 'Classifier-Optimal.mat'];

HasEncoderClassifier = isfile(EncoderPathNameExt) && isfile(ClassifierPathNameExt);

if HasEncoderClassifier
    m_Encoder = matfile(EncoderPathNameExt,"Writable",false);
    Encoder=m_Encoder.Encoder;
    m_Classifier = matfile(ClassifierPathNameExt,"Writable",false);
    Classifier=m_Classifier.Classifier;
end

%%


LayerNameIDX = contains({Encoder.Layers(:).Name},'Input_Encoder');
InputSize = Encoder.Layers(LayerNameIDX).InputSize;
LayerNameIDX = contains({Classifier.Layers(:).Name},'Input_Classifier');
LatentSize = Classifier.Layers(LayerNameIDX).InputSize;

NumChannels = InputSize(1);
NumAreas = InputSize(3);


BadData = preview(Datastore);
BadData = squeeze(isnan(BadData{1}(:,1,:,1)));

[BadChannel,BadArea] = ind2sub(size(BadData),find(BadData));
BadChannelTable = table(BadChannel,BadArea,'VariableNames',{'ChannelIndices','AreaIndices'});

ChannelIndices = 1:NumChannels;
AreaIndices = 1:NumAreas;

ChannelTable = combinations(AreaIndices,ChannelIndices);
if ~isempty(BadChannelTable)
[~,BadChannelIndices,~] = intersect(ChannelTable,BadChannelTable);
ChannelTable(BadChannelIndices,:) = [];
end

switch RemovalType
    case 'Channel'
        MaximumRemovals = height(ChannelTable);
    case 'Latent'
        MaximumRemovals = LatentSize;
end

end

