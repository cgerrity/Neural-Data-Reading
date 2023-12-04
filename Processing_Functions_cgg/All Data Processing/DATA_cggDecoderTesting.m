%% DATA_cggDecoderTesting

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

%%

sidx=1;
inputfolder=cfg(sidx).inputfolder;
outdatadir=cfg(sidx).outdatadir;
temporarydir=cfg(sidx).temporarydir;
SessionFolder=cfg(sidx).SessionFolder;
Epoch='Decision';
TargetDir=outdatadir;
TemporaryDir=temporarydir;

[cfg_Decoder] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,...
    'Epoch',Epoch);
[cfg_Temporary] = cgg_generateTemporaryDataFolders('TemporaryDir',TemporaryDir,...
    'Epoch',Epoch);
cfg_Decoding = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Fold',1);

%%
DataWidth = 250;
% StartingIDX = 'All';
StartingIDX = 1;
EndingIDX = StartingIDX;
WindowStride = 25;
NumFolds = 10;
cfg = cfg_Decoder;

cgg_procSimpleDecoders(DataWidth,StartingIDX,EndingIDX,WindowStride,NumFolds,cfg,'Decision',3);
%%

DataWidth = 100;
StartingIDX = 'All';
EndingIDX = 'All';
% StartingIDX = 1;
WindowStride = 25;
NumFolds = 10;
cfg = cfg_Decoding;

cgg_procSimpleDecoders_v2(DataWidth,StartingIDX,EndingIDX,WindowStride,NumFolds,cfg,'Decision',3);
%%
SubsetAmount=900;

[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,'Dimension',3);

Combined_ds=subset(Combined_ds,1:SubsetAmount);

this_NumObservations=numpartitions(Combined_ds);

KFoldPartition = cvpartition(this_NumObservations,"KFold",NumFolds);

kidx=1;

this_Training_IDX=training(KFoldPartition,kidx);
this_Testing_IDX=test(KFoldPartition,kidx);

this_TrainingCombined_ds=subset(Combined_ds,this_Training_IDX);
this_TestingCombined_ds=subset(Combined_ds,this_Testing_IDX);

this_TrainingCombined_ds = shuffle(this_TrainingCombined_ds);

this_NumTraining=numpartitions(this_TrainingCombined_ds);
this_NumTesting=numpartitions(this_TestingCombined_ds);

MdlLinear = incrementalClassificationECOC(MaxNumClasses=4,Coding="onevsall",Learners="linear");

    X_testing=cell(this_NumTesting,1);
    Y_testing=cell(this_NumTesting,1);
    parfor sidx=1:this_NumTesting
        this_tmp_Datastore=partition(this_TestingCombined_ds,this_NumTesting,sidx);
        this_Values=read(this_tmp_Datastore);
        this_X=this_Values{1};
        [NumExamples,~]=size(this_X);
        this_Y=repmat(this_Values{2},[NumExamples,1]);
        X_testing{sidx}=this_X;
        Y_testing{sidx}=this_Y;
    end
    X_testing=cell2mat(X_testing);
    Y_testing=cell2mat(Y_testing);

numObsPerChunk = 100;
NumChunks = 100;
AccuracyLinear=NaN(1,NumChunks);
Beta=NaN(1,NumChunks);
%
for cidx = 1:NumChunks
    
    X_training=cell(numObsPerChunk,1);
    Y_training=cell(numObsPerChunk,1);
    for sidx=1:numObsPerChunk
        this_ObsIDX=mod((cidx-1)*numObsPerChunk+sidx-1,this_NumTraining)+1;
        this_tmp_Datastore=partition(this_TrainingCombined_ds,this_NumTraining,this_ObsIDX);
        this_Values=read(this_tmp_Datastore);
        this_X=this_Values{1};
        [NumExamples,~]=size(this_X);
        this_Y=repmat(this_Values{2},[NumExamples,1]);
        X_training{sidx}=this_X;
        Y_training{sidx}=this_Y;
