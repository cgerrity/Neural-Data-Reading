function [IA_Table,StopChecking] = cgg_procImportanceAnalysisFromNetwork(InDatastore,Encoder,Classifier,ClassNames,varargin)
%CGG_PROCIMPORTANCEANALYSISFROMNETWORK Summary of this function goes here
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
RemovalType = CheckVararginPairs('RemovalType', 'Channel', varargin{:});
else
if ~(exist('RemovalType','var'))
RemovalType='Channel';
end
end

if isfunction
NumRemoved = CheckVararginPairs('NumRemoved', 1, varargin{:});
else
if ~(exist('NumRemoved','var'))
NumRemoved=1;
end
end

if isfunction
NumEntries = CheckVararginPairs('NumEntries', 348, varargin{:});
else
if ~(exist('NumEntries','var'))
NumEntries=348;
end
end

if isfunction
RemovalTable = CheckVararginPairs('RemovalTable', [], varargin{:});
else
if ~(exist('RemovalTable','var'))
RemovalTable=[];
end
end

if isfunction
RemovalTableSaveFunc = CheckVararginPairs('RemovalTableSaveFunc', [], varargin{:});
else
if ~(exist('RemovalTableSaveFunc','var'))
RemovalTableSaveFunc=[];
end
end

if isfunction
IAPathNameExt = CheckVararginPairs('IAPathNameExt', '', varargin{:});
else
if ~(exist('IAPathNameExt','var'))
IAPathNameExt='';
end
end

if isfunction
MustIncludeTable = CheckVararginPairs('MustIncludeTable', [], varargin{:});
else
if ~(exist('MustIncludeTable','var'))
MustIncludeTable=[];
end
end
%%

% cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
% Probe_Order=cfg_param.Probe_Order;
% [Probe_Dimensions,Probe_Areas,~,~] = cgg_getProbeDimensions(Probe_Order);
% Probe_Areas = Probe_Areas';
%%
NumDimensions = length(ClassNames);
OutputNames_Classifier = Classifier.OutputNames;
LossType_Classifier = repmat({'CrossEntropy'},1,NumDimensions);
LossType_Classifier(contains(OutputNames_Classifier,'CTC')) = {'CTC'};

%%

MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat);

NumBatches = ceil(numpartitions(InDatastore)/maxworkerMiniBatchSize);

%%

BadData = preview(InDatastore);
BadData = squeeze(isnan(BadData{1}(:,1,:,1)));

[BadChannel,BadArea] = ind2sub(size(BadData),find(BadData));
BadChannelTable = table(BadChannel,BadArea,'VariableNames',{'ChannelIndices','AreaIndices'});
%%

LayerNameIDX = contains({Encoder.Layers(:).Name},'Input_Encoder');
InputSize = Encoder.Layers(LayerNameIDX).InputSize;
LayerNameIDX = contains({Classifier.Layers(:).Name},'Input_Classifier');
LatentSize = Classifier.Layers(LayerNameIDX).InputSize;

NumChannels = InputSize(1);
NumAreas = InputSize(3);
%%

if ~istable(RemovalTable)
RemovalTable = cgg_makeRemovalTable(NumChannels,NumAreas,LatentSize,BadChannelTable,'RemovalType',RemovalType,'NumRemoved',NumRemoved,'NumEntries',NumEntries,'MustIncludeTable',MustIncludeTable);
if ~istable(RemovalTable)
IA_Table =  NaN;
StopChecking = false;
return
end
end

if ~isempty(RemovalTableSaveFunc)
    
    RemovalTableSaveFunc(RemovalTable);
    RemovalTable = cgg_getRemovalTable(IAPathNameExt);
end

% ChannelIndices = 1:NumChannels;
% AreaIndices = 1:NumAreas;
% 
% ChannelTable = combinations(AreaIndices,ChannelIndices);
% [~,BadChannelIndices,~] = intersect(ChannelTable,BadChannelTable);
% ChannelTable(BadChannelIndices,:) = [];

%%

