function SplitTable = cgg_getSplitTable(CM_Table,cfg,varargin)
%CGG_GETSPLITTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

if isfunction
WantDisplay = CheckVararginPairs('WantDisplay', true, varargin{:});
else
if ~(exist('WantDisplay','var'))
WantDisplay=true;
end
end

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
end

if isfunction
WantPreFetch = CheckVararginPairs('WantPreFetch', true, varargin{:});
else
if ~(exist('WantPreFetch','var'))
WantPreFetch=true;
end
end

% if isfunction
% WantSpecificChance = CheckVararginPairs('WantSpecificChance', false, varargin{:});
% else
% if ~(exist('WantSpecificChance','var'))
% WantSpecificChance=false;
% end
% end

varargin = cgg_removeFieldFromVarargin(varargin,'AttentionalFilter');
varargin = cgg_removeFieldFromVarargin(varargin,'Weights');
varargin = cgg_removeFieldFromVarargin(varargin,'TrialFilter');
varargin = cgg_removeFieldFromVarargin(varargin,'TrialFilter_Value');
varargin{end+1} = 'TrialFilter';
varargin{end+1} = TrialFilter;

%%

Subset = CheckVararginPairs('Subset', '', varargin{:});
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
[Subset,~] = cgg_verifySubset(Subset,wantSubset);

cfg_Encoder.Subset = Subset;
cfg_Encoder.wantSubset = wantSubset;
if ~isempty(Target)
cfg_Encoder.Target = Target;
end
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

    TypeValueFunc.Default = @(x,y) unique(x,'rows');
    TypeValueFunc.Double = @(x,y) unique(x);
    TypeValueFunc.Cell = @(x,y) unique([x{:}]);
    TypeValueFunc.CellCombine = @(x,y) combinations(x{:});
    TypeValues = cgg_procFilterIdentifiersTable(Identifiers_Table,TrialFilter,[],TypeValueFunc);

% % VariableTypes = Identifiers_Table_tmp.Properties.VariableTypes(ismember(Identifiers_Table_tmp.Properties.VariableNames,TrialFilter));
% DistributionVariable_Table=Identifiers_Table(:,TrialFilter);
% 
% if any(strcmp(DistributionVariable_Table.Properties.VariableTypes,"cell"))
%     All_TypeValues = cell(1,length(TrialFilter));
%     for tidx = 1:size(DistributionVariable_Table,2)
%     if strcmp(DistributionVariable_Table.Properties.VariableTypes{tidx},"cell")
%     All_TypeValues{tidx} = unique([DistributionVariable_Table{:,tidx}{:}]);
%     else
%     All_TypeValues{tidx} = unique([DistributionVariable_Table{:,tidx}]);
%     end
%     end
%     TypeValues = combinations(All_TypeValues{:});
% else
% % DistributionVariable=Identifiers_Table{:,TrialFilter};
% % TypeValues=unique(DistributionVariable,'rows');
% % MyFunc.Default = @(x,y) unique(x,'rows');
% TypeValues=unique(DistributionVariable_Table,'rows');
% end
TypeValues = TypeValues{:,:};
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
% SplitTable_Accuracy = cell(NumTypes,1);
% SplitTable_Window_Accuracy = cell(NumTypes,1);
% SplitTable_AttentionalTable = cell(NumTypes,1);
%%

for tidx = 1:NumTypes
    TrialFilter_Value = TypeValues(tidx,:);
    if WantDisplay
    fprintf('   --- Starting Split Pass on %s!\n',Split_TableRowNames(tidx));
    end
    % if ~WantSpecificChance
    % [MostCommon,RandomChance,Stratified] = cgg_getSpecifiedChanceLevels(cfg,'TrialFilter_Value',TrialFilter_Value,varargin{:});
    % else
    %     MostCommon = [];
    %     RandomChance = [];
    %     Stratified = [];
    % end
    NullTable = [];
    if WantPreFetch
        [~,NullTable] = cgg_isNullTableComplete(CM_Table,cfg,cfg_Encoder,'TrialFilter_Value',TrialFilter_Value,varargin{:});
    end
    MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'TrialFilter_Value',TrialFilter_Value,varargin{:},'NullTable',NullTable);
    % MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'TrialFilter_Value',TrialFilter_Value,'MostCommon',MostCommon,'RandomChance',RandomChance,'Stratified',Stratified,varargin{:});
    [Accuracy,Window_Accuracy] = cellfun(MetricFunc,CM_Table,"UniformOutput",false);
    AttentionalTable = cgg_getAttentionalTable(CM_Table,cfg,'TrialFilter_Value',TrialFilter_Value,varargin{:});
    Accuracy = cell2mat(Accuracy);
    Window_Accuracy = cell2mat(Window_Accuracy);
    
    SplitTable(tidx,"Accuracy") = {Accuracy};
    SplitTable(tidx,"Window Accuracy") = {Window_Accuracy};
    SplitTable(tidx,"Attentional Table") = {AttentionalTable};

    % SplitTable_Accuracy{tidx} = {Accuracy};
    % SplitTable_Window_Accuracy{tidx} = {Window_Accuracy};
    % SplitTable_AttentionalTable{tidx} = {AttentionalTable};

    fprintf('   *** Complete Split Pass on %s!\n',Split_TableRowNames(tidx));
end

% SplitTable(:,"Accuracy") = SplitTable_Accuracy;
% SplitTable(:,"Window Accuracy") = SplitTable_Window_Accuracy;
% SplitTable(:,"Attentional Table") = SplitTable_AttentionalTable;

end

