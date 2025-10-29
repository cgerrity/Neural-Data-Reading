function cgg_plotSplitBlockAccuracy(FullTable,cfg,varargin)
%CGG_PLOTSPLITBLOCKACCURACY Summary of this function goes here
%   Detailed explanation goes here

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;
cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
cfg.SplitExtraSaveTerm = cgg_setNaming(cfg.SplitExtraSaveTerm,'SurroundDeliminator',{'[',']'});

for seidx = 1:height(FullTable)
    SubsetName = FullTable.Properties.RowNames{seidx};
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

cgg_plotBlockAccuracy(this_Split_Table,this_cfg,'SubsetName',SubsetName);
cgg_plotBlockWindowedAccuracy(this_Split_Table,this_cfg,'SubsetName',SubsetName);

AttentionalTable =this_Split_Table{:,"Attentional Table"}{1};
AttentionalNames = AttentionalTable.Properties.RowNames;
    NumAttention = length(AttentionalNames);
for aidx = 1:NumAttention
    this_cfg = cfg;
    this_Attentional_Table=AttentionalTable(aidx,:);
    this_AttentionalName = AttentionalNames{aidx};
    this_AttentionalName = replace(this_AttentionalName,' ','-');
    this_AttentionalName = replace(this_AttentionalName,'/','-');
    this_AttentionalName = cgg_setNaming(this_AttentionalName,'SurroundDeliminator',{'{','}'});
    this_cfg.ExtraSaveTerm=string(this_SplitName) + string(this_AttentionalName);
    this_cfg.LoopType=sprintf('%s',cfg.SplitExtraSaveTerm);
    cgg_plotBlockAccuracy(this_Attentional_Table,this_cfg,'IsAttentional',true,'SubsetName',SubsetName);
    cgg_plotBlockWindowedAccuracy(this_Attentional_Table,this_cfg,'IsAttentional',true,'SubsetName',SubsetName);
end


end
end

end