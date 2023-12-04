function cgg_procSimpleDecoders(DataWidth,StartingIDX,EndingIDX,WindowStride,NumFolds,cfg,varargin)
%CGG_PROCSIMPLEDECODERS Summary of this function goes here
%   Detailed explanation goes here

%%

[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,varargin{:});

%%
Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.path;

LinearDecoder_NameExt = 'Linear_Decoder.mat';
LinearConfusionMatrix_NameExt = 'Linear_ConfusionMatrix.mat';
LinearInformation_NameExt = 'Linear_Information.mat';
LinearAccuracy_NameExt = 'Linear_Accuracy.mat';
% LinearAccuracyTimeCourse_NameExt = 'Linear_Accuracy_Time_Course.mat';

LinearDecoder_PathNameExt = [Decoding_Dir filesep LinearDecoder_NameExt];
LinearConfusionMatrix_PathNameExt = [Decoding_Dir filesep LinearConfusionMatrix_NameExt];
LinearInformation_PathNameExt = [Decoding_Dir filesep LinearInformation_NameExt];
LinearAccuracy_PathNameExt = [Decoding_Dir filesep LinearAccuracy_NameExt];
% LinearAccuracyTimeCourse_PathNameExt = [Decoding_Dir filesep LinearAccuracyTimeCourse_NameExt];
%%

SubsetAmount=500;
WantSubset=true;
NumIter=4;

NumObservations=numpartitions(Combined_ds);

if WantSubset
this_NumObservations=SubsetAmount;
else
this_NumObservations=NumObservations;
end

KFoldPartition = cvpartition(this_NumObservations,"KFold",NumFolds);

%% Loop


ModelLinear_All=cell(1,NumFolds);
ConfusionMatrix_All=cell(1,NumFolds);
ConfusionMatrixEach_All=cell(1,NumFolds);
ConfusionMatrixOrder_All=cell(1,NumFolds);
AccuracyLinear_All=cell(1,NumFolds);
% AccuracyLinearTimeCourse_All=cell(1,NumFolds);

for kidx=1:NumFolds

this_Training_IDX=training(KFoldPartition,kidx);
this_Testing_IDX=test(KFoldPartition,kidx);

if WantSubset
this_Training_IDX = [this_Training_IDX; false(NumObservations-SubsetAmount,1)];
this_Testing_IDX = [this_Testing_IDX; false(NumObservations-SubsetAmount,1)];
end

this_TrainingCombined_ds=subset(Combined_ds,this_Training_IDX);
this_TestingCombined_ds=subset(Combined_ds,this_Testing_IDX);

[X_training,Y_training] = cgg_getTallDecoderInputs(this_TrainingCombined_ds);
[X_testing,Y_testing] = cgg_getTallDecoderInputs(this_TestingCombined_ds);
%%
disp('Starting Linear Decoder')
mdlLinear = fitcecoc(X_training,Y_training,'Coding','onevsall','Verbose',2);
%%
GroupLabels=sort(gather(unique(Y_testing,'rows')));
NumLabels=length(GroupLabels);

cm_values_tmp=NaN(NumLabels,NumLabels,NumIter);
order_tmp=NaN(NumLabels,NumIter);

for idx=1:NumIter
Label_Predicted = predict(mdlLinear,X_testing);
[cm_values_tmp(:,:,idx),order_tmp(:,idx)] = confusionmat(gather(Y_testing),gather(Label_Predicted));
end

% [CombinedTimeCourse_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,varargin{:});
% 
% this_TestingCombinedTimeCourse_ds=subset(CombinedTimeCourse_ds,this_Testing_IDX);
% 
% [X_TimeCourse,Y_TimeCourse] = cgg_getTallDecoderInputs(this_TestingCombinedTimeCourse_ds);
% 
% cm_values_TimeCourse_tmp=NaN(NumLabels,NumLabels,NumIter);
% order_tmp=NaN(NumLabels,NumIter);
% 
% for idx=1:NumIter
% Label_Predicted = predict(mdlLinear,X_testing);
% [cm_values_tmp(:,:,idx),order_tmp(:,idx)] = confusionmat(gather(Y_testing),gather(Label_Predicted));
% end

cm_values=mean(cm_values_tmp,3);

TruePositives = trace(cm_values);
TotalObservations = sum(cm_values(:));
AccuracyLinear = TruePositives/TotalObservations;

ModelLinear_All{kidx}=mdlLinear;
ConfusionMatrix_All{kidx}=cm_values;
ConfusionMatrixEach_All{kidx}=cm_values_tmp;
ConfusionMatrixOrder_All{kidx}=order_tmp;
AccuracyLinear_All{kidx}=AccuracyLinear;

%%
m_LinearConfusionMatrix = matfile(LinearConfusionMatrix_PathNameExt,'Writable',true);
m_LinearConfusionMatrix.ConfusionMatrix=ConfusionMatrix_All;
m_LinearInformation = matfile(LinearInformation_PathNameExt,'Writable',true);
m_LinearInformation.ConfusionMatrixEach=ConfusionMatrixEach_All;
m_LinearInformation.ConfusionMatrixOrder=ConfusionMatrixOrder_All;
m_LinearInformation.Partition=KFoldPartition;
m_LinearAccuracy = matfile(LinearAccuracy_PathNameExt,'Writable',true);
m_LinearAccuracy.Accuracy=AccuracyLinear_All;

end

m_LinearDecoder = matfile(LinearDecoder_PathNameExt,'Writable',true);
m_LinearDecoder.ModelLinear=ModelLinear_All;

end

