function cgg_plotBlockAccuracy(FullTable,cfg,varargin)
%CGG_PLOTBLOCKACCURACY Summary of this function goes here
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

if isfield(cfg,'PlotTitle')
    cfg.LoopTitle = cfg.PlotTitle;
else
    cfg.LoopTitle = FullTable.Properties.RowNames{sidx};
end
    %%
Present_Table=FullTable{sidx,"Present Areas"}{1};
if ~isempty(SessionNumbers)
Present_Table.("Session Number") = repmat({SessionNumbers},[height(Present_Table),1]);
end
this_cfg = cfg;
this_cfg.IA_Type = '<Areas Present>';

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Present",'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end

cgg_plotOverallAccuracy(Present_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);

% Removed_Table=FullTable{sidx,"Removed Areas"}{1};
% if ~isempty(SessionNumbers)
% Removed_Table.("Session Number") = repmat({SessionNumbers},[height(Removed_Table),1]);
% end
% this_cfg = cfg;
% this_cfg.IA_Type = '<Areas Removed>';
% 
% this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
% this_cfg.LoopType = cgg_setNaming("Removed",'SurroundDeliminator',{'<','>'});
% if isempty(SubsetName)
% this_cfg.Subset = FullTable.Properties.RowNames{sidx};
% else
% this_cfg.Subset = SubsetName;
% end
% % this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};
% 
% cgg_plotOverallAccuracy(Removed_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);
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
% if isempty(SubsetName)
% this_cfg.Subset = FullTable.Properties.RowNames{sidx};
% else
% this_cfg.Subset = SubsetName;
% end
% % this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};
% 
% cgg_plotOverallAccuracy(NotPresent_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);
end

end