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

%%


% rng(0,'twister'); % For reproducibility
% n = 1000;
% r = linspace(-10,10,n)';
% x = 1 + r*5e-2 + sin(r)./r + 0.2*randn(n,1);

[xTrainImages,tTrain] = digitTrainCellArrayData;

[imageWidth,imageHeight]=size(xTrainImages{1});
inputSize = imageWidth*imageHeight;

NumInputs_Batch_1=numel(xTrainImages)/2;

xTrainImages_Batch_1=xTrainImages(1:NumInputs_Batch_1);
xTrainImages_Batch_2=xTrainImages(NumInputs_Batch_1+1:end);

tTrain_Batch_1=tTrain(:,1:NumInputs_Batch_1);
tTrain_Batch_2=tTrain(:,NumInputs_Batch_1+1:end);

NumInputs_Batch_2=numel(xTrainImages_Batch_2);

xTrain_Batch_1 = zeros(inputSize,NumInputs_Batch_1);
for i = 1:NumInputs_Batch_1
    xTrain_Batch_1(:,i) = xTrainImages_Batch_1{i}(:);
end
xTrain_Batch_2 = zeros(inputSize,NumInputs_Batch_2);
for i = 1:NumInputs_Batch_2
    xTrain_Batch_2(:,i) = xTrainImages_Batch_2{i}(:);
end

Full_xTrain_Batch{1}=xTrain_Batch_1;
Full_xTrain_Batch{2}=xTrain_Batch_2;

Full_tTrain_Batch{1}=tTrain_Batch_1;
Full_tTrain_Batch{2}=tTrain_Batch_2;

NumStacks=2;
hiddenSize_1 = 100;
hiddenSize_2=50;
NumEpochs=1000;
NumBatches = 2;

hiddenSize=NaN(1,NumStacks);
hiddenSize(1)=hiddenSize_1;
hiddenSize(2)=hiddenSize_2;

WantProgressWindow=false;

All_AutoEncoder=cell(1,NumStacks);
All_AutoEncoder_Net=cell(1,NumStacks);
All_FeatureVector=cell(NumBatches,NumStacks+1);

for bidx=1:NumBatches
All_FeatureVector{bidx,1}=Full_xTrain_Batch{bidx};
end

%

for sidx=1:NumStacks

    this_FeatureVector = All_FeatureVector{1,sidx};

this_AutoEncoder = trainAutoencoder(this_FeatureVector,hiddenSize(sidx),...
        'EncoderTransferFunction','satlin',...
        'DecoderTransferFunction','purelin',...
        'L2WeightRegularization',0.01,...
        'SparsityRegularization',4,...
        'SparsityProportion',0.10,...
        'MaxEpochs',1,...
        'ShowProgressWindow',WantProgressWindow);

this_FeatureVector = encode(this_AutoEncoder,this_FeatureVector);

this_AutoEncoder_Net=network(this_AutoEncoder);
this_AutoEncoder_Net.performFcn='mse';
this_AutoEncoder_Net.trainParam.epochs=NumEpochs;

All_AutoEncoder{sidx}=this_AutoEncoder;
All_AutoEncoder_Net{sidx}=this_AutoEncoder_Net;
All_FeatureVector{1,sidx+1}=this_FeatureVector;

end

softnet = trainSoftmaxLayer(this_FeatureVector,Full_tTrain_Batch{1},'MaxEpochs',1);

AutoEncoder_Stack = stack(All_AutoEncoder{:});

Encoder_Full = stack(All_AutoEncoder{:},softnet);

[Encoder_FrontEnd,Encoder_BackEnd] = cgg_getEncoderPartsFromWhole(AutoEncoder_Stack,softnet,Encoder_Full);
[Encoder_Full] = cgg_getEncoderWholeFromParts(Encoder_FrontEnd,Encoder_BackEnd,Encoder_Full_Ex);
%%
for bidx=1:NumBatches
    this_FeatureVector=Full_xTrain_Batch{bidx};
