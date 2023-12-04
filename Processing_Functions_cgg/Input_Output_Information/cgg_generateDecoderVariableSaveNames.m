function cfg_OUT = cgg_generateDecoderVariableSaveNames(Decoder,cfg_IN,wantSubset)
%CGG_GENERATEDECODERVARIABLESAVENAMES Summary of this function goes here
%   Detailed explanation goes here

%%

Decoding_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;
Partition_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

%%
if wantSubset
Model_NameExt = sprintf('%s_Model_Subset.mat',Decoder);
ModelTMP_NameExt = sprintf('%s_Model_Subset_tmp.mat',Decoder);
Information_NameExt = sprintf('%s_Information_Subset.mat',Decoder);
Accuracy_NameExt = sprintf('%s_Accuracy_Subset.mat',Decoder);
Importance_NameExt = sprintf('%s_Importance_Subset.mat',Decoder);
else
Model_NameExt = sprintf('%s_Model.mat',Decoder);
ModelTMP_NameExt = sprintf('%s_Model_tmp.mat',Decoder);
Information_NameExt = sprintf('%s_Information.mat',Decoder);
Accuracy_NameExt = sprintf('%s_Accuracy.mat',Decoder);
Importance_NameExt = sprintf('%s_Importance.mat',Decoder);
end

%%

Model_PathNameExt = [Decoding_Dir filesep Model_NameExt];
ModelTMP_PathNameExt = [Decoding_Dir filesep ModelTMP_NameExt];
Information_PathNameExt = [Decoding_Dir filesep Information_NameExt];
Accuracy_PathNameExt = [Decoding_Dir filesep Accuracy_NameExt];
Importance_PathNameExt = [Decoding_Dir filesep Importance_NameExt];

%%

if wantSubset
Partition_NameExt = 'KFoldPartition_Subset.mat';
else
Partition_NameExt = 'KFoldPartition.mat';
end
Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

%%

cfg_OUT=struct();
cfg_OUT.Model=Model_PathNameExt;
cfg_OUT.ModelTMP=ModelTMP_PathNameExt;
cfg_OUT.Information=Information_PathNameExt;
cfg_OUT.Accuracy=Accuracy_PathNameExt;
cfg_OUT.Importance=Importance_PathNameExt;
cfg_OUT.Partition=Partition_PathNameExt;

end

