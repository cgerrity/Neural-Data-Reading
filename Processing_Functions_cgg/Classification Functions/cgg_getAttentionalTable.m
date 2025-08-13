function AttentionalTable = cgg_getAttentionalTable(CM_Table,cfg,varargin)
%CGG_GETATTENTIONALTABLE Summary of this function goes here
%   Detailed explanation goes here

varargin = cgg_removeFieldFromVarargin(varargin,'AttentionalFilter');
%% Adjust CM_Table

if ~iscell(CM_Table)
CM_Table = {CM_Table};
elseif iscell(CM_Table{1})
CM_Table = CM_Table{1};
end
CM_Table = CM_Table(:);
%%
AttentionalFilters = ["TargetFeature","DistractorCorrect","DistractorError"];

NumFilters = length(AttentionalFilters);
%%
TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]];

NumVariables = size(TableVariables,1);
AttentionalTable = table('Size',[NumFilters,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2),...
        'RowNames',AttentionalFilters);

%%

for aidx = 1:length(AttentionalFilters)
    AttentionalFilter = AttentionalFilters(aidx);
    MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'AttentionalFilter',AttentionalFilter,varargin{:});
    [Accuracy,Window_Accuracy] = cellfun(MetricFunc,CM_Table,"UniformOutput",false);
    Accuracy = cell2mat(Accuracy);
    Window_Accuracy = cell2mat(Window_Accuracy);
    
    AttentionalTable(aidx,"Accuracy") = {Accuracy};
    AttentionalTable(aidx,"Window Accuracy") = {Window_Accuracy};

end

end