for sidx=1:NumStacks

    this_AutoEncoder=All_AutoEncoder{sidx};

    this_AutoEncoder = train(this_AutoEncoder,this_FeatureVector,this_FeatureVector,'useParallel','yes');
    this_FeatureVector = cgg_getEncoderFeaturesFromNetwork(this_AutoEncoder,this_FeatureVector);

    All_AutoEncoder{sidx}=this_AutoEncoder;

end
end

[FeatureVector_1] = cgg_getEncoderFeaturesFromNetworkStack(All_AutoEncoder,Full_xTrain_Batch{1});

% this_AutoEncoder_1 = trainAutoencoder(xTrain_Batch_1,hiddenSize(1),...
%         'EncoderTransferFunction','satlin',...
%         'DecoderTransferFunction','purelin',...
%         'L2WeightRegularization',0.01,...
%         'SparsityRegularization',4,...
%         'SparsityProportion',0.10,...
%         'MaxEpochs',1,...
%         'ShowProgressWindow',WantProgressWindow);
% 
% feature_1 = encode(this_AutoEncoder_1,xTrain_Batch_1);
% 
% this_AutoEncoder_2 = trainAutoencoder(feature_1,hiddenSize(2),...
%         'EncoderTransferFunction','satlin',...
%         'DecoderTransferFunction','purelin',...
%         'L2WeightRegularization',0.01,...
%         'SparsityRegularization',4,...
%         'SparsityProportion',0.10,...
%         'MaxEpochs',1,...
%         'ShowProgressWindow',WantProgressWindow);

%% Save image files to emulate brain data

[xTrainImages,tTrain] = digitTrainCellArrayData;
tTrainCategorical = onehotdecode(tTrain,[1:9,0],1);
NumClasses=numel(unique(tTrainCategorical));

Group_Amount=4;

[NumRows,NumColumns,NumDepth]=size(xTrainImages{1});
InputSize=size(xTrainImages{1});

[~,NumObservations]=size(xTrainImages);

NumCombinedObservations=NumObservations/Group_Amount;

Data_Dir='Data';
Target_Dir='Target';

%%
SaveVariablesName_Data={'Data'};
SaveVariablesName_Target={'Target'};
SavePathNameExt_Data=[Data_Dir filesep 'Data_%04d.mat'];
SavePathNameExt_Target=[Target_Dir filesep 'Target_%04d.mat'];

parfor coidx=1:NumCombinedObservations
    this_ObservationStartIDX=(coidx-1)*Group_Amount+1;
    this_ObservationEndIDX=coidx*Group_Amount;
    this_ObservationIndices=...
        this_ObservationStartIDX:this_ObservationEndIDX;

    this_CombinedObservation=[xTrainImages{this_ObservationIndices}];
    this_CombinedTarget=tTrainCategorical(this_ObservationIndices);

    this_SaveVariables_Data={this_CombinedObservation};
    this_SaveVariables_Target={this_CombinedTarget};

    this_SavePathNameExt_Data=sprintf(SavePathNameExt_Data,coidx);
    this_SavePathNameExt_Target=sprintf(SavePathNameExt_Target,coidx);

    cgg_saveVariableUsingMatfile(this_SaveVariables_Data,SaveVariablesName_Data,this_SavePathNameExt_Data);
    cgg_saveVariableUsingMatfile(this_SaveVariables_Target,SaveVariablesName_Target,this_SavePathNameExt_Target);

end

%%

DataWidth=NumColumns;
WindowStride=NumColumns;

ClassNames=["1","2","3","4","5","6","7","8","9","0"];

Data_Fun=@(x) cgg_loadDataArrayTMP(x,DataWidth,WindowStride);
Target_Fun=@(x) cgg_loadTargetArrayTMP(x,ClassNames);

Data_ds = fileDatastore(Data_Dir,"ReadFcn",Data_Fun);
Target_ds = fileDatastore(Target_Dir,"ReadFcn",Target_Fun);

DataStore_AutoEncoder=combine(Data_ds,Data_ds);
DataStore_Classifier=combine(Data_ds,Target_ds);

%% AutoEncoder with DataStore
NumTimeWindows=Group_Amount;

maxEpochs = 200;
maxEpochs_Tuning=500;
miniBatchSize = 400;
HiddenSizes=[500,500,500,200];
GradientThreshold=1;

