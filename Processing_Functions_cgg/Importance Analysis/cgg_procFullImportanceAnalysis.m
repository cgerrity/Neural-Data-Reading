function RemovalPlotTable = cgg_procFullImportanceAnalysis(cfg_Encoder,EpochDir,cfg,varargin)
%CGG_PROCFULLIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
NumRemoved = CheckVararginPairs('NumRemoved', 500, varargin{:});
else
if ~(exist('NumRemoved','var'))
NumRemoved=500;
end
end

if isfunction
NumRemovedChannel = CheckVararginPairs('NumRemovedChannel', 348, varargin{:});
else
if ~(exist('NumRemovedChannel','var'))
NumRemovedChannel=348;
end
end

if isfunction
NumEntries = CheckVararginPairs('NumEntries', 500, varargin{:});
else
if ~(exist('NumEntries','var'))
NumEntries=500;
end
end

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 32, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=32;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
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
RemovalType = CheckVararginPairs('RemovalType', 'Channel', varargin{:});
else
if ~(exist('RemovalType','var'))
RemovalType='Channel';
end
end

if isfunction
BaselineArea = CheckVararginPairs('BaselineArea', NaN, varargin{:});
else
if ~(exist('BaselineArea','var'))
BaselineArea=NaN;
end
end

if isfunction
BaselineChannel = CheckVararginPairs('BaselineChannel', NaN, varargin{:});
else
if ~(exist('BaselineChannel','var'))
BaselineChannel=NaN;
end
end

if isfunction
BaselineLatent = CheckVararginPairs('BaselineLatent', NaN, varargin{:});
else
if ~(exist('BaselineLatent','var'))
BaselineLatent=NaN;
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='Subset';
end
end

if isfunction
WantDelay = CheckVararginPairs('WantDelay', true, varargin{:});
else
if ~(exist('WantDelay','var'))
WantDelay=true;
end
end

%%

rng('shuffle');
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
% NumFolds = length(Folds);

%%

MessagePart1 = '+++ Single Removal Channel\n';
MessagePart2 = '+++ Selection Channel\n';
MessagePart3 = '+++ Random Channel\n';
MessagePart4 = '+++ Sequential Channel\n';
MessagePart5 = '+++ Single Removal Latent\n';
MessagePart6 = '+++ Selection Latent\n';
MessagePart7 = '+++ Random Latent\n';
MessagePart8 = '+++ Sequential Latent\n';

%%

% TableVariables = [["Name", "string"]; ...
%     ["Removal Type", "string"]; ...
%     ["Units Removed", "double"]; ...
%     ["Accuracy", "double"]; ...
%     ["Error STE", "double"]; ...
%     ["Error CI", "double"]];
% 
% NumVariables = size(TableVariables,1);
% RemovalPlotTable = table('Size',[0,NumVariables],... 
% 	    'VariableNames', TableVariables(:,1),...
% 	    'VariableTypes', TableVariables(:,2));

%% Part 1: Single Channel Removal
fprintf(MessagePart1);
[~,IA_Table_Average] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',1, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType','Channel','BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'WantDelay',WantDelay);

%%
SaveTerm = '_Selection';
IANameExt = sprintf('IA_Table%s.mat',SaveTerm);
AnalysisDir = fullfile(EpochDir.Results,'Analysis','Importance Analysis','Channel');
funcHandle =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,2,2)]);
HasRemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IANameExt, funcHandle);
if isempty(HasRemovalTable)
HasRemovalTable = false;
end

if ~HasRemovalTable
IA_Table_Average = sortrows(IA_Table_Average,"RankPeak","ascend");
RemovalTable = cgg_getRemovalTableFromRanking(IA_Table_Average, ...
    'BaselineArea',BaselineArea,'BaselineChannel',BaselineChannel, ...
    'BaselineLatent',BaselineLatent);

cgg_saveRemovalTable(RemovalTable,Folds,EpochDir.Results,'Channel',SessionName,SaveTerm);

end
%% Part 2: Select Channel Removal
fprintf(MessagePart2);
[IA_Table_Fold_Part2,~] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',1, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType','Channel','BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm','_Selection','WantDelay',WantDelay);

RemovalPlotTable = cgg_getRemovalPlotTable([],IA_Table_Fold_Part2,'Rank','Channel',cfg);

%% Part 3: Random Channel Removal
fprintf(MessagePart3);
[IA_Table_Fold_Part3,~] = cgg_procRandomImportanceAnalysis(cfg_Encoder,EpochDir,'MatchType',MatchType, ...
    'NumRemoved',NumRemovedChannel, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType','Channel','BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'WantRemovalTableAcrossFolds',true,'SessionName',SessionName, ...
    'Folds',Folds,'WantDelay',WantDelay);

