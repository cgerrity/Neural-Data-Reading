function RemovalPlotTable = cgg_procFullImportanceAnalysis_v2(cfg_Encoder,cfg_Epoch,cfg,varargin)
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
MatchType_Attention = CheckVararginPairs('MatchType_Attention', 'Scaled-MicroAccuracy', varargin{:});
else
if ~(exist('MatchType_Attention','var'))
MatchType_Attention='Scaled-MicroAccuracy';
end
end

% if isfunction
% NumRemoved = CheckVararginPairs('NumRemoved', 500, varargin{:});
% else
% if ~(exist('NumRemoved','var'))
% NumRemoved=500;
% end
% end

% if isfunction
% NumRemovedChannel = CheckVararginPairs('NumRemovedChannel', 348, varargin{:});
% else
% if ~(exist('NumRemovedChannel','var'))
% NumRemovedChannel=348;
% end
% end

% if isfunction
% NumEntries = CheckVararginPairs('NumEntries', 500, varargin{:});
% else
% if ~(exist('NumEntries','var'))
% NumEntries=500;
% end
% end

% if isfunction
% maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 32, varargin{:});
% else
% if ~(exist('maxworkerMiniBatchSize','var'))
% maxworkerMiniBatchSize=32;
% end
% end

% if isfunction
% DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
% else
% if ~(exist('DataFormat','var'))
% DataFormat={'SSCTB','CBT',''};
% end
% end

% if isfunction
% IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
% else
% if ~(exist('IsQuaddle','var'))
% IsQuaddle=true;
% end
% end

if isfunction
RemovalType = CheckVararginPairs('RemovalType', 'Channel', varargin{:});
else
if ~(exist('RemovalType','var'))
RemovalType='Channel';
end
end

% if isfunction
% BaselineArea = CheckVararginPairs('BaselineArea', NaN, varargin{:});
% else
% if ~(exist('BaselineArea','var'))
% BaselineArea=NaN;
% end
% end

% if isfunction
% BaselineChannel = CheckVararginPairs('BaselineChannel', NaN, varargin{:});
% else
% if ~(exist('BaselineChannel','var'))
% BaselineChannel=NaN;
% end
% end

% if isfunction
% BaselineLatent = CheckVararginPairs('BaselineLatent', NaN, varargin{:});
% else
% if ~(exist('BaselineLatent','var'))
% BaselineLatent=NaN;
% end
% end

% if isfunction
% SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
% else
% if ~(exist('SessionName','var'))
% SessionName='Subset';
% end
% end

% if isfunction
% WantDelay = CheckVararginPairs('WantDelay', true, varargin{:});
% else
% if ~(exist('WantDelay','var'))
% WantDelay=true;
% end
% end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

% if isfunction
% TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
% else
% if ~(exist('TargetFilter','var'))
% TargetFilter='Overall';
% end
% end

if isfunction
TargetFilters = CheckVararginPairs('TargetFilters', ["Overall","TargetFeature","DistractorCorrect","DistractorError"], varargin{:});
else
if ~(exist('TargetFilters','var'))
TargetFilters=["Overall","TargetFeature","DistractorCorrect","DistractorError"];
end
end

if isfunction
Alpha = CheckVararginPairs('Alpha', 0.05, varargin{:});
else
if ~(exist('Alpha','var'))
Alpha=0.05;
end
end

% if isfunction
% TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', NaN, varargin{:});
% else
% if ~(exist('TrialFilter_Value','var'))
% TrialFilter_Value=NaN;
% end
% end

if isfunction
RemovalTypes = CheckVararginPairs('RemovalTypes', "Channel", varargin{:});
else
if ~(exist('RemovalTypes','var'))
RemovalTypes="Channel";
end
end

if isfunction
TimeRange = CheckVararginPairs('TimeRange', [-Inf,Inf], varargin{:});
else
if ~(exist('TimeRange','var'))
TimeRange=[-Inf,Inf];
end
end

if isfunction
Methods = CheckVararginPairs('Methods', "Block", varargin{:});
else
if ~(exist('Methods','var'))
Methods="Block";
end
end

