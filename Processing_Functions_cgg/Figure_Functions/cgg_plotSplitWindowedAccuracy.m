function cgg_plotSplitWindowedAccuracy(FullTable,cfg)
%CGG_PLOTSPLITWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Split_Table=FullTable{1,cfg_Names.TableNameSplit_Table}{1};

cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
cfg.LoopType=[cfg.SplitExtraSaveTerm];

cgg_plotWindowedAccuracy(Split_Table,cfg);

end

