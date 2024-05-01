function cgg_procSimpleDecoders_v4(DataWidth,StartingIDX,EndingIDX,WindowStride,NumObsPerChunk,NumEpochs,Fold,Epoch,Decoder,cfg,varargin)
%CGG_PROCSIMPLEDECODERS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%%

if isfunction
Dimension = CheckVararginPairs('Dimension', 1:4, varargin{:});
else
if ~(exist('Dimension','var'))
Dimension=1:4;
end
end

if isfunction
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=true;
end
end

if isfunction
SubsetAmount = CheckVararginPairs('SubsetAmount', 500, varargin{:});
else
if ~(exist('SubsetAmount','var'))
SubsetAmount=500;
end
end

if isfunction
wantTrain = CheckVararginPairs('wantTrain', true, varargin{:});
else
if ~(exist('wantTrain','var'))
wantTrain=true;
end
end

if isfunction
wantTest = CheckVararginPairs('wantTest', true, varargin{:});
else
if ~(exist('wantTest','var'))
wantTest=true;
end
end

if isfunction
wantIA = CheckVararginPairs('wantIA', false, varargin{:});
else
if ~(exist('wantIA','var'))
wantIA=false;
end
end

if isfunction
IADecoder = CheckVararginPairs('IADecoder', 'SVM', varargin{:});
else
if ~(exist('IADecoder','var'))
IADecoder='SVM';
end
end

if isfunction
NumIter = CheckVararginPairs('NumIter', 4, varargin{:});
else
if ~(exist('NumIter','var'))
NumIter=4;
end
end

if isfunction
wantZeroFeatureDetector = CheckVararginPairs('wantZeroFeatureDetector', false, varargin{:});
else
if ~(exist('wantZeroFeatureDetector','var'))
wantZeroFeatureDetector=false;
end
end

if isfunction
ARModelOrder = CheckVararginPairs('ARModelOrder', '', varargin{:});
else
if ~(exist('ARModelOrder','var'))
ARModelOrder='';
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='combinedaccuracy';
end
end

% %% Parameters
% cfg_NameParameters = NAMEPARAMETERS_cgg_nameVariables;
% 
% ExtraSaveTermSubset=cfg_NameParameters.ExtraSaveTermSubset;
% ExtraSaveTermZeroFeature=cfg_NameParameters.ExtraSaveTermZeroFeature;
% ExtraSaveTermAR=cfg_NameParameters.ExtraSaveTermAR;

%%

wantTestOnly=false;
if ~wantTrain && wantTest
    wantTestOnly=true;
end

if wantIA
IADecoderIDX=strcmp(Decoder,IADecoder);
end

%%

kidx=Fold;

TargetDir=cfg.TargetDir.path;
ResultsDir=cfg.ResultsDir.path;

NumDecoders=length(Decoder);
cfg_All=cell(1,NumDecoders);

NumDimensions=length(Dimension);

% ExtraSaveTerm='';
% if wantSubset
% ExtraSaveTerm=[ExtraSaveTerm '_' ExtraSaveTermSubset];
% end
% if wantZeroFeatureDetector
% ExtraSaveTerm=[ExtraSaveTerm '_' ExtraSaveTermZeroFeature];
% end
% if ~isempty(ARModelOrder)
% ExtraSaveTerm=[ExtraSaveTerm '_' ExtraSaveTermAR];
% end

ExtraSaveTerm = cgg_generateExtraSaveTerm('wantSubset',wantSubset,...
    'wantZeroFeatureDetector',wantZeroFeatureDetector,...
    'ARModelOrder',ARModelOrder,'DataWidth',DataWidth,...
    'WindowStride',WindowStride);

DecoderModel_PathNameExt=cell(1,NumDecoders);
DecoderAccuracy_PathNameExt=cell(1,NumDecoders);
DecoderImportance_PathNameExt=cell(1,NumDecoders);

%%

for didx=1:NumDecoders
    this_Decoder=Decoder{didx};
