function cgg_runAutoEncoder(Fold,varargin)
%CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

cfg_Session = DATA_cggAllSessionInformationConfiguration;

cfg_param_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

cfg_Encoder = PARAMETERS_cgg_runAutoEncoder;

if isfunction
cfg_param = PARAMETERS_cgg_runAutoEncoder(varargin{:});
else
cfg_param = PARAMETERS_cgg_runAutoEncoder();
end

Epoch=cfg_param.Epoch;

%%

if ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
p=gcp("nocreate");
if isempty(p) || p.NumWorkers ~= cores
parpool(cores);
end
end

%%
outdatadir=cfg_Session(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Session(1).temporarydir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

Data_Normalized=true;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Encoding',true,'Fold',Fold,'Data_Normalized',Data_Normalized);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Encoding',true,'Fold',Fold,'Data_Normalized',Data_Normalized);
cfg.ResultsDir=cfg_Results.TargetDir;

%%

DataWidth = cfg_param.DataWidth;
StartingIDX = cfg_param.StartingIDX;
EndingIDX = cfg_param.EndingIDX;
WindowStride = cfg_param.WindowStride;
wantSubset = cfg_param.wantSubset;

SubsetAmount = cfg_param_Decoder.SubsetAmount;

%%

if isfunction
WindowStride = CheckVararginPairs('WindowStride', WindowStride, varargin{:});
end
if isfunction
DataWidth = CheckVararginPairs('DataWidth', DataWidth, varargin{:});
end

%%

if isfunction
cgg_procAutoEncoder(DataWidth,StartingIDX,EndingIDX,WindowStride,Fold,cfg,cfg_Encoder,'wantSubset',wantSubset,'SubsetAmount',SubsetAmount,varargin{:});
else
cgg_procAutoEncoder(DataWidth,StartingIDX,EndingIDX,WindowStride,Fold,cfg,cfg_Encoder,'wantSubset',wantSubset,'SubsetAmount',SubsetAmount);
end

end

