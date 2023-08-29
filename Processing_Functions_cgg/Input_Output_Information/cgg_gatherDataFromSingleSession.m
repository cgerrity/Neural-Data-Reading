function cgg_gatherDataFromSingleSession(SessionFolder,Epoch,TargetDir,varargin)
%CGG_GATHERDATAFROMSINGLESESSION Summary of this function goes here
%   Detailed explanation goes here

%%
isfunction=exist('varargin','var');

if isfunction
[cfg] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,...
    'Epoch',Epoch);
else
    Existence_Array = [exist('TargetDir','var'), ...
        exist('Epoch','var')];
    Existence_Value = bi2de(Existence_Array, 'left-msb');
    
    switch Existence_Value
        case 3 % TargetDir, Epoch
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,'Epoch',Epoch);
        case 2 % TargetDir, ~Epoch
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir);
        case 1 % ~TargetDir, Epoch
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders('Epoch',Epoch);
        case 0 % ~TargetDir, ~Epoch
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
        otherwise
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
    end % End for what directory variables are in the workspace currently
end % End for whether this is being called within a function

%%

EpochDir=[SessionFolder filesep 'Epoched_Data' filesep Epoch];

DataDir=[EpochDir filesep 'Data'];
TargetDir=[EpochDir filesep 'Target'];

[~,SessionName,~]=fileparts(SessionFolder);

SessionName = strrep(SessionName, '-', '_');

IsSessionProcessed = cgg_checkSessionProcessed(SessionName,cfg);

%%
if ~IsSessionProcessed

DataAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
ProcessingDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Processing.path;

TargetAggregate_PathNameExt=[TargetAggregateDir filesep 'Target_%d.mat'];
TargetInformation_PathNameExt=[ProcessingDir filesep 'Target_Information.mat'];
SessionProcessing_PathNameExt=[ProcessingDir filesep 'Session_Processing_Information.mat'];

%%

% get the folder contents
Data_Folder = dir(DataDir);
% remove all directories (isdir property is 1)
Data_Folder = Data_Folder(~[Data_Folder(:).isdir]);
% remove '.' and '..' and the 'Connected' Folder
Data_Folder = Data_Folder(~ismember({Data_Folder(:).name},{'.','..','.DS_Store','Connected'}));

Data_NameExt={Data_Folder.name};
NumData=length(Data_NameExt);

%%

% get the folder contents
DataAggregate_Folder = dir(DataAggregateDir);
% remove all directories (isdir property is 1)
DataAggregate_Folder = DataAggregate_Folder(~[DataAggregate_Folder(:).isdir]);
% remove '.' and '..' and the 'Connected' Folder
DataAggregate_Folder = DataAggregate_Folder(~ismember({DataAggregate_Folder(:).name},{'.','..','.DS_Store','Connected'}));

NumDataAggregate=length(DataAggregate_Folder);


%% Targets

% get the folder contents
TargetAggregate_Folder = dir(DataAggregateDir);
% remove all directories (isdir property is 1)
TargetAggregate_Folder = TargetAggregate_Folder(~[TargetAggregate_Folder(:).isdir]);
% remove '.' and '..' and the 'Connected' Folder
TargetAggregate_Folder = TargetAggregate_Folder(~ismember({TargetAggregate_Folder(:).name},{'.','..','.DS_Store','Connected'}));

NumTargetAggregate=length(TargetAggregate_Folder);
%%

Target=load([TargetDir filesep 'Target_Information.mat']);
Target=Target.Target;

ProbeProcessing=load([TargetDir filesep 'Probe_Processing_Information.mat']);
ProbeProcessing=ProbeProcessing.ProbeProcessing;

%%

existTargetInformation=isfile(TargetInformation_PathNameExt);

% If the aggregated target exists then load it otherwise initialize it as
% an empty structure
if existTargetInformation
    m_TargetInformation = matfile(...
        TargetInformation_PathNameExt,'Writable',true);
    TargetInformation=m_TargetInformation.TargetInformation;
    NumTargetInformation=length(TargetInformation);
else
    NumTargetInformation=0;
end
%% Warning: Count Check
% Check whether the count of Target descriptors match the number of data
% files

isequalNumAggregate=NumTargetAggregate==NumDataAggregate;

if ~isequalNumAggregate
   warning('DataNumbers:incorrectnumber',...
       ['Number of entries in Target (%d) do not match the number of '...
       'Data files (%d)'],NumTargetAggregate,NumDataAggregate);
end

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
All_Iterations = NumData; %<<<<<<<<<
%                ^^^^^^^
% Iteration count starts at 0... seems self explanatory ¯\_(ツ)_/¯
Iteration_Count = 0;

