function cgg_runAutoEncoder(Fold,varargin)
%CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SLURMChoice = CheckVararginPairs('SLURMChoice', NaN, varargin{:});
else
if ~(exist('SLURMChoice','var'))
SLURMChoice=NaN;
end
end

if isfunction
SLURMIDX = CheckVararginPairs('SLURMIDX', NaN, varargin{:});
else
if ~(exist('SLURMIDX','var'))
SLURMIDX=NaN;
end
end

if isfunction
SessionRunIDX = CheckVararginPairs('SessionRunIDX', NaN, varargin{:});
else
if ~(exist('SessionRunIDX','var'))
SessionRunIDX=NaN;
end
end

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

%%

if ~isnan(SessionRunIDX)
    Fold = mod(SessionRunIDX-1,10)+1;
    SessionIDX = floor((SessionRunIDX-1)/10)+1;
    cfg_Encoder.Subset = replace(cfg_Session(SessionIDX).SessionName,'-','_');
end

%%

cfg_Encoder.Fold = Fold;
Epoch=cfg_Encoder.Epoch;

if isfunction
cfg_Encoder.Epoch = CheckVararginPairs('Epoch', Epoch, varargin{:});
end
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

DataWidth = cfg_Encoder.DataWidth;
StartingIDX = cfg_Encoder.StartingIDX;
EndingIDX = cfg_Encoder.EndingIDX;
WindowStride = cfg_Encoder.WindowStride;
if isfield(cfg_Encoder,'Subset')
    if islogical(cfg_Encoder.Subset)
        cfg_Encoder.wantSubset = cfg_Encoder.Subset;
    elseif strcmp(cfg_Encoder.Subset,'None')
        cfg_Encoder.wantSubset = false;
    else
        cfg_Encoder.wantSubset = true;
    end
else
    cfg_Encoder.Subset = cfg_Encoder.wantSubset;
end

wantSubset = cfg_Encoder.wantSubset;

ModelName = cfg_Encoder.ModelName;
HiddenSizes = cfg_Encoder.HiddenSizes;
InitialLearningRate = cfg_Encoder.InitialLearningRate;

MiniBatchSize = cfg_Encoder.MiniBatchSize;
LossFactorReconstruction = cfg_Encoder.LossFactorReconstruction;
LossFactorKL = cfg_Encoder.LossFactorKL;

SubsetAmount = cfg_param_Decoder.SubsetAmount;
WantSaveOptimalNet = cfg_Encoder.WantSaveOptimalNet;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;

%%

if isfunction
WindowStride = CheckVararginPairs('WindowStride', WindowStride, varargin{:});
cfg_Encoder.WindowStride = WindowStride;
end
if isfunction
DataWidth = CheckVararginPairs('DataWidth', DataWidth, varargin{:});
cfg_Encoder.DataWidth = DataWidth;
end
if isfunction
cfg_Encoder.ModelName = CheckVararginPairs('ModelName', ModelName, varargin{:});
end
if isfunction
cfg_Encoder.HiddenSizes = CheckVararginPairs('HiddenSizes', HiddenSizes, varargin{:});
end
if isfunction
cfg_Encoder.InitialLearningRate = CheckVararginPairs('InitialLearningRate', InitialLearningRate, varargin{:});
end
if isfunction
cfg_Encoder.MiniBatchSize = CheckVararginPairs('MiniBatchSize', MiniBatchSize, varargin{:});
end
if isfunction
cfg_Encoder.maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', cfg_Encoder.maxworkerMiniBatchSize, varargin{:});
end
if isfunction
cfg_Encoder.LossFactorReconstruction = CheckVararginPairs('LossFactorReconstruction', LossFactorReconstruction, varargin{:});
end
if isfunction
cfg_Encoder.LossFactorKL = CheckVararginPairs('LossFactorKL', LossFactorKL, varargin{:});
end
if isfunction
cfg_Encoder.WantSaveOptimalNet = CheckVararginPairs('WantSaveOptimalNet', WantSaveOptimalNet, varargin{:});
end
if isfunction
cfg_Encoder.NumEpochsAutoEncoder = CheckVararginPairs('NumEpochsAutoEncoder', NumEpochsAutoEncoder, varargin{:});
cfg_Encoder.NumEpochsBase = cfg_Encoder.NumEpochsAutoEncoder;
end
if isfunction
cfg_Encoder.IsVariational = CheckVararginPairs('IsVariational', cfg_Encoder.IsVariational, varargin{:});
end
if isfunction
cfg_Encoder.STDChannelOffset = CheckVararginPairs('STDChannelOffset', cfg_Encoder.STDChannelOffset, varargin{:});
end
if isfunction
cfg_Encoder.STDWhiteNoise = CheckVararginPairs('STDWhiteNoise', cfg_Encoder.STDWhiteNoise, varargin{:});
end
if isfunction
cfg_Encoder.STDRandomWalk = CheckVararginPairs('STDRandomWalk', cfg_Encoder.STDRandomWalk, varargin{:});
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

disp(cfg_Encoder);
disp(datetime);

%%
if canUseGPU
    numberOfGPUs = gpuDeviceCount("available");
    % numberOfGPUs = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
    p=gcp("nocreate");
    if isempty(p)
    parpool(numberOfGPUs);
    end
elseif ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
    cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
    p=gcp("nocreate");
    if isempty(p)
    parpool(cores);
    end
end

%%

if isfunction
cgg_procAutoEncoder(DataWidth,StartingIDX,EndingIDX,WindowStride,Fold,cfg,cfg_Encoder,'wantSubset',wantSubset,'SubsetAmount',SubsetAmount,varargin{:});
else
cgg_procAutoEncoder(DataWidth,StartingIDX,EndingIDX,WindowStride,Fold,cfg,cfg_Encoder,'wantSubset',wantSubset,'SubsetAmount',SubsetAmount);
end

end

