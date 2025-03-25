function [FullTable,Outcfg] = cgg_getResultsPlotsParametersNetwork(EpochName,varargin)
%CGG_GETRESULTSPLOTSPARAMETERSNETWORK Summary of this function goes here
%   Detailed explanation goes here

%% Parameters
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;
cfg_Encoder = PARAMETERS_OPTIMAL_cgg_runAutoEncoder;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

%%

isfunction=exist('varargin','var');

if isfunction
wantSubset = CheckVararginPairs('wantSubset', cfg_Encoder.wantSubset, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=cfg_Encoder.wantSubset;
end
end

if isfunction
WantAnalysis = CheckVararginPairs('WantAnalysis', true, varargin{:});
else
if ~(exist('WantAnalysis','var'))
WantAnalysis=true;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
DataWidth = CheckVararginPairs('DataWidth', cfg_Encoder.DataWidth, varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth=cfg_Encoder.DataWidth;
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', cfg_Encoder.WindowStride, varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride=cfg_Encoder.WindowStride;
end
end

if isfunction
FilterColumn = CheckVararginPairs('FilterColumn', 'All', varargin{:});
else
if ~(exist('FilterColumn','var'))
FilterColumn='All';
end
end

if isfunction
IsBest = CheckVararginPairs('IsBest', true, varargin{:});
else
if ~(exist('IsBest','var'))
IsBest=true;
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
Split_TableRowNames = CheckVararginPairs('Split_TableRowNames', [], varargin{:});
else
if ~(exist('Split_TableRowNames','var'))
Split_TableRowNames=[];
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
HasSplit_TableRowNames = ~isempty(Split_TableRowNames);
%%
Epoch = cgg_getEpochNameFromString(EpochName);

HiddenSize=cfg_Encoder.HiddenSizes;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName = cfg_Encoder.ModelName;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
MiniBatchSize = cfg_Encoder.MiniBatchSize;
% LossFactorReconstruction = cfg_Encoder.LossFactorReconstruction;
% LossFactorKL = cfg_Encoder.LossFactorKL;
WeightedLoss = cfg_Encoder.WeightedLoss;
GradientThreshold = cfg_Encoder.GradientThreshold;
Optimizer = cfg_Encoder.Optimizer;
WeightReconstruction = cfg_Encoder.WeightReconstruction;
WeightKL = cfg_Encoder.WeightKL;
WeightClassification = cfg_Encoder.WeightClassification;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
Normalization = cfg_Encoder.Normalization;
LossType_Decoder = cfg_Encoder.LossType_Decoder;

STDChannelOffset = cfg_Encoder.STDChannelOffset;
STDWhiteNoise = cfg_Encoder.STDWhiteNoise;
STDRandomWalk = cfg_Encoder.STDRandomWalk;

%% Loop Values

[LoopType,NumLoops,LoopNames,LoopTitle] = cgg_getResultsParametersLoopValues('EpochName',EpochName,'wantSubset',wantSubset,'DataWidth',DataWidth,'WindowStride',WindowStride,'MatchType',MatchType,'IsBest',IsBest);

%% Parameters
% cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
% cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;
cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

%%

NumFolds = cfg_Decoder.NumFolds;

SamplingFrequency = cfg_Decoder.SamplingFrequency;

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Sessions(1).temporarydir;

%%
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',EpochName,'PlotFolder', 'Plot Data', 'PlotSubFolder', 'Network Results','Encoding',true,'Target',cfg_Encoder.Target);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',EpochName,'PlotFolder', 'Plot Data', 'PlotSubFolder', 'Network Results','Encoding',true,'Target',cfg_Encoder.Target);
cfg.ResultsDir=cfg_tmp.TargetDir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Encoding',true,'Target',cfg_Encoder.Target,'Fold',Fold,'Data_Normalized',Data_Normalized);
% cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch,'Encoding',true,'Target',cfg_Encoder.Target,'Fold',Fold,'Data_Normalized',Data_Normalized);
% cfg.ResultsDir=cfg_Results.TargetDir;
VarargIN = []; 
if isfunction
if ~isempty(varargin)
VarargIN = varargin{:};
end
end