% This is the format specification for the message that is displayed.
% Change this to get a different message displayed. The % at the end is 4
% since sprintf and fprintf takes the 4 to 2 to 1. Use 4 if you want to
% display a percent sign otherwise remove them (!!! if removed the delete
% message should no longer be '-1' at the end but '-0'. '\n' is 
%            VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
formatSpec = '*** Current Data Aggregation Progress is: %.2f%%%%\n'; %<<<<<
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
Current_Message=sprintf(formatSpec,0);
% Display the message
fprintf(Current_Message);

%%

TargetInformation_tmp=cell(NumData,1);
DataAggregate_Number_tmp=cell(NumData,1);

parfor didx=1:NumData
    this_Data_NameExt=Data_NameExt{didx};
    this_Data_PathNameExt=[DataDir filesep this_Data_NameExt];
    
    [~,this_Data_Name,this_Data_Ext]=fileparts(this_Data_PathNameExt);
    
    this_Data_Number=...
        str2double(regexp(this_Data_Name, '\d+(\.\d+)?', 'match'));
    this_Data_Name_NoNumber=...
        regexprep(this_Data_Name, '\d+(\.\d+)?', '');
    this_DataAggregate_Number=this_Data_Number+NumDataAggregate;
    
    this_Target=Target(this_Data_Number);
    this_Target.SessionName=SessionName;
    this_Target.DataSourceNumber=this_Data_Number;
    this_Target.ProbeProcessing=ProbeProcessing;
    
    existData=isfile(this_Data_PathNameExt);
    
    if existData
        this_DataAggregate_NameExt=sprintf(...
            [this_Data_Name_NoNumber '%d' this_Data_Ext],...
            this_DataAggregate_Number);
        this_DataAggregate_PathNameExt=[DataAggregateDir filesep ...
            this_DataAggregate_NameExt];
        copyfile(this_Data_PathNameExt, this_DataAggregate_PathNameExt);
        
        this_TargetAggregate_PathNameExt = sprintf(...
            TargetAggregate_PathNameExt,this_DataAggregate_Number);
        m_TargetAggregate = matfile(this_TargetAggregate_PathNameExt,'Writable',true);
        m_TargetAggregate.Target=this_Target;
        
     TargetInformation_tmp{didx}=this_Target;
     DataAggregate_Number_tmp{didx}=this_DataAggregate_Number;
        
    end
    
    send(q, didx); % send to data queue (is this a listener??) to run the 
    %progress update display function
    
end % End loop for iterating through all data examples

%% Save the Target Information for Decoding

for tidx=1:NumData
    this_TargetInformation=TargetInformation_tmp{tidx};
    this_DataAggregate_Number=DataAggregate_Number_tmp{tidx};
    
    TargetInformation(this_DataAggregate_Number)=this_TargetInformation;
end % End loop for iterating through all the Aggregated Target values

m_TargetInformation = matfile(TargetInformation_PathNameExt,'Writable',true);
m_TargetInformation.TargetInformation=TargetInformation;


%% Save the Probe Processing Information
% This will identify which probes have been processed and do not need to be
% reprocessed. Can also be used to indicate a probe should be reprocessed
% if the value is set to false.

if exist(SessionProcessing_PathNameExt,'file')
    m_Session = matfile(SessionProcessing_PathNameExt,'Writable',true);
    SessionProcessing=m_Session.SessionProcessing;
else
    SessionProcessing=struct();
    SessionProcessing.(SessionName)=false;
end

SessionProcessing.(SessionName)=true;
SessionProcessing.NumData.(SessionName)=NumData;

m_Session = matfile(SessionProcessing_PathNameExt,'Writable',true);
m_Session.SessionProcessing=SessionProcessing;

end % End of if for whether session has been processed

%% SubFunctions

% Function for displaying an update for a parfor loop. Not able to do as
% simply as with a regular for loop
function nUpdateWaitbar(~)
    % Update global iteration count
    Iteration_Count = Iteration_Count + 1;
    % Get percentage for progress
    Current_Progress=Iteration_Count/All_Iterations*100;
    % Generate deletion message to remove previous progress update. The
    % '-1' comes from fprintf converting the two %% to one % so the
    % original message is one character longer than what needs to be
    % deleted.
    Delete_Message=repmat(sprintf('\b'),1,length(Current_Message)-1);
    % Generate the update message using the formate specification
    % constructed earlier
    Current_Message=sprintf(formatSpec,Current_Progress);
    % Display the update message
    fprintf([Delete_Message,Current_Message]);
end

end

