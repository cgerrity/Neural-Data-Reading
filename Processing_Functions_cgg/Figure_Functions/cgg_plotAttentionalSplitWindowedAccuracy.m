function cgg_plotAttentionalSplitWindowedAccuracy(FullTable,cfg)
%CGG_PLOTATTENTIONALSPLITWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

AttentionalTable=FullTable{1,"Attentional Table"}{1};

% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
cfg.ExtraSaveTerm=['_' cfg.LoopType cfg.ExtraSaveTerm];
cfg.LoopType='Attentional_All';

cgg_plotWindowedAccuracy(AttentionalTable,cfg);

Split_Table=FullTable{1,cfg_Names.TableNameSplit_Table}{1};
SplitNames = Split_Table.Properties.RowNames;
NumSplits = length(SplitNames);

for sidx = 1:NumSplits
this_SplitName = SplitNames{sidx};
cfg.PlotTitle=this_SplitName;
this_SplitName = replace(this_SplitName,' ','-');
this_SplitName = replace(this_SplitName,'/','-');
cfg.LoopType=sprintf('Attentional_%s',this_SplitName);
this_AttentionalTable=Split_Table{sidx,"Attentional Table"}{1};
cgg_plotWindowedAccuracy(this_AttentionalTable,cfg);
end


end

