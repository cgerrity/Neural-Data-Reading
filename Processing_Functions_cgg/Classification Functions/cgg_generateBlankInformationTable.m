function Information_Table = cgg_generateBlankInformationTable(varargin)
%CGG_GENERATEBLANKINFORMATIONTABLE Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
DataNumber = CheckVararginPairs('DataNumber', [], varargin{:});
else
if ~(exist('DataNumber','var'))
DataNumber=[];
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', '', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='';
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', '', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='';
end
end

if isfunction
TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', [], varargin{:});
else
if ~(exist('TrialFilter_Value','var'))
TrialFilter_Value=[];
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', '', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='';
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', '', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='';
end
end

if isfunction
LabelClassFilter = CheckVararginPairs('LabelClassFilter', '', varargin{:});
else
if ~(exist('LabelClassFilter','var'))
LabelClassFilter='';
end
end

%%
TableHeight = 0;
if ~isempty(DataNumber)
TableHeight = length(DataNumber);
end

%%
TableVariables = [["DataNumber", "single"]; ...
    ["SessionName", "string"]; ...
    ["TrialFilter", "string"]; ...
    ["TrialFilter_Value", "double"]; ...
    ["TargetFilter", "string"]; ...
    ["MatchType", "string"]; ...
    ["LabelClassFilter", "string"]];

NumVariables = size(TableVariables,1);
Information_Table = table('Size',[TableHeight,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%%
if ~isempty(DataNumber)
Information_Table.DataNumber = DataNumber(:);
end

if ~isempty(SessionName)
    SessionName = string(SessionName);
    
    numRows = height(Information_Table);
    numSessions = length(SessionName);
    
    % Calculate repetitions per session name (rounds up if not perfectly divisible)
    repsPerSession = ceil(numRows / numSessions);
    
    % Repeat each session consecutively: Session 1, Session 1, Session 2, Session 2...
    expandedSessionNames = repelem(SessionName(:), repsPerSession,1);
    
    % Assign to the table (truncating any extra elements if it didn't divide evenly)
    Information_Table.SessionName = expandedSessionNames(1:numRows);
end
if ~isempty(TrialFilter)
    TrialFilter = string(TrialFilter);
    Information_Table.TrialFilter = repmat(TrialFilter,...
        [height(Information_Table),1]);
end
if ~isempty(TrialFilter_Value)
    Information_Table.TrialFilter_Value = repmat(TrialFilter_Value,...
        [height(Information_Table),1]);
end
if ~isempty(MatchType)
    MatchType = string(MatchType);
    Information_Table.MatchType = repmat(MatchType,...
        [height(Information_Table),1]);
end
if ~isempty(TargetFilter)
    TargetFilter = string(TargetFilter);
    Information_Table.TargetFilter = repmat(TargetFilter,...
        [height(Information_Table),1]);
end
% if ~isempty(LabelClassFilter)
    LabelClassFilter = string(LabelClassFilter);
    Information_Table.LabelClassFilter = repmat(LabelClassFilter,...
        [height(Information_Table),1]);
% end
end