LossType='Regression';

DataFormat={'SSCTB','SSCTB'};

DataStore_AutoEncoder_Batch_1=subset(DataStore_AutoEncoder,1:floor(NumCombinedObservations/2));
DataStore_AutoEncoder_Batch_2=subset(DataStore_AutoEncoder,floor(NumCombinedObservations/2)+1:NumCombinedObservations);

DataStore_Classifier_Batch_1=subset(DataStore_Classifier,1:floor(NumCombinedObservations/2));
DataStore_Classifier_Batch_2=subset(DataStore_Classifier,floor(NumCombinedObservations/2)+1:NumCombinedObservations);

% options = trainingOptions('sgdm', ...
%     'MaxEpochs',maxEpochs, ...
%     'MiniBatchSize',miniBatchSize, ...
%     'InitialLearnRate',0.01, ...
%     'GradientThreshold',1, ...
%     'Shuffle','every-epoch', ...
%     'Plots','training-progress',...
%     'Verbose',0,...
%     'ValidationData',DataStore_AutoEncoder_Batch_2, ...
%     'ExecutionEnvironment',"auto");

Example_Data=read(DataStore_AutoEncoder_Batch_1);
Example_Data=Example_Data{1};
InputSize=size(Example_Data);
InputSize=InputSize(1:3);

[Layers_AutoEncoder,Layers_Custom] = cgg_generateLayersForAutoEncoder(InputSize,HiddenSizes,NumTimeWindows,DataFormat{2});

InDataStore=DataStore_AutoEncoder_Batch_1;
InputNet= initialize(Layers_Custom);
NumEpochs=maxEpochs;

[net_custom] = cgg_trainCustomTrainingParallel(InputNet,InDataStore,DataFormat,NumEpochs,miniBatchSize,GradientThreshold,LossType);

% net = trainNetwork(DataStore_AutoEncoder_Batch_1,Layers_AutoEncoder,options);
%%

Layer_Names={net_custom.Layers(:).Name};

Layer_Encoder_IDX=contains(Layer_Names,'Encoder');
Layer_Decoder_IDX=contains(Layer_Names,'Decoder');

Layers_Encoder=net_custom.Layers(Layer_Encoder_IDX);

Layer_Names_Encoder=Layer_Names(Layer_Encoder_IDX);
% Layers_Encoder_Untrained=Layers_AutoEncoder(1:(2*numel(HiddenSizes)+1));

Layers_Tuning=[
    fullyConnectedLayer(NumClasses, 'Name','fc_Tuning')
    sequenceUnfoldingLayer('Name','unfold_Tuning')
    softmaxLayer("Name","softmaxoutput_Tuning")
    classificationLayer("Name","classoutput_Tuning")];

Layers_Custom_Tuning=[
    fullyConnectedLayer(NumClasses, 'Name','fc_Tuning')
    softmaxLayer("Name","softmaxoutput_Tuning")
    ];

% lgraph = layerGraph(net);
lgraph = layerGraph(net_custom);
% lgraph_Untrained = layerGraph(Layers_AutoEncoder);

% Layers_Decoder=net.Layers((2*(numel(HiddenSizes)+1)):end);
% Layers_RemoveNames={Layers_Decoder(:).Name};
Layers_RemoveNames=Layer_Names(Layer_Decoder_IDX);

% lgraph = removeLayers(lgraph,Layers_RemoveNames);
lgraph = removeLayers(lgraph,Layers_RemoveNames);
% lgraph_Untrained = removeLayers(lgraph_Untrained,Layers_RemoveNames);

% lgraph = addLayers(lgraph,Layers_Tuning);
lgraph = addLayers(lgraph,Layers_Custom_Tuning);
% lgraph_Untrained = addLayers(lgraph_Untrained,Layers_Tuning);

lgraph = connectLayers(lgraph,Layer_Names_Encoder{end},Layers_Custom_Tuning(1).Name);
% lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfold/miniBatchSize');
% lgraph_Untrained = connectLayers(lgraph_Untrained,Layers_Encoder(end).Name,Layers_Tuning(1).Name);

