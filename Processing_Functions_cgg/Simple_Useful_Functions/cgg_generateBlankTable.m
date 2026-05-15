function BlankTable = cgg_generateBlankTable(VariableNames,VariableTypes,varargin)
%CGG_GENERATEBLANKTABLE Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
NumRows = CheckVararginPairs('NumRows', 0, varargin{:});
else
if ~(exist('NumRows','var'))
NumRows=0;
end
end

%%
TableVariableNames = string(VariableNames);
TableVariableTypes = string(VariableTypes);

TableVariableNames = TableVariableNames(:);
TableVariableTypes = TableVariableTypes(:);
%%
TableVariables = [TableVariableNames,TableVariableTypes];

NumVariables = size(TableVariables,1);
BlankTable = table('Size',[NumRows,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

end