%         disp(this_Y);
    end
    X_training=cell2mat(X_training);
    Y_training=cell2mat(Y_training);

    MdlLinear = fit(MdlLinear,X_training,Y_training);

    Y_predicted = predict(MdlLinear,X_testing);

    [cm_values,order_tmp] = confusionmat(Y_testing,Y_predicted);

    TruePositives = trace(cm_values);
    TotalObservations = sum(cm_values(:));
    AccuracyLinear(cidx) = TruePositives/TotalObservations;
    Beta(cidx)=MdlLinear.BinaryLearners{1, 1}.Beta(1);
end

%%

DataAggregateDir=cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
TargetAggregateDir=cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
ProcessingDir=cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Processing.path;

TargetInformation_PathNameExt=[ProcessingDir filesep 'Target_Information.mat'];

DataAggregate_PathNameExt=[DataAggregateDir filesep ...
    Epoch '_Data_%d.mat'];
Target_PathNameExt=[TargetAggregateDir filesep ...
    Epoch 'Target_%d.mat'];

%%
% existTargetInformation=isfile(TargetInformation_PathNameExt);
% 
% % If the aggregated target exists then load it 
% if existTargetInformation
%     m_TargetInformation = matfile(...
%         TargetInformation_PathNameExt,'Writable',true);
%     TargetInformation=m_TargetInformation.TargetInformation;
% end

%%

% Create a datastore for .mat files in the folder

Dimension=3;
% DataWidth='All';
DataWidth=100;
WindowStride=25;
ChannelRemoval=[];
WantDisp=false;
WantRandomize=true;
WantNaNZeroed=false;
Want1DVector=true;
StartingIDX='All';
EndingIDX='All';

% 3001+1-smalldata
ReadDataArray_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,false);
ReadTallDataArray_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,true,true);
ReadFullDataArray_Fun=@(x) cgg_loadDataArray(x,'All',StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,false);

Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",ReadDataArray_Fun);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",@(x) cgg_loadTargetArray(x,'Dimension',Dimension));

FullData_ds = fileDatastore(DataAggregateDir,"ReadFcn",ReadFullDataArray_Fun);
TallData_ds = fileDatastore(DataAggregateDir,"ReadFcn",ReadTallDataArray_Fun);

trainData=combine(Data_ds,Target_ds);
TallCombined_ds=combine(TallData_ds,Target_ds);

imds = imageDatastore(DataAggregateDir,"FileExtensions",".mat","ReadFcn",ReadDataArray_Fun);

inputSize=size(preview(imds));
[NumChannels,NumSamples,NumProbes]=size(preview(FullData_ds));
%%
bbb = signalDatastore(cfg_Temporary.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch.Data.path,'SignalVariableNames',["X"],'IncludeSubfolders',true);
aaa=imageDatastore(cfg_Temporary.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch.Data.path,'LabelSource','foldernames',"FileExtensions",".mat",'IncludeSubfolders',true,"ReadFcn",@(x) getfield(load(x),'X'));
aaaa=cell2mat(tall(aaa));
bbbb=tall(aaa.Labels);
mdlLinear = fitcecoc(gather(aaaa),gather(bbbb),'Coding','onevsall','Verbose',2,'Learners','linear');
%%
% 
% NumWindows=NumSamples+1-DataWidth;
% % NumWindows=10;
% 
% for sidx=1:NumWindows
% this_ReadTallDataArray_Fun=@(x) cgg_loadDataArray(x,DataWidth,sidx,WantDisp,WantRandomize,true,true);
% TallCombined_ds.UnderlyingDatastores{1, 1}.ReadFcn = this_ReadTallDataArray_Fun;
% % this_TallData_ds = TallData_ds;
% % % this_TallData_ds = fileDatastore(DataAggregateDir,"ReadFcn",this_ReadTallDataArray_Fun);
% % 
% % this_AllTallCombined_ds=combine(this_TallData_ds,Target_ds);
% 
% this_AllCombined_tall=tall(TallCombined_ds);
% this_Tall_Data=this_AllCombined_tall(:,1);
% this_Tall_Target=this_AllCombined_tall(:,2);
% 
% this_t2 = cellfun(@(im) permute(im, [2, 1]), this_Tall_Data, 'UniformOutput', false);
% this_t3 = cellfun(@(im) permute(im, [2, 1]), this_Tall_Target, 'UniformOutput', false);
% 
% this_t2 = cell2mat(this_t2);
% this_t3 = cell2mat(this_t3);
% this_t3 = categorical(this_t3);
% 
% if sidx==1
% All_X=this_t2;
% All_Y=this_t3;
% else
% All_X=[All_X;this_t2];
% All_Y=[All_Y;this_t3];
% end
% 
% % if sidx==1
% % % AllTallCombined_ds=combine(this_TallData_ds,Target_ds);
% % this_AllCombined_tall=tall(TallCombined_ds);
% % else
% % AllTallCombined_ds=combine(AllTallCombined_ds,this_TallData_ds,Target_ds);
% % end
% 
% end
% %%
% disp('Starting Classifier');
% mdlLinear = fitcecoc(All_X,All_Y,'Coding','onevsall','Verbose',2);
% errorLinear = gather(loss(mdlLinear,All_X,All_Y));
% label = predict(mdlLinear,All_X);
% cm = confusionchart(All_Y,label,'RowSummary','row-normalized','ColumnSummary','column-normalized');