% %%
% RunTable = [];
% BestRunTable = [];
% CurrentCases = {'ClassifierHiddenSize','ClassifierName','DataWidth', ...
%     'HiddenSizes','InitialLearningRate','IsVariational','L2Factor', ...
%     'MiniBatchSize','ModelName','Normalization','NumEpochsAutoEncoder', ...
%     'Optimizer','WantNormalization','WeightedLoss','WindowStride', ...
%     'maxworkerMiniBatchSize','Weights','BottleNeckDepth','Dropout', ...
%     'GradientThreshold'};
% 
% %%
% LabelAngle = 45;
% WantFinished = false;
% %%
% for cidx = 1:length(CurrentCases)
% SweepType = CurrentCases{cidx};
% disp(SweepType);
% 
% [SweepName,SweepNameIgnore] = PARAMETERS_cggEncoderParameterSweep(SweepType);
% 
% [SweepAccuracy,SweepWindowAccuracy,SweepAllNames,RunTable,BestRunTable] = ...
%     cgg_procParameterSweepTable(SweepName,SweepNameIgnore,...
%     cfg,'MatchType',MatchType,'IsQuaddle',IsQuaddle, ...
%     'RunTable',RunTable,'BestRunTable',BestRunTable, ...
%     'WantFinished',WantFinished);
% 
% cgg_plotBarGraphWithError(SweepAccuracy,SweepAllNames,'PlotTitle',SweepType,'LabelAngle',LabelAngle);
% end
%%

FullTablePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.path;
SplitExtraSaveTerm = cgg_generateExtraSaveTerm('FilterColumn',FilterColumn);
FullTableNameExt=[sprintf('Full_Table_%s',LoopType) SplitExtraSaveTerm '.mat'];
% FullTableNameExt='Full_Table.mat';

FullTableSavePathNameExt=[FullTablePath filesep FullTableNameExt];

FullTableSaveVariablesName=cell(2,1);
FullTableSaveVariablesName{1}='FullTable';
FullTableSaveVariablesName{2}='Outcfg';

wantFullTable=false;

if isfile(FullTableSavePathNameExt)
m_FullTable=matfile(FullTableSavePathNameExt,"Writable",false);
if any(strcmp(fields(m_FullTable),FullTableSaveVariablesName{1})) && ...
        any(strcmp(fields(m_FullTable),FullTableSaveVariablesName{2}))
FullTable=m_FullTable.FullTable;
Outcfg=m_FullTable.Outcfg;

Outcfg.TargetDir = cfg.TargetDir.path;
Outcfg.ResultsDir = cfg.ResultsDir.path;

end
else
    wantFullTable=true;
end

%%

if wantFullTable
%%

ExtraSaveTerm = cgg_generateExtraSaveTerm('wantSubset',wantSubset);
cfg_partition = cgg_generatePartitionVariableSaveName(cfg,'ExtraSaveTerm',ExtraSaveTerm);
Partition_PathNameExt = cfg_partition.Partition;

%% Identifiers Table

SavePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.path;
SaveNameExt=sprintf('Identifiers_Table%s.mat',cgg_generateExtraSaveTerm('wantSubset',wantSubset));

SavePathNameExt=[SavePath filesep SaveNameExt];

if isfile(SavePathNameExt)
m_Identifiers_Table=matfile(SavePathNameExt,"Writable",false);
if ~isempty(who(m_Identifiers_Table,'Identifiers_Table'))
Identifiers_Table=m_Identifiers_Table.Identifiers_Table;
end
else
    Identifiers_Table=[];
end

if isempty(Identifiers_Table)

Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset);

SaveVariables={Identifiers_Table};
SaveVariablesName={'Identifiers_Table'};

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

end
%%

Overall_Encoding_Dir = cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Encoding.Target.path;
%% Split

if all(~strcmp(FilterColumn,'All') & ~strcmp(FilterColumn,'Target Feature'))
DistributionVariable=Identifiers_Table{:,FilterColumn};
TypeValues=unique(DistributionVariable,'rows');
[NumTypes,NumColumns]=size(TypeValues);
else
TypeValues=0;
% NumTypes=1;
[NumTypes,NumColumns]=size(TypeValues);
if strcmp(FilterColumn,'Target Feature')
TypeValues=0;
NumTypes=1;
end
end

% %% CM Table
% 
% CMTableSavePathNameExt = [Encoding_Dir filesep 'CM_Table.mat'];
% 
% m_Identifiers_Table=matfile(SavePathNameExt,"Writable",false);
% 
% CM_Table = m_Accuracy.CM_Table;

