
clc; clear; close all;
%%

StatusType = 'All Parameters';

switch StatusType
    case 'Paper'
SLURMChoice_All = {'Base',11,12,7,1,3,6,9,10};
SLURMIDX_All = {1,[1,4],[1,2,3,5,7,8,9,10],[1,2,3,4,5,7,8,9,10], ...
    [1,2,3,6,7,8,9,10],[1,2,3,4,5,6,7,8,9],[1,2,3,4,5],[5,6],2};
Fold_All = 1:10;
SessionRunIDX_All = NaN;
    case 'Session'
SLURMChoice_All = {'Base'};
SLURMIDX_All = {1};
Fold_All = 1;
SessionRunIDX_All = 1:250;
    case 'All Parameters'
SLURMChoice_All = {'Base',1,2,3,4,5,6,7,8,9,10,11,12};
SLURMIDX_All = {1,[1,2,3,6,7,8,9,10],1:10,1:10,[1,2,3,5,7,9,10],1:10,1:10,1:10,1:10,1:10,1:6,[1,4],1:10};
Fold_All = 1:10;
SessionRunIDX_All = NaN;
end

%%
TableVariables = [["SLURMChoice", "string"]; ...
    ["SLURMIDX", "string"]; ...
    ["Fold", "double"]; ...
    ["SessionRunIDX", "double"]; ...
    ["Autoencoder Progress", "double"]; ...
    ["Full Progress", "double"]];

NumVariables = size(TableVariables,1);
ProgressTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
%%

for cidx = 1:length(SLURMChoice_All)
    SLURMChoice = SLURMChoice_All{cidx};
    this_SLURMIDX_All = SLURMIDX_All{cidx};
    for idx = 1:length(this_SLURMIDX_All)
        SLURMIDX = this_SLURMIDX_All(idx);
        for fidx = 1:length(Fold_All)
            for sidx = 1:length(SessionRunIDX_All)

Fold = Fold_All(fidx);
SessionRunIDX = SessionRunIDX_All(sidx);
isfunction=exist('varargin','var');
%%

cfg_Session = DATA_cggAllSessionInformationConfiguration;

cfg_param_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

if isfunction
cfg_Encoder = PARAMETERS_cgg_runAutoEncoder(varargin{:});
else
cfg_Encoder = PARAMETERS_cgg_runAutoEncoder();
end

if strcmp(SLURMChoice,'Base') && ~isnan(SLURMIDX)
TableSLURM = SLURMPARAMETERS_cgg_runAutoEncoder_v2(SLURMChoice,SLURMIDX);
[Fold,cfg_Encoder] = cgg_assignSLURMEncoderParameters(cfg_Encoder,TableSLURM);
elseif ~isnan(SLURMIDX) && ~isnan(SLURMChoice)
TableSLURM = SLURMPARAMETERS_cgg_runAutoEncoder_v2(SLURMChoice,SLURMIDX);
[~,cfg_Encoder] = cgg_assignSLURMEncoderParameters(cfg_Encoder,TableSLURM);
end

if ~isnan(SessionRunIDX)
    Fold = mod(SessionRunIDX-1,10)+1;
    SessionIDX = floor((SessionRunIDX-1)/10)+1;
    cfg_Encoder.Subset = replace(cfg_Session(SessionIDX).SessionName,'-','_');
end

cfg_Encoder.Fold = Fold;
Epoch=cfg_Encoder.Epoch;

%%

cfg_Encoder.NumEpochsBase = cfg_Encoder.NumEpochsAutoEncoder;
cfg_Encoder.NumEpochsSession = cfg_Encoder.NumEpochsFull;

cfg_Encoder.LossFactorReconstruction = cfg_Encoder.WeightReconstruction;
cfg_Encoder.LossFactorKL = cfg_Encoder.WeightKL;
%%
cfg_TimeStart = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
cfg_Encoder.Time_Start = -cfg_TimeStart.Window_Before_Data;
cfg_Encoder.Time_End = cfg_TimeStart.Window_After_Data;
cfg_PreProcessing = PARAMETERS_cgg_proc_NeuralDataPreparation('SessionName','none');
cfg_Encoder.SamplingRate = cfg_PreProcessing.rect_samprate;
%%
outdatadir=cfg_Session(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Session(1).temporarydir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

Data_Normalized=true;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Encoding',true,'Target',cfg_Encoder.Target,'Fold',Fold,'Data_Normalized',Data_Normalized);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Encoding',true,'Target',cfg_Encoder.Target,'Fold',Fold,'Data_Normalized',Data_Normalized);
cfg.ResultsDir=cfg_Results.TargetDir;


%%

if isfield(cfg_Encoder,'Subset')
    cfg_Encoder.wantSubset = cfg_Encoder.Subset;
else
    cfg_Encoder.Subset = cfg_Encoder.wantSubset;
end

%%
cfg_Encoder.IsQuaddle = true;
if ~strcmp(cfg_Encoder.Target,'Dimension')
cfg_Encoder.IsQuaddle = false;
end
if strcmp(cfg_Encoder.Epoch,'Synthetic') || contains(cfg_Encoder.Epoch,'Synthetic')
cfg_Encoder.IsQuaddle = false;
end

%%

Encoding_Dir = cgg_getDirectory(cfg.ResultsDir,'Fold');

cfg_Network = cgg_generateEncoderSubFolders_v2(Encoding_Dir,cfg_Encoder);

%%
if ~isnan(SessionRunIDX)
    fprintf('\t(((Session: %s --- Fold: %d))) \n',cfg_Encoder.Subset, cfg_Encoder.Fold);
else
fprintf('\t(((Fold: %d))) \n',cfg_Encoder.Fold);
end

[ResultFull,ResultAutoencoder] = cgg_checkTrainingStatus(cfg_Network,'NumEpochsAutoEncoder',cfg_Encoder.NumEpochsAutoEncoder,'NumEpochsFull',cfg_Encoder.NumEpochsFull);
% cgg_checkTrainingStatus(cfg_Network);
this_Row = height(ProgressTable) + 1;
if ~isnan(SessionRunIDX)
    ProgressTable(this_Row,:) = {SLURMChoice,cfg_Encoder.Subset,Fold,SessionRunIDX,ResultAutoencoder,ResultFull};
else
ProgressTable(this_Row,:) = {SLURMChoice,SLURMIDX,Fold,SessionRunIDX,ResultAutoencoder,ResultFull};
end
            end
        end
    end
end
%%

PercentileFunction = @(x) prctile(x,50); % You can replace this with any other aggregation function
MeanFunction = @(x) mean(x); % You can replace this with any other aggregation function
TableFun = @(x) {PercentileFunction(x),MeanFunction(x)};

% Use groupsummary to apply the function for each unique combination of 'Field1' and 'Field2' over 'Field3'
ProgressTable_Percentile = groupsummary(ProgressTable, {'SLURMChoice', 'SLURMIDX'}, TableFun, 'Full Progress');
