function [CM_Table] = cgg_procPredictionsFromDatastoreNetwork(InDatastore,InputNet,ClassNames,varargin)
%CGG_PROCCONFUSIONMATRIXFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
wantPredict = CheckVararginPairs('wantPredict', true, varargin{:});
else
if ~(exist('wantPredict','var'))
wantPredict=true;
end
end

if isfunction
wantLoss = CheckVararginPairs('wantLoss', false, varargin{:});
else
if ~(exist('wantLoss','var'))
wantLoss=false;
end
end

%%

[OutputInformation,OutputAdditionalInformation] = ...
    cgg_getNetworkOutputInformation(InputNet);
LossType = OutputAdditionalInformation.LossType;

%%

NumMean=length(OutputInformation.Mean);
NumLogVar=length(OutputInformation.LogVar);
NumDimensions=length(OutputInformation.Classifier);
NumReconstruction=length(OutputInformation.Reconstruction);

%%

MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat);

[X,~,~] = next(MaxMbq);

NumTrials=numpartitions(InDatastore);

NumDimensions=length(ClassNames);
NumTimeSteps = size(X,finddim(X,"T"));
NumBatches = size(X,finddim(X,"B"));

Window_Prediction = NaN(NumDimensions,NumTrials,NumTimeSteps);
Window_TrueValue = NaN(NumDimensions,NumTrials,NumTimeSteps);
DataNumber = NaN(NumTrials,1);

AllOutputNames=[OutputInformation.Mean, OutputInformation.LogVar, ...
    OutputInformation.Classifier, OutputInformation.Reconstruction];

NumOutputs=length(AllOutputNames);

%%

reset(MaxMbq);

CurrentTrialCount = 1;

%%%%%%%

while hasdata(MaxMbq)

[X,T,this_DataNumber] = next(MaxMbq);

this_DataNumber = extractdata(this_DataNumber);

Y=cell(NumOutputs,1);

if wantPredict
    [Y{:},State] = predict(InputNet,X,Outputs=AllOutputNames);
else
    [Y{:},State] = forward(InputNet,X,Outputs=AllOutputNames);
end

%%

if NumMean>0
    mu=Y{1:NumMean};
else
    mu=[];
end
if NumLogVar>0
    logSigmaSq=Y{(1:NumLogVar)+NumMean};
else
    logSigmaSq=[];
end
if NumDimensions>0
    Y_Classification=Y((1:NumDimensions)+NumMean+NumLogVar);
else
    Y_Classification=[];
end
if NumReconstruction>0
    Y_Reconstruction=Y{(1:NumReconstruction)+NumMean+NumLogVar+NumDimensions};
else
    Y_Reconstruction=[];
end

T_Reconstruction=X;

NumBatches = size(X,finddim(X,"B"));
NumTrials = NumBatches;

this_TrialRange = CurrentTrialCount:(CurrentTrialCount+NumTrials-1);

[this_Window_Prediction,this_Window_TrueValue,~] = ...
    cgg_getPredictionFromClassifierProbabilities(T,Y_Classification,ClassNames,'wantLoss',wantLoss,'IsQuaddle',IsQuaddle,'NumTimeSteps',NumTimeSteps,'NumTrials',NumTrials,'LossType',LossType);

Window_TrueValue(:,this_TrialRange,:) = this_Window_TrueValue;
Window_Prediction(:,this_TrialRange,:) = this_Window_Prediction;
DataNumber(this_TrialRange) = this_DataNumber;

CurrentTrialCount = CurrentTrialCount+NumTrials;

%%%%%%%%
end
%%

Window_TrueValue_Table = permute(Window_TrueValue,[2,3,1]);
Window_TrueValue_Table = squeeze(Window_TrueValue_Table(:,1,:));
Window_Prediction_Table = permute(Window_Prediction,[2,3,1]);
% Window_Prediction_Table = permute(Window_Prediction,[2,1,3]);
% Window_Prediction_Table = squeeze(num2cell(Window_Prediction_Table,2));

