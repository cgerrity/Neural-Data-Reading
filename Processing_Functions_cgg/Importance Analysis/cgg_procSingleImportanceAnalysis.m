function [IA_Table_Fold,IA_Table_Average] = cgg_procSingleImportanceAnalysis(cfg_Encoder,cfg_Epoch,varargin)
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
NumRemoved = CheckVararginPairs('NumRemoved', 1, varargin{:});
else
if ~(exist('NumRemoved','var'))
NumRemoved=1;
end
end

if isfunction
NumEntries = CheckVararginPairs('NumEntries', 348, varargin{:});
else
if ~(exist('NumEntries','var'))
NumEntries=348;
end
end

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 8, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=8;
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
SaveTerm = CheckVararginPairs('SaveTerm', '', varargin{:});
else
if ~(exist('SaveTerm','var'))
SaveTerm='';
end
end

if isfunction
WantRemovalTableAcrossFolds = CheckVararginPairs('WantRemovalTableAcrossFolds', false, varargin{:});
else
if ~(exist('WantRemovalTableAcrossFolds','var'))
WantRemovalTableAcrossFolds=false;
end
end

if isfunction
PauseTime_Long = CheckVararginPairs('PauseTime_Long', 60, varargin{:});
else
if ~(exist('PauseTime_Long','var'))
PauseTime_Long=60;
end
end

if isfunction
PauseTime_Short = CheckVararginPairs('PauseTime_Short', 15, varargin{:});
else
if ~(exist('PauseTime_Short','var'))
PauseTime_Short=15;
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

if ~WantDelay
PauseTime_Long = 1;
PauseTime_Short = 1;
end

%%

EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');
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

% TargetDir = [cfg_Epoch.Results filesep 'Encoding' filesep Target];
TargetDir = [EpochDir_Results filesep 'Encoding' filesep Target];
% TargetDir = cgg_getDirectory(cfg_Epoch.ResultsDir,'Target');

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
for idx = 1:randi(10)
Folds = Folds(randperm(NumFolds));
end

IA_Table_Accuracy_Cell = cell(NumFolds,1);
Fold_Cell = cell(NumFolds,1);

%%
RemovalTableSaveFunc = [];
if WantRemovalTableAcrossFolds
% RemovalTableSaveFunc = @(Table) cgg_saveRemovalTable(Table,Folds, ...
%     EpochDir.Results,RemovalType,SessionName,SaveTerm);
RemovalTableSaveFunc = @(Table) cgg_saveSameRemovalTableAcrossFolds(Table,Folds,cfg_Epoch,RemovalType,SessionName,SaveTerm);
end
%% Function for Checking if Removal Tables are the same

FixNaNFunc = @(x) cellfun(@(x) cgg_setNaNToValue(x,0),x,'UniformOutput',false);
CheckTableFunc =@(Table) varfun(FixNaNFunc,Table,"InputVariables",["AreaRemoved","ChannelRemoved","LatentRemoved"]);
AreTablesSameFunc = @(Table1,Table2) ...
    isequal(CheckTableFunc(Table1),CheckTableFunc(Table2));

%%

% ResetFunc = [];
% NeedRun = true;
% if WantRemovalTableAcrossFolds
% 
%     ResetFunc = @() cgg_resetRemovalTablesAcrossFolds(EpochDir,RemovalType, ...
%     SessionName,SaveTerm,Folds);
% % IANameExt = sprintf('IA_Table%s.mat',SaveTerm);
% % IAPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IANameExt);
% % [NewRemovalTable,TablesMatch] = cgg_checkRemovalTablesAcrossFolds(IAPathNameExt,Folds);
% % cgg_saveRemovalTable(NewRemovalTable,Folds,EpochDir.Results, ...
% %     RemovalType,SessionName,SaveTerm,'ResetAnalysis',~TablesMatch);
% % fprintf('!!! Reseting analysis due to mismatched Removal Tables\n');
% end
%%
CurrentMessage = '+++ Current Fold: %d, Number of Removals: %d\n';
%%
for fidx = 1:NumFolds
    %%%% Iterate through folds
Fold = Folds(fidx);
% disp({Fold,NumRemoved});
fprintf(CurrentMessage,Fold,NumRemoved);
IA_AccuracyNameExt = sprintf('IA_Table%s_%s.mat',SaveTerm,MatchType);
% IA_AccuracyPathNameExt = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType,sprintf('Fold %d',Fold),SessionName,IA_AccuracyNameExt);
IA_AccuracyPathNameExt = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType,sprintf('Fold %d',Fold),SessionName,IA_AccuracyNameExt);

if isfile(IA_AccuracyPathNameExt)
m_IA_Table_Accuracy = matfile(IA_AccuracyPathNameExt,"Writable",false);
IA_Table_Accuracy = m_IA_Table_Accuracy.IA_Table;
else

IANameExt = sprintf('IA_Table%s.mat',SaveTerm);
% IAPathNameExt = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType,sprintf('Fold %d',Fold),SessionName,IANameExt);
IAPathNameExt = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType,sprintf('Fold %d',Fold),SessionName,IANameExt);

[HasIA_Table,HasRemovalTable] = cgg_checkImportanceAnalysis(IAPathNameExt);
[IA_Table,RemovalTable,TablesMatch] = cgg_getImportanceAnalysis(IAPathNameExt);

if HasRemovalTable && HasIA_Table
    % This is in case there are multiple instances running and they set
    % different values to the removal table while the IA_Table has already
    % been produced
    TablesMatch = AreTablesSameFunc(RemovalTable,IA_Table);
