function AttentionalTable = cgg_getAttentionalTable(CM_Table,cfg,varargin)
%CGG_GETATTENTIONALTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantDisplay = CheckVararginPairs('WantDisplay', true, varargin{:});
else
if ~(exist('WantDisplay','var'))
WantDisplay=true;
end
end

if isfunction
WantPreFetch = CheckVararginPairs('WantPreFetch', true, varargin{:});
else
if ~(exist('WantPreFetch','var'))
WantPreFetch=true;
end
end

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
end
% 
% if isfunction
% WantSpecificChance = CheckVararginPairs('WantSpecificChance', false, varargin{:});
% else
% if ~(exist('WantSpecificChance','var'))
% WantSpecificChance=false;
% end
% end

varargin = cgg_removeFieldFromVarargin(varargin,'AttentionalFilter');
varargin = cgg_removeFieldFromVarargin(varargin,'MatchType');
MatchType_Attention = CheckVararginPairs('MatchType_Attention', 'Scaled-MicroAccuracy', varargin{:});
varargin{end+1} = 'MatchType';
varargin{end+1} = MatchType_Attention;
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
    if WantDisplay
    fprintf('   --- Starting Attentional Pass on %s!\n',AttentionalFilters(aidx));
    end
    % if ~WantSpecificChance
    % [MostCommon,RandomChance,Stratified] = cgg_getSpecifiedChanceLevels(cfg,'AttentionalFilter',AttentionalFilter,varargin{:});
    % else
    %     MostCommon = [];
    %     RandomChance = [];
    %     Stratified = [];
    % end
    NullTable = [];
    if WantPreFetch
    [~,NullTable] = cgg_isNullTableComplete(CM_Table,cfg,cfg_Encoder,'TargetFilter',AttentionalFilter,varargin{:});
    end
    MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'AttentionalFilter',AttentionalFilter,varargin{:},'NullTable',NullTable);
    % MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'AttentionalFilter',AttentionalFilter,'MostCommon',MostCommon,'RandomChance',RandomChance,'Stratified',Stratified,varargin{:});
    [Accuracy,Window_Accuracy] = cellfun(MetricFunc,CM_Table,"UniformOutput",false);
    Accuracy = cell2mat(Accuracy);
    Window_Accuracy = cell2mat(Window_Accuracy);
    
    AttentionalTable(aidx,"Accuracy") = {Accuracy};
    AttentionalTable(aidx,"Window Accuracy") = {Window_Accuracy};

end

end