% sel_trial = 1;
% sel_window = 1;
% 
% DataNumber_tmp = DataNumber(sel_trial);
% Window_TrueValue_Table_tmp = Window_TrueValue_Table(sel_trial,:);
% Window_Prediction_Table_tmp = mat2cell(Window_Prediction_Table(sel_trial,sel_window,:),1,1,4);
% Window_Prediction_Table_tmp = squeeze(Window_Prediction_Table(sel_trial,sel_window,:))';
% 
% CM_Table_tmp = table(DataNumber_tmp,Window_TrueValue_Table_tmp,...
%   Window_Prediction_Table_tmp,'VariableNames',{'DataNumber','TrueValue','Window'});

% CM_Table = table(DataNumber,Window_TrueValue_Table,...
%   Window_Prediction_Table,'VariableNames',{'DataNumber','TrueValue','Window'});

% CM_Table = splitvars(CM_Table,'Window');
% CM_Table = convertvars(CM_Table,"Window_1",'double');

for widx=1:NumTimeSteps
    this_WindowName=sprintf('Window_%d',widx);
    this_Window_Prediction = squeeze(Window_Prediction_Table(:,widx,:));
    if widx==1
    CM_Table = table(DataNumber,Window_TrueValue_Table,...
  this_Window_Prediction,'VariableNames',{'DataNumber','TrueValue',this_WindowName});
    else
    CM_Table.(this_WindowName)=this_Window_Prediction;
    end
end
% %%
% 
% CM_Cell=cell(1,NumDatastore);
% 
% 
% 
% %%
% 
% NumDatastore=numpartitions(InDatastore);
% 
% ClassNames=diag(diag(ClassNames));
% 
% wantZeroFeatureDetector=false;
% if numel(InputNet)>1
%     wantZeroFeatureDetector=true;
% end
% 
% %%
% 
% CM_Cell=cell(1,NumDatastore);
% 
% parfor didx=1:NumDatastore
%     this_tmp_Datastore=partition(InDatastore,NumDatastore,didx);
%     this_Values=read(this_tmp_Datastore);
%     FileName=this_tmp_Datastore.UnderlyingDatastores{1}.Files;
%     [this_DataNumber,~] = cgg_getNumberFromFileName(FileName);
%     this_X=this_Values{1};
%     [NumWindows,~]=size(this_X);
%     this_TrueValue=this_Values{2}(DimensionNumber);
% 
%     this_CM_Table=[];
% 
%     for widx=1:NumWindows
% 
%         if wantZeroFeatureDetector && length(ClassNames)==1
%             [this_Y,ClassConfidence,~] = cgg_procPredictionsFromModels(InputNet{1},this_X(widx,:));
%         else
% 
%         [this_Y,ClassConfidence,~] = cgg_procPredictionsFromModels(InputNet,this_X(widx,:));
% 
%             if wantZeroFeatureDetector
%                 if this_Y{1}==0
%                     this_Y=0;
%                 elseif this_Y{1}==1
%                     this_Y=this_Y{2};
%                 else
%                 end
%                 ClassConfidence=cell2mat(ClassConfidence);
%             end
%         end
% 
%     this_WindowName=sprintf('Window_%d',widx);
%     this_WindowName_Confidence=sprintf('Window_%d_Confidence',widx);
%     if widx==1
%     this_CM_Table = table(this_DataNumber,this_TrueValue,ClassNames',...
%   this_Y,ClassConfidence,'VariableNames',{'DataNumber','TrueValue','ClassNames',this_WindowName,this_WindowName_Confidence});
%     else
%     this_CM_Table.(this_WindowName)=this_Y;
%     this_CM_Table.(this_WindowName_Confidence)=ClassConfidence;
%     end
% %         if widx==1
% %         this_CM_Table = table(this_DataNumber,this_TrueValue,ClassNames',...
% %       ClassConfidence,'VariableNames',{'DataNumber','TrueValue','ClassNames',this_WindowName});
% %         else
% %         this_CM_Table.(this_WindowName)=ClassConfidence;
% %         end
% 
%     end
% 
%     CM_Cell{didx}=this_CM_Table
% 
% end
% %%
% clear('CM_Table');
% for didx=1:NumDatastore
% this_CM_Table=CM_Cell{didx};
% if exist('CM_Table','var')
% CM_Table = cgg_getCombineTablesWithMissingColumns(CM_Table,this_CM_Table);
% else
% CM_Table=this_CM_Table;
% end
% end

end