%%
rng('shuffle');
%%
Target = cfg_Encoder.Target;
% HiddenSize=cfg_Encoder.HiddenSizes;
% InitialLearningRate=cfg_Encoder.InitialLearningRate;
% ModelName = cfg_Encoder.ModelName;
% ClassifierName = cfg_Encoder.ClassifierName;
% ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
% MiniBatchSize = cfg_Encoder.MiniBatchSize;
% NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
% WeightReconstruction = cfg_Encoder.WeightReconstruction;
% WeightKL = cfg_Encoder.WeightKL;
% WeightClassification = cfg_Encoder.WeightClassification;
% WeightedLoss = cfg_Encoder.WeightedLoss;
% GradientThreshold = cfg_Encoder.GradientThreshold;
% Optimizer = cfg_Encoder.Optimizer;
% Normalization = cfg_Encoder.Normalization;
% LossType_Decoder = cfg_Encoder.LossType_Decoder;
% 
% STDChannelOffset = cfg_Encoder.STDChannelOffset;
% STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
% STDRandomWalk = cfg_Encoder.STDRandomWalk;
% 
% wantSubset = cfg_Encoder.wantSubset;
% DataWidth = cfg_Encoder.DataWidth;
% WindowStride = cfg_Encoder.WindowStride;

% EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');

% TargetDir = [EpochDir_Results filesep 'Encoding' filesep Target];
EncodingTargetDir = fullfile(EpochDir_Results,'Encoding',Target);

% cfg_Network = cgg_generateEncoderSubFolders([TargetDir filesep 'Fold_1'],ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder);
% cfg_Network = cgg_generateEncoderSubFolders_v2([],cfg_Encoder,'WantDirectory',false);
% EncodingParametersPath = cgg_getDirectory(cfg_Network,'Classifier');
% EncodingParametersPath = extractAfter(EncodingParametersPath,'Fold_1/');

% EncodingParametersPathNameExt = [EncodingParametersPath filesep 'EncodingParameters.yaml'];
% EncodingParametersPathNameExt = fullfile(EncodingParametersPath, 'EncodingParameters.yaml');
%%
% EncoderParameters = cgg_procDirectorySearchAndApply(EncodingTargetDir, EncodingParametersPathNameExt, @cgg_getAllEncoderParametersTable,'IsSingleLevel',true);
% Folds = EncoderParameters.Fold;
% Folds = Folds{1};
% NumFolds = length(Folds);

%%
fprintf('*** Obtaining All Sessions and their associated parameters\n');
cfg_Encoder_tmp = cfg_Encoder;
cfg_Encoder_tmp.Subset = '%s';
cfg_Network = cgg_generateEncoderSubFolders_v2('',cfg_Encoder_tmp,'WantDirectory',false);
OptimalPath = cgg_getDirectory(cfg_Network,'Classifier');

OptimalPathNameExt = fullfile(sprintf(OptimalPath,'*'),'EncodingParameters.yaml');

EncoderParametersFunc = @(x,y) cgg_getAllEncoderCMTable(x,y,...
    'WantFinished',false,'WantValidation',false);
EncoderParameters_CM_Table = cgg_procDirectorySearchAndApply(EncodingTargetDir, ...
    OptimalPathNameExt, EncoderParametersFunc,'IsSingleLevel',true);

EncoderParameters_CM_Table(...
    strcmp(EncoderParameters_CM_Table.Subset,'true'),:) = [];

EncoderParameters_CM_Table = EncoderParameters_CM_Table(randperm(height(EncoderParameters_CM_Table)),:);