%     this_DecoderFolderName=[this_Decoder ExtraSaveTerm];

cfg_All{didx} = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',this_Decoder,'Fold',Fold);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Decoder',this_Decoder,'Fold',Fold);
cfg_All{didx}.ResultsDir=cfg_Results.TargetDir;

%%
% this_cfg_Decoder = cgg_generateDecoderVariableSaveNames(this_Decoder,cfg_All{didx},wantSubset,'Dimension',Dimension);
this_cfg_Decoder = cgg_generateDecoderVariableSaveNames_v2(this_Decoder,cfg_All{didx},'ExtraSaveTerm',ExtraSaveTerm);

DecoderModel_PathNameExt{didx} = this_cfg_Decoder.Model;
DecoderAccuracy_PathNameExt{didx} = this_cfg_Decoder.Accuracy;
DecoderImportance_PathNameExt{didx} = this_cfg_Decoder.Importance;

end

% Partition_NameExt = 'KFoldPartition.mat';
Partition_PathNameExt = this_cfg_Decoder.Partition;

%%

if isfunction
    [Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg_All{1},varargin{:});
else
    if (exist('Dimension','var')) && (~exist('ARModelOrder','var'))
    [Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg_All{1},'Dimension',Dimension);
    elseif (exist('Dimension','var'))
    [Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg_All{1},'Dimension',Dimension,'ARModelOrder',ARModelOrder);
    end
end

%%

if wantSubset
Combined_ds=subset(Combined_ds,1:SubsetAmount);
end

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;
KFoldPartition=KFoldPartition(1);

this_Training_IDX=training(KFoldPartition,kidx);
this_Testing_IDX=test(KFoldPartition,kidx);

this_TrainingCombined_ds=subset(Combined_ds,this_Training_IDX);
this_TestingCombined_ds=subset(Combined_ds,this_Testing_IDX);

this_TrainingCombined_ds = shuffle(this_TrainingCombined_ds);

this_NumTraining=numpartitions(this_TrainingCombined_ds);

% NumClasses=readall(Combined_ds.UnderlyingDatastores{2});
% NumClasses=gather(tall(Combined_ds.UnderlyingDatastores{2}));
NumClasses=[];
evalc('NumClasses=gather(tall(Combined_ds.UnderlyingDatastores{2}));');
if iscell(NumClasses)
if isnumeric(NumClasses{1})
    [Dim1,Dim2]=size(NumClasses{1});
    [Dim3,Dim4]=size(NumClasses);
if (Dim1>1&&Dim3>1)||(Dim2>1&&Dim4>1)
    NumClasses=NumClasses';
end
    NumClasses=cell2mat(NumClasses);
    [Dim1,Dim2]=size(NumClasses);
if Dim1<Dim2
    NumClasses=NumClasses';
end
end
end

ClassNames=cell(1,NumDimensions);
for fdidx=1:NumDimensions
ClassNames{fdidx}=unique(NumClasses(:,fdidx));
end
NumClasses=cellfun(@(x) length(x),ClassNames);

%%

MdlDecoder=cell(1,NumDecoders);

for didx=1:NumDecoders
MdlDecoder{didx} = cgg_loadDecoderModels_v2(Decoder{didx},NumClasses,DecoderModel_PathNameExt{didx});
end

%%

NumChunksPerDataCycle=ceil(this_NumTraining/NumObsPerChunk);
NumChunks=NumEpochs*NumChunksPerDataCycle;

% AccuracyDecoder_Current=NaN(NumDecoders,NumChunks);
% Window_Accuracy=cell(NumDecoders,1);
% Each_Prediction=cell(NumDimensions,NumDecoders);
% CM_Table_Cell=cell(NumDimensions,NumDecoders);
% CM_Table=cell(NumDecoders,1);
DataCycle = 0;
NewDataCycle = false;
CurrentChunksinCycle=0;