%% Target Values

TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
TrueValue=Identifiers_Table{:,TrueValueIDX};
[NumTrials,NumDimension]=size(TrueValue);
ClassNames=cell(1,NumDimension);
for fdidx=1:NumDimension
this_ClassNames=unique(TrueValue(:,fdidx));
ClassNames{fdidx}=unique(this_ClassNames);
end

%% Attentional Filtering Components
TargetDimension = Identifiers_Table{:,"Target Feature"};
FeatureMatrix = TrueValue;
TargetDimensionIDX = sub2ind(size(FeatureMatrix), (1:size(FeatureMatrix,1))', TargetDimension);

ActiveDimensionsTable = varfun(@(x1){unique(x1)},Identifiers_Table,"InputVariables","Target Feature","GroupingVariables","Session Name");
TMP_Table = innerjoin(Identifiers_Table, ActiveDimensionsTable, 'Keys', 'Session Name');
ActiveDimensionTMP = TMP_Table.("Fun_Target Feature");
Identifiers_Table.("Active Dimensions") = ActiveDimensionTMP;

InactiveMatrix = cellfun(@(x) ~ismember(1:NumDimension, x), Identifiers_Table.("Active Dimensions"), 'UniformOutput', false);
InactiveMatrix = double(cell2mat(InactiveMatrix));

DistractorMatrix = FeatureMatrix ~=0;
DistractorMatrix(TargetDimensionIDX) = 0;
NeutralMatrix = FeatureMatrix == 0 - InactiveMatrix;

TargetWeights = zeros(size(FeatureMatrix));
TargetWeights(TargetDimensionIDX) = 1;

DistractorWeights = DistractorMatrix./sum(DistractorMatrix,2);
DistractorWeights(isnan(DistractorWeights)) = 0;

NeutralWeights = NeutralMatrix./sum(NeutralMatrix,2);
NeutralWeights(isnan(NeutralWeights)) = 0;

InactiveWeights = double(InactiveMatrix);

AttentionalFiltering = struct();
AttentionalFiltering.Overall = ones(size(TargetWeights));
AttentionalFiltering.Target = TargetWeights;
AttentionalFiltering.Distractor = DistractorWeights;
AttentionalFiltering.Neutral = NeutralWeights;
AttentionalFiltering.Inactive = InactiveWeights;

Identifiers_Table.Overall = ones(size(TargetWeights));
Identifiers_Table.Target = TargetWeights;
Identifiers_Table.Distractor = DistractorWeights;
Identifiers_Table.Neutral = NeutralWeights;
Identifiers_Table.Inactive = InactiveWeights;

%% Get Baseline Measures

IsScaled = contains(MatchType,'Scaled');
MatchTypeBaseline = extractAfter(MatchType,'Scaled-');

[MostCommon_Baseline,RandomChance_Baseline,Stratified_Baseline] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchTypeBaseline,IsQuaddle);

if IsScaled
ChanceLevel = max([MostCommon_Baseline,RandomChance_Baseline,Stratified_Baseline]);
MostCommon = (MostCommon_Baseline-ChanceLevel)/(1-ChanceLevel);
RandomChance = (RandomChance_Baseline-ChanceLevel)/(1-ChanceLevel);
Stratified = (Stratified_Baseline-ChanceLevel)/(1-ChanceLevel);
end

%% Get Baseline Measure for Attentional Filtering

BaselineFun = @(x) cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchTypeBaseline,IsQuaddle,'Weights',x);

[MostCommonAttentional_Baseline,RandomChanceAttentional_Baseline,...
    StratifiedAttentional_Baseline] = ...
    structfun(BaselineFun, AttentionalFiltering,"UniformOutput",false);
MostCommonAttentional_Baseline = StratifiedAttentional_Baseline;
RandomChanceAttentional_Baseline = StratifiedAttentional_Baseline;

AttentionalNames = fieldnames(AttentionalFiltering);
NumAttention = length(AttentionalNames);

%%

Accuracy_All=cell(NumLoops,1);
Window_Accuracy_All=cell(NumLoops,1);
CM_Table_All=cell(NumLoops,1);
Split_Table_All=cell(NumLoops,1);
% Split_Accuracy_All=cell(NumLoops,1);
% Split_Window_Accuracy_All=cell(NumLoops,1);

