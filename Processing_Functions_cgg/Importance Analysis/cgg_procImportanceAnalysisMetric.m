function [IA_Table_Accuracy] = cgg_procImportanceAnalysisMetric(IA_Table,ClassNames,varargin)
%CGG_PROCIMPORTANCEANALYSISMETRIC Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

%%

CM_Table = IA_Table.CM_Table;
CM_Table_TrueValue = CM_Table{1};
TrueValue = CM_Table_TrueValue.TrueValue;

% Per Session Random Chance and Most Common for testing

MatchType_Calc = MatchType;
IsScaled = contains(MatchType,'Scaled');
if IsScaled
    MatchType_Calc = extractAfter(MatchType,'Scaled-');
    if isempty(MatchType_Calc)
        MatchType_Calc = extractAfter(MatchType,'Scaled_');
    end
    if isempty(MatchType_Calc)
        MatchType_Calc = extractAfter(MatchType,'Scaled');
    end
end

[MostCommon,RandomChance] = cgg_getBaselineAccuracyMeasures(TrueValue,ClassNames,MatchType_Calc,IsQuaddle);
%%

IA_Table_Accuracy = IA_Table;
IA_Table_Accuracy = removevars(IA_Table_Accuracy,'CM_Table');

this_CM_Table = IA_Table.CM_Table{1};
VariableNames=this_CM_Table.Properties.VariableNames;
WindowIndices=contains(VariableNames,'Window');
WindowNames=VariableNames(WindowIndices);
NumWindows=numel(WindowNames);

NumIA = height(IA_Table);
Accuracy = NaN(NumIA,1);
WindowAccuracy = NaN(NumIA,NumWindows);

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
All_Iterations = NumIA; %<<<<<<<<<
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
formatSpec = '*** Current [%s at %s] Importance Analysis Metric Progress is: %.2f%%%%\n*** Time Elapsed: %s, Estimated Time Remaining: %s\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,Current_Day,Current_Time,0,Elapsed_Time,'N/A');
% Display the message
fprintf(Current_Message);
tic
%%

parfor iaidx = 1:NumIA
this_CM_Table = CM_Table{iaidx};

[~,~,this_Accuracy] = ...
cgg_procConfusionMatrixFromTable(this_CM_Table,...
ClassNames,'MatchType',MatchType,...
'IsQuaddle',IsQuaddle,...
'RandomChance',RandomChance,...
'MostCommon',MostCommon);

Accuracy(iaidx) = this_Accuracy;

[~,~,this_WindowAccuracy] = ...
cgg_procConfusionMatrixWindowsFromTable(...
this_CM_Table,ClassNames,...
'MatchType',MatchType,...
'IsQuaddle',IsQuaddle,...
'RandomChance',RandomChance,...
'MostCommon',MostCommon);

WindowAccuracy(iaidx,:) = this_WindowAccuracy;

send(q, iaidx); % send to data queue (is this a listener??) to run the 
%progress update display function
end

IA_Table_Accuracy.Accuracy = Accuracy;
IA_Table_Accuracy.WindowAccuracy = WindowAccuracy;

% IA_Table_Accuracy = cgg_calcImportanceAnalysis(IA_Table_Accuracy, ...
%     'BaselineArea',BaselineArea,'BaselineChannel',BaselineChannel, ...
%     'BaselineLatent',BaselineLatent,'MatchType',MatchType);

% Baseline_IDX = isnan(IA_Table.AreaRemoved) & ...
%     isnan(IA_Table.ChannelRemoved) & ...
%     isnan(IA_Table.LatentRemoved);
% 
% Baseline_Accuracy = IA_Table_Accuracy.Accuracy(Baseline_IDX);
% Baseline_WindowAccuracy = IA_Table_Accuracy.WindowAccuracy(Baseline_IDX,:);
% 
% if IsScaled
% Baseline_Accuracy(Baseline_Accuracy < 0) = NaN;
% Baseline_WindowAccuracy(Baseline_WindowAccuracy < 0) = NaN;
% 
% Accuracy(Accuracy < 0) = 0;
% WindowAccuracy(WindowAccuracy < 0) = 0;
% end
% 
% Accuracy_Difference = Accuracy-Baseline_Accuracy;
% WindowAccuracy_Difference = WindowAccuracy-Baseline_WindowAccuracy;
% 
% Accuracy_RelativeDifference = Accuracy_Difference./Baseline_Accuracy;
% WindowAccuracy_RelativeDifference = WindowAccuracy_Difference./Baseline_WindowAccuracy;
% 
% [WindowAccuracy_Min_Difference,WindowAccuracy_Min_DifferenceIDX] = ...
%     min(WindowAccuracy_Difference,[],2);
% [WindowAccuracy_Min_RelativeDifference,WindowAccuracy_Min_RelativeDifferenceIDX]...
%     = min(WindowAccuracy_RelativeDifference,[],2);
% 
% %%
% 
% IA_Table_Accuracy.Accuracy_Difference = Accuracy_Difference;
% IA_Table_Accuracy.WindowAccuracy_Difference = WindowAccuracy_Difference;
% 
% IA_Table_Accuracy.Accuracy_RelativeDifference = Accuracy_RelativeDifference;
% IA_Table_Accuracy.WindowAccuracy_RelativeDifference = WindowAccuracy_RelativeDifference;
% 
% IA_Table_Accuracy.WindowAccuracy_Min_Difference = WindowAccuracy_Min_Difference;
% IA_Table_Accuracy.WindowAccuracy_Min_DifferenceIDX = WindowAccuracy_Min_DifferenceIDX;
% 
% IA_Table_Accuracy.WindowAccuracy_Min_RelativeDifference = WindowAccuracy_Min_RelativeDifference;
% IA_Table_Accuracy.WindowAccuracy_Min_RelativeDifferenceIDX = WindowAccuracy_Min_RelativeDifferenceIDX;


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