end

% HasIA_Table = false;
% HasRemovalTable = false;
% IA_Table = [];
% RemovalTable = [];
% TablesMatch = true;
% if isfile(IAPathNameExt)
% m_IA_Table = matfile(IAPathNameExt,"Writable",false);
% HasIA_Table = any(ismember(who(m_IA_Table),'IA_Table'));
% HasRemovalTable = any(ismember(who(m_IA_Table),'RemovalTable'));
%     if HasIA_Table
%     IA_Table = m_IA_Table.IA_Table;
%     end
%     if HasRemovalTable
%     RemovalTable = m_IA_Table.RemovalTable;
%     % if ~isempty(RemovalTableSaveFunc)
%     %     RemovalTableSaveFunc(RemovalTable);
%     % end
%     end
%     if HasRemovalTable && HasIA_Table
%     % This is in case there are multiple instances running and they set
%     % different values to the removal table while the IA_Table has already
%     % been produced
%     TablesMatch = AreTablesSameFunc(RemovalTable,IA_Table);
%     end
% end

if HasIA_Table && TablesMatch
% IA_Table = m_IA_Table.IA_Table;
% [~,~,~,ClassNames] = cgg_getDatastore(cfg_Epoch.Main,SessionName,Fold,cfg_Encoder);
[~,~,~,ClassNames] = cgg_getDatastore(EpochDir_Main,SessionName,Fold,cfg_Encoder);
if ~HasRemovalTable
    % cgg_saveImportanceAnalysis(IA_Table,cfg_Epoch.Results,...
    % RemovalType,Fold,SessionName);
    cgg_saveImportanceAnalysis(IA_Table,EpochDir_Results,...
    RemovalType,Fold,SessionName);
end
else

% [~,~,Testing,ClassNames] = cgg_getDatastore(cfg_Epoch.Main,SessionName,Fold,cfg_Encoder);
[~,~,Testing,ClassNames] = cgg_getDatastore(EpochDir_Main,SessionName,Fold,cfg_Encoder);
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

% while NeedRun
    
[IA_Table,StopChecking] = cgg_procImportanceAnalysisFromNetwork(Testing,...
    Encoder,Classifier,ClassNames,'NumEntries',NumEntries,...
    'NumRemoved',NumRemoved,...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize,...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'RemovalTable',RemovalTable, ...
    'RemovalTableSaveFunc',RemovalTableSaveFunc, ...
    'IAPathNameExt',IAPathNameExt);

%%

if ~istable(IA_Table)
    IA_Table_Fold = NaN;
    IA_Table_Average = NaN;
return
end

pause(randi(PauseTime_Long)-1);

if ~StopChecking
% cgg_saveImportanceAnalysis(IA_Table,cfg_Epoch.Results,...
%     RemovalType,Fold,SessionName,'SaveTerm',SaveTerm);
cgg_saveImportanceAnalysis(IA_Table,EpochDir_Results,...
    RemovalType,Fold,SessionName,'SaveTerm',SaveTerm);
end

% if WantRemovalTableAcrossFolds
%     NeedRun = ~ResetFunc();
% else
%     NeedRun = false;
% end
% end

end

[IA_Table_Accuracy] = cgg_procImportanceAnalysisMetric(IA_Table,ClassNames,'IsQuaddle',IsQuaddle,'MatchType',MatchType);

pause(randi(PauseTime_Short)-1);

% cgg_saveImportanceAnalysis(IA_Table_Accuracy,cfg_Epoch.Results,...
%     RemovalType,Fold,SessionName,'MatchType',MatchType, ...
%     'SaveTerm',SaveTerm);
cgg_saveImportanceAnalysis(IA_Table_Accuracy,EpochDir_Results,...
    RemovalType,Fold,SessionName,'MatchType',MatchType, ...
    'SaveTerm',SaveTerm);
end

%%

IA_Table_Accuracy = cgg_calcImportanceAnalysis(IA_Table_Accuracy, ...
    'BaselineArea',BaselineArea,'BaselineChannel',BaselineChannel, ...
    'BaselineLatent',BaselineLatent,'MatchType',MatchType);

IA_Table_Accuracy_Cell{Fold} = IA_Table_Accuracy;
Fold_Cell{Fold} = Fold;


end
%%

Accuracy_Cell = cellfun(@(x) x.Accuracy,IA_Table_Accuracy_Cell, ...
    'UniformOutput',false);
WindowAccuracy_Cell = cellfun(@(x) x.WindowAccuracy,IA_Table_Accuracy_Cell, ...
    'UniformOutput',false);
Accuracy = mean(cat(3,Accuracy_Cell{:}),3);
WindowAccuracy = mean(cat(3,WindowAccuracy_Cell{:}),3);

IA_Table_Average = IA_Table_Accuracy_Cell{1}(:,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);
IA_Table_Average.Accuracy = Accuracy;
IA_Table_Average.WindowAccuracy = WindowAccuracy;

IA_Table_Average = cgg_calcImportanceAnalysis(IA_Table_Average, ...
    'BaselineArea',BaselineArea,'BaselineChannel',BaselineChannel, ...
    'BaselineLatent',BaselineLatent,'MatchType',MatchType);

IA_Table_Fold = table(IA_Table_Accuracy_Cell,Fold_Cell,'VariableNames',...
    {'IA_Table_Metric','Fold'});

end