options = trainingOptions('sgdm', ...
    'MaxEpochs',maxEpochs_Tuning, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress',...
    'Verbose',0,...
    'ValidationData',DataStore_Classifier_Batch_2, ...
    'ExecutionEnvironment',"auto");


DataFormat={'SSCTB','CTB'};
InDataStore=DataStore_Classifier_Batch_1;
InputNet=dlnetwork(lgraph);

[net_tuning] = cgg_trainCustomTrainingParallel(InputNet,InDataStore,DataFormat,NumEpochs,miniBatchSize,GradientThreshold,LossType);

% net_tuning = trainNetwork(DataStore_Classifier_Batch_1,lgraph,options);
% net_tuning_Untrained = trainNetwork(xTrainTable_Batch_1_Classifier,lgraph_Untrained,options);

%%

NumPredictions=1;

this_Batch=DataStore_Classifier_Batch_2;
NumInputs=numpartitions(this_Batch);

this_viewIDX=randi(NumInputs,NumPredictions,1);

this_DataStoreExample = partition(this_Batch,NumInputs,this_viewIDX);

this_Example=read(this_DataStoreExample);

this_Example_Data=this_Example{1};
this_Example_Target=this_Example{2};
this_Example_Target=onehotdecode(this_Example_Target,[1:9,0],1);

%     workerImds = this_DataStoreExample;
% 
%     % Create minibatchqueue using partitioned datastore on each worker.
%     workerMbq = minibatchqueue(workerImds,...
%         MiniBatchFormat=DataFormat);
% 
%     [workerX,workerT] = next(workerMbq);
% 
% dlarray(this_Example_Data,"SSCT")

this_Example_Data_DLArray=dlarray(this_Example_Data,"SSCTB");

Prediction_Reconstruction = forward(net_custom,this_Example_Data_DLArray);
Prediction_Reconstruction = extractdata(Prediction_Reconstruction);

Prediction_Classification = forward(net_tuning,this_Example_Data_DLArray);
Prediction_Classification = extractdata(Prediction_Classification);

% Prediction_Reconstruction = predict(net,this_Example_Data);
% Prediction_Classification = predict(net_tuning,this_Example_Data);

[~,~,~,NumPlots]=size(this_Example_Data);

Prediction_Classification = squeeze(onehotdecode(Prediction_Classification,[1:9,0],1));

for idx = 1:NumPlots

    this_Target=this_Example_Target(idx);
    this_Prediction=Prediction_Classification(idx);

    subplot(2,NumPlots,idx);
    imshow(this_Example_Data(:,:,:,idx));
    title(sprintf('Target Image of %s',this_Target));
    subplot(2,NumPlots,idx+NumPlots);
    imshow((Prediction_Reconstruction(:,:,:,idx)));
    title(sprintf('Predicted Image of %s',this_Prediction));
end

%%

maxEpochs = 200;
maxEpochs_Tuning=500;
miniBatchSize = 200;

xTrainTable_Batch_1=table(xTrainImages_Batch_1',xTrainImages_Batch_1');
xTrainTable_Batch_2=table(xTrainImages_Batch_2',xTrainImages_Batch_2');

tTrainCategorical_Batch_1 = onehotdecode(tTrain_Batch_1,[1:9,0],1);
tTrainCategorical_Batch_2 = onehotdecode(tTrain_Batch_2,[1:9,0],1);

xTrainTable_Batch_1_Classifier=table(xTrainImages_Batch_1',tTrainCategorical_Batch_1');
xTrainTable_Batch_2_Classifier=table(xTrainImages_Batch_2',tTrainCategorical_Batch_2');

options = trainingOptions('sgdm', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress',...
    'Verbose',0,...
    'ValidationData',xTrainTable_Batch_2, ...
    'ExecutionEnvironment',"parallel");

% InputSize=[size(xTrainImages{1}) 1];
InputSize=size(xTrainImages{1});
HiddenSizes=[500,500,500,200];

[Layers_AutoEncoder] = cgg_generateLayersForAutoEncoder(InputSize,HiddenSizes);

% net = trainNetwork(xTrainImages_Batch_1,xTrainImages_Batch_1,Layers_AutoEncoder,options);