%%
NumFolds=10;
SubsetAmount=500;
WantTallSubset=false;

NumObservations=numpartitions(TallCombined_ds);

if WantTallSubset
this_NumObservations=SubsetAmount;
else
this_NumObservations=NumObservations;
end

KFoldPartition = cvpartition(this_NumObservations,"KFold",NumFolds);



TallCombined_ds_sub=subset(TallCombined_ds,1:SubsetAmount);
% AllTallCombined_ds_sub=subset(AllTallCombined_ds,1:SubsetAmount);
TallData_ds_sub=subset(TallData_ds,1:SubsetAmount);
Target_ds_sub=subset(Target_ds,1:SubsetAmount);

if WantTallSubset
Combined_tall=tall(TallCombined_ds_sub);
imtall=tall(TallData_ds_sub);
Target_tall=tall(Target_ds_sub);
% AllCombined_tall=tall(AllTallCombined_ds_sub);
else
Combined_tall=tall(TallCombined_ds);
imtall=tall(TallData_ds);
Target_tall=tall(Target_ds);
% AllCombined_tall=tall(AllTallCombined_ds);
end
%%
disp('Starting Tall Array Section')
Tall_Data=Combined_tall(:,1);
Tall_Target=Combined_tall(:,2);

All_X=cell2mat(Tall_Data);

Data_Sizes = cellfun(@(x) size(x), Tall_Data, 'UniformOutput', false);
Data_Sizes = cellfun(@(x) x(1), Data_Sizes, 'UniformOutput', false);

All_Y = cellfun(@(x,y) repmat(x,y,1),Tall_Target,Data_Sizes, 'UniformOutput', false);
All_Y = cell2mat(All_Y);
% All_Y = categorical(All_Y);

% [NumDataExample,~]=size(All_Y);
% NewOrder=randperm(gather(NumDataExample));

disp('Starting Classifier');
mdlLinear = fitcecoc(All_X,All_Y,'Coding','onevsall','Verbose',2);
%
errorLinear = gather(loss(mdlLinear,All_X,All_Y));
% label = predict(mdlLinear,All_X);

GroupLabels=sort(gather(unique(All_Y,'rows')));

NumIter=15;
for idx=1:NumIter
label = predict(mdlLinear,All_X);
cm_values_tmp(:,:,idx) = gather(confusionmat(All_Y,label));
end

cm_values=mode(cm_values_tmp,3);


% TrueLabels = gather(All_Y);
% PredictedLabels = gather(label);
% PredictedLabels= = 
cm = confusionchart(cm_values,GroupLabels,'RowSummary','row-normalized','ColumnSummary','column-normalized');

TruePositives = trace(cm_values);
TotalObservations = sum(cm_values(:));
AccuracyLinear = TruePositives/TotalObservations;

