function SplitTable = cgg_getSplitTable(CM_Table,cfg,varargin)
%CGG_GETSPLITTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', 'All', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='All';
end
end

varargin = cgg_removeFieldFromVarargin(varargin,'AttentionalFilter');
varargin = cgg_removeFieldFromVarargin(varargin,'Weights');
varargin = cgg_removeFieldFromVarargin(varargin,'TrialFilter');
varargin = cgg_removeFieldFromVarargin(varargin,'TrialFilter_Value');
varargin{end+1} = 'TrialFilter';
varargin{end+1} = TrialFilter;
%% Adjust CM_Table

if ~iscell(CM_Table)
CM_Table = {CM_Table};
elseif iscell(CM_Table{1})
CM_Table = CM_Table{1};
end
CM_Table = CM_Table(:);
%%
this_varargin = cgg_removeFieldFromVarargin(varargin,'Subset');
Identifiers_Table = cgg_getIdentifiersTable(cfg,false,this_varargin{:});

if all(~strcmp(TrialFilter,'All') & ~strcmp(TrialFilter,'Target Feature'))
DistributionVariable=Identifiers_Table{:,TrialFilter};
TypeValues=unique(DistributionVariable,'rows');
[NumTypes,NumColumns]=size(TypeValues);
else
TypeValues=0;
% NumTypes=1;
[NumTypes,NumColumns]=size(TypeValues);
if strcmp(TrialFilter,'Target Feature')
TypeValues=0;
NumTypes=1;
end
end

%%
Split_TableRowNames = cgg_getSplitTableRowNames(TrialFilter,TypeValues);
%%
TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"];...
    ["Attentional Table", "cell"]];

NumVariables = size(TableVariables,1);
SplitTable = table('Size',[NumTypes,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2),...
        'RowNames',Split_TableRowNames);

%%

for tidx = 1:NumTypes
    TrialFilter_Value = TypeValues(tidx,:);
    MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'TrialFilter_Value',TrialFilter_Value,varargin{:});
    [Accuracy,Window_Accuracy] = cellfun(MetricFunc,CM_Table,"UniformOutput",false);
    AttentionalTable = cgg_getAttentionalTable(CM_Table,cfg,'TrialFilter_Value',TrialFilter_Value,varargin{:});
    Accuracy = cell2mat(Accuracy);
    Window_Accuracy = cell2mat(Window_Accuracy);
    
    SplitTable(tidx,"Accuracy") = {Accuracy};
    SplitTable(tidx,"Window Accuracy") = {Window_Accuracy};
    SplitTable(tidx,"Attentional Table") = {AttentionalTable};

    fprintf('*** Complete Split Pass on %s!\n',Split_TableRowNames(tidx));
end



end