% NumChunksPerDataCycle=floor(this_NumTraining/NumObsPerChunk);
% if ~(rem(this_NumTraining,NumObsPerChunk)==0)
%     NumChunksPerDataCycle=NumChunksPerDataCycle+1;
% end

% NumTotalDataCycles=floor(NumChunks/NumChunksPerDataCycle);
% NumAdditionalChunks=rem(NumChunks,NumChunksPerDataCycle);

% NumDataLoads=NumTotalDataCycles*this_NumTraining+NumAdditionalChunks*NumObsPerChunk;

%%

if wantTrain||wantTest
%% Update Information Setup

% Setting up the DataQueue to receive messages during the parfor loop and
% have it run the update function
q = parallel.pool.DataQueue;
afterEach(q, @nUpdateWaitbar);
gcp;

% Set the number of iterations for the loop.
% Change the value of All_Iterations to the total number of iterations for
% the proper progress update. Change this for specific uses
%                VVVVVVV
% All_Iterations = NumChunks*NumDecoders+NumDataLoads; %<<<<<<<<<
All_Iterations = NumChunks*NumDecoders*NumDimensions+NumChunks; %<<<<<<<<<
%                ^^^^^^^
if wantTestOnly
All_Iterations = NumDimensions*NumDecoders;
end

Iteration_Count = 0;
% Initialize the time elapsed and remaining
Elapsed_Time=seconds(0); Elapsed_Time.Format='hh:mm:ss';
Remaining_Time=seconds(0); Remaining_Time.Format='hh:mm:ss';
Current_Day=datetime('now','TimeZone','local','Format','MMM-d');
Current_Time=datetime('now','TimeZone','local','Format','HH:mm:ss');

