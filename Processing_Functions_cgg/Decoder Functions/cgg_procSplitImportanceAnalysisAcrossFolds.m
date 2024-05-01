function [OutTable_Cell,TypeValues_Cell,Identifiers_Table] = ...
    cgg_procSplitImportanceAnalysisAcrossFolds(VariableName,Epoch,...
    Decoder,FoldStart,FoldEnd,wantSubset,INcfg,varargin)
%CGG_PROCSPLITIMPORTANCEANALYSISACROSSFOLDS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Identifiers_Table = CheckVararginPairs('Identifiers_Table', '', varargin{:});
else
if ~(exist('Identifiers_Table','var'))
Identifiers_Table='';
end
end

MetricWanted='Importance';
SubMetricWanted='CM_Table_IA';
FilterColumn=VariableName;

%%

TargetDir=INcfg.TargetDir.path;
ResultsDir=INcfg.ResultsDir.path;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'ImportanceAnalysis',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'ImportanceAnalysis',true);
cfg.ResultsDir=cfg_tmp.TargetDir;

SavePath=cfg.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ImportanceAnalysis.ImportanceAnalysisData.path;
SaveNameExt=sprintf('Importance_Split_%s.mat',VariableName);

SavePathNameExt=[SavePath filesep SaveNameExt];

if isfile(SavePathNameExt)
m_Split=matfile(SavePathNameExt,"Writable",false);
if ~isempty(who(m_Split,'OutTable_Cell'))
OutTable_Cell=m_Split.OutTable_Cell;
end
if ~isempty(who(m_Split,'TypeValues_Cell'))
TypeValues_Cell=m_Split.TypeValues_Cell;
end
if ~isempty(who(m_Split,'Identifiers_Table'))
Identifiers_Table=m_Split.Identifiers_Table;
end
end

%%

if isempty(Identifiers_Table)
[Identifiers,IdentifierName,~] = cgg_getDataStatistics(VariableName,wantSubset);

InputIdentifiers=cell2mat(Identifiers);
InputNames=cellstr(IdentifierName);
InputNames{strcmp(InputNames,'Data Number')}='DataNumber';

Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);
end

%%

if ~(exist('OutTable_Cell','var') && exist('TypeValues_Cell','var'))

NumFolds = numel(FoldStart:FoldEnd); 

ClassNames=[];

OutTable_Cell=cell(1,NumFolds);
TypeValues_Cell=cell(1,NumFolds);

for fidx=FoldStart:FoldEnd

    Fold = fidx;

    if wantSubset
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',[Decoder,'_Subset'],'Fold',Fold,...
    'ImportanceAnalysis',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Decoder',[Decoder,'_Subset'],'Fold',Fold,...
    'ImportanceAnalysis',true);
cfg.ResultsDir=cfg_tmp.TargetDir;
    else
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold,'ImportanceAnalysis',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold,'ImportanceAnalysis',true);
cfg.ResultsDir=cfg_tmp.TargetDir;
    end

this_cfg_Decoder = cgg_generateDecoderVariableSaveNames(Decoder,cfg,wantSubset);

m_Partition = matfile(this_cfg_Decoder.Partition,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

this_MetricPathNameExt=this_cfg_Decoder.(MetricWanted);

m_Metric = matfile(this_MetricPathNameExt,'Writable',false);
this_CM_Table_IA = m_Metric.(SubMetricWanted);

TrueValue=this_CM_Table_IA.CM_Table{1}{1}.TrueValue;
[~,NumDimension]=size(TrueValue);
ClassNames=cell(1,NumDimension);
for didx=1:NumDimension
this_ClassNames=unique(TrueValue(:,didx));
ClassNames{didx}=unique(this_ClassNames);
end

this_TestingIDX=test(KFoldPartition,fidx);

this_Identifiers_Table=Identifiers_Table(this_TestingIDX,:);

[OutTable_Cell{fidx},TypeValues_Cell{fidx}] = cgg_procImportanceAnalysisFromTable(this_CM_Table_IA,ClassNames,this_Identifiers_Table,'FilterColumn',FilterColumn);

end % End of Fold loop
end % End of existence check
%%

SaveVariables=cell(1,3);
SaveVariablesName=cell(1,3);

SaveVariables{1}=OutTable_Cell;
SaveVariables{2}=TypeValues_Cell;
SaveVariables{3}=Identifiers_Table;

SaveVariablesName{1}='OutTable_Cell';
SaveVariablesName{2}='TypeValues_Cell';
SaveVariablesName{3}='Identifiers_Table';

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt)


end

