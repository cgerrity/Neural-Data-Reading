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

% cfg_Names = NAMEPARAMETERS_cgg_nameVariables;
cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
% cfg.SplitExtraSaveTerm = cgg_setNaming("Block",'SurroundDeliminator',{'<','>'});

for sidx = 1:height(FullTable)
Present_Table=FullTable{sidx,"Present Areas"}{1};

this_cfg = cfg;

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Present",'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end
this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};

cgg_plotOverallAccuracy(Present_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional);

Removed_Table=FullTable{sidx,"Removed Areas"}{1};

this_cfg = cfg;

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Removed",'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end
this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};

cgg_plotOverallAccuracy(Removed_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional);

NotPresent_Table=FullTable{sidx,"Not Present Areas"}{1};

this_cfg = cfg;

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Not Present",'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end
this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};

cgg_plotOverallAccuracy(NotPresent_Table,this_cfg,'IsBlock',true,'IsAttentional',IsAttentional);
end

end