% This is the format specification for the message that is displayed.
% Change this to get a different message displayed. The % at the end is 4
% since sprintf and fprintf takes the 4 to 2 to 1. Use 4 if you want to
% display a percent sign otherwise remove them (!!! if removed the delete
% message should no longer be '-1' at the end but '-0'. '\n' is 
%            VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
formatSpec = '*** Current [%s at %s] Decoder Training Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if wantTestOnly
formatSpec = '*** Current [%s at %s] Decoder Testing Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
end

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,Current_Day,Current_Time,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%
end

if wantTrain
for cidx = 1:NumChunks
    
    CurrentChunksinCycle=CurrentChunksinCycle+1;
    this_NumObsPerChunk=NumObsPerChunk;
    if CurrentChunksinCycle*NumObsPerChunk-this_NumTraining>0
        this_NumObsPerChunk=(1-CurrentChunksinCycle)*NumObsPerChunk+this_NumTraining;
        DataCycle=DataCycle+1;
        NewDataCycle=true;
    end

    X_training=cell(this_NumObsPerChunk,1);
    Y_training=cell(this_NumObsPerChunk,1);

    parfor sidx=1:this_NumObsPerChunk
        this_ObsIDX=mod((CurrentChunksinCycle-1)*NumObsPerChunk+sidx-1,this_NumTraining)+1;
        this_tmp_Datastore=partition(this_TrainingCombined_ds,this_NumTraining,this_ObsIDX);
        this_Values=read(this_tmp_Datastore);
        this_X=this_Values{1};
        [this_NumExamples,~]=size(this_X);
        this_Y_All=diag(diag(this_Values{2}))';
        this_Y=repmat(this_Y_All,[this_NumExamples,1]);
        X_training{sidx}=this_X;
        Y_training{sidx}=this_Y;
    % send(q, sidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
    end

    X_training=cell2mat(X_training);
    Y_training=cell2mat(Y_training);

%     Message_CurrentChunk=sprintf('>>> Current Chunk Iteration is %d\n',cidx);
%     Message_X_Size=sprintf('>>> Size of X is %d by %d\n',size(X_training));
%     Message_Y_Size=sprintf('>>> Size of Y is %d by %d\n',size(Y_training));

%     Delete_Message_CurrentChunk=repmat(sprintf('\b'),1,length(Message_CurrentChunk));
%     Delete_Message_X=repmat(sprintf('\b'),1,length(Message_X_Size));
%     Delete_Message_Y=repmat(sprintf('\b'),1,length(Message_Y_Size));

%     fprintf(Message_CurrentChunk);
%     fprintf(Message_X_Size);
%     fprintf(Message_Y_Size);
%%
for didx=1:NumDecoders
% % %     CM_Table_Iter=cell(1,NumIter);
% % %     CM_Table_Cell_Iter=cell(NumDimensions,NumIter);
    %%
    for fdidx=1:NumDimensions
    
    this_Y_training=Y_training(:,fdidx);

    if wantZeroFeatureDetector
    this_MdlZero=MdlDecoder{didx}{fdidx,"ZeroFeature"};
    this_MdlZero=this_MdlZero{1};
    this_MdlFeature=MdlDecoder{didx}{fdidx,"Feature"};
    this_MdlFeature=this_MdlFeature{1};

    this_Y_training_Zero=this_Y_training~=0;
    this_MdlZero = fit(this_MdlZero,X_training,this_Y_training_Zero);

    this_Y_training_Feature=this_Y_training(this_Y_training_Zero,:);
    this_X_training_Feature=X_training(this_Y_training_Zero,:);
    if ~isempty(this_Y_training_Feature)
    this_MdlFeature = fit(this_MdlFeature,this_X_training_Feature,this_Y_training_Feature);
    end
    MdlDecoder{didx}{fdidx,"ZeroFeature"}={this_MdlZero};
    MdlDecoder{didx}{fdidx,"Feature"}={this_MdlFeature};

    else
    this_MdlAll=MdlDecoder{didx}{fdidx,"All"};
    this_MdlAll=this_MdlAll{1};

    this_MdlAll = fit(this_MdlAll,X_training,this_Y_training);

    MdlDecoder{didx}{fdidx,"All"}={this_MdlAll};
    end
%%
% % % if wantTest
% % % %     [CM_Table_Cell{fdidx,didx}] = cgg_procPredictionsFromDatastore(this_TestingCombined_ds,this_Mdl,ClassNames{fdidx},'DimensionNumber',fdidx);
% % %     for idx=1:NumIter
% % % if wantZeroFeatureDetector
% % %     [CM_Table_Cell_Iter{fdidx,idx}] = cgg_procPredictionsFromDatastore(this_TestingCombined_ds,{this_MdlZero,this_MdlFeature},ClassNames{fdidx},'DimensionNumber',fdidx);
% % % else
% % %     [CM_Table_Cell_Iter{fdidx,idx}] = cgg_procPredictionsFromDatastore(this_TestingCombined_ds,this_MdlAll,ClassNames{fdidx},'DimensionNumber',fdidx);
% % % end
% % %     end
% % % end

if isfunction
    send(q, cidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
else
cgg_updateWaitbar(Iteration_Count,All_Iterations,Current_Message,formatSpec);
end
    end % End Loop through dimensions
%%

cgg_procTestingResults(this_TestingCombined_ds,MdlDecoder{didx},'ClassNames',ClassNames,'NumIter',NumIter,'MatchType',MatchType,'SavePathNameExt',DecoderAccuracy_PathNameExt{didx});

cgg_saveVariableUsingMatfile(MdlDecoder(didx),{'ModelDecoder'},DecoderModel_PathNameExt{didx});

% % % for idx=1:NumIter
% % % CM_Table_Iter{idx} = cgg_procCombinePredictions(CM_Table_Cell_Iter(:,idx),'wantZeroFeatureDetector',wantZeroFeatureDetector);
% % % end

%     CM_Table{didx} = cgg_procCombinePredictions(CM_Table_Cell(:,didx));
%     [CM_Table{didx}] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table{didx});
% % %     [CM_Table{didx}] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table_Iter);
% % %     [~,~,AccuracyDecoder_Current(didx,cidx)] = cgg_procConfusionMatrixFromTable(CM_Table{didx},ClassNames,'MatchType',MatchType);
% % %     [~,~,Window_Accuracy{didx}] = cgg_procConfusionMatrixWindowsFromTable(CM_Table{didx},ClassNames,'MatchType',MatchType);

if isfunction
    send(q, cidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
else
cgg_updateWaitbar(Iteration_Count,All_Iterations,Current_Message,formatSpec);
end

end

    if NewDataCycle
        this_TrainingCombined_ds = shuffle(this_TrainingCombined_ds);
        NewDataCycle = false;
        CurrentChunksinCycle = 0;
    end

%     fprintf(Delete_Message_CurrentChunk);
%     fprintf(Delete_Message_X);
%     fprintf(Delete_Message_Y);
end

%%
end

%%

if wantTestOnly

    for didx=1:NumDecoders
        Accuracy_Prior = cgg_loadAccuracy(DecoderAccuracy_PathNameExt{didx});
        cgg_procTestingResults(this_TestingCombined_ds,MdlDecoder{didx},'ClassNames',ClassNames,'NumIter',NumIter,'MatchType',MatchType,'Accuracy_Prior',Accuracy_Prior(1:end-1),'SavePathNameExt',DecoderAccuracy_PathNameExt{didx});
    
        if isfunction
            send(q, cidx); % send to data queue (is this a listener??) to run the 
            %progress update display function
        else
            cgg_updateWaitbar(Iteration_Count,All_Iterations,Current_Message,formatSpec);
        end

    end
end


%%

% if wantTestOnly
% 
%     AccuracyDecoder_Current=NaN(NumDecoders,1);
%     Window_Accuracy=cell(NumDecoders,1);
% %     Each_Prediction=cell(1,NumDecoders);
%     CM_Table=cell(NumDecoders,1);
% 
%     for didx=1:NumDecoders
%         CM_Table_Iter=cell(1,NumIter);
%         CM_Table_Cell_Iter=cell(NumDimensions,NumIter);
%         for fdidx=1:NumDimensions
%     % this_Mdl=MdlDecoder{fdidx,didx};
%     % this_Y_training=Y_training(:,fdidx);
%     % this_Mdl = fit(this_Mdl,X_training,this_Y_training);
%     % MdlDecoder{fdidx,didx}=this_Mdl;
% 
% %     [CM_Table_Cell{fdidx,didx}] = cgg_procPredictionsFromDatastore(this_TestingCombined_ds,this_Mdl,ClassNames{fdidx},'DimensionNumber',fdidx);
%     for idx=1:NumIter
%         if wantZeroFeatureDetector
%             this_MdlZero=MdlDecoder{didx}{fdidx,"ZeroFeature"};
%             this_MdlZero=this_MdlZero{1};
%             this_MdlFeature=MdlDecoder{didx}{fdidx,"Feature"};
%             this_MdlFeature=this_MdlFeature{1};
%             [CM_Table_Cell_Iter{fdidx,idx}] = ...
%                 cgg_procPredictionsFromDatastore(...
%                 this_TestingCombined_ds,{this_MdlZero,this_MdlFeature},...
%                 ClassNames{fdidx},'DimensionNumber',fdidx);
%         else
%             this_MdlAll=MdlDecoder{didx}{fdidx,"All"};
%             this_MdlAll=this_MdlAll{1};
%             [CM_Table_Cell_Iter{fdidx,idx}] = ...
%                 cgg_procPredictionsFromDatastore(...
%                 this_TestingCombined_ds,this_MdlAll,...
%                 ClassNames{fdidx},'DimensionNumber',fdidx);
%         end
%     end
% 
%     if isfunction
%         send(q, cidx); % send to data queue (is this a listener??) to run the 
%         %progress update display function
%     else
%     cgg_updateWaitbar(Iteration_Count,All_Iterations,Current_Message,formatSpec);
%     end
%         end % End of Loop through dimensions
% 
%     for idx=1:NumIter
%         CM_Table_Iter{idx} = cgg_procCombinePredictions(...
%             CM_Table_Cell_Iter(:,idx),...
%             'wantZeroFeatureDetector',wantZeroFeatureDetector);
%     end
% 
% %     CM_Table{didx} = cgg_procCombinePredictions(CM_Table_Cell(:,didx));
% %     [CM_Table{didx}] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table{didx});
%     [CM_Table{didx}] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table_Iter);
%     [~,~,AccuracyDecoder_Current(didx)] = cgg_procConfusionMatrixFromTable(CM_Table{didx},ClassNames,'MatchType',MatchType);
%     [~,~,Window_Accuracy{didx}] = cgg_procConfusionMatrixWindowsFromTable(CM_Table{didx},ClassNames,'MatchType',MatchType);
% 
%     end
% 
% end

