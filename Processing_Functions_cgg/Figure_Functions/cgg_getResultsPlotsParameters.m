function [FullTable,Outcfg] = cgg_getResultsPlotsParameters(EpochName,varargin)
%CGG_GETRESULTSPLOTSPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

%% Parameters
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

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

[LoopType,NumLoops] = cgg_getResultsParametersLoopValues('EpochName',EpochName,'Decoders',Decoders,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder,'DataWidth',DataWidth,'WindowStride',WindowStride);

NumDecoders = length(Decoders);

%% Extra Save Term
ExtraSaveTerm = cgg_generateExtraSaveTerm(varargin{:});

%% Identifiers Table

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',EpochName,'PlotData',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',EpochName,'PlotData',true);
cfg.ResultsDir=cfg_tmp.TargetDir;

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

%%

Accuracy_All=cell(NumDecoders,1);
Window_Accuracy_All=cell(NumDecoders,1);
CM_Table_All=cell(NumDecoders,1);

parfor didx=1:NumDecoders

for fidx=1:NumFolds

    Fold = fidx;
    Decoder = Decoders{didx};

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',EpochName,'Decoder',Decoder,'Fold',Fold);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',EpochName,'Decoder',Decoder,'Fold',Fold);
cfg.ResultsDir=cfg_Results.TargetDir;

%%
this_cfg_Decoder = cgg_generateDecoderVariableSaveNames_v2(Decoder,cfg,'ExtraSaveTerm',ExtraSaveTerm);

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
    Accuracy_All{didx}=NaN(NumFolds,NumIter);
    Window_Accuracy_All{didx}=NaN(NumFolds,NumWindows);
    CM_Table_All{didx}=cell(NumFolds,1);
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

Accuracy_All{didx}(fidx,:)=this_Accuracy;
Window_Accuracy_All{didx}(fidx,:)=this_Window_Accuracy;
CM_Table_All{didx}{fidx} = this_CM_Table;
%%
end

end

end

%%

TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
TrueValue=Identifiers_Table{:,TrueValueIDX};
[NumTrials,NumDimension]=size(TrueValue);
ClassNames=cell(1,NumDimension);
for fdidx=1:NumDimension
this_ClassNames=unique(TrueValue(:,fdidx));
ClassNames{fdidx}=unique(this_ClassNames);
end

RandomChance=NaN(1,NumIterRand);
parfor idx=1:NumIterRand
Prediction=NaN(size(TrueValue));
for tidx=1:NumTrials
Prediction(tidx,:) = cgg_getRandomPrediction(ClassNames);
end

RandomChance(idx) = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);
end

RandomChance=mean(RandomChance);

%%

FullTable=table(Accuracy_All,Window_Accuracy_All,CM_Table_All,'RowNames',Decoders);

%%
Outcfg.DataWidth=DataWidth;
Outcfg.WindowStride=WindowStride;
Outcfg.Decoders=Decoders;
Outcfg.SamplingFrequency=SamplingFrequency;
Outcfg.IADecoder=IADecoder;
Outcfg.Time_Start=Time_Start;
Outcfg.TargetDir=TargetDir;
Outcfg.ResultsDir=ResultsDir;
Outcfg.ExtraSaveTerm=ExtraSaveTerm;
Outcfg.Epoch=Epoch;
Outcfg.EpochName=EpochName;
Outcfg.RandomChance=RandomChance;



end