% cm_values = gather(confusionmat(TrueLabels,PredictedLabels));
% TruePositives = sum(All_Y==label);
% TruePositives_tmp = sum(TrueLabels==PredictedLabels);
% TotalObservations = length(label);
% TotalObservations_tmp = length(TrueLabels);
% AccuracyLinear = gather(TruePositives/TotalObservations);
% AccuracyLinear_tmp = TruePositives_tmp/TotalObservations_tmp;

% %%
% Tall_Data=Combined_tall(:,1);
% Tall_Target=Combined_tall(:,2);
% 
% for sidx=1:NumWindows
%     this_idx=(sidx-1)*2;
% this_Tall_Data=AllCombined_tall(:,this_idx+1);
% this_Tall_Target=AllCombined_tall(:,this_idx+2);
% 
% 
% this_t2 = cellfun(@(im) permute(im, [2, 1]), this_Tall_Data, 'UniformOutput', false);
% this_t3 = cellfun(@(im) permute(im, [2, 1]), this_Tall_Target, 'UniformOutput', false);
% 
% this_t2 = cell2mat(this_t2);
% this_t3 = cell2mat(this_t3);
% this_t3 = categorical(this_t3);
% 
% if sidx==1
% All_X=this_t2;
% All_Y=this_t3;
% else
% All_X=[All_X;this_t2];
% All_Y=[All_Y;this_t3];
% end
% 
% end
% 
% disp('Starting Classifier');
% mdlLinear = fitcecoc(All_X,All_Y,'Coding','onevsall','Verbose',2);
% errorLinear = gather(loss(mdlLinear,All_X,All_Y));
% label = predict(mdlLinear,All_X);
% cm = confusionchart(All_Y,label,'RowSummary','row-normalized','ColumnSummary','column-normalized');
% %%
% t2 = cellfun(@(im) permute(im, [2, 1]), Tall_Data, 'UniformOutput', false);
% t3 = cellfun(@(im) permute(im, [2, 1]), Tall_Target, 'UniformOutput', false);
% t2 = cell2mat(t2);
% % t2 = t2(:,1:50);
% % gather(size(t2))
% % gather(classUnderlying(t2))
% t3 = cell2mat(t3);
% t3 = categorical(t3);
% % gather(size(t3))
% % gather(classUnderlying(t3))
% % 
% % mdlLinear = fitcecoc(t2,t3,'Coding','onevsall','Verbose',2);
% % errorLinear = gather(loss(mdlLinear,t2,t3));
% 
% % % mdlLinear = fitcecoc(All_X,All_Y,'Coding','onevsall','Verbose',2);
% % % errorLinear = gather(loss(mdlLinear,All_X,All_Y));

%%
tic
Labels_tmp=readall(Target_ds);
toc
tic
Labels_tmp_tmo=gather(Tall_Target);
toc
%%
imds.Labels=categorical(diag(diag([Labels_tmp{:}])));

% countlabels(trainData,'UnderlyingDatastoreIndex',2)
% LabelInformation=countEachLabel(imds);
LabelInformation = cgg_procDataLabelInformation(imds);

[NumClasses,~]=size(LabelInformation);

% % Set the ReadFcn to load the .mat files
% matFilesDatastore.ReadFcn = @(file) load(file);

%%

% Total_Data_Start=14900;
% Total_Data_End=15000;

Total_Data_Start=1;
Total_Data_End=500;

Amount_Data='All';

if isequal(Amount_Data,'All')
imds_tmp=imds;
else
imds_tmp=subset(imds,Total_Data_Start:Total_Data_End);
end

[trainImds, valImds] = splitEachLabel(imds_tmp, 0.8, 'randomized');

LabelInformation_Train = cgg_procDataLabelInformation(trainImds);
LabelInformation_Val = cgg_procDataLabelInformation(valImds);

[NumClasses_Train,~]=size(LabelInformation_Train);
[NumClasses_Val,~]=size(LabelInformation_Val);
%%
% inputSize_each=NaN(length(imds.Files),length(inputSize));