%%

% AccuracyDecoder_Prior=[];
% AccuracyDecoder=cell(1,NumDecoders);
% for didx=1:NumDecoders 
% if isfile(DecoderAccuracy_PathNameExt{didx})
% m_DecoderAccuracy = matfile(DecoderAccuracy_PathNameExt{didx},'Writable',true);
% AccuracyDecoder_Prior = m_DecoderAccuracy.Accuracy;
% AccuracyDecoder_Prior=diag(diag(AccuracyDecoder_Prior));
% AccuracyDecoder_Prior=AccuracyDecoder_Prior';
% end
% if ~wantTrain && wantTest
% AccuracyDecoder_Prior=AccuracyDecoder_Prior(1:end-1);
% end
% this_AccuracyDecoder_Current=squeeze(AccuracyDecoder_Current(didx,:));
% this_AccuracyDecoder_Current=diag(diag(this_AccuracyDecoder_Current));
% this_AccuracyDecoder_Current=this_AccuracyDecoder_Current';
% AccuracyDecoder{didx}=[AccuracyDecoder_Prior,this_AccuracyDecoder_Current];
% end

%% Importance Analysis

if wantIA

% IA_Window_Accuracy=cell(1,NumDecoders);
% IA_Accuracy=cell(1,NumDecoders);
% Difference_Window_Accuracy=cell(1,NumDecoders);
% Difference_Accuracy=cell(1,NumDecoders);
% Reference_Window_Accuracy=cell(1,NumDecoders);
% Reference_Accuracy=cell(1,NumDecoders);
% Probe_Areas=cell(1,NumDecoders);

