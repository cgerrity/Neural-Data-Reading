function cgg_plotAttentionalBlockAccuracy(FullTable,cfg)
%CGG_PLOTSPLITBLOCKACCURACY Summary of this function goes here
%   Detailed explanation goes here

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;
cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
cfg.SplitExtraSaveTerm = cgg_setNaming(cfg.SplitExtraSaveTerm,'SurroundDeliminator',{'[',']'});

for seidx = 1:height(FullTable)
    Split_Table=FullTable{seidx,cfg_Names.TableNameSplit_Table}{1};
    SplitNames = Split_Table.Properties.RowNames;
    NumSplits = length(SplitNames);

for sidx = 1:NumSplits
this_Split_Table=Split_Table(sidx,:);

this_cfg = cfg;
this_SplitName = SplitNames{sidx};
this_cfg.PlotTitle=this_SplitName;
this_cfg.LoopTitle = this_SplitName;
this_SplitName = replace(this_SplitName,' ','-');
this_SplitName = replace(this_SplitName,'/','-');
this_SplitName = cgg_setNaming(this_SplitName,'SurroundDeliminator',{'{','}'});
this_cfg.ExtraSaveTerm=string(this_SplitName);
this_cfg.LoopType=sprintf('%s',cfg.SplitExtraSaveTerm);

cgg_plotBlockAccuracy(this_Split_Table,this_cfg);
cgg_plotBlockWindowedAccuracy(this_Split_Table,this_cfg);

end
end

end