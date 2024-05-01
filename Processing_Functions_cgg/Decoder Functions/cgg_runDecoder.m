function cgg_runDecoder(Fold)
%CGG_RUNDECODER Summary of this function goes here
%   Detailed explanation goes here

cfg_Session = DATA_cggAllSessionInformationConfiguration;

cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;

Epoch=cfg_param.Epoch;
Decoder=cfg_param.Decoder;

%%

if ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
p=gcp("nocreate");
if isempty(p)
parpool(cores);
end
end

%%
outdatadir=cfg_Session(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Session(1).temporarydir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir);
cfg.ResultsDir=cfg_tmp.TargetDir;

%%

DataWidth = cfg_param.DataWidth;
StartingIDX = cfg_param.StartingIDX;
EndingIDX = cfg_param.EndingIDX;
WindowStride = cfg_param.WindowStride;
% NumFolds = cfg_param.NumFolds;
Dimension = cfg_param.Dimension;
wantTrialChosen = cfg_param.wantTrialChosen;
NumObsPerChunk = cfg_param.NumObsPerChunk;
NumChunks = cfg_param.NumChunks;
SubsetAmount = cfg_param.SubsetAmount;
NumIter = cfg_param.NumIter;
wantSubset = cfg_param.wantSubset;
wantIA = cfg_param.wantIA;
IADecoder = cfg_param.IADecoder;
wantTrain = cfg_param.wantTrain;
wantTest = cfg_param.wantTest;
%%
if wantTrialChosen
cgg_procSimpleDecoders_v3(DataWidth,StartingIDX,EndingIDX,WindowStride,NumObsPerChunk,NumChunks,Fold,Epoch,Decoder,cfg,'TrialChosen',true,'NumIter',NumIter,'wantSubset',wantSubset,'SubsetAmount',SubsetAmount,'wantIA',wantIA,'wantTrain',wantTrain,'wantTest',wantTest,'IADecoder',IADecoder);
else
cgg_procSimpleDecoders_v3(DataWidth,StartingIDX,EndingIDX,WindowStride,NumObsPerChunk,NumChunks,Fold,Epoch,Decoder,cfg,'Dimension',Dimension,'NumIter',NumIter,'wantSubset',wantSubset,'SubsetAmount',SubsetAmount,'wantIA',wantIA,'wantTrain',wantTrain,'wantTest',wantTest,'IADecoder',IADecoder);
end

end