Accuracy_All_Attention=cell(NumAttention,1);
Window_Accuracy_All_Attention=cell(NumAttention,1);
CM_Table_All_Attention=cell(NumAttention,1);
AttentionalTable_All = cell(NumLoops,1);
% Split_Table_All_Attention=cell(NumAttention,1);

Split_Accuracy_Attention_All=cell(1,NumTypes);
Split_Window_Accuracy_Attention_All=cell(1,NumTypes);

%%

for lidx=1:NumLoops
%%
    NumIter=0;
    LoopNumber = lidx;
    Split_TableSaveNameExt=sprintf('Split_Table%s.mat',SplitExtraSaveTerm);
    Split_TableSavePathNameExt=[SavePath filesep Split_TableSaveNameExt];

if isfile(Split_TableSavePathNameExt)
m_Split_Table=matfile(Split_TableSavePathNameExt,"Writable",false);
if any(strcmp(fields(m_Split_Table),'Split_Table'))
Split_Table=m_Split_Table.Split_Table;
end
else
    Split_Table=[];
    this_Split_Accuracy_All=cell(NumTypes,1);
    this_Split_Window_Accuracy_All=cell(NumTypes,1);
end
%%

IsFirst = true;
for fidx=1:NumFolds

    Fold = fidx;

    this_FoldName = sprintf('Fold_%d',Fold);
    this_Fold_Encoding_Dir = [Overall_Encoding_Dir filesep this_FoldName];

if exist(this_Fold_Encoding_Dir, 'dir')

% cfg_tmp = cgg_generateEncoderSubFolders(this_Fold_Encoding_Dir,ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,LossFactorReconstruction,LossFactorKL,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer);
cfg_tmp = cgg_generateEncoderSubFolders(this_Fold_Encoding_Dir,ModelName,DataWidth,WindowStride,HiddenSize,InitialLearningRate,WeightReconstruction,WeightKL,WeightClassification,MiniBatchSize,wantSubset,WeightedLoss,GradientThreshold,ClassifierName,ClassifierHiddenSize,STDChannelOffset,STDWhiteNoise,STDRandomWalk,Optimizer,NumEpochsAutoEncoder,Normalization,LossType_Decoder);
this_Encoding_Dir = cgg_getDirectory(cfg_tmp,'Classifier');
% this_Encoding_Dir = cgg_getDirectory(cfg_tmp,'IsSubset');

% this_Encoding_Dir = cfg_tmp.EncodingDir.ModelName.WidthStride.HiddenSize.Learning.MiniBatchSize.DataAugmentation.IsSubset.Loss.Classifier.path;
end
%%

CMTableSavePathNameExt = [this_Encoding_Dir filesep 'CM_Table.mat'];

%%
if isfile(CMTableSavePathNameExt)

m_CM_Table = matfile(CMTableSavePathNameExt,'Writable',false);
this_CM_Table = m_CM_Table.CM_Table;

%%
m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

this_TestingIDX=test(KFoldPartition,fidx);

this_Identifiers_Table=Identifiers_Table(this_TestingIDX,:);

this_CM_Table=join(this_CM_Table,this_Identifiers_Table);

%%

% [~,~,this_Accuracy] = cgg_procConfusionMatrixFromTable(this_CM_Table,ClassNames,'MatchType',MatchType,'IsQuaddle',IsQuaddle,'RandomChance',RandomChance_Baseline,'MostCommon',MostCommon_Baseline);

[~,~,this_Window_Accuracy] = cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,ClassNames,'MatchType',MatchType,'IsQuaddle',IsQuaddle,'RandomChance',RandomChance_Baseline,'MostCommon',MostCommon_Baseline);

this_Accuracy = max(this_Window_Accuracy);

if IsFirst
    [~,NumWindows]=size(this_Window_Accuracy);
    Accuracy_All{lidx}=NaN(NumFolds,1);
    Window_Accuracy_All{lidx}=NaN(NumFolds,NumWindows);
    CM_Table_All{lidx}=cell(NumFolds,1);
end