net = trainNetwork(xTrainTable_Batch_1,Layers_AutoEncoder,options);

%%

Layers_Encoder=net.Layers(1:(2*numel(HiddenSizes)+1));
Layers_Encoder_Untrained=Layers_AutoEncoder(1:(2*numel(HiddenSizes)+1));

Layers_Tuning=[
    fullyConnectedLayer(NumClasses, 'Name','new_fc')
    softmaxLayer("Name","softmaxoutput")
    classificationLayer("Name","classoutput")];

lgraph = layerGraph(net);
lgraph_Untrained = layerGraph(Layers_AutoEncoder);

Layers_Decoder=net.Layers((2*(numel(HiddenSizes)+1)):end);
Layers_RemoveNames={Layers_Decoder(:).Name};

lgraph = removeLayers(lgraph,Layers_RemoveNames);
lgraph_Untrained = removeLayers(lgraph_Untrained,Layers_RemoveNames);

lgraph = addLayers(lgraph,Layers_Tuning);
lgraph_Untrained = addLayers(lgraph_Untrained,Layers_Tuning);

lgraph = connectLayers(lgraph,Layers_Encoder(end).Name,Layers_Tuning(1).Name);
lgraph_Untrained = connectLayers(lgraph_Untrained,Layers_Encoder(end).Name,Layers_Tuning(1).Name);

options = trainingOptions('sgdm', ...
    'MaxEpochs',maxEpochs_Tuning, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress',...
    'Verbose',0,...
    'ValidationData',xTrainTable_Batch_2_Classifier, ...
    'ExecutionEnvironment',"parallel");

net_tuning = trainNetwork(xTrainTable_Batch_1_Classifier,lgraph,options);
net_tuning_Untrained = trainNetwork(xTrainTable_Batch_1_Classifier,lgraph_Untrained,options);
%%

NumPredictions=3;

this_Batch=xTrainTable_Batch_2;
this_Batch_Classifier=xTrainTable_Batch_2_Classifier;
[NumInputs,~]=size(this_Batch);

this_viewIDX=randi(NumInputs,NumPredictions,1);

this_Example=this_Batch(this_viewIDX,1);
this_Example_Classifier=this_Batch_Classifier(this_viewIDX,1);

this_Value_Classifier=this_Batch_Classifier(this_viewIDX,2);

Prediction_Reconstruction = predict(net,this_Example);
Prediction_Classification = predict(net_tuning,this_Example_Classifier);

Prediction_Classification = onehotdecode(Prediction_Classification,[1:9,0],2);

for idx = 1:NumPredictions

    this_Target=this_Value_Classifier{idx,1};
    this_Prediction=Prediction_Classification(idx);

    % subplot(2,NumPredictions,2*(idx-1)+1);
    subplot(2,NumPredictions,idx);
    imshow(this_Example{idx,1}{1});
    title(sprintf('Target Image of %s',this_Target));
    % subplot(2,NumPredictions,2*idx);
    subplot(2,NumPredictions,idx+NumPredictions);
    imshow((Prediction_Reconstruction(:,:,:,idx)));
    title(sprintf('Predicted Image of %s',this_Prediction));
end

%%

Layers_Encoder=net.Layers(1:(2*numel(HiddenSizes)+1));

Layers_Encoder_Tuning=[
    Layers_Encoder
    fullyConnectedLayer(NumClasses, 'Name','new_fc')
    softmaxLayer("Name","softmaxoutput")
    classificationLayer("Name","classoutput")];

Layers_Tuning=[
    fullyConnectedLayer(NumClasses, 'Name','new_fc')
    softmaxLayer("Name","softmaxoutput")
    classificationLayer("Name","classoutput")];

lgraph = layerGraph(net);

Layers_Decoder=net.Layers((2*(numel(HiddenSizes)+1)):end);
Layers_RemoveNames={Layers_Decoder(:).Name};

lgraph = removeLayers(lgraph,Layers_RemoveNames);

lgraph = addLayers(lgraph,Layers_Tuning);

lgraph = connectLayers(lgraph,Layers_Encoder(end).Name,Layers_Tuning(1).Name);

Layers_Classifier=[
    Layers_AutoEncoder(1:7)
    Layers_Tuning];

