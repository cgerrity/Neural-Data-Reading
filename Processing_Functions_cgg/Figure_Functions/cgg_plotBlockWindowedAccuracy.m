function cgg_plotBlockWindowedAccuracy(FullTable,cfg,varargin)
%CGG_PLOTSPLITWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsAttentional = CheckVararginPairs('IsAttentional', false, varargin{:});
else
if ~(exist('IsAttentional','var'))
IsAttentional=false;
end
end

if isfunction
SubsetName = CheckVararginPairs('SubsetName', '', varargin{:});
else
if ~(exist('SubsetName','var'))
SubsetName='';
end
end

if isfunction
WantSameSessionNumbers = CheckVararginPairs('WantSameSessionNumbers', true, varargin{:});
else
if ~(exist('WantSameSessionNumbers','var'))
WantSameSessionNumbers=true;
end
end

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
end
end

% cfg_Names = NAMEPARAMETERS_cgg_nameVariables;
cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
% cfg.SplitExtraSaveTerm = cgg_setNaming("Block",'SurroundDeliminator',{'<','>'});

%%
if WantSameSessionNumbers
SessionNumbers = FullTable.("Session Number"){1};
end
%%
for sidx = 1:height(FullTable)
% Split_Table=FullTable{sidx,cfg_Names.TableNameSplit_Table}{1};
Present_Table=FullTable{sidx,"Present Areas"}{1};
if ~isempty(SessionNumbers)
Present_Table.("Session Number") = repmat({SessionNumbers},[height(Present_Table),1]);
end
this_cfg = cfg;
this_cfg.IA_Type = '<Areas Present>';

% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
% this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.LoopNames{1} this_cfg.ExtraSaveTerm];
this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Present",'SurroundDeliminator',{'<','>'});
% this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.ExtraSaveTerm];
% this_cfg.LoopType=cfg.SplitExtraSaveTerm;
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end
this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};

% cgg_plotOverallAccuracy(Split_Table,this_cfg);
cgg_plotWindowedAccuracy(Present_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);

% Removed_Table=FullTable{sidx,"Removed Areas"}{1};
% if ~isempty(SessionNumbers)
% Removed_Table.("Session Number") = repmat({SessionNumbers},[height(Removed_Table),1]);
% end
% this_cfg = cfg;
% this_cfg.IA_Type = '<Areas Removed>';
% 
% this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
% this_cfg.LoopType = cgg_setNaming("Removed",'SurroundDeliminator',{'<','>'});
% 
% if isempty(SubsetName)
% this_cfg.Subset = FullTable.Properties.RowNames{sidx};
% else
% this_cfg.Subset = SubsetName;
% end
% this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};
% 
% cgg_plotWindowedAccuracy(Removed_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);
% 
% NotPresent_Table=FullTable{sidx,"Not Present Areas"}{1};
% if ~isempty(SessionNumbers)
% NotPresent_Table.("Session Number") = repmat({SessionNumbers},[height(NotPresent_Table),1]);
% end
% this_cfg = cfg;
% this_cfg.IA_Type = '<Areas Not Present>';
% 
% this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
% this_cfg.LoopType = cgg_setNaming("Not Present",'SurroundDeliminator',{'<','>'});
% 
% if isempty(SubsetName)
% this_cfg.Subset = FullTable.Properties.RowNames{sidx};
% else
% this_cfg.Subset = SubsetName;
% end
% this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};
% 
% cgg_plotWindowedAccuracy(NotPresent_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);
end

%%

% CombinedFullTable = cgg_getSpecifiedFullTableSessions(FullTable);
% 
% this_cfg = cfg;
% this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.ExtraSaveTerm];
% this_cfg.LoopType=cfg.SplitExtraSaveTerm;
% this_cfg.Subset = 'Combined';
% 
% Split_Table=CombinedFullTable{1,cfg_Names.TableNameSplit_Table}{1};
% 
% cgg_plotWindowedAccuracy(Split_Table,this_cfg);

% MatchType = '';
% if strcmp(cfg.MatchType,'Scaled-BalancedAccuracy')
%     MatchType = 'BA';
% elseif strcmp(cfg.MatchType,'Scaled-MicroAccuracy')
%     MatchType = 'MA';
% end
% 
% cfg.LoopType=[cfg.LoopType '_' MatchType];

% cgg_plotWindowedAccuracy(Split_Table,cfg);

end

