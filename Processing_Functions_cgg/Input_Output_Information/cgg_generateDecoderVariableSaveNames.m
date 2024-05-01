function cfg_OUT = cgg_generateDecoderVariableSaveNames(Decoder,cfg_IN,wantSubset,varargin)
%CGG_GENERATEDECODERVARIABLESAVENAMES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%%

if isfunction
Dimension = CheckVararginPairs('Dimension', '', varargin{:});
else
if ~(exist('Dimension','var'))
Dimension='';
end
end
%%

% Decoding_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;
% Partition_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

Decoding_Dir = cfg_IN.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;
Partition_Dir = cfg_IN.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

%%
if wantSubset
    if isempty(Dimension)
Model_NameExt = sprintf('%s_Model_Subset.mat',Decoder);
ModelTMP_NameExt = sprintf('%s_Model_Subset_tmp.mat',Decoder);
    else
Model_NameExt = sprintf('%s_Model_Dimension_%s_Subset.mat',Decoder,'%d');
ModelTMP_NameExt = sprintf('%s_Model_Dimension_%s_Subset_tmp.mat',Decoder,'%d');
    end
Information_NameExt = sprintf('%s_Information_Subset.mat',Decoder);
Accuracy_NameExt = sprintf('%s_Accuracy_Subset.mat',Decoder);
Importance_NameExt = sprintf('%s_Importance_Subset.mat',Decoder);
ImportanceTMP_NameExt = sprintf('%s_Importance_Subset_tmp.mat',Decoder);
else
    if isempty(Dimension)
Model_NameExt = sprintf('%s_Model.mat',Decoder);
ModelTMP_NameExt = sprintf('%s_Model_tmp.mat',Decoder);  
    else
Model_NameExt = sprintf('%s_Model_Dimension_%s.mat',Decoder,'%d');
ModelTMP_NameExt = sprintf('%s_Model_Dimension_%s_tmp.mat',Decoder,'%d');
    end
Information_NameExt = sprintf('%s_Information.mat',Decoder);
Accuracy_NameExt = sprintf('%s_Accuracy.mat',Decoder);
Importance_NameExt = sprintf('%s_Importance.mat',Decoder);
ImportanceTMP_NameExt = sprintf('%s_Importance_tmp.mat',Decoder);
end

%%

if ~(isempty(Dimension))
Model_PathNameExt=cell(1,length(Dimension));
ModelTMP_PathNameExt=cell(1,length(Dimension));
for fdidx=1:length(Dimension)
Model_PathNameExt{fdidx} = sprintf([Decoding_Dir filesep Model_NameExt],Dimension(fdidx));
ModelTMP_PathNameExt{fdidx} = sprintf([Decoding_Dir filesep ModelTMP_NameExt],Dimension(fdidx));
end
else
Model_PathNameExt=cell(1);
ModelTMP_PathNameExt=cell(1);
Model_PathNameExt{1} = [Decoding_Dir filesep Model_NameExt];
ModelTMP_PathNameExt{1} = [Decoding_Dir filesep ModelTMP_NameExt];
end
Information_PathNameExt = [Decoding_Dir filesep Information_NameExt];
Accuracy_PathNameExt = [Decoding_Dir filesep Accuracy_NameExt];
Importance_PathNameExt = [Decoding_Dir filesep Importance_NameExt];
ImportanceTMP_PathNameExt = [Decoding_Dir filesep ImportanceTMP_NameExt];

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
cfg_OUT.ImportanceTMP=ImportanceTMP_PathNameExt;
cfg_OUT.Partition=Partition_PathNameExt;

end

