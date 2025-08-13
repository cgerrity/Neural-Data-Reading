function FullTable_tmp = cgg_getFullAccuracyTable(CM_Table,cfg,varargin)
%CGG_GETFULLACCURACYTABLE Summary of this function goes here
%   Detailed explanation goes here

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

Subset = CheckVararginPairs('Subset', '', varargin{:});
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
[Subset,~] = cgg_verifySubset(Subset,wantSubset);

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

%% Overall Accuracy

this_varargin = varargin;
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter_Value');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'Weights');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'AttentionalFilter');

MetricFunc = @(x,y) cgg_procCompleteMetric(x,cfg,this_varargin{:});
[Accuracy,Window_Accuracy] = cellfun(MetricFunc,CM_Table,"UniformOutput",false);
Accuracy = cell2mat(Accuracy);
Window_Accuracy = cell2mat(Window_Accuracy);

FullTable_tmp(:,"Accuracy") = {Accuracy};
FullTable_tmp(:,"Window Accuracy") = {Window_Accuracy};

fprintf('*** Complete Overall Pass on %s!\n',Subset);
%% Attentional Table

this_varargin = varargin;
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter');
this_varargin = cgg_removeFieldFromVarargin(this_varargin,'TrialFilter_Value');

AttentionalTable = cgg_getAttentionalTable(CM_Table,cfg,this_varargin{:});

FullTable_tmp(:,"Attentional Table") = {AttentionalTable};
fprintf('*** Complete Attentional Pass on %s!\n',Subset);
%% Split Table

this_varargin = varargin;
SplitTable = cgg_getSplitTable(CM_Table,cfg,this_varargin{:});

FullTable_tmp(:,"Split Table") = {SplitTable};
fprintf('*** Complete Split Pass on %s!\n',Subset);
end