RemovalPlotTable = cgg_getRemovalPlotTable(RemovalPlotTable,IA_Table_Fold_Part3,'Random','Channel',cfg);

%% Part 4: Sequential Channel Removal
fprintf(MessagePart4);
[IA_Table_Fold_Part4,~] = cgg_procSequentialImportanceAnalysis(cfg_Encoder,EpochDir,'MatchType',MatchType, ...
    'NumRemoved',NumRemovedChannel, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType','Channel','BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'WantRemovalTableAcrossFolds',true,'SessionName',SessionName, ...
    'Folds',Folds,'WantDelay',WantDelay);

RemovalPlotTable = cgg_getRemovalPlotTable(RemovalPlotTable,IA_Table_Fold_Part4,'Sequential','Channel',cfg);

% %% Part 5: Single Latent Removal
% fprintf(MessagePart5);
% [IA_Table_Fold,~] = cgg_procSingleImportanceAnalysis(...
%     cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',1, ...
%     'NumEntries',NumEntries, ...
%     'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
%     'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
%     'RemovalType','Latent','BaselineArea',BaselineArea, ...
%     'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
%     'WantDelay',WantDelay);
% 
% %%
% 
% NumFolds = height(IA_Table_Fold);
% 
% LatentFolds = NaN(NumFolds,1);
% LatentRemovalTable = cell(NumFolds,1);
% 
% for fidx = 1:NumFolds
% this_IA_Table_Fold = IA_Table_Fold(fidx,:);
% this_IA_Table = this_IA_Table_Fold.IA_Table_Metric;
% this_Fold = this_IA_Table_Fold.Fold;
% this_IA_Table = sortrows(this_IA_Table,"RankPeak","ascend");
% RemovalTable = cgg_getRemovalTableFromRanking(this_IA_Table, ...
%     'BaselineArea',BaselineArea,'BaselineChannel',BaselineChannel, ...
%     'BaselineLatent',BaselineLatent);
% 
% LatentFolds(fidx) = this_Fold;
% LatentRemovalTable{fidx} = RemovalTable;
% end
% 
% SaveTerm = '_Selection';
% 
% cgg_saveRemovalTable(LatentRemovalTable,LatentFolds,EpochDir.Results,'Latent',SessionName,SaveTerm);
% %% Part 6: Select Latent Removal
% fprintf(MessagePart6);
% [IA_Table_Fold_Part6,~] = cgg_procSingleImportanceAnalysis(...
%     cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',1, ...
%     'NumEntries',NumEntries, ...
%     'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
%     'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
%     'RemovalType','Latent','BaselineArea',BaselineArea, ...
%     'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
%     'SaveTerm','_Selection','WantDelay',WantDelay);
% 
% RemovalPlotTable = cgg_getRemovalPlotTable(RemovalPlotTable,IA_Table_Fold_Part6,'Rank','Latent',cfg);
% 
% %% Part 7: Random Latent Removal
% fprintf(MessagePart7);
% [IA_Table_Fold_Part7,~] = cgg_procRandomImportanceAnalysis(cfg_Encoder,EpochDir,'MatchType',MatchType, ...
%     'NumRemoved',NumRemoved, ...
%     'NumEntries',NumEntries, ...
%     'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
%     'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
%     'RemovalType','Latent','BaselineArea',BaselineArea, ...
%     'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
%     'WantRemovalTableAcrossFolds',false,'SessionName',SessionName, ...
%     'Folds',Folds,'WantDelay',WantDelay);
% 
% RemovalPlotTable = cgg_getRemovalPlotTable(RemovalPlotTable,IA_Table_Fold_Part7,'Random','Latent',cfg);
% 
% %% Part 8: Sequential Latent Removal
% fprintf(MessagePart8);
% [IA_Table_Fold_Part8,~] = cgg_procSequentialImportanceAnalysis(cfg_Encoder,EpochDir,'MatchType',MatchType, ...
%     'NumRemoved',NumRemoved, ...
%     'NumEntries',NumEntries, ...
%     'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
%     'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
%     'RemovalType','Latent','BaselineArea',BaselineArea, ...
%     'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
%     'WantRemovalTableAcrossFolds',false,'SessionName',SessionName, ...
%     'Folds',Folds,'WantDelay',WantDelay);
% 
% RemovalPlotTable = cgg_getRemovalPlotTable(RemovalPlotTable,IA_Table_Fold_Part8,'Sequential','Latent',cfg);
% 

end

