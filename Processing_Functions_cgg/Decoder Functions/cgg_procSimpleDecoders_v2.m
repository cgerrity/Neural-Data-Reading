function cgg_procSimpleDecoders_v2(DataWidth,StartingIDX,EndingIDX,WindowStride,NumObsPerChunk,NumChunks,Fold,SubsetAmount,wantSubset,cfg,varargin)
%CGG_PROCSIMPLEDECODERS Summary of this function goes here
%   Detailed explanation goes here

kidx=Fold;
%%
cfg_Linear = cgg_generateDecoderVariableSaveNames('Linear',cfg);

LinearModel_PathNameExt = cfg_Linear.Model;
LinearModelTMP_PathNameExt = cfg_Linear.ModelTMP;
% LinearInformation_PathNameExt = cfg_Linear.Information;
LinearAccuracy_PathNameExt = cfg_Linear.Accuracy;
LinearImportance_PathNameExt = cfg_Linear.Importance;

% Partition_NameExt = 'KFoldPartition.mat';
Partition_PathNameExt = cfg_Linear.Partition;


%%

[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,varargin{:});
%%
if wantSubset
Combined_ds=subset(Combined_ds,1:SubsetAmount);
end

m_Partition = matfile(Partition_PathNameExt,'Writable',false);
KFoldPartition=m_Partition.KFoldPartition;

this_Training_IDX=training(KFoldPartition,kidx);
this_Testing_IDX=test(KFoldPartition,kidx);

this_TrainingCombined_ds=subset(Combined_ds,this_Training_IDX);
this_TestingCombined_ds=subset(Combined_ds,this_Testing_IDX);

this_TrainingCombined_ds = shuffle(this_TrainingCombined_ds);

this_NumTraining=numpartitions(this_TrainingCombined_ds);

NumClasses=readall(Combined_ds.UnderlyingDatastores{2});
if iscell(NumClasses)
if isnumeric(NumClasses{1})
    NumClasses=cell2mat(NumClasses);
end
end
ClassNames=unique(NumClasses);
NumClasses=length(ClassNames);

%%

if isfile(LinearModel_PathNameExt)
m_LinearModel = matfile(LinearModel_PathNameExt,'Writable',false);
MdlLinear = m_LinearModel.ModelLinear;
else
MdlLinear = incrementalClassificationECOC(MaxNumClasses=NumClasses,Coding="onevsall",Learners="linear");
end

%%
AccuracyLinear=NaN(1,NumChunks);
DataCycle = 0;
NewDataCycle = false;
CurrentChunksinCycle=0;

NumChunksPerDataCycle=floor(this_NumTraining/NumObsPerChunk);
if ~(rem(this_NumTraining,NumObsPerChunk)==0)
    NumChunksPerDataCycle=NumChunksPerDataCycle+1;
end

NumTotalDataCycles=floor(NumChunks/NumChunksPerDataCycle);
NumAdditionalChunks=rem(NumChunks,NumChunksPerDataCycle);

NumDataLoads=NumTotalDataCycles*this_NumTraining+NumAdditionalChunks*NumObsPerChunk;

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
All_Iterations = NumChunks+NumDataLoads; %<<<<<<<<<
%                ^^^^^^^
% Iteration count starts at 0... seems self explanatory ¯\_(ツ)_/¯
Iteration_Count = 0;
% Initialize the time elapsed and remaining
Elapsed_Time=seconds(0); Elapsed_Time.Format='hh:mm:ss';
Remaining_Time=seconds(0); Remaining_Time.Format='hh:mm:ss';

% This is the format specification for the message that is displayed.
% Change this to get a different message displayed. The % at the end is 4
% since sprintf and fprintf takes the 4 to 2 to 1. Use 4 if you want to
% display a percent sign otherwise remove them (!!! if removed the delete
% message should no longer be '-1' at the end but '-0'. '\n' is 
%            VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
formatSpec = '*** Current Linear Decoding Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%
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
        this_Y=repmat(this_Values{2},[this_NumExamples,1]);
        X_training{sidx}=this_X;
        Y_training{sidx}=this_Y;
    send(q, sidx); % send to data queue (is this a listener??) to run the 
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

    MdlLinear = fit(MdlLinear,X_training,Y_training);
%%

[Window_Accuracy,AccuracyLinear(cidx)] = cgg_procConfusionMatrixFromDatastore(this_TestingCombined_ds,MdlLinear,ClassNames);

    if NewDataCycle
        this_TrainingCombined_ds = shuffle(this_TrainingCombined_ds);
        NewDataCycle = false;
        CurrentChunksinCycle = 0;
    end

%     fprintf(Delete_Message_CurrentChunk);
%     fprintf(Delete_Message_X);
%     fprintf(Delete_Message_Y);

    send(q, cidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
end

%%
if isfile(LinearAccuracy_PathNameExt)
m_LinearAccuracy = matfile(LinearAccuracy_PathNameExt,'Writable',true);
AccuracyLinear_Prior = m_LinearAccuracy.Accuracy;
AccuracyLinear=[AccuracyLinear_Prior,AccuracyLinear];
end

%% Importance Analysis

% [IA_Window_Accuracy,IA_Accuracy,Difference_Window_Accuracy,Difference_Accuracy,Reference_Window_Accuracy,Reference_Accuracy] = cgg_procImportanceAnalysis(this_TrainingCombined_ds,MdlLinear,ClassNames,varargin{:});

%%

if isfile(LinearModel_PathNameExt)
delete(LinearModel_PathNameExt);
end

m_LinearAccuracy = matfile(LinearAccuracy_PathNameExt,'Writable',true);
m_LinearAccuracy.Accuracy=AccuracyLinear;
m_LinearAccuracy.Window_Accuracy=Window_Accuracy;
% m_LinearImportance = matfile(LinearImportance_PathNameExt,'Writable',true);
% m_LinearImportance.IA_Window_Accuracy=IA_Window_Accuracy;
% m_LinearImportance.IA_Accuracy=IA_Accuracy;
% m_LinearImportance.Difference_Window_Accuracy=Difference_Window_Accuracy;
% m_LinearImportance.Difference_Accuracy=Difference_Accuracy;
% m_LinearImportance.Reference_Window_Accuracy=Reference_Window_Accuracy;
% m_LinearImportance.Reference_Accuracy=Reference_Accuracy;
m_LinearModel = matfile(LinearModelTMP_PathNameExt,'Writable',true);
m_LinearModel.ModelLinear=MdlLinear;

if isfile(LinearModel_PathNameExt)
delete(LinearModel_PathNameExt);
end

movefile(LinearModelTMP_PathNameExt,LinearModel_PathNameExt);

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
    % Generate deletion message to remove previous progress update. The
    % '-1' comes from fprintf converting the two %% to one % so the
    % original message is one character longer than what needs to be
    % deleted.
    Delete_Message=repmat(sprintf('\b'),1,length(Current_Message)-1);
    % Generate the update message using the formate specification
    % constructed earlier
    Current_Message=sprintf(formatSpec,Current_Progress,Elapsed_Time,...
        Remaining_Time);
    % Display the update message
    fprintf([Delete_Message,Current_Message]);
end

end