% if wantZeroFeatureDetector
%     IAMdl=MdlDecoder{IADecoderIDX}{:,["ZeroFeature","Feature"]};
% else
%     IAMdl=MdlDecoder{IADecoderIDX}{:,"All"};
% end

IAMdl=MdlDecoder{IADecoderIDX};

CM_Table_IA = cgg_procImportanceAnalysis_v3(this_TestingCombined_ds,IAMdl,ClassNames,varargin{:});

% for didx=1:NumDecoders
% [IA_Window_Accuracy{didx},IA_Accuracy{didx},Difference_Window_Accuracy{didx},Difference_Accuracy{didx},Reference_Window_Accuracy{didx},Reference_Accuracy{didx},Probe_Areas{didx}] = cgg_procImportanceAnalysis(this_TrainingCombined_ds,MdlDecoder{didx},ClassNames,varargin{:});
% end

    SaveVariables={CM_Table_IA};
    SaveVariablesName={'CM_Table_IA'};
    SavePathNameExt=DecoderImportance_PathNameExt{IADecoderIDX};
    cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

% m_DecoderImportance = matfile(DecoderImportanceTMP_PathNameExt{IADecoderIDX},'Writable',true);
% m_DecoderImportance.CM_Table_IA=CM_Table_IA;
% 
% if isfile(DecoderImportance_PathNameExt{IADecoderIDX})
% delete(DecoderImportance_PathNameExt{IADecoderIDX});
% end
% 
% movefile(DecoderImportanceTMP_PathNameExt{IADecoderIDX},DecoderImportance_PathNameExt{IADecoderIDX});