% net_tuning = assembleNetwork(lgraph);

net_tuning = trainNetwork(xTrain_Batch_1,tTrain_Batch_1,lgraph,options);



%%

% layersEncoder = [
%     fullyConnectedLayer(100,"Name","fc_Encoder")
%     reluLayer("Name","relu_Encoder")];
% layersDecoder = [
%     fullyConnectedLayer(100,"Name","fc_Decoder")];
% 
% NetworkEncoder=dlnetwork(layersEncoder,'Initialize',false);
% NetworkDecoder=dlnetwork(layersDecoder,'Initialize',false);
% 
% inputSize=[size(xTrainImages{1}),1];
% 
% TestNet = encoderDecoderNetwork(inputSize,NetworkEncoder,NetworkDecoder)


%%

All_AutoEncoder=network(All_AutoEncoder);
All_AutoEncoder.performFcn='mse';
All_AutoEncoder.trainParam.epochs=NumEpochs;

% this_AutoEncoder_1 = train(this_AutoEncoder,xTrain_Batch_1,xTrain_Batch_1,'useParallel','yes');
% this_AutoEncoder_2 = train(this_AutoEncoder,xTrain_Batch_2,xTrain_Batch_2,'useParallel','yes');
% 
% this_AutoEncoder_12 = train(this_AutoEncoder_1,xTrain_Batch_2,xTrain_Batch_2,'useParallel','yes');
% this_AutoEncoder_21 = train(this_AutoEncoder_2,xTrain_Batch_1,xTrain_Batch_1,'useParallel','yes');

All_AutoEncoder = train(All_AutoEncoder,xTrain_Batch_1,xTrain_Batch_1,'useParallel','yes');
All_AutoEncoder = train(All_AutoEncoder,xTrain_Batch_2,xTrain_Batch_2,'useParallel','yes');

% All_AutoEncoder = stack(this_AutoEncoder_1,this_AutoEncoder_2);

%
% XReconstructed_All_12 = this_AutoEncoder_12([xTrain_Batch_1,xTrain_Batch_2]);
% XReconstructed_All_21 = this_AutoEncoder_21([xTrain_Batch_1,xTrain_Batch_2]);
% XReconstructed_All_1 = this_AutoEncoder_1([xTrain_Batch_1,xTrain_Batch_2]);
% XReconstructed_All_2 = this_AutoEncoder_2([xTrain_Batch_1,xTrain_Batch_2]);
% 
% XReconstructed_1_12 = this_AutoEncoder_12(xTrain_Batch_1);
% XReconstructed_1_21 = this_AutoEncoder_21(xTrain_Batch_1);
% XReconstructed_1_1 = this_AutoEncoder_1(xTrain_Batch_1);
% XReconstructed_1_2 = this_AutoEncoder_2(xTrain_Batch_1);
% 
% XReconstructed_2_12 = this_AutoEncoder_12(xTrain_Batch_2);
% XReconstructed_2_21 = this_AutoEncoder_21(xTrain_Batch_2);
% XReconstructed_2_1 = this_AutoEncoder_1(xTrain_Batch_2);
% XReconstructed_2_2 = this_AutoEncoder_2(xTrain_Batch_2);
% 
% mseError_All_12 = mse([xTrain_Batch_1,xTrain_Batch_2]-XReconstructed_All_12);
% mseError_All_21 = mse([xTrain_Batch_1,xTrain_Batch_2]-XReconstructed_All_21);
% mseError_All_1 = mse([xTrain_Batch_1,xTrain_Batch_2]-XReconstructed_All_1);
% mseError_All_2 = mse([xTrain_Batch_1,xTrain_Batch_2]-XReconstructed_All_2);
% 
% mseError_1_12 = mse(xTrain_Batch_1-XReconstructed_1_12);
% mseError_1_21 = mse(xTrain_Batch_1-XReconstructed_1_21);
% mseError_1_1 = mse(xTrain_Batch_1-XReconstructed_1_1);
% mseError_1_2 = mse(xTrain_Batch_1-XReconstructed_1_2);
% 
% mseError_2_12 = mse(xTrain_Batch_2-XReconstructed_2_12);
% mseError_2_21 = mse(xTrain_Batch_2-XReconstructed_2_21);
% mseError_2_1 = mse(xTrain_Batch_2-XReconstructed_2_1);
% mseError_2_2 = mse(xTrain_Batch_2-XReconstructed_2_2);
% 
% MSE_AutoEncoder_1={mseError_All_1,mseError_1_1,mseError_2_1}';
% MSE_AutoEncoder_2={mseError_All_2,mseError_1_2,mseError_2_2}';
% MSE_AutoEncoder_12={mseError_All_12,mseError_1_12,mseError_2_12}';
% MSE_AutoEncoder_21={mseError_All_21,mseError_1_21,mseError_2_21}';
% 
% 
% mse_Table=table(MSE_AutoEncoder_1,MSE_AutoEncoder_2,MSE_AutoEncoder_12,MSE_AutoEncoder_21,'RowNames',{'All Images','Batch 1','Batch 2'});

