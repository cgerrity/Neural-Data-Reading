
if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
clc; clear; close all;
end

%% Chosen Parameters

VariableName='Shared Feature Coding'; Count_Y_Lim = [0,25000];
% VariableName='Dimension 1'; Count_Y_Lim = [0,20000];
% VariableName='Dimension 2'; Count_Y_Lim = [0,20000];
% VariableName='Dimension 3'; Count_Y_Lim = [0,20000];
% VariableName='Dimension 4'; Count_Y_Lim = [0,20000];
% VariableName='Gain'; Count_Y_Lim = [0,25000];
% VariableName='Loss'; Count_Y_Lim = [0,25000];
% VariableName='Correct Trial'; Count_Y_Lim = [0,25000];
% VariableName='Learned'; Count_Y_Lim = [0,25000];
% VariableName='ACC_001'; Count_Y_Lim = [0,30000];
% VariableName='ACC_002'; Count_Y_Lim = [0,30000];
% VariableName='PFC_001'; Count_Y_Lim = [0,30000];
% VariableName='PFC_002'; Count_Y_Lim = [0,30000];
% VariableName='CD_001'; Count_Y_Lim = [0,30000];
% VariableName='CD_002'; Count_Y_Lim = [0,30000];
% VariableName='Target Feature'; Count_Y_Lim = [0,25000];
% VariableName='Trials From Learning Point'; Count_Y_Lim = [0,25000];
% VariableName = 'Trials From Learning Point Category'; Count_Y_Lim = [0,25000];
% VariableName='Session Name'; Count_Y_Lim = [0,25000];
% VariableName='Dimensionality'; Count_Y_Lim = [0,25000];
wantSubset = false;
% wantBar = false;
% wantDifference = true;

if ~(exist('Identifiers','var')&&exist('IdentifierName','var'))
[Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset);
else
[Identifiers,IdentifierName,FullDataTable] = cgg_getDataStatistics(VariableName,wantSubset,'Identifiers',Identifiers,'IdentifierName',IdentifierName);
end

cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;
% cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

Epoch=cfg_param.Epoch;
% Decoder=cfg_param.Decoder;

% outdatadir=cfg_Sessions(1).outdatadir;
% TargetDir=outdatadir;

DistributionType=VariableName;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'DistributionType',DistributionType);
[~,outputfolder_base,temporaryfolder_base,~] = cgg_getBaseFolders();

ResultsDir = [temporaryfolder_base filesep 'Data_Neural'];

cfg = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'DistributionType',DistributionType);
TitleName = VariableName;
%%

switch VariableName
    case 'Dimension 1'
        cfg_dim = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
        DimNames = cfg_dim.FeatureValues_Names([1,2,3,5]);
        TitleName = DimNames{1};
    case 'Dimension 2'
        cfg_dim = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
        DimNames = cfg_dim.FeatureValues_Names([1,2,3,5]);
        TitleName = DimNames{2};
    case 'Dimension 3'
        cfg_dim = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
        DimNames = cfg_dim.FeatureValues_Names([1,2,3,5]);
        TitleName = DimNames{3};
    case 'Dimension 4'
        cfg_dim = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
        DimNames = cfg_dim.FeatureValues_Names([1,2,3,5]);
        TitleName = DimNames{4};
    case 'Shared Feature Coding'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=categorical({'EC Shared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="2")=categorical({'EC NonShared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="3")=categorical({'EE Shared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="4")=categorical({'EE NonShared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="5")=categorical({'CC Shared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="6")=categorical({'CC NonShared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="7")=categorical({'CE Shared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="8")=categorical({'CE NonShared'});
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="9")=categorical({'Start'});

FeatureValueOrder = {'EC Shared','EC NonShared','EE Shared','EE NonShared','CC Shared','CC NonShared','CE Shared','CE NonShared','Start'};
FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'Target Feature'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Shape', 'Pattern', 'Color', 'Arms'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="2")=FeatureValueOrder{2};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="3")=FeatureValueOrder{3};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="4")=FeatureValueOrder{4};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);

    case 'Correct Trial'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Error', 'Correct'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
TitleName = 'Outcome';
    case 'Learned'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Learned', 'Learned','Non Learned Block'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="-1")=FeatureValueOrder{3};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'Trials From Learning Point Category'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Learned', 'fewer than 5','-5 to -1','0 to 9','10 to 19', 'more than 20'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="2")=FeatureValueOrder{2};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="3")=FeatureValueOrder{3};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="4")=FeatureValueOrder{4};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="5")=FeatureValueOrder{5};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="6")=FeatureValueOrder{6};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'ACC_001'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Included', 'Included'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'ACC_002'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Included', 'Included'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'PFC_001'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Included', 'Included'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'PFC_002'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Included', 'Included'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'CD_001'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Included', 'Included'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'CD_002'
