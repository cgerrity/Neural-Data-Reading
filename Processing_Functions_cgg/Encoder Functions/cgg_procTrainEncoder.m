function AutoEncoder = cgg_procTrainEncoder(AutoEncoder,InDataStore,NumTrainEpochs,NumObservations,NumObsPerChunk,NumEpochs,varargin)
%CGG_PROCTRAINENCODER Summary of this function goes here
%   Detailed explanation goes here

NumStacks=length(AutoEncoder);

isfunction=exist('varargin','var');

%%

NumChunksPerDataCycle=ceil(NumObservations/NumObsPerChunk);
NumChunks=NumEpochs*NumChunksPerDataCycle;

% AccuracyDecoder_Current=NaN(NumDecoders,NumChunks);
% Window_Accuracy=cell(NumDecoders,1);
% Each_Prediction=cell(NumDimensions,NumDecoders);
% CM_Table_Cell=cell(NumDimensions,NumDecoders);
% CM_Table=cell(NumDecoders,1);
DataCycle = 0;
NewDataCycle = false;
CurrentChunksinCycle=0;



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
All_Iterations = NumChunks; %<<<<<<<<<
%                ^^^^^^^

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
formatSpec = '*** Current [%s at %s] Encoder Training Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,Current_Day,Current_Time,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%
for cidx = 1:NumChunks
CurrentChunksinCycle=CurrentChunksinCycle+1;
    this_NumObsPerChunk=NumObsPerChunk;
    if CurrentChunksinCycle*NumObsPerChunk-NumObservations>0
        this_NumObsPerChunk=(1-CurrentChunksinCycle)*NumObsPerChunk+NumObservations;
        DataCycle=DataCycle+1;
        NewDataCycle=true;
    end

    X_training=cell(this_NumObsPerChunk,1);

    parfor oidx=1:this_NumObsPerChunk
        this_ObsIDX=mod((CurrentChunksinCycle-1)*NumObsPerChunk+oidx-1,NumObservations)+1;
        this_tmp_Datastore=partition(InDataStore,NumObservations,this_ObsIDX);
        this_Values=read(this_tmp_Datastore);
        this_X=this_Values{1};
        X_training{oidx}=this_X;
    % send(q, sidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
    end

    X_training=cell2mat(X_training);

    this_FeatureVector=X_training';

for sidx=1:NumStacks

    this_AutoEncoder=AutoEncoder{sidx};

    this_AutoEncoder.trainParam.epochs=NumTrainEpochs;

    this_AutoEncoder = train(this_AutoEncoder,this_FeatureVector,this_FeatureVector,'useParallel','yes');
    this_FeatureVector = cgg_getEncoderFeaturesFromNetwork(this_AutoEncoder,this_FeatureVector);

    AutoEncoder{sidx}=this_AutoEncoder;

end

if isfunction
    send(q, cidx); % send to data queue (is this a listener??) to run the 
    %progress update display function
else
cgg_updateWaitbar(Iteration_Count,All_Iterations,Current_Message,formatSpec);
end

    if NewDataCycle
        InDataStore = shuffle(InDataStore);
        NewDataCycle = false;
        CurrentChunksinCycle = 0;
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