%%

% create encoder form trained network
encoder = network;
% Define topology
encoder.numInputs = 1;
encoder.numLayers = 1;
encoder.inputConnect(1,1) = 1;
encoder.outputConnect = 1;
encoder.biasConnect = 1;

% Set values for labels
encoder.name = 'Encoder';
encoder.layers{1}.name = 'Encoder';
% Copy parameters from input network
encoder.inputs{1}.size = All_AutoEncoder.inputs{1}.size;
encoder.layers{1}.size = All_AutoEncoder.layers{1}.size;
encoder.layers{1}.transferFcn = All_AutoEncoder.layers{1}.transferFcn;
encoder.IW{1,1} = All_AutoEncoder.IW{1,1};
encoder.b{1} = All_AutoEncoder.b{1};
% Set a training function
encoder.trainFcn = All_AutoEncoder.trainFcn;
% Set the input
encoderStruct = struct(encoder);
networkStruct = struct(All_AutoEncoder);
encoderStruct.inputs{1} = networkStruct.inputs{1};
encoder = network(encoderStruct);
% extract features from net
Z = encoder(xTrain_Batch_1);



% Z=encode(this_AutoEncoder,xTrain_Batch_1);


%%
% autoenc_1 = trainAutoencoder(xTrainImages,hiddenSize_1,...
%         'EncoderTransferFunction','satlin',...
%         'DecoderTransferFunction','purelin',...
%         'L2WeightRegularization',0.01,...
%         'SparsityRegularization',4,...
%         'SparsityProportion',0.10);
autoenc_1_flat = trainAutoencoder(xTrain,hiddenSize_1,...
        'EncoderTransferFunction','satlin',...
        'DecoderTransferFunction','purelin',...
        'L2WeightRegularization',0.01,...
        'SparsityRegularization',4,...
        'SparsityProportion',0.10);

feature_1 = encode(autoenc_1,xTrainImages);

autoenc_2 = trainAutoencoder(feature_1,hiddenSize_2,...
        'EncoderTransferFunction','satlin',...
        'DecoderTransferFunction','purelin',...
        'L2WeightRegularization',0.01,...
        'SparsityRegularization',4,...
        'SparsityProportion',0.10);

stackednet = stack(autoenc_1,autoenc_2);

Z = stackednet(xTrain);

