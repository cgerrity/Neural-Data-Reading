function cfg_OUT = cgg_generateDecoderVariableSaveNames_v2(Decoder,INcfg,varargin)
%CGG_GENERATEDECODERVARIABLESAVENAMES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%%

if isfunction
ExtraSaveTerm = CheckVararginPairs('ExtraSaveTerm', '', varargin{:});
else
if ~(exist('ExtraSaveTerm','var'))
ExtraSaveTerm='';
end
end

%%

% Decoding_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;
% Partition_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

Decoding_Dir = INcfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;
Partition_Dir = INcfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

%%

Model_NameExt = sprintf('%s_Model%s.mat',Decoder,ExtraSaveTerm);
Information_NameExt = sprintf('%s_Information%s.mat',Decoder,ExtraSaveTerm);
Accuracy_NameExt = sprintf('%s_Accuracy%s.mat',Decoder,ExtraSaveTerm);
Importance_NameExt = sprintf('%s_Importance%s.mat',Decoder,ExtraSaveTerm);


%%

Model_PathNameExt = [Decoding_Dir filesep Model_NameExt];
Information_PathNameExt = [Decoding_Dir filesep Information_NameExt];
Accuracy_PathNameExt = [Decoding_Dir filesep Accuracy_NameExt];
Importance_PathNameExt = [Decoding_Dir filesep Importance_NameExt];

%%

if contains(ExtraSaveTerm,'Subset')
Partition_NameExt = 'KFoldPartition_Subset.mat';
else
Partition_NameExt = 'KFoldPartition.mat';
end
Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

%%

cfg_OUT=struct();
cfg_OUT.Model=Model_PathNameExt;
cfg_OUT.Information=Information_PathNameExt;
cfg_OUT.Accuracy=Accuracy_PathNameExt;
cfg_OUT.Importance=Importance_PathNameExt;
cfg_OUT.Partition=Partition_PathNameExt;

end

