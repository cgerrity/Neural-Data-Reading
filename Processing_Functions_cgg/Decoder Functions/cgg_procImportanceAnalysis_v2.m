function Full_CM_Table = cgg_procImportanceAnalysis_v2(InDatastore,Mdl,ClassNames,varargin)
%CGG_PROCIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

InDatastore_tmp=InDatastore;

isfunction=exist('varargin','var');

if isfunction
NumIter = CheckVararginPairs('NumIter', 4, varargin{:});
else
if ~(exist('NumIter','var'))
NumIter=4;
end
end

% Window_Accuracy = cell(NumIter,1);
% Accuracy = NaN(NumIter,1);
CM_Table = cell(NumIter,1);
% Window_CM = cell(NumIter,1);
% Full_CM = cell(NumIter,1);

for idx=1:NumIter

[~,~,~,~,~,CM_Table{idx}] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);

end

[CM_Table] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table);

% [~,~,Accuracy] = cgg_procConfusionMatrixFromTable(CM_Table,ClassNames);
% [~,~,Window_Accuracy] = cgg_procConfusionMatrixWindowsFromTable(CM_Table,ClassNames);

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

% Full_CM_Table = table('Size',[numel(ChannelRemoval)+1 3],'VariableTypes',{'cell','string','double'},'VariableNames',{'CM_Table','AreaRemoved','ChannelRemoved'});
Full_CM_Table = cell([numel(ChannelRemoval)+1 1]);
Full_CM_Table{1,1}={CM_Table};
Full_AreaRemoved = cell([numel(ChannelRemoval)+1 1]);
Full_AreaRemoved{1,1}='None';
Full_ChannelRemoved = cell([numel(ChannelRemoval)+1 1]);
Full_ChannelRemoved{1,1}=0;
% Full_CM_Table.CM_Table(1)={CM_Table};
% Full_CM_Table.AreaRemoved(1)='None';

% IA_Accuracy=NaN(NumChannels,NumAreas);
% IA_Window_Accuracy=NaN(NumChannels,NumAreas,length(Window_Accuracy));
% 
% Difference_Accuracy=NaN(NumChannels,NumAreas);
% Difference_Window_Accuracy=NaN(NumChannels,NumAreas,length(Window_Accuracy));

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
Current_Day=datetime('now','TimeZone','local','Format','MMM-d');
Current_Time=datetime('now','TimeZone','local','Format','HH:mm:ss');

% This is the format specification for the message that is displayed.
% Change this to get a different message displayed. The % at the end is 4
% since sprintf and fprintf takes the 4 to 2 to 1. Use 4 if you want to
% display a percent sign otherwise remove them (!!! if removed the delete
% message should no longer be '-1' at the end but '-0'. '\n' is 
%            VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
formatSpec = '*** Current [%s at %s] Importance Analysis Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,Current_Day,Current_Time,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%

parfor caidx=1:numel(ChannelRemoval)
% for aidx=1:NumAreas

    [cidx,aidx] = ind2sub([NumChannels,NumAreas],caidx);

this_Datastore=InDatastore_tmp;

this_ChannelRemoval = ChannelRemoval{cidx,aidx};
this_ChannelRemoved=this_ChannelRemoval(1);
this_AreaRemoved=Probe_Areas{aidx};

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,this_ChannelRemoval,false,true,true,true);

this_Datastore.UnderlyingDatastores{1}.ReadFcn=Data_Fun;

% [IA_Window_Accuracy{cidx,pidx},IA_Accuracy{cidx,pidx}] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);

% [IA_Window_Accuracy(cidx,pidx,:),IA_Accuracy(cidx,pidx)] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);
% this_IA_Window_Accuracy = cell(NumIter,1);
% this_IA_Accuracy = NaN(NumIter,1);
% 
% for idx=1:NumIter
% [this_IA_Window_Accuracy{idx},this_IA_Accuracy(idx),~,~] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);
% end

this_IA_CM_Table = cell(NumIter,1);

for idx=1:NumIter
[~,~,~,~,~,this_IA_CM_Table{idx}] = cgg_procConfusionMatrixFromDatastore(InDatastore_tmp,Mdl,ClassNames);
end

[this_IA_CM_Table] = cgg_gatherConfusionMatrixTablesOverIterations(this_IA_CM_Table);

Full_CM_Table{caidx+1,1}={this_IA_CM_Table};
Full_AreaRemoved{caidx+1,1}=string(this_AreaRemoved);
Full_ChannelRemoved{caidx+1,1}=this_ChannelRemoved;

% this_IA_CM_Table.AreaRemoved(:)=string(this_AreaRemoved);
% this_IA_CM_Table.ChannelRemoved(:)=this_ChannelRemoved;
% 
% this_IA_Accuracy = mean(this_IA_Accuracy);
% this_IA_Window_Accuracy=cell2mat(this_IA_Window_Accuracy);
% this_IA_Window_Accuracy = mean(this_IA_Window_Accuracy,1);
% 
% IA_Accuracy(cidx,aidx) = this_IA_Accuracy;
% IA_Window_Accuracy(cidx,aidx,:) = this_IA_Window_Accuracy;
% 
% Difference_Accuracy(cidx,aidx) = this_IA_Accuracy-Accuracy;
% Difference_Window_Accuracy(cidx,aidx,:) = this_IA_Window_Accuracy-Window_Accuracy;

send(q, caidx); % send to data queue (is this a listener??) to run the 
%progress update display function

% end
end

InDatastore_tmp.UnderlyingDatastores{1}.ReadFcn=...
    InDatastore_tmp.UnderlyingDatastores{1}.PreviewFcn;

%%

Full_CM_Table = table(Full_CM_Table,Full_AreaRemoved,...
    Full_ChannelRemoved,'VariableNames',...
    {'CM_Table','AreaRemoved','ChannelRemoved'});

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