% if istable(RemovalTable)
% ChannelRemovalIndices = RemovalTable.ChannelRemoved;
% AreaRemovalIndices = RemovalTable.AreaRemoved;
% LatentRemovalIndices = RemovalTable.LatentRemoved;
% AreaNames = RemovalTable.AreaNames;
% NumEntries = height(RemovalTable);
% else
% 
% switch RemovalType
%     case 'Channel'
%         NumOptions = height(ChannelTable);
%         % NumOptions = NumChannels*NumAreas;
%         if NumRemoved > NumOptions
%             IA_Table = NaN;
%             return
%         end
%         RemovalIndices = cgg_getCombinations(1:NumOptions, NumRemoved, NumEntries);
%         NumEntries = size(RemovalIndices,1);
%         AllChannels = ChannelTable.ChannelIndices;
%         AllAreas = ChannelTable.AreaIndices;
%         ChannelRemovalIndices = AllChannels(RemovalIndices);
%         AreaRemovalIndices = AllAreas(RemovalIndices);
%         % [ChannelRemovalIndices,AreaRemovalIndices] = ind2sub([NumChannels,NumAreas],RemovalIndices);
%         LatentRemovalIndices = NaN(NumEntries,NumRemoved);
%         AreaNames = Probe_Areas(Probe_Dimensions(AreaRemovalIndices));
% 
%         if NumEntries == 1
%         AreaNames = AreaNames';
%         AreaRemovalIndices = AreaRemovalIndices';
%         ChannelRemovalIndices = ChannelRemovalIndices';
%         end
%     case 'Latent'
%         NumOptions = LatentSize;
%         if NumRemoved > NumOptions
%             IA_Table = NaN;
%             return
%         end
%         RemovalIndices = cgg_getCombinations(1:NumOptions, NumRemoved, NumEntries);
%         NumEntries = size(RemovalIndices,1);
%         LatentRemovalIndices = RemovalIndices;
%         ChannelRemovalIndices = NaN(NumEntries,NumRemoved);
%         AreaRemovalIndices = NaN(NumEntries,NumRemoved);
%         AreaNames = repmat({'None'},[NumEntries,NumRemoved]);
%         if NumEntries == 1
%         LatentRemovalIndices = LatentRemovalIndices';
%         end
% end
% 
% %%
% 
% ChannelRemovalIndices = num2cell(ChannelRemovalIndices,2);
% AreaRemovalIndices = num2cell(AreaRemovalIndices,2);
% LatentRemovalIndices = num2cell(LatentRemovalIndices,2);
% AreaNames = num2cell(AreaNames,2);
% 
% %%
% ChannelRemovalIndices = [{NaN(1,NumRemoved)};ChannelRemovalIndices];
% AreaRemovalIndices = [{NaN(1,NumRemoved)};AreaRemovalIndices];
% LatentRemovalIndices = [{NaN(1,NumRemoved)};LatentRemovalIndices];
% AreaNames = [{repmat({'None'},[1,NumRemoved])};AreaNames];
% NumEntries = NumEntries+1;
% 
% end

% %%
% if ~isempty(RemovalTableSaveFunc)
% RemovalTable = table(AreaRemovalIndices,...
%     ChannelRemovalIndices,LatentRemovalIndices,AreaNames,'VariableNames',...
%     {'AreaRemoved','ChannelRemoved','LatentRemoved','AreaNames'});
% RemovalTableSaveFunc(RemovalTable);
% end
%%

NumIA = height(RemovalTable);

Full_CM_Table = cell([NumIA 1]);

IA_Table = RemovalTable;
IA_Table.CM_Table = Full_CM_Table;

% IA_Table = table(Full_CM_Table,AreaRemovalIndices,...
%     ChannelRemovalIndices,LatentRemovalIndices,AreaNames,'VariableNames',...
%     {'CM_Table','AreaRemoved','ChannelRemoved','LatentRemoved','AreaNames'});

% NumIA = height(IA_Table);

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
All_Iterations = NumBatches*NumIA; %<<<<<<<<<
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

StopCheckingQueue = parallel.pool.DataQueue;
afterEach(StopCheckingQueue, @StopCheckingFunc);

%%

wantLoss = false;
Normalization_Factor = 0;
Loss_Classification_PerDimension = NaN;

ChannelRemoval = IA_Table.ChannelRemoved;
AreaRemoval = IA_Table.AreaRemoved;
LatentRemoval = IA_Table.LatentRemoved;
CM_Table = IA_Table.CM_Table;

StopChecking = false;

%%

while hasdata(MaxMbq) && ~StopChecking

    % disp({'Before:While',StopChecking})

    [HasIA_Table,~] = cgg_checkImportanceAnalysis(IAPathNameExt);
    if HasIA_Table
        send(StopCheckingQueue, 1);
        % Iteration_Count = All_Iterations - 1;
        send(q, 1); 
        % StopChecking = true;
        break
    end
    % disp({'After:While',StopChecking})

