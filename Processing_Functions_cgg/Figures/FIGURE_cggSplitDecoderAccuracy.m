

if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
clc; clear; close all;
end

Epoch = 'Decision';
FoldStart = 1; FoldEnd = 10;
NumFolds = numel(FoldStart:FoldEnd); 
SamplingFrequency=1000;
wantSubset = true;
wantStratifiedPartition = true;

VariableName='Correct Trial';

X_Name='Time (s)';
Y_Name='Accuracy';


%%

if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
[Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset);
else
% [Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset,'Identifiers',Identifiers,'IdentifierName',IdentifierName);
end

%%

cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

DataWidth = cfg_Decoder.DataWidth/SamplingFrequency;
WindowStride = cfg_Decoder.WindowStride/SamplingFrequency;

Decoders = cfg_Decoder.Decoder;
NumDecoders = length(Decoders);

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;

if wantSubset
    if wantStratifiedPartition
Partition_NameExt = 'KFoldPartition_Subset.mat';
    else
Partition_NameExt = 'KFoldPartition_Subset_NS.mat';
    end
else
    if wantStratifiedPartition
Partition_NameExt = 'KFoldPartition.mat';
    else
Partition_NameExt = 'KFoldPartition_NS.mat';
    end
end

Each_Prediction=cell(NumDecoders,NumFolds);
EachIdentifiers=cell(NumDecoders,NumFolds);

ClassNames=[];

for didx=1:NumDecoders
for fidx=FoldStart:FoldEnd

    Fold = fidx;
    Decoder = Decoders{didx};

    if wantSubset
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',[Decoder,'_Subset'],'Fold',Fold);
    else
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);
    end

Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;

Partition_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

if wantSubset
Accuracy_NameExt = sprintf('%s_Accuracy_Subset.mat',Decoder);
else
Accuracy_NameExt = sprintf('%s_Accuracy.mat',Decoder);
end

Accuracy_PathNameExt = [Decoding_Dir filesep Accuracy_NameExt];

m_Accuracy = matfile(Accuracy_PathNameExt,'Writable',false);
Each_Prediction{didx,fidx} = m_Accuracy.Each_Prediction;

this_TestingIDX=test(KFoldPartition,fidx);

EachIdentifiers{didx,fidx}=Identifiers(this_TestingIDX);

end

this_ClassNames=cell2mat(transpose(cellfun(@(x2) cell2mat(x2),Each_Prediction{1,fidx},'UniformOutput',false)));
this_ClassNames=this_ClassNames(:,1);
this_ClassNames=unique(this_ClassNames);
ClassNames=unique([ClassNames;this_ClassNames]);
end

InSavePlotCFG = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Plots;
%%

this_fidx=1;
this_didx=1;
this_widx=1;

PlotTitle=sprintf('Accuracy split by %s for Decoder: %s',VariableName,Decoders{this_didx});

for fidx=1:NumFolds

CM_Cell=Each_Prediction{this_didx,fidx};
CM_Table = cgg_gatherConfusionMatrixCellToTable(CM_Cell);

InputIdentifiers=cell2mat(EachIdentifiers{this_didx,fidx});
InputNames=cellstr(IdentifierName);
InputNames{strcmp(InputNames,'Data Number')}='DataNumber';

Identifiers_Table=array2table(InputIdentifiers,'VariableNames',InputNames);

CMFull_Table=join(CM_Table,Identifiers_Table);

NumWindows=contains(CMFull_Table.Properties.VariableNames,'Window_');
NumWindows=sum(NumWindows);

%%

if strcmp(VariableName,'All')
TypeValues="All";
NumTypes=length(TypeValues);
else
this_DistributionVariable=CMFull_Table.(VariableName);
TypeValues=unique(this_DistributionVariable);
NumTypes=length(TypeValues);
end

if fidx==1
SplitAccuracy=NaN(NumFolds,NumWindows,NumTypes);
end
PlotNames=cell(1,NumTypes);

for tidx=1:NumTypes
    PlotNames{tidx}=num2str(TypeValues(tidx));
    for widx=1:NumWindows

this_WindowName=sprintf('Window_%d',widx);

if strcmp(VariableName,'All')
    [NumRows,~]=size(CMFull_Table);
    this_Selection=true(NumRows,1);
else
    this_Selection=CMFull_Table.(VariableName)==TypeValues(tidx);
end

this_CM_Table = CMFull_Table(this_Selection,["TrueValue",this_WindowName]);

this_TrueValue=this_CM_Table.TrueValue;
this_PredictedValue=this_CM_Table.(this_WindowName);

this_CM = confusionmat(this_TrueValue,this_PredictedValue,'Order',ClassNames);

TruePositives = trace(this_CM);
TotalObservations = sum(this_CM(:));
SplitAccuracy(fidx,widx,tidx) = TruePositives/TotalObservations;

    end
end

end



[fig_plot,p_Plots,p_Error] = cgg_plotTimeSeriesPlot(SplitAccuracy,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'SamplingRate',SamplingFrequency,'X_Name',X_Name,'Y_Name',Y_Name,'PlotTitle',PlotTitle,'PlotNames',PlotNames);


% %%
% this_fidx=1;
% this_didx=2;
% 
% IdentifierIDX=strcmp(IdentifierName,VariableName);
% DistributionVariableFull=cellfun(@(x) x(IdentifierIDX),EachIdentifiers{this_didx,this_fidx},'UniformOutput',true);
% 
% this_Each_Prediction=Each_Prediction{this_didx,this_fidx};
% 
% TypeValues=unique(DistributionVariableFull);
% NumTypes=length(TypeValues);
% 
% this_ClassNames=[0,3,7,8];
% 
% Full_CM=zeros(length(this_ClassNames),length(this_ClassNames),NumTypes);
% SplitAccuracy=NaN(1,NumTypes);
% 
% for tidx=1:NumTypes
%     this_Full_CM=length(this_ClassNames);
% 
%     this_Type=TypeValues(tidx);
% 
%     this_TypeIDX=DistributionVariableFull==this_Type;
% 
%     this_Prediction=this_Each_Prediction(this_TypeIDX);
% 
%     NumPredictions=numel(this_Prediction);
% 
%     for pidx=1:NumPredictions
% 
%     this_CM_1=cellfun(@(x) x(1),this_Prediction{pidx});
%     this_CM_2=cellfun(@(x) x(2),this_Prediction{pidx});
%     this_CM=[this_CM_1,this_CM_2];
% 
%     this_CM = confusionmat(this_CM(:,1),this_CM(:,2),'Order',this_ClassNames);
% 
%     this_Full_CM = this_Full_CM+this_CM;
%     end
% 
%     Full_CM(:,:,tidx)=this_Full_CM;
% 
%     TruePositives = trace(this_Full_CM);
% TotalObservations = sum(this_Full_CM(:));
% SplitAccuracy(tidx) = TruePositives/TotalObservations;
% end
% 
% figure;
% bar(SplitAccuracy)
% 
% xticklabels(TypeValues);
% 
% title(VariableName);
% ylabel('Accuracy');
