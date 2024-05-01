function [FullTable,Outcfg] = cgg_getResultsPlotsParameters_v2(EpochName,varargin)
%CGG_GETRESULTSPLOTSPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

%% Parameters
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

%%

isfunction=exist('varargin','var');

if isfunction
Decoders = CheckVararginPairs('Decoders', cfg_Decoder.Decoder, varargin{:});
else
if ~(exist('Decoders','var'))
Decoders=cfg_Decoder.Decoder;
end
end

if isfunction
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=true;
end
end

if isfunction
wantZeroFeatureDetector = CheckVararginPairs('wantZeroFeatureDetector', false, varargin{:});
else
if ~(exist('wantZeroFeatureDetector','var'))
wantZeroFeatureDetector=false;
end
end

if isfunction
ARModelOrder = CheckVararginPairs('ARModelOrder', '', varargin{:});
else
if ~(exist('ARModelOrder','var'))
ARModelOrder='';
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='combinedaccuracy';
end
end

if isfunction
NumIterRand = CheckVararginPairs('NumIterRand', 2000, varargin{:});
else
if ~(exist('NumIterRand','var'))
NumIterRand=2000;
end
end

if isfunction
DataWidth = CheckVararginPairs('DataWidth', 100, varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth=100;
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', 50, varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride=50;
end
end

if isfunction
FilterColumn = CheckVararginPairs('FilterColumn', 'All', varargin{:});
else
if ~(exist('FilterColumn','var'))
FilterColumn='All';
end
end

%%
Epoch = cgg_getEpochNameFromString(EpochName);

%% Parameters
% cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
% cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;
cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

%%

NumFolds = cfg_Decoder.NumFolds;

SamplingFrequency = cfg_Decoder.SamplingFrequency;

% DataWidth = cfg_Decoder.DataWidth/SamplingFrequency;
% WindowStride = cfg_Decoder.WindowStride/SamplingFrequency;

% Decoders = cfg_Decoder.Decoder;
IADecoderIDX=strcmp(Decoders,cfg_Decoder.IADecoder);
IADecoder=Decoders(IADecoderIDX);
% NumDecoders = length(Decoders);

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Sessions(1).temporarydir;

%% Loop Values

[LoopType,NumLoops,LoopNames,LoopTitle] = cgg_getResultsParametersLoopValues('EpochName',EpochName,'Decoders',Decoders,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder,'DataWidth',DataWidth,'WindowStride',WindowStride,'MatchType',MatchType);

%% Extra Save Term
ExtraSaveTerm = cgg_generateExtraSaveTerm('EpochName',EpochName,'Decoders',Decoders,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder,'DataWidth',DataWidth,'WindowStride',WindowStride,'MatchType',MatchType);
VarargIN = varargin{:};
%%
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',EpochName,'PlotData',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',EpochName,'PlotData',true);
cfg.ResultsDir=cfg_tmp.TargetDir;

%%

FullTablePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotData.path;
SplitExtraSaveTerm = cgg_generateExtraSaveTerm('FilterColumn',FilterColumn);
FullTableNameExt=[sprintf('Full_Table_%s',LoopType) SplitExtraSaveTerm '.mat'];

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
end
else
    wantFullTable=true;
end

%%

if wantFullTable
%% Identifiers Table

SavePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotData.path;
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
[Identifiers,IdentifierName,~] = cgg_getDataStatistics(VariableName,wantSubset);

InputIdentifiers=cell2mat(Identifiers);
InputNames=cellstr(IdentifierName);
InputNames{strcmp(InputNames,'Data Number')}='DataNumber';

Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);

SaveVariables=cell(1);
SaveVariablesName=cell(1);
SaveVariables{1}=Identifiers_Table;
SaveVariablesName{1}='Identifiers_Table';

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

end

%% Split

if all(~strcmp(FilterColumn,'All') & ~strcmp(FilterColumn,'Target Feature'))
DistributionVariable=Identifiers_Table{:,FilterColumn};
TypeValues=unique(DistributionVariable,'rows');
[NumTypes,NumColumns]=size(TypeValues);
else
TypeValues=0;
NumTypes=1;
if strcmp(FilterColumn,'Target Feature')
TypeValues=0;
NumTypes=1;
end
end
%% Target Values

TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
TrueValue=Identifiers_Table{:,TrueValueIDX};
[NumTrials,NumDimension]=size(TrueValue);
ClassNames=cell(1,NumDimension);
for fdidx=1:NumDimension
this_ClassNames=unique(TrueValue(:,fdidx));
ClassNames{fdidx}=unique(this_ClassNames);
end

