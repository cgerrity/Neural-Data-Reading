function cgg_procSimpleDecoders_v3(DataWidth,StartingIDX,EndingIDX,WindowStride,NumObsPerChunk,NumChunks,Fold,Epoch,Decoder,cfg,varargin)
%CGG_PROCSIMPLEDECODERS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%%

if isfunction
wantSubset = CheckVararginPairs('wantSubset', false, varargin{:});
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

wantTestOnly=false;
if ~wantTrain && wantTest
    wantTestOnly=true;
end

%%

kidx=Fold;

TargetDir=cfg.TargetDir.path;

NumDecoders=length(Decoder);
cfg_All=cell(1,NumDecoders);

DecoderModel_PathNameExt=cell(1,NumDecoders);
DecoderModelTMP_PathNameExt=cell(1,NumDecoders);
% DecoderInformation_PathNameExt=cell(1,NumDecoders);
DecoderAccuracy_PathNameExt=cell(1,NumDecoders);
DecoderImportance_PathNameExt=cell(1,NumDecoders);

%%

for didx=1:NumDecoders
    this_Decoder=Decoder{didx};
    this_DecoderFolderName=this_Decoder;
    if wantSubset
        this_DecoderFolderName=[this_Decoder '_Subset'];
    end
cfg_All{didx} = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',this_DecoderFolderName,'Fold',Fold);

%%
this_cfg_Decoder = cgg_generateDecoderVariableSaveNames(this_Decoder,cfg_All{didx},wantSubset);

DecoderModel_PathNameExt{didx} = this_cfg_Decoder.Model;
DecoderModelTMP_PathNameExt{didx} = this_cfg_Decoder.ModelTMP;
% DecoderInformation_PathNameExt{didx} = cfg_Decoder.Information;
DecoderAccuracy_PathNameExt{didx} = this_cfg_Decoder.Accuracy;
DecoderImportance_PathNameExt{didx} = this_cfg_Decoder.Importance;

end

% Partition_NameExt = 'KFoldPartition.mat';
Partition_PathNameExt = this_cfg_Decoder.Partition;

%%

if isfunction
[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg_All{1},varargin{:});
else
if (exist('Dimension','var'))
[Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg_All{1},'Dimension',Dimension);
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
evalc('NumClasses=gather(tall(Combined_ds.UnderlyingDatastores{2}));');
if iscell(NumClasses)
if isnumeric(NumClasses{1})
    NumClasses=cell2mat(NumClasses);
end
end
ClassNames=unique(NumClasses);
NumClasses=length(ClassNames);

%%

MdlDecoder=cell(1,NumDecoders);

for didx=1:NumDecoders

MdlDecoder{didx} = cgg_loadDecoderModels(Decoder{didx},NumClasses,DecoderModel_PathNameExt{didx});

end

%%
AccuracyDecoder_Current=NaN(NumDecoders,NumChunks);
Window_Accuracy=cell(1,NumDecoders);
Each_Prediction=cell(1,NumDecoders);
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
All_Iterations = NumChunks*NumDecoders; %<<<<<<<<<
%                ^^^^^^^
if wantTestOnly
All_Iterations = NumDecoders;
end

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
formatSpec = '*** Current Decoder Training Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
if wantTestOnly
formatSpec = '*** Current Decoder Testing Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n';
end

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,0,Elapsed_Time,'N/A');
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
        this_Y=repmat(this_Values{2},[this_NumExamples,1]);
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

parfor didx=1:NumDecoders

    MdlDecoder{didx} = fit(MdlDecoder{didx},X_training,Y_training);
%%

if wantTest
[Window_Accuracy{didx},AccuracyDecoder_Current(didx,cidx),~,~,Each_Prediction{didx}] = cgg_procConfusionMatrixFromDatastore(this_TestingCombined_ds,MdlDecoder{didx},ClassNames);
end

    send(q, cidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
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

    AccuracyDecoder_Current=NaN(NumDecoders,1);
    Window_Accuracy=cell(1,NumDecoders);
    Each_Prediction=cell(1,NumDecoders);

    parfor didx=1:NumDecoders

    [Window_Accuracy{didx},AccuracyDecoder_Current(didx),~,~,Each_Prediction{didx}] = cgg_procConfusionMatrixFromDatastore(this_TestingCombined_ds,MdlDecoder{didx},ClassNames);

    send(q, didx); % send to data queue (is this a listener??) to run the 
    %progress update display function
    end

end

%%

AccuracyDecoder_Prior=[];
AccuracyDecoder=cell(1,NumDecoders);
for didx=1:NumDecoders
if isfile(DecoderAccuracy_PathNameExt{didx})
m_DecoderAccuracy = matfile(DecoderAccuracy_PathNameExt{didx},'Writable',true);
AccuracyDecoder_Prior = m_DecoderAccuracy.Accuracy;
end
if ~wantTrain && wantTest
AccuracyDecoder_Prior=AccuracyDecoder_Prior(1:end-1);
end
AccuracyDecoder{didx}=[AccuracyDecoder_Prior,AccuracyDecoder_Current(didx,:)];
end

%% Importance Analysis

if isfunction
wantIA = CheckVararginPairs('wantIA', false, varargin{:});
else
if ~(exist('wantIA','var'))
wantIA=false;
end
end

if wantIA
IA_Window_Accuracy=cell(1,NumDecoders);
IA_Accuracy=cell(1,NumDecoders);
Difference_Window_Accuracy=cell(1,NumDecoders);
Difference_Accuracy=cell(1,NumDecoders);
Reference_Window_Accuracy=cell(1,NumDecoders);
Reference_Accuracy=cell(1,NumDecoders);
Probe_Areas=cell(1,NumDecoders);

for didx=1:NumDecoders
[IA_Window_Accuracy{didx},IA_Accuracy{didx},Difference_Window_Accuracy{didx},Difference_Accuracy{didx},Reference_Window_Accuracy{didx},Reference_Accuracy{didx},Probe_Areas{didx}] = cgg_procImportanceAnalysis(this_TrainingCombined_ds,MdlDecoder{didx},ClassNames,varargin{:});
end

end

%%

for didx=1:NumDecoders

if wantIA
m_DecoderImportance = matfile(DecoderImportance_PathNameExt{didx},'Writable',true);
m_DecoderImportance.IA_Window_Accuracy=IA_Window_Accuracy{didx};
m_DecoderImportance.IA_Accuracy=IA_Accuracy{didx};
m_DecoderImportance.Difference_Window_Accuracy=Difference_Window_Accuracy{didx};
m_DecoderImportance.Difference_Accuracy=Difference_Accuracy{didx};
m_DecoderImportance.Reference_Window_Accuracy=Reference_Window_Accuracy{didx};
m_DecoderImportance.Reference_Accuracy=Reference_Accuracy{didx};
end

m_DecoderAccuracy = matfile(DecoderAccuracy_PathNameExt{didx},'Writable',true);
m_DecoderAccuracy.Accuracy=AccuracyDecoder{didx};
m_DecoderAccuracy.Window_Accuracy=Window_Accuracy{didx};
m_DecoderAccuracy.Each_Prediction=Each_Prediction{didx};
m_DecoderModel = matfile(DecoderModelTMP_PathNameExt{didx},'Writable',true);
m_DecoderModel.ModelDecoder=MdlDecoder{didx};

if isfile(DecoderModel_PathNameExt{didx})
delete(DecoderModel_PathNameExt{didx});
end

movefile(DecoderModelTMP_PathNameExt{didx},DecoderModel_PathNameExt{didx});

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