% % for idx=1:length(imds.Files)
% for idx=1:941
% inputSize_each(idx,:)=size(read(imds));
% end
%%
% 
% digitDatasetPath = fullfile(matlabroot,'toolbox','nnet', ...
%     'nndemos','nndatasets','DigitDataset');
% imds = imageDatastore(digitDatasetPath, ...
%     'IncludeSubfolders',true, ...
%     'LabelSource','foldernames');

%%
Decoding_Dir = cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

LinearDecoder_NameExt = 'Linear_Decoder.mat';
LinearConfusionMatrix_NameExt = 'Linear_ConfusionMatrix.mat';
LinearInformation_NameExt = 'Linear_Information.mat';
LinearAccuracy_NameExt = 'Linear_Accuracy.mat';

LinearDecoder_PathNameExt = [Decoding_Dir filesep LinearDecoder_NameExt];
LinearConfusionMatrix_PathNameExt = [Decoding_Dir filesep LinearConfusionMatrix_NameExt];
LinearInformation_PathNameExt = [Decoding_Dir filesep LinearInformation_NameExt];
LinearAccuracy_PathNameExt = [Decoding_Dir filesep LinearAccuracy_NameExt];

m_LinearConfusionMatrix = matfile(LinearConfusionMatrix_PathNameExt,'Writable',true);
ConfusionMatrix = m_LinearConfusionMatrix.ConfusionMatrix;
m_LinearInformation = matfile(LinearInformation_PathNameExt,'Writable',true);
ConfusionMatrixEach_All = m_LinearInformation.ConfusionMatrixEach;
Order = m_LinearInformation.ConfusionMatrixOrder;
KFoldPartition = m_LinearInformation.Partition;
m_LinearAccuracy = matfile(LinearAccuracy_PathNameExt,'Writable',true);
AccuracyLinear_All = m_LinearAccuracy.Accuracy;

%%

% Order=[0,3,7,8];

[Accuracy,Accuracy_STE,Accuracy_NoZero,Accuracy_NoZero_STE,...
    ConfusionMatrix_Mean,ConfusionMatrix_STE,ConfusionMatrix_Order] = ...
    cgg_getAccuracyStatistics(ConfusionMatrix,Order);

this_CM=ConfusionMatrix_Mean;
this_CM=round(this_CM);
% this_CM=this_CM(1:4,1:4);

NumGroups=length(this_CM);

cm=confusionchart(this_CM,ConfusionMatrix_Order,'ColumnSummary','column-normalized','RowSummary','row-normalized');

CM_Positions=cm.InnerPosition;
CM_DiagonalColor=cm.DiagonalColor;

Bottom_Left_X = CM_Positions(1);
Bottom_Left_Y = CM_Positions(2);
Width = CM_Positions(3);
Height = CM_Positions(4);

Bottom_Right_X = Bottom_Left_X+Width;
Bottom_Right_Y = Bottom_Left_Y;

Annotation_Width = Width/(NumGroups+0.75^(NumGroups-1));
Annotation_Height = Height/(NumGroups+0.75^(NumGroups-1));
% Annotation_Height = Height*(4.75/20/5*(NumGroups+1));

Annotation_X = Bottom_Right_X-Annotation_Width;
Annotation_Y = Bottom_Right_Y;

Annotation_Dimension = [Annotation_X,Annotation_Y,Annotation_Width,Annotation_Height];

Annotation_Dimension_Top = [Annotation_X,Annotation_Y,Annotation_Width,Annotation_Height/2];
Annotation_Dimension_Bottom = [Annotation_X,Annotation_Y+Annotation_Height/2,Annotation_Width,Annotation_Height/2];

String_Accuracy=sprintf('Full: %.1f%%',Accuracy*100);
String_Accuracy_NoZero=sprintf('No Zero: %.1f%%',Accuracy_NoZero*100);

annotation('rectangle',Annotation_Dimension_Top,'FaceColor',CM_DiagonalColor,'FaceAlpha',Accuracy);
annotation('rectangle',Annotation_Dimension_Bottom,'FaceColor',CM_DiagonalColor,'FaceAlpha',Accuracy_NoZero);
annotation('textbox',Annotation_Dimension_Top,'String',String_Accuracy,'Horizontalalignment','center','Verticalalignment','middle');
annotation('textbox',Annotation_Dimension_Bottom,'String',String_Accuracy_NoZero,'Horizontalalignment','center','Verticalalignment','middle');

