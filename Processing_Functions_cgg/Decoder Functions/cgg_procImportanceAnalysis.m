function [IA_Window_Accuracy,IA_Accuracy,Difference_Window_Accuracy,Difference_Accuracy,Window_Accuracy,Accuracy,Probe_Areas] = cgg_procImportanceAnalysis(InDatastore,Mdl,ClassNames,varargin)
%CGG_PROCIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

InDatastore_tmp=InDatastore;

NumIter = CheckVararginPairs('NumIter', 4, varargin{:});

Window_Accuracy = cell(NumIter,1);
Accuracy = NaN(NumIter,1);
% Window_CM = cell(NumIter,1);
% Full_CM = cell(NumIter,1);

for idx=1:NumIter

[Window_Accuracy{idx},Accuracy(idx),~,~,~,~] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);

end

Accuracy=mean(Accuracy);
Window_Accuracy=cell2mat(Window_Accuracy);
Window_Accuracy=mean(Window_Accuracy,1);

%%

ReadFunctionInformation=functions(InDatastore_tmp.UnderlyingDatastores{1}.ReadFcn);

DataWidth=ReadFunctionInformation.workspace{1}.DataWidth;
StartingIDX=ReadFunctionInformation.workspace{1}.StartingIDX;
EndingIDX=ReadFunctionInformation.workspace{1}.EndingIDX;
WindowStride=ReadFunctionInformation.workspace{1}.WindowStride;

%%

% NumChannels=NEEDED;
% NumProbes=NEEDED;

Data_Fun=@(x) cgg_loadDataArray(x,1,1,1,1,[],false,false,false,false);
InDatastore_tmp.UnderlyingDatastores{1}.ReadFcn=Data_Fun;

this_Data_tmp=preview(InDatastore_tmp);

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');

Probe_Order=cfg_param.Probe_Order;

[~,Probe_Areas,~,Same_Areas] = cgg_getProbeDimensions(Probe_Order);

[NumChannels,~,~] = size(this_Data_tmp{1});

NumAreas = length(Same_Areas);

ChannelRemoval=cell(NumChannels,NumAreas);
for cidx=1:NumChannels
    for aidx=1:NumAreas
        this_probe_IDX = Same_Areas{aidx};
        for sidx=1:length(this_probe_IDX)
        ChannelRemoval{cidx,aidx}(sidx,:)=[cidx,this_probe_IDX(sidx)];
        end
    end
end

%%

% IA_Window_Accuracy=cell(NumChannels,NumProbes);
% IA_Accuracy=cell(NumChannels,NumProbes);

IA_Accuracy=NaN(NumChannels,NumAreas);
IA_Window_Accuracy=NaN(NumChannels,NumAreas,length(Window_Accuracy));

Difference_Accuracy=NaN(NumChannels,NumAreas);
Difference_Window_Accuracy=NaN(NumChannels,NumAreas,length(Window_Accuracy));

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
All_Iterations = NumChannels*NumAreas; %<<<<<<<<<
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
formatSpec = '*** Current Importance Analysis Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%

parfor cidx=1:NumChannels
for aidx=1:NumAreas

this_Datastore=InDatastore_tmp;

this_ChannelRemoval = ChannelRemoval{cidx,aidx};

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,this_ChannelRemoval,false,true,true,true);

this_Datastore.UnderlyingDatastores{1}.ReadFcn=Data_Fun;

% [IA_Window_Accuracy{cidx,pidx},IA_Accuracy{cidx,pidx}] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);

% [IA_Window_Accuracy(cidx,pidx,:),IA_Accuracy(cidx,pidx)] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);
this_IA_Window_Accuracy = cell(NumIter,1);
this_IA_Accuracy = NaN(NumIter,1);

for idx=1:NumIter
[this_IA_Window_Accuracy{idx},this_IA_Accuracy(idx),~,~] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);
end

this_IA_Accuracy = mean(this_IA_Accuracy);
this_IA_Window_Accuracy=cell2mat(this_IA_Window_Accuracy);
this_IA_Window_Accuracy = mean(this_IA_Window_Accuracy,1);

IA_Accuracy(cidx,aidx) = this_IA_Accuracy;
IA_Window_Accuracy(cidx,aidx,:) = this_IA_Window_Accuracy;

Difference_Accuracy(cidx,aidx) = this_IA_Accuracy-Accuracy;
Difference_Window_Accuracy(cidx,aidx,:) = this_IA_Window_Accuracy-Window_Accuracy;

send(q, cidx); % send to data queue (is this a listener??) to run the 
%progress update display function

end
end

InDatastore_tmp.UnderlyingDatastores{1}.ReadFcn=...
    InDatastore_tmp.UnderlyingDatastores{1}.PreviewFcn;

%%

% Difference_Accuracy = IA_Accuracy-Accuracy;
% Difference_Window_Accuracy = Window_Accuracy-IA_Window_Accuracy;

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