% fprintf('??? Debug 1-> Fold: %d Is First: %d\n',fidx,IsFirst);
for aidx = 1:NumAttention

    this_Field = AttentionalNames{aidx};
    this_RandomChance = RandomChanceAttentional_Baseline.(this_Field);
    this_MostCommon = MostCommonAttentional_Baseline.(this_Field);
    % this_RandomChance = RandomChance_Baseline;
    % this_MostCommon = MostCommon_Baseline;
    this_Weights = this_CM_Table.(this_Field);

    [~,~,this_Window_Accuracy_Attention] = ...
        cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,...
        ClassNames,'MatchType',MatchType,'IsQuaddle',IsQuaddle,...
        'RandomChance',this_RandomChance,...
        'MostCommon',this_MostCommon,'Weights',this_Weights);
    this_Accuracy_Attention = max(this_Window_Accuracy_Attention);


    if IsFirst
    [~,this_NumWindows]=size(this_Window_Accuracy_Attention);
    Accuracy_All_Attention{aidx}=NaN(NumFolds,1);
    Window_Accuracy_All_Attention{aidx}=NaN(NumFolds,this_NumWindows);
    CM_Table_All_Attention{aidx}=cell(NumFolds,1);
    end

    Accuracy_All_Attention{aidx}(fidx,:)=this_Accuracy_Attention;
    Window_Accuracy_All_Attention{aidx}(fidx,:)=this_Window_Accuracy_Attention;
    CM_Table_All_Attention{lidx}{aidx} = this_CM_Table;
end

%%
% if fidx==1


%%
Accuracy_All{lidx}(fidx,:)=this_Accuracy;
Window_Accuracy_All{lidx}(fidx,:)=this_Window_Accuracy;
CM_Table_All{lidx}{fidx} = this_CM_Table;

if isempty(Split_Table)
this_Split_Accuracy=NaN(1,NumTypes);
this_Split_Window_Accuracy=cell(1,NumTypes);

% this_Split_Accuracy_Attention=cell(1,NumTypes);
% this_Split_Window_Accuracy_Attention=cell(1,NumTypes);

for tidx=1:NumTypes
    this_FilterValue=TypeValues(tidx,:);
% fprintf('??? Debug Before Single Accuracy Calculation\n');
[~,~,this_Split_Accuracy(tidx)] = cgg_procConfusionMatrixFromTable(this_CM_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue,'MatchType',MatchType,'IsQuaddle',IsQuaddle,'RandomChance',RandomChance_Baseline,'MostCommon',MostCommon_Baseline);
% fprintf('??? Debug After Single Accuracy Calculation\n');
[~,~,this_Split_Window_Accuracy{tidx}] = cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue,'MatchType',MatchType,'IsQuaddle',IsQuaddle,'RandomChance',RandomChance_Baseline,'MostCommon',MostCommon_Baseline);
this_Split_Accuracy(tidx) = max(this_Split_Window_Accuracy{tidx});

if IsFirst
Split_Accuracy_Attention_All{tidx} = cell(NumAttention,1);
Split_Window_Accuracy_Attention_All{tidx} = cell(NumAttention,1);
end
% fprintf('??? Debug 1-> Accuracy Rows: %d Window Rows: %d\n',size(this_Split_Accuracy_Attention{tidx},1),size(this_Split_Window_Accuracy_Attention{tidx},1));
for aidx = 1:NumAttention

    this_Field = AttentionalNames{aidx};
    this_RandomChance = RandomChanceAttentional_Baseline.(this_Field);
    this_MostCommon = MostCommonAttentional_Baseline.(this_Field);
    this_Weights = this_CM_Table.(this_Field);

    % fprintf('??? Debug 1-> Attentional Name: %s Filter: %s Filter Type %d\n',this_Field,FilterColumn{1},this_FilterValue);
    
    [~,~,this_Window_Accuracy_Attention] = ...
        cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,...
        ClassNames,'FilterColumn',FilterColumn,...
        'FilterValue',this_FilterValue,...
        'MatchType',MatchType,'IsQuaddle',IsQuaddle,...
        'RandomChance',this_RandomChance,...
        'MostCommon',this_MostCommon,'Weights',this_Weights);
    this_Accuracy_Attention = max(this_Window_Accuracy_Attention);

% fprintf('??? Debug 1-> Fold: %d Is First: %d\n',fidx,IsFirst);
    if IsFirst
    [~,this_NumWindows]=size(this_Window_Accuracy_Attention);
    Split_Accuracy_Attention_All{tidx}{aidx}=NaN(NumFolds,1);
    Split_Window_Accuracy_Attention_All{tidx}{aidx}=NaN(NumFolds,this_NumWindows);
    end