end

%%

for didx=1:NumDecoders

% if wantIA
% m_DecoderImportance = matfile(DecoderImportance_PathNameExt{didx},'Writable',true);
% m_DecoderImportance.IA_Window_Accuracy=IA_Window_Accuracy{didx};
% m_DecoderImportance.IA_Accuracy=IA_Accuracy{didx};
% m_DecoderImportance.Difference_Window_Accuracy=Difference_Window_Accuracy{didx};
% m_DecoderImportance.Difference_Accuracy=Difference_Accuracy{didx};
% m_DecoderImportance.Reference_Window_Accuracy=Reference_Window_Accuracy{didx};
% m_DecoderImportance.Reference_Accuracy=Reference_Accuracy{didx};
% end
% if wantTest

%     SaveVariables={AccuracyDecoder{didx},Window_Accuracy{didx},CM_Table{didx}};
%     SaveVariablesName={'Accuracy','Window_Accuracy','CM_Table'};
%     SavePathNameExt=DecoderAccuracy_PathNameExt{didx};
%     cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);
% m_DecoderAccuracy = matfile(DecoderAccuracy_PathNameExt{didx},'Writable',true);
% m_DecoderAccuracy.Accuracy=AccuracyDecoder{didx};
% m_DecoderAccuracy.Window_Accuracy=Window_Accuracy{didx};
% % m_DecoderAccuracy.Each_Prediction=Each_Prediction{didx};
% m_DecoderAccuracy.CM_Table=CM_Table{didx};
% end

if wantTrain

    cgg_saveVariableUsingMatfile(MdlDecoder(didx),{'ModelDecoder'},DecoderModel_PathNameExt{didx});
%     for fdidx=1:NumDimensions
%         this_DecoderModelTMP_PathNameExt=...
%             DecoderModelTMP_PathNameExt{didx}{fdidx};
% m_DecoderModel = matfile(this_DecoderModelTMP_PathNameExt,'Writable',true);
% m_DecoderModel.ModelDecoder=MdlDecoder{fdidx,didx};
% MdlDecoder
% cgg_saveVariableUsingMatfile(MdlDecoder(fdidx,didx),{'ModelDecoder'},DecoderModel_PathNameExt{didx}{fdidx});

% if isfile(DecoderModel_PathNameExt{didx})
% delete(DecoderModel_PathNameExt{didx});
% end
% 
% movefile(DecoderModelTMP_PathNameExt{didx},DecoderModel_PathNameExt{didx});
%     end
end
end
%% SubFunctions

% Function for displaying an update for a parfor loop. Not able to do as
% simply as with a regular for loop
function nUpdateWaitbar(~)
    % Update global iteration count
    Iteration_Count = Iteration_Count + 1;
    % Get percentage for progress
    Current_Progress=Iteration_Count/All_Iterations*100;
    % Get the amount of time that has passed and how much remains
    Elapsed_Time=seconds(toc); Elapsed_Time.Format='hh:mm:ss';
    Remaining_Time=Elapsed_Time/Current_Progress*(100-Current_Progress);
    Remaining_Time.Format='hh:mm:ss';
    Current_Day=datetime('now','TimeZone','local','Format','MMM-d');
    Current_Time=datetime('now','TimeZone','local','Format','HH:mm:ss');
    % Generate deletion message to remove previous progress update. The
    % '-1' comes from fprintf converting the two %% to one % so the
    % original message is one character longer than what needs to be
    % deleted.
    Delete_Message=repmat(sprintf('\b'),1,length(Current_Message)-1);
    % Generate the update message using the formate specification
    % constructed earlier
    Current_Message=sprintf(formatSpec,Current_Day,Current_Time,...
        Current_Progress,Elapsed_Time,Remaining_Time);
    % Display the update message
    fprintf([Delete_Message,Current_Message]);
end

end