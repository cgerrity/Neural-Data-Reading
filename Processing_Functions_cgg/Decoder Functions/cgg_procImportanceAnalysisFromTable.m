function [OutTable,TypeValues] = cgg_procImportanceAnalysisFromTable(CM_Table_IA,ClassNames,Identifiers_Table,varargin)
%CGG_PROCIMPORTANCEANALYSISFROMTABLE Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
FilterColumn = CheckVararginPairs('FilterColumn', 'All', varargin{:});
else
if ~(exist('FilterColumn','var'))
FilterColumn='All';
end
end

%%

this_DistributionVariable=Identifiers_Table.(FilterColumn);
TypeValues=unique(this_DistributionVariable);
NumTypes=length(TypeValues);

if strcmp(FilterColumn,'Target Feature')
TypeValues=0;
NumTypes=1;
end

%%

Row_Base=strcmp(CM_Table_IA.AreaRemoved,'None');
% Row_Base=find(Row_Base==1);

this_CM_Table=CM_Table_IA{Row_Base,"CM_Table"};
this_CM_Table=this_CM_Table{1}{1};

NumIA=height(CM_Table_IA);
IARange=1:NumIA;
IARange(Row_Base)=[];

this_CMFull_Table=join(this_CM_Table,Identifiers_Table);

[~,~,Full_Accuracy_Base] = cgg_procConfusionMatrixFromTable(this_CM_Table,ClassNames);

[~,~,Window_Accuracy_Base] = cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,ClassNames);

%%

Full_Filtered_Accuracy_Base=NaN(1,NumTypes);
Window_Filtered_Accuracy_Base=cell(1,NumTypes);

    for tidx=1:NumTypes
        this_FilterValue=TypeValues(tidx);

[~,~,Full_Filtered_Accuracy_Base(tidx)] = cgg_procConfusionMatrixFromTable(this_CMFull_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue);

[~,~,Window_Filtered_Accuracy_Base{tidx}] = cgg_procConfusionMatrixWindowsFromTable(this_CMFull_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue);

    end

OutTableSize=[NumIA,4+(NumTypes)*2];
OutTableVarTypes=["double",repmat("double",1,NumTypes),"cell",repmat("cell",1,NumTypes),"string","double"];
OutTableVarNames=["UnfilteredFullAccuracy","FilteredFullAccuracy","UnfilteredWindowAccuracy","FilteredWindowAccuracy","AreaRemoved","ChannelRemoved"];
% OutTableVarTypeNames=compose('Split_Value_%d',TypeValues);

% OutTable_tmp=table('Size',OutTableSize,'VariableTypes',OutTableVarTypes,'VariableNames',OutTableVarNames);
OutTable=table('Size',OutTableSize,'VariableTypes',OutTableVarTypes);
OutTable = mergevars(OutTable,(3+NumTypes*1):(2+NumTypes*2));
OutTable = mergevars(OutTable,(2+NumTypes*0):(1+NumTypes*1));
% OutTable = mergevars(OutTable,(3+NumTypes*1):(2+NumTypes*2),"MergeAsTable",true);
% OutTable = mergevars(OutTable,(2+NumTypes*0):(1+NumTypes*1),"MergeAsTable",true);
OutTable.Properties.VariableNames=OutTableVarNames;

% OutTable.FilteredFullAccuracy.Properties.VariableNames=OutTableVarTypeNames;
% OutTable.FilteredWindowAccuracy.Properties.VariableNames=OutTableVarTypeNames;

OutTable(1,:)={Full_Accuracy_Base,Full_Filtered_Accuracy_Base,{Window_Accuracy_Base},Window_Filtered_Accuracy_Base,"None",0};
%%