% fprintf('??? Debug 2-> Accuracy Rows: %d Accuracy Split Rows: %d  Window Rows: %d Window Split Rows: %d\n',size(this_Accuracy_Attention,1),size(Split_Accuracy_Attention_All{tidx}{aidx},1),size(this_Window_Accuracy_Attention,1),size(Split_Window_Accuracy_Attention_All{tidx}{aidx},1));
    Split_Accuracy_Attention_All{tidx}{aidx}(fidx,:)=this_Accuracy_Attention;
    Split_Window_Accuracy_Attention_All{tidx}{aidx}(fidx,:)=this_Window_Accuracy_Attention;
end

end

% if fidx==1
%     [~,NumWindows]=size(this_Split_Window_Accuracy{1});
%     Split_Accuracy_All{lidx}=cell(NumTypes,1);
%     % Split_Accuracy_All{lidx}=NaN(NumFolds,NumTypes);
%     Split_Window_Accuracy_All{lidx}=cell(NumTypes,1);
%     for tidx=1:NumTypes
%         Split_Accuracy_All{lidx}{tidx}=NaN(NumFolds,1);
%         Split_Window_Accuracy_All{lidx}{tidx}=NaN(NumFolds,NumWindows);
%     end
% end
%%
% fprintf('??? Debug 2-> Fold: %d Is First: %d\n',fidx,IsFirst);
if IsFirst
    [~,NumWindows]=size(this_Split_Window_Accuracy{1});
    for tidx=1:NumTypes
        this_Split_Accuracy_All{tidx}=NaN(NumFolds,1);
        this_Split_Window_Accuracy_All{tidx}=NaN(NumFolds,NumWindows);
    end
    
end
% fprintf('??? Debug 3-> Fold: %d Is First: %d\n',fidx,IsFirst);
%%
% Split_Accuracy_All{lidx}(fidx,:)=this_Split_Accuracy;
for tidx=1:NumTypes
    this_Split_Accuracy_All{tidx}(fidx,:)=this_Split_Accuracy(tidx);
    this_Split_Window_Accuracy_All{tidx}(fidx,:)=this_Split_Window_Accuracy{tidx};
end
end % Check if Split Table exists already
%%
end % Check if Metrics have been calculated and exist
IsFirst = false;
end % Loop through the Folds

if isempty(Split_Table)
FilterColumnSTR=string(FilterColumn);
if ~HasSplit_TableRowNames
Split_TableRowNames=cell(1,NumTypes);
end
this_AttentionalTable = cell(NumTypes,1);
    for tidx=1:NumTypes
        this_Split_TableRowNames='';
        for cidx=1:NumColumns
            this_FilterColumn=FilterColumnSTR(cidx);
        this_FilterValue=TypeValues(tidx,cidx);
        if cidx>1
            this_Split_TableRowNames=[this_Split_TableRowNames ' '];
        end
        this_Split_TableRowNames=[this_Split_TableRowNames, sprintf('%s:%d',this_FilterColumn,this_FilterValue)];
        end
        if ~HasSplit_TableRowNames
        Split_TableRowNames{tidx}=this_Split_TableRowNames;
        end
        % fprintf('??? Debug 2-> Accuracy Rows: %d Window Rows: %d\n',size(Split_Accuracy_Attention_All{tidx},1),size(Split_Window_Accuracy_Attention_All{tidx},1));
        this_AttentionalTable{tidx} = table(Split_Accuracy_Attention_All{tidx},Split_Window_Accuracy_Attention_All{tidx},'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy},'RowNames',AttentionalNames);
    end
% fprintf('??? Debug 2-> AttentionalTable Rows: %d\n',size(this_AttentionalTable,1));

Split_Table=table(this_Split_Accuracy_All,this_Split_Window_Accuracy_All,this_AttentionalTable,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy,'Attentional Table'},'RowNames',Split_TableRowNames);
% Split_Table=table(this_Split_Accuracy_All,this_Split_Window_Accuracy_All,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy},'RowNames',Split_TableRowNames);
Split_TableSaveVariables=cell(1);
Split_TableSaveVariablesName=cell(1);
Split_TableSaveVariables{1}=Split_Table;
Split_TableSaveVariablesName{1}='Split_Table';

cgg_saveVariableUsingMatfile(Split_TableSaveVariables,...
    Split_TableSaveVariablesName,Split_TableSavePathNameExt);

end

