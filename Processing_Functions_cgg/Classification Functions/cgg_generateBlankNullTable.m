function NullTable = cgg_generateBlankNullTable(varargin)
%CGG_GENERATEBLANKNULLTABLE Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
Target = CheckVararginPairs('Target', '', varargin{:});
else
if ~(exist('Target','var'))
Target='';
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
TargetFilter = CheckVararginPairs('TargetFilter', '', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='';
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
DataNumber = CheckVararginPairs('DataNumber', [], varargin{:});
else
if ~(exist('DataNumber','var'))
DataNumber=[];
end
end

%%
TableHeight = 0;
if ~isempty(DataNumber)
TableHeight = 1;
end
if ~isempty(Target)
TableHeight = 1;
end
if ~isempty(SessionName)
TableHeight = 1;
end
if ~isempty(TrialFilter)
TableHeight = 1;
end
if ~isempty(TrialFilter_Value)
TableHeight = 1;
end
if ~isempty(TargetFilter)
TableHeight = 1;
end
if ~isempty(MatchType)
TableHeight = 1;
end
%%
TableVariables = [["DataNumber", "cell"]; ...
    ["Target", "string"]; ...
    ["SessionName", "string"]; ...
    ["TrialFilter", "string"]; ...
    ["TrialFilter_Value", "double"]; ...
    ["TargetFilter", "string"]; ...
    ["MatchType", "string"]; ...
    ["BaselineChanceDistribution", "cell"]; ...
    ["ChanceDistribution", "cell"]];

NumVariables = size(TableVariables,1);
NullTable = table('Size',[TableHeight,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

[TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Pack');

%%
if ~isempty(DataNumber)
NullTable.DataNumber = {DataNumber};
end
if ~isempty(Target)
Target = string(Target);
NullTable.Target = Target;
end
if ~isempty(SessionName)
SessionName = string(SessionName);
NullTable.SessionName = SessionName;
end
if ~isempty(TrialFilter)
TrialFilter = string(TrialFilter);
NullTable.TrialFilter = TrialFilter;
end
if ~isempty(TrialFilter_Value)
NullTable.TrialFilter_Value = TrialFilter_Value;
end
if ~isempty(TargetFilter)
TargetFilter = string(TargetFilter);
NullTable.TargetFilter = TargetFilter;
end
if ~isempty(MatchType)
MatchType = string(MatchType);
NullTable.MatchType = MatchType;
end


end

