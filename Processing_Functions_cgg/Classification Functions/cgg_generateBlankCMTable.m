function CM_Table = cgg_generateBlankCMTable(varargin)
%CGG_GENERATEBLANKCMTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NumWindows = CheckVararginPairs('NumWindows', [], varargin{:});
else
if ~(exist('NumWindows','var'))
NumWindows=[];
end
end

if isfunction
DataNumber = CheckVararginPairs('DataNumber', [], varargin{:});
else
if ~(exist('DataNumber','var'))
DataNumber=[];
end
end

if isfunction
TrueValue = CheckVararginPairs('TrueValue', [], varargin{:});
else
if ~(exist('TrueValue','var'))
TrueValue=[];
end
end

%%
TableHeight = 0;
if ~isempty(DataNumber)
TableHeight = length(DataNumber);
end
if ~isempty(TrueValue)
TableHeight = max([TableHeight,size(TrueValue,1)]);
end
%%
TableVariables = [["DataNumber", "single"]; ...
    ["TrueValue", "double"]];

if isempty(NumWindows)
WindowNames = ["Window_1", "double"];
else
WindowNames = [compose("Window_%d",(1:NumWindows)'),repmat("double",[NumWindows,1])];
end

TableVariables = [TableVariables;WindowNames];

NumVariables = size(TableVariables,1);
CM_Table = table('Size',[TableHeight,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%%
if ~isempty(DataNumber)
CM_Table.DataNumber = DataNumber(:);
end
if ~isempty(TrueValue)
CM_Table.TrueValue = TrueValue;
end
end