FullDataTable.FeatureValue=string(FullDataTable.FeatureValue);
FeatureValueOrder = {'Not Included', 'Included'};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="0")=FeatureValueOrder{1};
FullDataTable.FeatureValue(FullDataTable.FeatureValue=="1")=FeatureValueOrder{2};

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,FeatureValueOrder);
    case 'Session Name'

FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue);

end

InVariableName=VariableName;
InEpoch=Epoch;
InSavePlotCFG=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Distribution;


cgg_plotDataDistribution(FullDataTable,InVariableName,InEpoch,InSavePlotCFG,TitleName,Count_Y_Lim)

%%

% %%
% 
% if exist('Identifiers','var')&&exist('IdentifiersName','var')
% 
% cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;
% cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
% 
% % SubsetAmount=cfg_param.SubsetAmount;
% % NumFolds=cfg_param.NumFolds;
% % Dimension = cfg_param.Dimension;
% wantSubset = false;
% 
% 
% %%
% 
% Epoch=cfg_param.Epoch;
% Decoder=cfg_param.Decoder;
% 
% outdatadir=cfg_Sessions(1).outdatadir;
% TargetDir=outdatadir;
% 
% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder{1},'Fold',1);
% 
% Partition_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;
% 
% if wantSubset
% Partition_NameExt = 'KFoldPartition_Subset.mat';
% Partition_NS_NameExt = 'KFoldPartition_Subset_NS.mat';
% else
% Partition_NameExt = 'KFoldPartition.mat';
% Partition_NS_NameExt = 'KFoldPartition_NS.mat';
% end
% Partition_PathNameExt = [Partition_Dir filesep Partition_NameExt];
% Partition_NS_PathNameExt = [Partition_Dir filesep Partition_NS_NameExt];
% 
% m_Partition = matfile(Partition_PathNameExt,'Writable',false);
% KFoldPartition=m_Partition.KFoldPartition;
% m_Partition_NS = matfile(Partition_NS_PathNameExt,'Writable',false);
% KFoldPartition_NS=m_Partition_NS.KFoldPartition;
% 
% NumKPartitions=numel(KFoldPartition);
% NumFolds=KFoldPartition(1).NumTestSets;
% SubsetAmount=KFoldPartition(1).NumObservations;
% 
% %%
% 
% TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
% Target_Fun=@(x) cgg_loadTargetArray(x);
% Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);
% 
% if wantSubset
% Target_ds=subset(Target_ds,1:SubsetAmount);
% end
% 
% %% Data Distributions to Analyze
% 
% UniqueDataIdentifiers=gather(tall(Target_ds));
% 
% Identifiers=cellfun(@(x) x{1},UniqueDataIdentifiers,'UniformOutput',false);
% 
% IdentifierName=UniqueDataIdentifiers{1}{2};
% 
% NumDatapoints=numel(Identifiers);
% NumDatapointsPerFold=round(NumDatapoints/NumFolds);
% 
% end
% %% Obtain Distribution Variables
% 
% % Full Dataset
% IdentifierIDX=strcmp(IdentifierName,DistributionVariableName);
% DistributionVariableFull=cellfun(@(x) x(IdentifierIDX),Identifiers,'UniformOutput',true);
% 
% % DistributionVariable=NaN(NumDatapointsPerFold,NumFolds,NumKPartitions);
% % DistributionVariable_NS=NaN(NumDatapointsPerFold,NumFolds,NumKPartitions);
% 
% DistributionVariable=cell(NumFolds,NumKPartitions);
% DistributionVariable_NS=cell(NumFolds,NumKPartitions);
% 
% for pidx=1:NumKPartitions
% for fidx=1:NumFolds
%     this_KFoldPartition=KFoldPartition(pidx);
%     this_KFoldPartition_NS=KFoldPartition_NS(pidx);
% 
% Testing_IDX=test(this_KFoldPartition,fidx);
% Testing_NS_IDX=test(this_KFoldPartition_NS,fidx);
% 
% this_DistributionVariable=DistributionVariableFull(Testing_IDX);
% this_DistributionVariable_NS=DistributionVariableFull(Testing_NS_IDX);
% 
% % DistributionVariable(:,fidx,pidx)=this_DistributionVariable;
% % DistributionVariable_NS(:,fidx,pidx)=this_DistributionVariable_NS;
% 
% DistributionVariable{fidx,pidx}=this_DistributionVariable;
% DistributionVariable_NS{fidx,pidx}=this_DistributionVariable_NS;
% 
% end
% end
% 
% %%
% 
% want_bar=false;
% wantDifference=true;
% 
% ClassNames=unique(DistributionVariableFull);
% NumClasses=length(ClassNames);
% 
% BinsFull = arrayfun(@(x)length(find(DistributionVariableFull == x)), ClassNames, 'Uniform', true);
% 
% BinsEach=NaN(NumClasses,NumFolds,NumKPartitions);
% BinsEach_NS=NaN(NumClasses,NumFolds,NumKPartitions);
% % for pidx=1:NumKPartitions
% % for fidx=1:NumFolds
% % % BinsEach(:,fidx,pidx) = arrayfun(@(x)length(find(DistributionVariable(:,fidx,pidx) == x)), ClassNames, 'Uniform', true);
% % % BinsEach_NS(:,fidx,pidx) = arrayfun(@(x)length(find(DistributionVariable_NS(:,fidx,pidx) == x)), ClassNames, 'Uniform', true);
% % end
% % end
% 
% for cidx=1:NumClasses
% BinsEach(cidx,:,:) = cellfun(@(x)length(find(x == ClassNames(cidx))), DistributionVariable, 'Uniform', true);
% BinsEach_NS(cidx,:,:) = cellfun(@(x)length(find(x == ClassNames(cidx))), DistributionVariable_NS, 'Uniform', true);
% end
% 
% BinsFullFrac=BinsFull./sum(BinsFull);
% BinsEachFrac=BinsEach./sum(BinsEach,1);
% BinsEachFrac_NS=BinsEach_NS./sum(BinsEach_NS,1);
% 
% BinsEachFracDiff=BinsEachFrac-BinsFullFrac;
% BinsEachFracDiff_NS=BinsEachFrac_NS-BinsFullFrac;
% 
% BinsEachFracMean=mean(BinsEachFrac,[2,3]);
% BinsEachFracMean_NS=mean(BinsEachFrac_NS,[2,3]);
% BinsEachFracSTD=std(BinsEachFrac,[],[2,3]);
% BinsEachFracSTD_NS=std(BinsEachFrac_NS,[],[2,3]);
% BinsEachFracSTE=std(BinsEachFrac,[],[2,3])/sqrt(NumFolds);
% BinsEachFracSTE_NS=std(BinsEachFrac_NS,[],[2,3])/sqrt(NumFolds);
% 
% XLocation=1:NumClasses;
% 
% 
% 
% % b_Full=bar(XLocation,BinsFullFrac);
% 
% % b_Each=bar(XLocation,BinsEachFracMean);
% 
% ClassOrder=cell(NumClasses,1);
% 
% for fidx=1:NumClasses
% ClassOrder{fidx}=num2str(ClassNames(fidx));
% end
% 
% ClassNamesFull_Array=repmat(ClassOrder,1,1);
% SourceNamesFull_Array=repmat("Full Data",NumClasses,1);
% 
% DataTable=table(ClassNamesFull_Array(:),SourceNamesFull_Array(:),BinsFullFrac(:));
% DataTable.Properties.VariableNames = ["FeatureValue","Source","Fraction"];
% 
% ClassNamesEach_Array=repmat(ClassOrder,1,NumFolds,NumKPartitions);
% SourceNamesEach_Array=repmat("Statified",NumClasses,NumFolds,NumKPartitions);
% SourceNamesEach_NS_Array=repmat("Not Stratified",NumClasses,NumFolds,NumKPartitions);
% 
% DataTable_Each=table(ClassNamesEach_Array(:),SourceNamesEach_Array(:),BinsEachFrac(:));
% DataTable_Each.Properties.VariableNames = ["FeatureValue","Source","Fraction"];
% DataTable_Each_NS=table(ClassNamesEach_Array(:),SourceNamesEach_NS_Array(:),BinsEachFrac_NS(:));
% DataTable_Each_NS.Properties.VariableNames = ["FeatureValue","Source","Fraction"];
% 
% DataTable_EachDiff=table(ClassNamesEach_Array(:),SourceNamesEach_Array(:),BinsEachFracDiff(:));
% DataTable_EachDiff.Properties.VariableNames = ["FeatureValue","Source","Fraction"];
% DataTable_EachDiff_NS=table(ClassNamesEach_Array(:),SourceNamesEach_NS_Array(:),BinsEachFracDiff_NS(:));
% DataTable_EachDiff_NS.Properties.VariableNames = ["FeatureValue","Source","Fraction"];
% 
% FullDataTable=[DataTable;DataTable_Each;DataTable_Each_NS];
% FullDataTableDiff=[DataTable_EachDiff;DataTable_EachDiff_NS];
% 
% FullDataTable.FeatureValue = categorical(FullDataTable.FeatureValue,ClassOrder);
% FullDataTableDiff.FeatureValue = categorical(FullDataTableDiff.FeatureValue,ClassOrder);
% %%
% if wantBar
% 
% % XLocation=1:NumClasses;
% 
% % b_All=bar(XLocation,[BinsFullFrac,BinsEachFracMean,BinsEachFracMean_NS]);
% 
% BinsFullFrac=FullDataTable.Fraction(strcmp(FullDataTable.Source,'Full Data'));
% BinsFullFracName=FullDataTable.FeatureValue(strcmp(FullDataTable.Source,'Full Data'));
% 
% b_All=bar(BinsFullFrac);
% 
% % XLocationAll={b_All.XEndPoints};
% % XLocationEach=XLocationAll{2};
% % XLocationEach_NS=XLocationAll{3};
% 
% xticklabels(BinsFullFracName);
% xlabel('Difficulty');
% ylabel('Number of Trials');
% 
% % hold on
% % eror_Each = errorbar(XLocationEach,BinsEachFracMean,BinsEachFracSTE,BinsEachFracSTE); 
% % eror_Each_NS = errorbar(XLocationEach_NS,BinsEachFracMean_NS,BinsEachFracSTE_NS,BinsEachFracSTE_NS); 
% % hold off
% % 
% % eror_Each.Color = [0 0 0];   
% % eror_Each.LineStyle = 'none'; 
% % 
% % eror_Each_NS.Color = [0 0 0];   
% % eror_Each_NS.LineStyle = 'none'; 
% 
% else
% 
% 
% % swarmchart(ClassNamesCat,BinsFullFrac)
% % hold on
% % swarmchart(ClassNamesCat,BinsEachFrac_NS)
% % swarmchart(ClassNamesCat,BinsEachFrac)
% % hold off
% 
% % boxchart(BinsFullFrac')
% % hold on
% % boxchart(BinsEachFrac_NS')
% % boxchart(BinsEachFrac')
% % hold off
% 
% if wantDifference
% 
% b_Distribution=boxchart(FullDataTableDiff.FeatureValue,FullDataTableDiff.Fraction,'GroupByColor',FullDataTableDiff.Source,'Notch','on');
% 
% else
% b_Distribution=boxchart(FullDataTable.FeatureValue,FullDataTable.Fraction,'GroupByColor',FullDataTable.Source,'Notch','on');
% 
% % ylim([0,0.12]);
% b_Distribution(3).LineWidth=2;
% b_Distribution(3).BoxWidth=0.75;
% end
% legend
% 
% b_Distribution(1).LineWidth=2;
% b_Distribution(2).LineWidth=2;
% 
% b_Distribution(1).BoxWidth=0.75;
% b_Distribution(2).BoxWidth=0.75;
% 
% % yline(0);
% 
% end
% 
% title(VariableName)