%%

% NumData=100;
% 
% for didx=1:NumData
%     
%     this_Data=load(sprintf(DataAggregate_PathNameExt,didx));
%     this_Data=this_Data.Data;
%     
% end


%%
layers = [
    imageInputLayer(inputSize,"Name","imageinput","Normalization","none")
    fullyConnectedLayer(1000,"Name","fc_1")
    reluLayer("Name","relu_1")
    fullyConnectedLayer(1000,"Name","fc_2")
    reluLayer("Name","relu_2")
    fullyConnectedLayer(1000,"Name","fc_3")
    reluLayer("Name","relu_3")
    fullyConnectedLayer(NumClasses,"Name","fc_4")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

options = trainingOptions('sgdm', ...
    'MaxEpochs',50,...
    'InitialLearnRate',0.01, ...
    'Verbose',false, ...
    'ValidationData', valImds, ...
    'ExecutionEnvironment','parallel',...
    'Plots','training-progress',...
    'LearnRateSchedule','piecewise');

net = trainNetwork(trainImds,layers,options);

% %%
% 
% aa=[];
% aaa=[];
% aaaa=[];
% aaaaa=[];
% aaaaaa=[];
% bbb=[];
% 
% a=[1;2;3;4];
% 
% aa(:,1)=a;
% aa(:,2)=a+4*1;
% aa(:,3)=a+4*2;
% aa(:,4)=a+4*3;
% aa(:,5)=a+4*4;
% 
% aaa(:,:,1)=aa;
% aaa(:,:,2)=aa+20;
% 
% aaaa(:,:,:,1)=aaa;
% aaaa(:,:,:,2)=aaa+40;
% aaaa(:,:,:,3)=aaa+80;
% 
% aaaaa= permute(aaaa,[4 1 2 3]);
% 
% aaaaaa= reshape(aaaaa,3,[]);
%%
cfg = cfg_Decoder;

Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

LinearDecoder_NameExt = 'Linear_Decoder.mat';
LinearInformation_NameExt = 'Linear_Information.mat';

LinearDecoder_PathNameExt = [Decoding_Dir filesep LinearDecoder_NameExt];
LinearInformation_PathNameExt = [Decoding_Dir filesep LinearInformation_NameExt];
%%
m_LinearInformation = matfile(LinearInformation_PathNameExt,'Writable',false);
m_LinearDecoder = matfile(LinearDecoder_PathNameExt,'Writable',false);
%%

KFoldPartition=m_LinearInformation.Partition;
ModelLinear=m_LinearDecoder.ModelLinear;
%%
DataWidth = 100;
StartingIDX = 'All';
EndingIDX = 'All';
WindowStride = 25;
NumFolds = 10;

SubsetAmount=500;
WantSubset=true;
NumIter=4;
NumProbes=6;
NumChannels=64;
SamplingFrequency=1000;

[Combined_ds] = cgg_getCombinedDataStoreForTall('All',1,1,WindowStride,cfg,'Dimension',3);

Example=read(Combined_ds);
Example=Example{1};
[~,Example_Size]=size(Example);

NumSamples=Example_Size/NumProbes/NumChannels;

FinalStartIDX=NumSamples+1-DataWidth;

StartingIndices=1:WindowStride:FinalStartIDX;

NumStrides=length(StartingIndices);

% NumStrides=3;
% NumFolds=5;

Accuracy_All=NaN(NumFolds,NumStrides);
%%
for sidx=1:NumStrides
StartingIDX = StartingIndices(sidx);
EndingIDX = StartingIDX;

[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,'Dimension',3);

NumObservations=numpartitions(Combined_ds);

if WantSubset
this_NumObservations=SubsetAmount;
else
this_NumObservations=NumObservations;
end

sidx=1;

[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,'Dimension',3);

%
parfor pidx=1:NumFolds

this_Testing_IDX=test(KFoldPartition,pidx);

if WantSubset
this_Testing_IDX = [this_Testing_IDX; false(NumObservations-SubsetAmount,1)];
end

this_TestingCombined_ds=subset(Combined_ds,this_Testing_IDX);

[X_testing,Y_testing] = cgg_getTallDecoderInputs(this_TestingCombined_ds);
X_testing=gather(X_testing);
Y_testing=gather(Y_testing);

%%
this_Mdl=ModelLinear{pidx};

% GroupLabels=sort(gather(unique(Y_testing,'rows')));
GroupLabels=sort(unique(Y_testing,'rows'));
NumLabels=length(GroupLabels);

cm_values_tmp=NaN(NumLabels,NumLabels,NumIter);
order_tmp=NaN(NumLabels,NumIter);

for idx=1:NumIter
Label_Predicted = predict(this_Mdl,X_testing);
% [cm_values_tmp(:,:,idx),order_tmp(:,idx)] = confusionmat(gather(Y_testing),gather(Label_Predicted));
[cm_values_tmp(:,:,idx),order_tmp(:,idx)] = confusionmat(Y_testing,Label_Predicted);
end

cm_values=mean(cm_values_tmp,3);

[Accuracy,Accuracy_STE,Accuracy_NoZero,Accuracy_NoZero_STE,...
    ConfusionMatrix_Mean,ConfusionMatrix_STE,ConfusionMatrix_Order] = ...
    cgg_getAccuracyStatistics(cm_values,order_tmp);

Accuracy_All(pidx,sidx)=Accuracy;
end
end

%%

for fidx=5:10

Fold = fidx;

cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

cfg_param = PARAMETERS_cgg_procSimpleDecoders_v2;

Epoch=cfg_param.Epoch;
Decoder=cfg_param.Decoder;

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;

LinearAccuracy_NameExt = 'Linear_Accuracy.mat';

LinearAccuracy_PathNameExt = [Decoding_Dir filesep LinearAccuracy_NameExt];

m_LinearAccuracy = matfile(LinearAccuracy_PathNameExt,'Writable',false);
Accuracy(fidx,:) = m_LinearAccuracy.Accuracy;
Window_Accuracy(fidx,:) = m_LinearAccuracy.Window_Accuracy;

end

%%

DataWidth = 100;

SamplingFrequency=1000;

[NumFolds,NumStrides] = size(Window_Accuracy);

Accuracy_Mean=mean(Accuracy,1);
Accuracy_STE=std(Accuracy,[],1)/sqrt(NumFolds);

Window_Accuracy_Mean=mean(Window_Accuracy,1);
Window_Accuracy_STE=std(Window_Accuracy,[],1)/sqrt(NumFolds);

Accuracy_Time_Start=-1.5+DataWidth/SamplingFrequency/2;
Accuracy_Time_End=1.5-DataWidth/SamplingFrequency/2;

Accuracy_Time=linspace(Accuracy_Time_Start,Accuracy_Time_End,NumStrides);

figure;

plot(Accuracy_Time,Window_Accuracy_Mean,'LineWidth',2,'Color',[0 0.4470 0.7410]);
hold on
plot(Accuracy_Time,Window_Accuracy_Mean-Window_Accuracy_STE,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle',':');
plot(Accuracy_Time,Window_Accuracy_Mean+Window_Accuracy_STE,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle',':');
xline(0,'LineWidth',2);
xline(-0.7,'LineWidth',2);
xline(-0.4,'LineWidth',2);
hold off

% ylim([0.4,0.6]);

xlabel('Time From Decision Recorded (s)','FontSize',16);
ylabel('Accuracy','FontSize',16)

figure;

plot(Accuracy_Mean,'LineWidth',2,'Color',[0 0.4470 0.7410]);
hold on
plot(Accuracy_Mean-Accuracy_STE,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle',':');
plot(Accuracy_Mean+Accuracy_STE,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle',':');
hold off

% ylim([0.4,0.5]);

xlabel('Iterations','FontSize',16);
ylabel('Accuracy','FontSize',16)