CM_Table_IA_AreaRemoved=CM_Table_IA.AreaRemoved;
CM_Table_IA_ChannelRemoved=CM_Table_IA.ChannelRemoved;
CM_Table_IA_CM_Table=CM_Table_IA.CM_Table;

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
All_Iterations = NumIA-1; %<<<<<<<<<
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
formatSpec = '*** Current [%s at %s] Split Importance Analysis Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,Current_Day,Current_Time,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%
parfor iaidx=IARange

    this_AreaRemoved=CM_Table_IA_AreaRemoved{iaidx};
    this_AreaRemoved=this_AreaRemoved{1};
    this_ChannelRemoved=CM_Table_IA_ChannelRemoved{iaidx};
    % this_ChannelRemoved=this_ChannelRemoved{1};

    this_CM_Table=CM_Table_IA_CM_Table{iaidx}{1};

    this_CMFull_Table=join(this_CM_Table,Identifiers_Table);

    [~,~,this_Full_Accuracy] = cgg_procConfusionMatrixFromTable(this_CM_Table,ClassNames);

    [~,~,this_Window_Accuracy] = cgg_procConfusionMatrixWindowsFromTable(this_CM_Table,ClassNames);

    this_Full_Filtered_Accuracy=NaN(1,NumTypes);
    this_Window_Filtered_Accuracy=cell(1,NumTypes);

    for tidx=1:NumTypes
        this_FilterValue=TypeValues(tidx);

[~,~,this_Full_Filtered_Accuracy(tidx)] = cgg_procConfusionMatrixFromTable(this_CMFull_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue);

[~,~,this_Window_Filtered_Accuracy{tidx}] = cgg_procConfusionMatrixWindowsFromTable(this_CMFull_Table,ClassNames,'FilterColumn',FilterColumn,'FilterValue',this_FilterValue);

    end

% this_OutTable=table(this_Full_Accuracy,this_Full_Filtered_Accuracy,{this_Window_Accuracy},this_Window_Filtered_Accuracy,this_AreaRemoved,this_ChannelRemoved);
% 
% this_OutTable.Properties.VariableNames=["UnfilteredFullAccuracy","FilteredFullAccuracy","UnfilteredWindowAccuracy","FilteredWindowAccuracy","AreaRemoved","ChannelRemoved"];
% 
% OutTable=[OutTable;this_OutTable];

OutTable(iaidx,:)={this_Full_Accuracy,this_Full_Filtered_Accuracy,{this_Window_Accuracy},this_Window_Filtered_Accuracy,this_AreaRemoved,this_ChannelRemoved};

send(q, iaidx); % send to data queue (is this a listener??) to run the 
%progress update display function

end

%% Difference

BaseIDX=1;

OutTable.UnfilteredFullDifference=OutTable.UnfilteredFullAccuracy-OutTable.UnfilteredFullAccuracy(BaseIDX);

OutTable.FilteredFullDifference=OutTable.FilteredFullAccuracy-OutTable.FilteredFullAccuracy(BaseIDX,:);

OutTable.UnfilteredWindowDifference=cellfun(@(x) x-OutTable.UnfilteredWindowAccuracy{BaseIDX},OutTable.UnfilteredWindowAccuracy,'UniformOutput',false);

FilteredWindowDifference=cell(0);

for tidx=1:NumTypes
FilteredWindowDifference(:,tidx)=cellfun(@(x) x-OutTable.FilteredWindowAccuracy{BaseIDX,tidx},OutTable.FilteredWindowAccuracy(:,tidx),'UniformOutput',false);
end

OutTable.FilteredWindowDifference=FilteredWindowDifference;

%% Percent

OutTable.UnfilteredFullPercent=OutTable.UnfilteredFullDifference./OutTable.UnfilteredFullAccuracy(BaseIDX);

OutTable.FilteredFullPercent=OutTable.FilteredFullDifference./OutTable.FilteredFullAccuracy(BaseIDX,:);

OutTable.UnfilteredWindowPercent=cellfun(@(x) x./OutTable.UnfilteredWindowAccuracy{BaseIDX},OutTable.UnfilteredWindowDifference,'UniformOutput',false);

FilteredWindowPercent=cell(0);

for tidx=1:NumTypes
FilteredWindowPercent(:,tidx)=cellfun(@(x) x./OutTable.FilteredWindowAccuracy{BaseIDX,tidx},OutTable.FilteredWindowDifference(:,tidx),'UniformOutput',false);
end

OutTable.FilteredWindowPercent=FilteredWindowPercent;

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