Split_Table_All{lidx}=Split_Table;
AttentionalTable = table(Accuracy_All_Attention,Window_Accuracy_All_Attention,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy},'RowNames',AttentionalNames);
AttentionalTable_All{lidx} = AttentionalTable;

end % Loop through all the loops

%%

FullTableRowNames = LoopNames;

% FullTable=table(Accuracy_All,Window_Accuracy_All,CM_Table_All,Split_Table_All,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy,cfg_Names.TableNameCM_Table,cfg_Names.TableNameSplit_Table},'RowNames',FullTableRowNames);
% AttentionalTable = table(Accuracy_All_Attention,Window_Accuracy_All_Attention,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy},'RowNames',AttentionalNames);
FullTable=table(Accuracy_All,Window_Accuracy_All,Split_Table_All,AttentionalTable_All,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy,cfg_Names.TableNameSplit_Table,'Attentional Table'},'RowNames',FullTableRowNames);
%%
Outcfg.DataWidth=DataWidth;
Outcfg.WindowStride=WindowStride;
% Outcfg.Decoders=Decoders;
Outcfg.LoopNames=LoopNames;
Outcfg.LoopTitle=LoopTitle;
Outcfg.LoopType=LoopType;
Outcfg.SamplingFrequency=SamplingFrequency;
% Outcfg.IADecoder=IADecoder;
Outcfg.Time_Start=Time_Start;
Outcfg.TargetDir=TargetDir;
Outcfg.ResultsDir=ResultsDir;
Outcfg.ExtraSaveTerm=ExtraSaveTerm;
Outcfg.SplitExtraSaveTerm=SplitExtraSaveTerm;
Outcfg.VarargIN=VarargIN;
Outcfg.Epoch=Epoch;
Outcfg.EpochName=EpochName;
Outcfg.RandomChance=RandomChance;
Outcfg.MostCommon=MostCommon;
Outcfg.FilterColumn=FilterColumn;
Outcfg.wantSubset=wantSubset;
% Outcfg.wantZeroFeatureDetector=wantZeroFeatureDetector;
% Outcfg.ARModelOrder=ARModelOrder;
Outcfg.MatchType=MatchType;
Outcfg.NumWindows = NumWindows;
Outcfg.IsQuaddle = IsQuaddle;
Outcfg.AttentionalTable = AttentionalTable;

%%

FullTableSaveVariables=cell(2,1);
FullTableSaveVariablesName=cell(2,1);
FullTableSaveVariables{1}=FullTable;
FullTableSaveVariables{2}=Outcfg;
FullTableSaveVariablesName{1}='FullTable';
FullTableSaveVariablesName{2}='Outcfg';

cgg_saveVariableUsingMatfile(FullTableSaveVariables,FullTableSaveVariablesName,FullTableSavePathNameExt);

end % want full table is true

Outcfg.cfg = cfg;

%%
EpochDir = struct();
EpochDir.Main = cgg_getDirectory(cfg.TargetDir,'Epoch');
EpochDir.Results = cgg_getDirectory(cfg.ResultsDir,'Epoch'); 
%% Importance Analysis
if WantAnalysis

NumEntries = 500;
RemovalPlotTable = cgg_procFullImportanceAnalysis(cfg_Encoder, ...
    EpochDir,Outcfg,'NumEntries',NumEntries,'WantDelay',WantDelay);
Outcfg.RemovalPlotTable = RemovalPlotTable;

%% Correlation Analysis

Learning_Model_Variables = {'Absolute Prediction Error','Outcome',...
    'Error Trace','Choice Probability WM','Choice Probability RL',...
    'Choice Probability CMB','Value RL','Value WM','WM Weight'};

% Run multiple instances working on different learning model variables
Learning_Model_Variables = ...
    Learning_Model_Variables(randperm(length(Learning_Model_Variables)));

CorrelationTable = [];

for vidx = 1:length(Learning_Model_Variables)
LMVariable = Learning_Model_Variables{vidx};
this_CorrelationTable = cgg_procFullLatentCorrelationAnalysis( ...
    cfg_Encoder,EpochDir,'LMVariable',LMVariable);

if isempty(CorrelationTable)
    CorrelationTable = this_CorrelationTable;
else
    CorrelationTable = [CorrelationTable; this_CorrelationTable];
end

end

Outcfg.CorrelationTable = CorrelationTable;
end

end

