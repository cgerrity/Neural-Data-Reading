function cgg_plotAttentionalSplitWindowedAccuracy(FullTable,cfg)
%CGG_PLOTATTENTIONALSPLITWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

AttentionalTable=FullTable{1,"Attentional Table"}{1};

cfg.MatchType=cfg.MatchType_Attention;

MatchType = '';
% if strcmp(cfg.MatchType,'Scaled-BalancedAccuracy')
%     MatchType = '_BA';
% elseif strcmp(cfg.MatchType,'Scaled-MicroAccuracy')
%     MatchType = '_MA';
% end

% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
cfg.ExtraSaveTerm=['_' cfg.LoopType cfg.ExtraSaveTerm];
cfg.LoopType='Attentional_All';
cfg.LoopType = sprintf('Attentional_%s%s','All',MatchType);

cgg_plotWindowedAccuracy(AttentionalTable,cfg);

Split_Table=FullTable{1,cfg_Names.TableNameSplit_Table}{1};
SplitNames = Split_Table.Properties.RowNames;
NumSplits = length(SplitNames);

for sidx = 1:NumSplits
this_SplitName = SplitNames{sidx};
cfg.PlotTitle=this_SplitName;
this_SplitName = replace(this_SplitName,' ','-');
this_SplitName = replace(this_SplitName,'/','-');
cfg.LoopType=sprintf('Attentional_%s%s',this_SplitName,MatchType);
this_AttentionalTable=Split_Table{sidx,"Attentional Table"}{1};

[this_AttentionalTable] = cgg_getAttentionalPlotNames(this_AttentionalTable);

if sidx == 1
AttentionalNames = this_AttentionalTable.Properties.RowNames;
AttentionalTableSwapped = cell(1,length(AttentionalNames));
end

for aidx = 1:length(AttentionalNames)
    this_tmpTable = this_AttentionalTable(AttentionalNames{aidx},:);
    this_tmpTable.Properties.RowNames{1} = this_SplitName;
        AttentionalTableSwapped{aidx} = [AttentionalTableSwapped{aidx};this_tmpTable];

end

cgg_plotWindowedAccuracy(this_AttentionalTable,cfg,'IsAttentional',true);
end

for aidx = 1:length(AttentionalTableSwapped)

this_SplitName = AttentionalNames{aidx};
cfg.PlotTitle=this_SplitName;
this_SplitName = replace(this_SplitName,' ','-');
this_SplitName = replace(this_SplitName,'/','-');
cfg.LoopType=sprintf('Attentional_%s%s',this_SplitName,cfg.SplitExtraSaveTerm);
this_AttentionalTable=AttentionalTableSwapped{aidx};

cgg_plotWindowedAccuracy(this_AttentionalTable,cfg,'IsAttentional',true);
end


end