[X,T,DataNumber] = next(MaxMbq);
Encoder=resetState(Encoder);
[Y_Encoded] = predict(Encoder,X);

X_Parallel = parallel.pool.Constant(X);
Y_Encoded_Parallel = parallel.pool.Constant(Y_Encoded);



parfor ridx = 1:NumIA

    %%
    % disp({'Before:Loop',StopChecking})

    if StopChecking
            Iteration_Count = All_Iterations - 1;
            send(q, ridx); 
            % send to data queue (is this a listener??) to run the progress
            % update display function
            continue
    else
        [HasIA_Table,~] = cgg_checkImportanceAnalysis(IAPathNameExt);
        if HasIA_Table
            send(StopCheckingQueue, ridx); 
            % StopChecking = true;
            % Iteration_Count = All_Iterations - 1;
            send(q, ridx); 
            % send to data queue (is this a listener??) to run the progress
            % update display function
            continue
        end
    end

    % disp({'After:Loop',StopChecking})
    %%

    this_ChannelRemoval = ChannelRemoval(ridx,:);
    this_AreaRemoval = AreaRemoval(ridx,:);
    this_LatentRemoval = LatentRemoval(ridx,:);
    this_ChannelRemoval = this_ChannelRemoval{1};
    this_AreaRemoval = this_AreaRemoval{1};
    this_LatentRemoval = this_LatentRemoval{1};

    HasChannelAreaRemoval = ~(any(isnan(this_ChannelRemoval)) ...
        || any(isnan(this_AreaRemoval)));
    HasLatentRemoval = ~any(isnan(this_LatentRemoval));

    if HasChannelAreaRemoval
        % this_X = X;
        this_X = X_Parallel.Value;
        for acidx = 1:length(this_ChannelRemoval)
            this_cidx = this_ChannelRemoval(acidx);
            this_aidx = this_AreaRemoval(acidx);
            this_X(this_cidx,:,this_aidx,:,:) = 0;
        end
        % Encoder=resetState(Encoder);
        % [this_Y_Encoded] = predict(Encoder,this_X);
        [this_Y_Encoded] = cgg_procNetworkPass(this_X,Encoder);
    else
        % this_Y_Encoded = Y_Encoded;
        this_Y_Encoded = Y_Encoded_Parallel.Value;
    end

    if HasLatentRemoval
        this_Y_Encoded(this_LatentRemoval,:,:) = 0;
    end

% Classifier=resetState(Classifier);
% Y_Classified=cell(NumDimensions,1);
% [Y_Classified{:},~] = predict(Classifier,this_Y_Encoded,Outputs=OutputNames_Classifier);
[Y_Classified,~] = cgg_procNetworkPass(this_Y_Encoded,Classifier,'OutputNames',OutputNames_Classifier);

% this_CM_Table = IA_Table.CM_Table{ridx};
this_CM_Table = CM_Table{ridx};

[~,this_CM_Table] = cgg_getClassifierOutputsFromProbabilities(...
    T,Y_Classified,ClassNames,DataNumber,...
    Loss_Classification_PerDimension,this_CM_Table,Normalization_Factor,...
    'IsQuaddle',IsQuaddle,'wantLoss',wantLoss,...
    'LossType',LossType_Classifier);

% IA_Table.CM_Table{ridx}=this_CM_Table;
CM_Table{ridx}=this_CM_Table;
send(q, ridx); % send to data queue (is this a listener??) to run the 
%progress update display function

end

end

% [HasIA_Table,~] = cgg_checkImportanceAnalysis();
if StopChecking
fprintf('~~~ Fold Importance Analysis Ended Early Due to Other Instance Completion \n');
[IA_Table,~,~] = cgg_getImportanceAnalysis(IAPathNameExt);
% fprintf('~~~ Fold Importance Analysis Ended Early Due to Other Instance Completion \n');
else
    IA_Table.CM_Table=CM_Table;
end

%% SubFunctions

% Function for displaying an update for a parfor loop. Not able to do as
% simply as with a regular for loop
function nUpdateWaitbar(~)
    % Update global iteration count
    Iteration_Count = Iteration_Count + 1;
    if StopChecking
        Iteration_Count = All_Iterations;
    end
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

function StopCheckingFunc(~)
StopChecking = true;
end


end