%%

Accuracy_All=cell(NumLoops,1);
Window_Accuracy_All=cell(NumLoops,1);
CM_Table_All=cell(NumLoops,1);
Split_Table_All=cell(NumLoops,1);
% Split_Accuracy_All=cell(NumLoops,1);
% Split_Window_Accuracy_All=cell(NumLoops,1);

parfor lidx=1:NumLoops

    NumIter=0;

    LoopNumber = lidx;

    cfgVariables = cgg_getResultsPlotsInputVariables(LoopType,LoopNumber,'EpochName',EpochName,'Decoders',Decoders,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder,'DataWidth',DataWidth,'WindowStride',WindowStride,'MatchType',MatchType);

    this_Decoder=cfgVariables.(cfg_Names.LoopDecoder);
    this_ARModelOrder=cfgVariables.(cfg_Names.LoopAR);
    this_EpochName=cfgVariables.(cfg_Names.LoopProcessing);
    this_wantSubset=cfgVariables.(cfg_Names.LoopSubset);
    this_DataWidth=cfgVariables.(cfg_Names.LoopDataWidth);
    this_WindowStride=cfgVariables.(cfg_Names.LoopWindowStride);
    this_MatchType=cfgVariables.(cfg_Names.LoopMatchType);

    this_ExtraSaveTerm = cgg_generateExtraSaveTerm('Decoders',this_Decoder,'wantSubset',this_wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',this_ARModelOrder,'DataWidth',this_DataWidth,'WindowStride',this_WindowStride,'MatchType',this_MatchType,'FilterColumn',FilterColumn);

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',this_EpochName,'PlotData',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',this_EpochName,'PlotData',true);
cfg.ResultsDir=cfg_tmp.TargetDir;

    SavePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotData.path;
    SaveNameExt=sprintf('Split_Table%s.mat',this_ExtraSaveTerm);

SavePathNameExt=[SavePath filesep SaveNameExt];

if isfile(SavePathNameExt)
m_Split_Table=matfile(SavePathNameExt,"Writable",false);
if any(strcmp(fields(m_Split_Table),'Split_Table'))
Split_Table=m_Split_Table.Split_Table;
end
else
    Split_Table=[];
    this_Split_Accuracy_All=cell(NumTypes,1);
    this_Split_Window_Accuracy_All=cell(NumTypes,1);
end

for fidx=1:NumFolds

    Fold = fidx;
    this_ExtraSaveTerm = cgg_generateExtraSaveTerm('wantSubset',this_wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',this_ARModelOrder,'DataWidth',this_DataWidth,'WindowStride',this_WindowStride);
this_cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',this_EpochName,'Decoder',this_Decoder,'Fold',Fold);
this_cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',this_EpochName,'Decoder',this_Decoder,'Fold',Fold);
this_cfg.ResultsDir=this_cfg_Results.TargetDir;

%%
this_cfg_Decoder = cgg_generateDecoderVariableSaveNames_v2(this_Decoder,this_cfg,'ExtraSaveTerm',this_ExtraSaveTerm);

Accuracy_PathNameExt = this_cfg_Decoder.Accuracy;
% Importance_PathNameExt = this_cfg_Decoder.Importance;
Partition_PathNameExt = this_cfg_Decoder.Partition;
%%
if isfile(Accuracy_PathNameExt)

m_Accuracy = matfile(Accuracy_PathNameExt,'Writable',false);

this_Accuracy = m_Accuracy.Accuracy;
this_Window_Accuracy = m_Accuracy.Window_Accuracy;
this_CM_Table = m_Accuracy.CM_Table;
%%
if fidx==1
    [~,NumIter]=size(this_Accuracy);
    [~,NumWindows]=size(this_Window_Accuracy);
    Accuracy_All{lidx}=NaN(NumFolds,NumIter);
    Window_Accuracy_All{lidx}=NaN(NumFolds,NumWindows);
    CM_Table_All{lidx}=cell(NumFolds,1);
end

[~,this_NumIter]=size(this_Accuracy);
this_Accuracy=[this_Accuracy,NaN(1,NumIter-this_NumIter)];

%%
m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

this_TestingIDX=test(KFoldPartition,fidx);

this_Identifiers_Table=Identifiers_Table(this_TestingIDX,:);

this_CM_Table=join(this_CM_Table,this_Identifiers_Table);

%%

Accuracy_All{lidx}(fidx,:)=this_Accuracy;
Window_Accuracy_All{lidx}(fidx,:)=this_Window_Accuracy;
CM_Table_All{lidx}{fidx} = this_CM_Table;

if isempty(Split_Table)
this_Split_Accuracy=NaN(1,NumTypes);
this_Split_Window_Accuracy=cell(1,NumTypes);

for tidx=1:NumTypes
    this_FilterValue=TypeValues(tidx,:);

[~,~,this_Split_Accuracy(tidx)] = cgg_procConfusionMatrixFromTable(this_CM_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue);

[~,~,this_Split_Window_Accuracy{tidx}] = cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue);

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

