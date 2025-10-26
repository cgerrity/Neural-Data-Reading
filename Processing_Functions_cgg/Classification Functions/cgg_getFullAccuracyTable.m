function FullTable_tmp = cgg_getFullAccuracyTable(CM_Table,cfg,varargin)
%CGG_GETFULLACCURACYTABLE Summary of this function goes here
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

%% Get CFG for any analysis
% You can uncomment this section to generate the base cfg for further
% testing
% [~,TargetDir,ResultsDir,~] = ...
%     cgg_getBaseFoldersFromSessionInformation('','','');
% 
% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch);
% cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch);
% cfg.ResultsDir=cfg_Results.TargetDir;

%%
varargin{end + 1} = 'Target';
varargin{end + 1} = Target;
% varargin{end + 1} = 'WantDisplay';
% varargin{end + 1} = WantDisplay;
varargin{end + 1} = 'WantPreFetch';
varargin{end + 1} = WantPreFetch;
%%

Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
AdditionalTarget = CheckVararginPairs('AdditionalTarget', {}, varargin{:});

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
TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Split Table", "cell"]; ...
    ["Attentional Table", "cell"]];

NumVariables = size(TableVariables,1);
FullTable_tmp = table('Size',[1,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%% 
if WantPreFetch
Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset,'Epoch',Epoch,'AdditionalTarget',AdditionalTarget,'Subset',Subset);
fprintf('@@@ Loaded Identifiers Table for %s\n',Subset);
varargin{end + 1} = 'Identifiers_Table';
varargin{end + 1} = Identifiers_Table;
end

this_varargin = varargin;
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter_Value');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'Weights');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'AttentionalFilter');

NullTable = [];
if WantPreFetch
[~,NullTable] = cgg_isNullTableComplete(CM_Table,cfg,cfg_Encoder,this_varargin{:});
end
%% Overall Accuracy
OverallTimer = tic;
if WantDisplay
fprintf('--- Starting Overall Pass on %s!\n',Subset);
end
MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,'NullTable',NullTable,this_varargin{:});
[Accuracy,Window_Accuracy] = cellfun(MetricFunc,CM_Table,"UniformOutput",false);
Accuracy = cell2mat(Accuracy);
Window_Accuracy = cell2mat(Window_Accuracy);

FullTable_tmp(:,"Accuracy") = {Accuracy};
FullTable_tmp(:,"Window Accuracy") = {Window_Accuracy};

% if ~exist('OverallTimer','var')
% OverallTimer = tic;
% end
OverallTime = seconds(toc(OverallTimer));
OverallTime.Format='hh:mm:ss';
fprintf('*** Complete Overall Pass on %s! [Time: %s]\n',Subset,OverallTime);
%% Attentional Table

this_varargin = varargin;
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter_Value');

AttentionalTimer = tic;
AttentionalTable = cgg_getAttentionalTable(CM_Table,cfg,this_varargin{:});

% if ~exist('AttentionalTimer','var')
% AttentionalTimer = tic;
% end
AttentionalTime = seconds(toc(AttentionalTimer));
AttentionalTime.Format='hh:mm:ss';
fprintf('   *** Complete Attentional Pass on %s! [Time: %s]\n',Subset,AttentionalTime);
%% Split Table

SplitTimer = tic;
this_varargin = varargin;
SplitTable = cgg_getSplitTable(CM_Table,cfg,this_varargin{:});
AttentionalSplitTable = cgg_procSwitchTableRows(SplitTable, "Split Table", "Attentional Table");
AttentionalTable = [AttentionalTable,AttentionalSplitTable];

FullTable_tmp(:,"Attentional Table") = {AttentionalTable};
FullTable_tmp(:,"Split Table") = {SplitTable};
% if ~exist('SplitTimer','var')
% SplitTimer = tic;
% end
SplitTime = seconds(toc(SplitTimer));
SplitTime.Format='hh:mm:ss';
fprintf('   *** Complete Split Pass on %s! [Time: %s]\n',Subset,SplitTime);
end