% n = 1000;
% r = sort(-10 + 20*rand(n,1));
% xtest = 1 + r*5e-2 + sin(r)./r + 0.4*randn(n,1);
% 
% % Z = encode(stackednet,xtest');
% Z = stackednet(xtest');

%%

digitDatasetPath = fullfile(toolboxdir("nnet"),"nndemos", ...
    "nndatasets","DigitDataset");
imds = imageDatastore(digitDatasetPath, ...
    IncludeSubfolders=true, ...
    LabelSource="foldernames");

[imdsTrain,imdsTest] = splitEachLabel(imds,0.9,"randomized");

inputSize = [28 28 1];
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
augimdsTrain = shuffle(augimdsTrain);

classes = categories(imdsTrain.Labels);
numClasses = numel(classes);

layers = [
    imageInputLayer(inputSize,Normalization="none")
    convolution2dLayer(5,20)
    batchNormalizationLayer
    reluLayer
    convolution2dLayer(3,20,Padding=1)
    batchNormalizationLayer
    reluLayer
    convolution2dLayer(3,20,Padding=1)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer];

net = dlnetwork(layers);

InputNet=net;
InDataStore=augimdsTrain;
DataFormat=["SSCB" "" ""];

[net] = trainCustomTrainingParallel(InputNet,InDataStore,DataFormat);

%%

if canUseGPU
    executionEnvironment = "gpu";
    numberOfGPUs = gpuDeviceCount("available");
    pool = parpool(numberOfGPUs);
else
    executionEnvironment = "cpu";
    pool = gcp;
end

numWorkers = pool.NumWorkers;

numEpochs = 20;
miniBatchSize = 128;
velocity = [];

if executionEnvironment == "gpu"
     miniBatchSize = miniBatchSize .* numWorkers;
end

workerMiniBatchSize = floor(miniBatchSize ./ repmat(numWorkers,1,numWorkers));
remainder = miniBatchSize - sum(workerMiniBatchSize);
workerMiniBatchSize = workerMiniBatchSize + [ones(1,remainder) zeros(1,numWorkers-remainder)];

batchNormLayers = arrayfun(@(l)isa(l,"nnet.cnn.layer.BatchNormalizationLayer"),net.Layers);
batchNormLayersNames = string({net.Layers(batchNormLayers).Name});
state = net.State;
isBatchNormalizationStateMean = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedMean";
isBatchNormalizationStateVariance = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedVariance";

monitor = trainingProgressMonitor( ...
    Metrics="TrainingLoss", ...
    Info=["Epoch" "Workers"], ...
    XLabel="Iteration");

spmd
    stopTrainingEventQueue = parallel.pool.DataQueue;
end
stopTrainingQueue = stopTrainingEventQueue{1};

dataQueue = parallel.pool.DataQueue;
displayFcn = @(x) displayTrainingProgress(x,numEpochs,numWorkers,monitor,stopTrainingQueue);
afterEach(dataQueue,displayFcn)

spmd
    % Partition the datastore.
    workerImds = partition(augimdsTrain,numWorkers,spmdIndex);

    % Create minibatchqueue using partitioned datastore on each worker.
    workerMbq = minibatchqueue(workerImds,3,...
        MiniBatchSize=workerMiniBatchSize(spmdIndex),...
        MiniBatchFcn=@preprocessMiniBatch,...
        MiniBatchFormat=["SSCB" "" ""]);

    workerVelocity = velocity;
    epoch = 0;
    iteration = 0;
    stopRequest = false;

    while epoch < numEpochs && ~stopRequest
        epoch = epoch + 1;
        shuffle(workerMbq);

        % Loop over mini-batches.
        while spmdReduce(@and,hasdata(workerMbq)) && ~stopRequest
            iteration = iteration + 1;

            % Read a mini-batch of data.
            [workerX,workerT,workerNumObservations] = next(workerMbq);

            % Evaluate the model loss and gradients on the worker.
            [workerLoss,workerGradients,workerState] = dlfeval(@modelLoss,net,workerX,workerT);

            % Aggregate the losses on all workers.
            workerNormalizationFactor = workerMiniBatchSize(spmdIndex)./miniBatchSize;
            loss = spmdPlus(workerNormalizationFactor*extractdata(workerLoss));

            % Aggregate the network state on all workers.
            net.State = aggregateState(workerState,workerNormalizationFactor,...
                isBatchNormalizationStateMean,isBatchNormalizationStateVariance);

            % Aggregate the gradients on all workers.
            workerGradients.Value = dlupdate(@aggregateGradients,workerGradients.Value,{workerNormalizationFactor});

            % Update the network parameters using the SGDM optimizer.
            [net,workerVelocity] = sgdmupdate(net,workerGradients,workerVelocity);
        end

        % Stop training if the Stop button has been clicked.
        stopRequest = spmdPlus(stopTrainingEventQueue.QueueLength);

        % Send training progress information to the client.
        if spmdIndex == 1
            data = [epoch loss iteration];
            send(dataQueue,gather(data));
        end
    end

end