if fidx==1
    [~,NumWindows]=size(this_Split_Window_Accuracy{1});
    for tidx=1:NumTypes
        this_Split_Accuracy_All{tidx}=NaN(NumFolds,1);
        this_Split_Window_Accuracy_All{tidx}=NaN(NumFolds,NumWindows);
    end
end

%%
% Split_Accuracy_All{lidx}(fidx,:)=this_Split_Accuracy;
for tidx=1:NumTypes
    this_Split_Accuracy_All{tidx}(fidx,:)=this_Split_Accuracy(tidx);
    this_Split_Window_Accuracy_All{tidx}(fidx,:)=this_Split_Window_Accuracy{tidx};
end
end % Check if Split Table exists already
%%
end % Check if Metrics have been calculated and exist

end % Loop through the Folds

if isempty(Split_Table)
FilterColumnSTR=string(FilterColumn);
Split_TableRowNames=cell(1,NumTypes);
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
        Split_TableRowNames{tidx}=this_Split_TableRowNames;
    end

Split_Table=table(this_Split_Accuracy_All,this_Split_Window_Accuracy_All,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy},'RowNames',Split_TableRowNames);

SaveVariables=cell(1);
SaveVariablesName=cell(1);
SaveVariables{1}=Split_Table;
SaveVariablesName{1}='Split_Table';

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

end

Split_Table_All{lidx}=Split_Table;

end % Loop through all the loops

%%

% TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
% TrueValue=Identifiers_Table{:,TrueValueIDX};
% [NumTrials,NumDimension]=size(TrueValue);
% ClassNames=cell(1,NumDimension);
% for fdidx=1:NumDimension
% this_ClassNames=unique(TrueValue(:,fdidx));
% ClassNames{fdidx}=unique(this_ClassNames);
% end

RandomChance=NaN(1,NumIterRand);
parfor idx=1:NumIterRand
Prediction=NaN(size(TrueValue));
for tidx=1:NumTrials
Prediction(tidx,:) = cgg_getRandomPrediction(ClassNames);
end

RandomChance(idx) = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);
end

RandomChance=mean(RandomChance);


[UniqueTarget,~,UniqueValues] = unique(TrueValue,'rows');
ModeTargetIDX = mode(UniqueValues);
ModeTarget = UniqueTarget(ModeTargetIDX,:); %# the first output argument

Prediction=repmat(ModeTarget,NumTrials,1);

MostCommon = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);

%%

FullTableRowNames = LoopNames;

% FullTable=table(Accuracy_All,Window_Accuracy_All,CM_Table_All,Split_Table_All,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy,cfg_Names.TableNameCM_Table,cfg_Names.TableNameSplit_Table},'RowNames',FullTableRowNames);
FullTable=table(Accuracy_All,Window_Accuracy_All,Split_Table_All,'VariableNames',{cfg_Names.TableNameAccuracy,cfg_Names.TableNameWindow_Accuracy,cfg_Names.TableNameSplit_Table},'RowNames',FullTableRowNames);
%%
Outcfg.DataWidth=DataWidth;
Outcfg.WindowStride=WindowStride;
Outcfg.Decoders=Decoders;
Outcfg.LoopNames=LoopNames;
Outcfg.LoopTitle=LoopTitle;
Outcfg.LoopType=LoopType;
Outcfg.SamplingFrequency=SamplingFrequency;
Outcfg.IADecoder=IADecoder;
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
Outcfg.wantZeroFeatureDetector=wantZeroFeatureDetector;
Outcfg.ARModelOrder=ARModelOrder;
Outcfg.MatchType=MatchType;

%%

FullTableSaveVariables=cell(2,1);
FullTableSaveVariablesName=cell(2,1);
FullTableSaveVariables{1}=FullTable;
FullTableSaveVariables{2}=Outcfg;
FullTableSaveVariablesName{1}='FullTable';
FullTableSaveVariablesName{2}='Outcfg';

cgg_saveVariableUsingMatfile(FullTableSaveVariables,FullTableSaveVariablesName,FullTableSavePathNameExt);

end % want full table is true
end

