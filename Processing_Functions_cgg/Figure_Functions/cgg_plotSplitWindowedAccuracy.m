function cgg_plotSplitWindowedAccuracy(FullTable,cfg)
%CGG_PLOTSPLITWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

% Split_Table=FullTable{1,cfg_Names.TableNameSplit_Table}{1};
% 
% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
% cfg.LoopType=[cfg.SplitExtraSaveTerm];

cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
cfg.SplitExtraSaveTerm = cgg_setNaming(cfg.SplitExtraSaveTerm,'SurroundDeliminator',{'[',']'});

for sidx = 1:height(FullTable)
Split_Table=FullTable{sidx,cfg_Names.TableNameSplit_Table}{1};

this_cfg = cfg;

% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
% this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.LoopNames{1} this_cfg.ExtraSaveTerm];
this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.ExtraSaveTerm];
this_cfg.LoopType=cfg.SplitExtraSaveTerm;
this_cfg.Subset = FullTable.Properties.RowNames{sidx};

% cgg_plotOverallAccuracy(Split_Table,this_cfg);
cgg_plotWindowedAccuracy(Split_Table,this_cfg);
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