% %%
% TargetFilters = string(TargetFilters);
% if ~any(strcmp(TargetFilters,'Overall'))
% TargetFilters = ["Overall","TargetFeature","DistractorCorrect","DistractorError"];
% end
% NumTargetFilters = length(TargetFilters);
% 
% Identifiers_Table = cgg_getIdentifiersTable(cfg_Epoch,false);
% if all(~strcmp(TrialFilter,'All') & ~strcmp(TrialFilter,'Target Feature'))
% 
%     TypeValueFunc.Default = @(x,y) unique(x,'rows');
%     TypeValueFunc.Double = @(x,y) unique(x);
%     TypeValueFunc.Cell = @(x,y) unique([x{:}]);
%     TypeValueFunc.CellCombine = @(x,y) combinations(x{:});
%     TypeValues = cgg_procFilterIdentifiersTable(Identifiers_Table,TrialFilter,[],TypeValueFunc);
% TypeValues = TypeValues{:,:};
% [NumTypes,~]=size(TypeValues);
% else
% TypeValues=NaN;
% [NumTypes,~]=size(TypeValues);
% if strcmp(TrialFilter,'Target Feature')
% TypeValues=0;
% NumTypes=1;
% end
% end
% 
% %%
% fprintf('*** Constructing Importance Analysis Pass Table\n');
% 
% IA_PassTable = cell(NumTypes*NumTargetFilters,1);
% CombinationCounter = 0;
% for aidx = 1:NumTargetFilters
%     TargetFilter = TargetFilters(aidx);
%     if strcmp(TargetFilter,"Overall")
%         this_MatchType = MatchType;
%     else
%         this_MatchType = MatchType_Attention;
%     end
% for tidx = 1:NumTypes
%     TrialFilter_Value = TypeValues(tidx,:);
% IA_PassTable_Func = @(x,y) cgg_getPassTable(x{1},cfg_Epoch,...
%     'SessionName',y,'MatchType',this_MatchType,'TrialFilter',TrialFilter,...
%     'TrialFilter_Value',TrialFilter_Value,'TargetFilter',TargetFilter,...
%     'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange);
% 
% this_IA_PassTable = rowfun(IA_PassTable_Func,EncoderParameters_CM_Table,"InputVariables",["Fold","Subset"],"SeparateInputs",true,"ExtractCellContents",false,"NumOutputs",1,"OutputFormat","cell");
% this_IA_PassTable = vertcat(this_IA_PassTable{:});
% CombinationCounter = CombinationCounter +1;
% IA_PassTable{CombinationCounter} = this_IA_PassTable;
% end
% end
% IA_PassTable = vertcat(IA_PassTable{:});
%%

fprintf('*** Constructing Importance Analysis Pass Table\n');
IA_PassTable_Session_Func = @(x,y) cgg_getOverallPassTable(...
    x, y,cfg_Epoch,'MatchType',MatchType,...
    'MatchType_Attention',MatchType_Attention,...
    'TrialFilter',TrialFilter,'TargetFilters',TargetFilters,...
    'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
    'Methods',Methods);

% IA_PassTable = rowfun(IA_PassTable_Session_Func,EncoderParameters_CM_Table,"InputVariables",["Fold","Subset"],"SeparateInputs",true,"ExtractCellContents",true,"NumOutputs",1,"OutputFormat","cell");
% IA_PassTable = vertcat(IA_PassTable{:});

IA_PassTable_Cell_Func = @() rowfun(IA_PassTable_Session_Func,EncoderParameters_CM_Table,"InputVariables",["Fold","Subset"],"SeparateInputs",true,"ExtractCellContents",true,"NumOutputs",1,"OutputFormat","cell");
Cat_Func = @(x) vertcat(x{:});
IA_PassTable_Func = @() Cat_Func(IA_PassTable_Cell_Func());
IA_PassTable = IA_PassTable_Func();

%%
% IA_PassTable = cgg_getOverallPassTable(Folds,cfg_Epoch,'SessionName',SessionName,'MatchType',MatchType);
fprintf('*** Getting Null Threshold for Signigicance Level: %.3f\n',Alpha);
ThresholdTable = cgg_getNullThreshold(IA_PassTable,cfg_Epoch,cfg_Encoder,'SetType','Testing','Alpha',Alpha,'EncoderParameters_CM_Table',EncoderParameters_CM_Table);
IA_PassTable{:, "TrialFilter_Value"} = fillmissing(IA_PassTable{:, "TrialFilter_Value"}, 'constant', Inf);
IA_PassTable = join(IA_PassTable,ThresholdTable);

%%
RepeatPass = true;

fprintf('*** Running Importance Analysis Passes\n');
while RepeatPass
IA_PassTable = IA_PassTable(randperm(size(IA_PassTable,1)),:);

NumPasses = height(IA_PassTable);
for pidx = 1:NumPasses
    fprintf('*** Running Importance Analysis Passes: Pass %d of %d\n',pidx,NumPasses);
    cgg_runImportanceAnalysis(IA_PassTable(pidx,:),cfg_Epoch,cfg_Encoder,varargin)
% Insert run of Importance Analysis
end

% IA_PassTable = rowfun(IA_PassTable_Session_Func,EncoderParameters_CM_Table,"InputVariables",["Fold","Subset"],"SeparateInputs",true,"ExtractCellContents",false,"NumOutputs",1,"OutputFormat","cell");
% IA_PassTable = vertcat(IA_PassTable{:});
IA_PassTable = IA_PassTable_Func();
% IA_PassTable = cgg_getOverallPassTable(Folds,cfg_Epoch,'SessionName',SessionName);
IA_PassTable{:, "TrialFilter_Value"} = fillmissing(IA_PassTable{:, "TrialFilter_Value"}, 'constant', Inf);
IA_PassTable = join(IA_PassTable,ThresholdTable);

RepeatPass = ~all(IA_PassTable.IsComplete & ~IA_PassTable.HasFlag);
end

%%
RemovalPlotTable = [];
end

